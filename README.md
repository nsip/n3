# n3
n3 packaging repository

This repository builds from the following NSIP repositories:
* n3-client
* n3-transport
* DC-UI

It also includes Influx db and NATS server

## Versioning

Versioning system throughout follow this convention

n.n.n

where n is an integer incremented by 1 for each version/build on the following pattern: major.minor.build

For example if the release number is

1.7.12

then 1 is the major release number, 7 is the minor release number, and 12 is the build number.

The release version number consists only of the first two numbers (in our example 1.7)



## Purpose / Steps

* Build DC-UI and get distribution static files
* Download InfluxDB for all platforms
* Build N3 code
* GoLang Wrapper to serve N3 and DC-UI static content and eventually auto detect IP number etc


## Requirements

* go version >= 1.12
* git
* bzr - brew install bazaar
* node / npm


