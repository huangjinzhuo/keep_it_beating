{\rtf1\ansi\deff0\nouicompat{\fonttbl{\f0\fnil\fcharset0 Calibri;}}
{\*\generator Riched20 10.0.17134}\viewkind4\uc1 
\pard\sa200\sl276\slmult1\f0\fs22\lang9 # update all packages \par
sudo yum update  -y  \par
# download and unzip Java (JDK), set env JAVA_HOME, PATH=$PATH:$JAVA_HOME/bin\par
# download and unzip Kafka. Zookeeper is included in Kafka.\par
\par
# start Zookeeper\par
bin/zookeeper-server-start.sh config/zookeeper.properties\par
# start Kafka\par
bin/kafka-server-start.sh config/server.properties\par
# write a test topic\par
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 -- partitions 1 --topic test\par
\par
\par
\par
\par
}
 