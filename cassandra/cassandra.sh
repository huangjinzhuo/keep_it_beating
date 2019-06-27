#Install Java
sudo apt install openjdk-8-jre -y
java -version

#Set Java env variable $JAVA_HOME in /etc/profile
echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee -a /etc/profile
source /etc/profile
echo $JAVA_HOME


#Install Python
sudo apt install python -y

#Download and install Cassandra
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
sudo apt update
sudo apt install cassandra

#test cassandra
sudo service cassandra start
cqlsh localhost

#config cassandra in /etc/cassandra/cassandra.yaml
select one node as seed node. enter the same node IP in seeds field for all seed nodes:
- seeds: "10.0.1.249"

#start cassandra
cassandra -f 			#or, just run as root: sudo cassandra -fR
#if you see port 7199 and 7000 are already being used(by Java), just restart the machine
and java will release the port
#if you see permission problem to the directories:
sudo chmod 777 /var/lib/cassandra/data




 

