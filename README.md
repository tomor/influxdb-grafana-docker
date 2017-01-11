# influxdb-grafana-docker
Docker compose definition file with `InfluxDB 1.1.1` and `Grafana 4.0.1` plus `bash script` for creation of sample data.

## First time setup
### run docker containers
```
sudo docker-compose up -d
```
### create database
```
curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"
```
### configure urls
```
cp conf/services.list.dist conf/services.list
vim conf/services.list
```
### start bash script to collect data
```
./bin/api_check_repeat.sh # watch out this will run in foreground and block the terminal
```
### check if data are there
```
curl -G 'http://localhost:8086/query' --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM http_responses"
```
### Open Grafana and setup Data sources, Dashboard
- <http://localhost:3000> - admin/admin


## Basic Operate

### Grafana
- <http://localhost:3000> - grafana web (login admin/admin)

### InfluxDB CLI
```
$ sudo docker exec -ti influxdbgrafanadocker_influxdb_1 /usr/bin/influx
```
### Collect sample data
- `./bin/api_check.sh` collects the data once
- `./bin/api_check_repeat.sh` starts the previous script every 2 seconds

### Advanced operations
- todo - Where is the data from the InfluxDB container
- todo - Where are the data from the Grafana (dashboards)
- todo - How to upgrade image versions without loosing Grafana dashboards and InfluxDB data
