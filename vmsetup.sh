# Scratch pad of commands executed to set up fresh VM.
# Assumes Debian 9

# Recommended prereq for GPG keys for debian repos to work
# properly, doesn't come with default google image
# See: https://blog.sleeplessbeastie.eu/2017/11/02/how-to-fix-missing-dirmngr/
sudo apt-get install dirmngr --install-recommends

sudo apt-get update
sudo apt-get install software-properties-common

####
### Neo4j Portion
####
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb http://debian.neo4j.org/repo stable/' | sudo tee -a /etc/apt/sources.list.d/neo4j.list
sudo apt-get update
sudo apt-get install neo4j-enterprise=3.3.1

