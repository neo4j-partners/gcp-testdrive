// Nodes created for Lessons, Submitter, Center and Topic
// Relations created 

        // Uniqueness constraints.
CREATE CONSTRAINT ON (l:Lesson) ASSERT l.name IS UNIQUE;

        // Load.
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM 'https://guides.neo4j.com/nasa/data/llis.csv' AS line
WITH line, SPLIT(line.LessonDate, '-') AS date

CREATE (lesson:Lesson { name: TOINT(line.`LessonId`) } )
SET lesson.year = TOINT(date[0]),
    lesson.month = TOINT(date[1]),
    lesson.day = TOINT(date[2]),
    lesson.title = (line.Title),
    lesson.abstract = (line.Abstract),
    lesson.lesson = (line.Lesson),
    lesson.org = (line.MissionDirectorate),
    lesson.safety = (line.SafetyIssue),
    lesson.url = (line.url)

    
// Merges multiple entries of node in csv file
MERGE (submitter:Submitter { name: UPPER(line.Submitter1) })
MERGE (center:Center { name: UPPER(line.Organization) })
MERGE (topic:Topic { name: TOINT(line.Topic) })
MERGE (category:Category { name: UPPER(line.Category) })

CREATE (topic)-[:Contains]->(lesson)
CREATE (submitter)-[:Wrote]->(lesson)
CREATE (lesson)-[:OccurredAt]->(center)
CREATE (lesson)-[:InCategory]->(category)

;
