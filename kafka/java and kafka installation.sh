https://www.youtube.com/watch?v=m8aEVx0gCEI&t=338s

#To change host name
#vi /etc/sysconfig/network  	  #or file name /etc/hostname
#HOSTNAME=kafka.decentcore.com     #input this line in the file

#Check IP address:
ifconfig

#Edit /etc/hosts file to add the short name 
vi /etc/hosts
10.0.1.83	kafka.decentcore.com	kafka

#Reboot and hostname is changed.

#systemctl status firewalld check. Stop it.
systemctl disable firewalld             #Firewall will not start on next reboot
systemctl stop firewalld

# update all packages
sudo yum update  -y           # or use:      sudo apt update

# download and unzip Java (Java runtime), in ~/.profile, set env
sudo apt install openjdk-8-jdk -y

JAVA_HOME="usr/lib/jvm/java-08-openjdk-amd64"
PATH=$PATH:$JAVA_HOME/bin

# download and unzip Kafka. Zookeeper is included in Kafka.
wget http://us.mirrors.quenda.co/apache/kafka/2.3.0/kafka_2.11-2.3.0.tgz
tar -xzf kafka_2.11-2.3.0.tgz


KAFKA_HOME="usr/lib/jvm/java-08-openjdk-amd64"
PATH=$PATH:$KAFKA_HOME/bin

# start Zookeeper
bin/zookeeper-server-start.sh config/zookeeper.properties
#you can see zookeeper is bind to port 2181
#Once it's running, we can use another terminal to add the above command to rc.local
#file so next time the zookeeper can start when reboot:
sudo vi /etc/rc.d/rc.local
$KAFKA_HOME/bin/zookeeper-server-start.sh config/zookeeper.properties >/dev/null 2>&1 &
#add the above line to the end of rc.local file. It will automatically run in the background
#and redirected standard input/output to null.
sudo chmod +x /etc/rc.d/rc.local
sudo systemctl enable rc-local			#add the rc-local service to systemctl.
sudo systemctl start rc-local			#start the rc-local service.


# start Kafka with another terminal 
bin/kafka-server-start.sh config/server.properties

# write a test topic
bin/kafka-topics.sh --create --zookeeper ip-10-0-1-83:2181 --topic  mytest --partitions 1 --replication-factor 1

#start producer on a new terminal
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic MyFirstTopic

#start consumer on a new terminal
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic MyFirstTopic

#now you type anything in producer terminal and it will appear on the consumer terminal.

#Zookeeper shell command to check connected brokers:
bin/zookeeper-shell.sh 10.0.1.83:2181 ls /brokers/ids







 