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
### configure urls which will be monitored via curl
```
cp conf/services.list.dist conf/services.list
vim conf/services.list
```
### start bash script to collect data
```
./bin/collect_data_loop # it will run in foreground (and block the terminal)
```
### check if data are there
```
curl -G 'http://localhost:8086/query' --data-urlencode "db=mydb" --data-urlencode "q=SELECT * FROM http_responses"
```
### Open Grafana and setup Data sources, Dashboard
- <http://localhost:3000> - admin/admin

#### Data source
- Name: not important
- Default: checked
- Type: InfluxDB
- Url: http://influxdb:8086 (we can use container name thanks to the docker link)
- Access: Proxy
- Database: mydb (the name which is in the `collect_data` bash script)
- User,Password: empty

#### Dashboard
- New dashboard: (top left "Home" -> Create New -> Graph)
- Click "Panel Title" -> Edit 
- On the Metrics tab setup the query `A`
 - `select measurement`: "http_responses"
 - WHERE name = ..select tag value..
 - `field(value)` = http_code (for example)
 - ALIAS BY: .. select your name
 - Group by time interval: >5s


## Basic Operate

### Grafana
- <http://localhost:3000> - grafana web (login admin/admin)

### InfluxDB CLI
```
$ sudo docker exec -ti influxdbgrafanadocker_influxdb_1 /usr/bin/influx
```
### Collect sample data
- `./bin/collect_data` collects the data once
- `./bin/collect_data_loop` starts the previous script every 2 seconds

### ./conf/services.list
- contains list of urls which will be "curled". Each url on separate line. One line has format: `<name>|<curl params>`
- `<curl params>` can contain more parameters then just url (though it's enough), but the current implementation of `collect_data` script does not allow usage of spaces in attributes values
 - valid example with header: `Localhost-test|-X POST -H MONITOR:true http://localhost:8080`
 - invalid, due to space in header value: `Localhost-POST|-XPOST -H "MONITOR: true" http://localhost:8080`

## What next?
- Where are the data from the InfluxDB container, retention strategy, Grafana data?
- How to upgrade image versions without loosing Grafana dashboards and InfluxDB data
