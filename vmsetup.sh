# Scratch pad of commands executed to set up fresh VM.
# Assumes Debian 9

# Recommended prereq for GPG keys for debian repos to work
# properly, doesn't come with default google image
# See: https://blog.sleeplessbeastie.eu/2017/11/02/how-to-fix-missing-dirmngr/
sudo apt-get install dirmngr --install-recommends

sudo apt-get update
sudo apt-get install software-properties-common

# Key for the java repo we're about to add...
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

sudo add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main"

sudo apt-get update

# Install java 8, accept licenses
sudo apt-get install oracle-java8-installer

# If download step fails, download manually and place installer
# in /var/cache/oracle-jdk8-installer and re-run install of that
# installer package
#
# If this still doesn't work (because it can get weird on google images)
# then manually install
# https://www.digitalocean.com/community/tutorials/how-to-manually-install-oracle-java-on-a-debian-or-ubuntu-vps

# sudo update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_161/bin/java 100 
# sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_161/bin/javac 100


####
### Neo4j Portion
####
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb http://debian.neo4j.org/repo stable/' | sudo tee -a /etc/apt/sources.list.d/neo4j.list
sudo apt-get update
sudo apt-get install neo4j-enterprise=3.3.1

