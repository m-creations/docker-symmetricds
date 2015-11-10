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

sudo cp master-000.properties /data/symmetric-ds/master/engines/master-000.properties

sudo cp insert.sql /data/symmetric-ds/master/tmp/insert.sql

sudo cp slave-001.properties /data/symmetric-ds/slave/engines/slave-001.properties



docker run -h client.weave.local  -it --rm mysql/mysql-server:5.6  /bin/bash

mysql -h masterdb.weave.local -u root -proot -e "CREATE DATABASE mastersymmetricdsdb;"

mysql -h masterdb.weave.local -u root -proot -e "CREATE TABLE mastersymmetricdsdb.example (id INT,data VARCHAR(100));"

mysql -h masterdb.weave.local -u root -proot -e "INSERT INTO mastersymmetricdsdb.example(id,data) VALUES (1,'test data');"

mysql -h slavedb.weave.local -u root -proot -e "CREATE DATABASE slavesymmetricdsdb;"


docker build -t mcreations/docker-openwrt-symmetricds  .

eval $(weave env)

docker run --name master-symmetricds -h master-symmetricds.weave.local  -v /data/symmetric-ds/master/engines:/opt/symmetric-ds/engines  -v /data/symmetric-ds/master/logs:/opt/symmetric-ds/logs -v /data/symmetric-ds/master/tmp:/opt/symmetric-ds/tmp -e MASTER_ENGINE_NAME=master-000 -d   mcreations/docker-openwrt-symmetricds

docker run --name slave-symmetricds -h slave-symmetricds.weave.local  -v /data/symmetric-ds/slave/engines:/opt/symmetric-ds/engines  -v /data/symmetric-ds/slave/logs:/opt/symmetric-ds/logs -d   mcreations/docker-openwrt-symmetricds 
