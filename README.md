# influxdb-grafana-docker
Docker compose definition file with `InfluxDB 1.1.1` and `Grafana 4.0.1` plus `bash script` for creation of sample data.

## Run
```
$ docker-compose up -d
```

## Operate

### Grafana
- <http://localhost:3000>  grafana web (login admin/admin)

### InfluxDB CLI
```
docker exec -ti <influxdb-container-name> /usr/bin/influx
```
### Collect sample data
.. todo describe the bash script
