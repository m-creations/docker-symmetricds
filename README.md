wget https://github.com/zettio/weave/releases/download/latest_release/weave
chmod a+x weave
sudo cp weave /usr/local/bin 

weave launch

eval $(weave env)

docker run --name masterdb -h masterdb.weave.local -e MYSQL_ROOT_PASSWORD=root -d mariadb:10.0.22

docker run --name slavedb -h slavedb.weave.local -e MYSQL_ROOT_PASSWORD=root -d mariadb:10.0.22

sudo mkdir -p /data/symmetric-ds/master/engines
sudo mkdir -p /data/symmetric-ds/master/logs
sudo mkdir -p /data/symmetric-ds/master/tmp
sudo mkdir -p /data/symmetric-ds/slave/engines
sudo mkdir -p /data/symmetric-ds/slave/logs

cat <<EOF> master-000.properties
engine.name=master-000
group.id=master
external.id=000
sync.url=http://master-symmetricds.weave.local:31415/sync/master-000
registration.url=
db.driver=com.mysql.jdbc.Driver
db.url=jdbc:mysql://masterdb.weave.local/mastersymmetricdsdb?tinyInt1isBit=false
db.user=root
db.password=root
job.purge.period.time.ms=7200000
job.routing.period.time.ms=5000
job.push.period.time.ms=10000
job.pull.period.time.ms=10000
initial.load.create.first=true
EOF

sudo mv master-000.properties /data/symmetric-ds/master/engines/master-000.properties
sudo cp insert.sql /data/symmetric-ds/master/tmp/insert.sql



cat <<EOF> slave-001.properties
engine.name=slave-001
group.id=slave
external.id=001
registration.url=http://master-symmetricds.weave.local:31415/sync/master-000
db.driver=com.mysql.jdbc.Driver
db.url=jdbc:mysql://slavedb.weave.local/slavesymmetricdsdb?tinyInt1isBit=false
db.user=root
db.password=root
job.purge.period.time.ms=7200000
job.routing.period.time.ms=5000
job.push.period.time.ms=10000
job.pull.period.time.ms=10000
initial.load.create.first=true
EOF

sudo mv slave-001.properties /data/symmetric-ds/slave/engines/slave-001.properties



docker run -h client.weave.local  -it --rm mysql/mysql-server:5.6  /bin/bash
mysql -h masterdb.weave.local -u root -proot -e "CREATE DATABASE mastersymmetricdsdb;"
mysql -h masterdb.weave.local -u root -proot -e "CREATE TABLE mastersymmetricdsdb.example (id INT,data VARCHAR(100));"
mysql -h masterdb.weave.local -u root -proot -e "INSERT INTO mastersymmetricdsdb.example(id,data) VALUES (1,'test data');"
mysql -h slavedb.weave.local -u root -proot -e "CREATE DATABASE slavesymmetricdsdb;"


docker build -t mcreations/docker-openwrt-symmetricds  .

eval $(weave env)

docker run --name master-symmetricds -h master-symmetricds.weave.local  -v /data/symmetric-ds/master/engines:/opt/symmetric-ds/engines  -v /data/symmetric-ds/master/logs:/opt/symmetric-ds/logs -v /data/symmetric-ds/master/tmp:/opt/symmetric-ds/tmp -e MASTER_ENGINE_NAME=master-000 -d   mcreations/docker-openwrt-symmetricds /bin/bash

docker run --name slave-symmetricds -h slave-symmetricds.weave.local  -v /data/symmetric-ds/slave/engines:/opt/symmetric-ds/engines  -v /data/symmetric-ds/slave/logs:/opt/symmetric-ds/logs -d   mcreations/docker-openwrt-symmetricds 
