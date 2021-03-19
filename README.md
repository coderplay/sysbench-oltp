# sysbench-tpcc

TPCC-like workload for sysbench 1.0.x.

# MySQL 

## [optional] Launch container through docker

```
docker run -i -e mysql_address=$your_mysql_address -t mzhou/sysbench-tpcc /bin/bash
```

## [optional] Launch container from kubernetes 

```
kubectl run -it tpcc --env="mysql_address=$your_mysql_address" --image=mzhou/sysbench-tpcc --restart=Never --rm /bin/bash 
```

## Prepare data and tables

```
mysql -h $mysql_address -u root -e "create database sbt"

./tpcc.lua --mysql-host=$mysql_address --mysql-user=root --mysql-db=sbt --time=300 --threads=64 --report-interval=1 \
--tables=10 --scale=100 --db-driver=mysql prepare
```


## Run benchmark

```
./tpcc.lua --mysql-host=$mysql_address --mysql-user=root --mysql-db=sbt --time=300 --threads=64 --report-interval=1 \
--tables=10 --scale=100 --db-driver=mysql run
```

## Cleanup 

```
./tpcc.lua --mysql-host=$mysql_address --mysql-user=root --mysql-db=sbt --time=300 --threads=64 --report-interval=1 \
--tables=10 --scale=100 --db-driver=mysql cleanup
```

# TiDB

## [optional] Launch container through docker

```
docker run -i -e tidb_address=$tidb_address -t mzhou/sysbench-tpcc /bin/bash
```

## [optional] Kaunch container from kubernetes
 
```
kubectl run -it tpcc \
--env="tidb_address=$(kubectl -n tidb get svc -l app.kubernetes.io/component=tidb,app.kubernetes.io/used-by=end-user -o jsonpath='{.items[0].spec.clusterIP}')" \
--image=mzhou/sysbench-tpcc --restart=Never --rm /bin/bash 
```

## Prepare data and tables

```
mysql -h $tidb_address -P 4000 -u root -e "create database sbt"

./tpcc.lua --mysql-host=$tidb_address --mysql-port=4000 --mysql-user=root --mysql-db=sbt --time=300 --threads=64 \
--report-interval=1 --tables=10 --scale=100 --db-driver=mysql prepare
```

## Run benchmark

```
./tpcc.lua --mysql-host=$tidb_address --mysql-port=4000 --mysql-user=root --mysql-db=sbt --time=300 --threads=64 \
--report-interval=1 --tables=10 --scale=100 --db-driver=mysql run
```

## Cleanup 

```
./tpcc.lua --mysql-host=$tidb_address --mysql-port=4000 --mysql-user=root --mysql-db=sbt --time=300 --threads=64 \
--report-interval=1 --tables=10 --scale=100 --db-driver=mysql cleanup
```