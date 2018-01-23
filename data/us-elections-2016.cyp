create index on :Area(fips);
create index on :Candidate(npid);
create index on :State(state);
call apoc.periodic.iterate('
UNWIND ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"] as state
RETURN state','
with "http://origin-east-elections.politico.com/mapdata/2016/elections-ftp-download/"+{state}+".txt" as url
load csv from url as row fieldterminator ";"
// separate the header
with row, row[0..19] as header
// name the header fields
with row,header[1] as date, header[2] as state, header[3] as county_no, header[4] as fips, header[5] as area_name, header[6] as race_no, header[7] as office, header[8] as race_type,
header[9] as seat_no, header[10] as office_name, header[11] as seat_name, header[12] as race_type_party, header[13] as race_type_name, 
header[14] as office_description, header[15] as number_of_winners, header[16] as number_in_runoff, toInt(header[17]) as reported_precincts, toInt(header[18]) as total_precincts


// get-or-create an :Election node for the office, and date
MERGE (e:Election {date:date, office:office,race:race_type}) ON CREATE SET e.name=office_name, e.raceName = race_type_name
// get-or-create an :Area node (State or County) by state and fips, set additional properties
MERGE (a:Area {state:state,fips:fips}) ON CREATE SET a.name = area_name,  a.county_no = county_no 
// TODO , a.college = college
// always update reporting numbers, also calculate percentage of reported precincts
SET a.reporting = case when total_precincts = 0 then 0 else 100.0*reported_precincts/total_precincts end, 
    a.reported_precincts = reported_precincts, a.total_precincts = total_precincts
with *
// dynamically add a label for the state
call apoc.create.addLabels(a,case when fips="00000" then ["State"] else [] end) yield node
// find the state if any
OPTIONAL MATCH (st:State {state:state})
// if we found a state and the current area is not the state, connect them with :IS_IN
FOREACH (_ in case when fips <> "00000" and not st is null then [1] else [] end | 
   MERGE (a)-[:IS_IN]->(st)
)
// compute the number of remaining blocks
with *, (length(row)-19)/12 as seats
// for each of those blocks
unwind range(0,seats-1) as seat_idx
// get a slice of the row-data
with *, row[(19+seat_idx*12)..(19+(seat_idx+1)*12)] as seat 
// name fields
with *,seat[0] as ap_cand_no, seat[1] as cand_order, seat[2] as party, 
     trim(coalesce(seat[3],"") + " " + coalesce(seat[4],"") + " "+ coalesce(seat[5],"") + " "+ coalesce(seat[6],"")) as name, 
     seat[8] as incumbent, toInt(seat[9]) as votes, seat[11] as npid,
     case seat[10] when "X" then true when " " then false when "R" then null end as winner
// get-or-create :Candidate node based on global npid
MERGE (c:Candidate {npid:npid}) ON CREATE SET c.name = name, c.incumbent = incumbent, c.party = party
// connect candidate with election
MERGE (c)-[:RUNS_IN]->(e)
// create a :Vote within the area for that candidate
MERGE (a)-[:REPORTS]->(v:Vote {npid:npid})
// always update the votes and winner info
SET v.votes = votes, v.winner = winner
// connect the vote to the candidate
MERGE (v)-[:FOR]->(c);',{batchSize:1});
