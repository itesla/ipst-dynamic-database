# ipst-dynamic-database
An application to store data necessary for dynamic simulation (regulations ...)



# Quickstart

Required: build and ipst-dynamic-simulation project (https://github.com/itesla/ipst-dynamic-simulation.git)

## Build and install

```bash
mvn clean install
```

Output of the dynamic-database building step, are:
1. a server-side artifact: a .ear file to be deployed to a [wildfly](https://wildfly.org/) application server, backed by a mysql RDBMS.
To simplify the installation and setup, a set of configurations are  provided, allowing the services to be run in a docker container. Software required: [docker engine CE](https://hub.docker.com/search/?type=edition&offering=community) and [docker-compose](https://docs.docker.com/compose/)

2. a set of .jar files, provides the client code to connect and use the server-side services and complements a powsybl-core + dynamic-simulation installation.
   copy all the jars from *./distribution-dynamic-database/target/ipst-distribution-dynamic-database-IPST-DYNAMIC-DATABASE-VERSION-full/ipst/share/java* to the powsybl-core's *share/java* directory


## To start docker:
```bash
docker-compose up
```

### Notes:
 * Because all the required components (wildfly, mysql) have to be downloaded, the first run could take some time to execute;
Later executions will be faster. Option *docker-compose up -d* executes docker in background.
 * In case you build the image behind a proxy (corporate proxy for example), you will need to define the environment variable `http_proxy` before building


## To shutdown docker:
```bash
docker-compose down
```
(or, CTRL-C in the same terminal, if it runs in foreground)


## To shutdown docker and clean everything:
Shutdown and remove the dynamic-database images, including the volume with the database content
```bash
docker-compose down --rmi all -v
```
