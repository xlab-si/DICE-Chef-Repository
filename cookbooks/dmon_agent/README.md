dmon_agent Cookbook
============

This cookbook installs dmon_agent from 
https://github.com/igabriel85/IeAT-DICE-Repository/tree/master/dmon-agent.
It's a microservice designed to provide control over different metrics 
collection components. In the current version these include Collectd and 
Logstash-forwarder. Those programs are installed according to the big data 
system (role) that you choose.

## Cookbook requirements

- apt
- dice_common
- poise-python


## Recipes

- `dmon_agent::default` - installs dmon_agent and registers the node on dmon
- `dmon_agent::mock_dmon` - runs mock http server for testing http_request
- `dmon_agent::collectd` - installs Collectd (running dice_common::host before 
this is required)
- `dmon_agent::lsf` - installs Logstash-forwarder
- `dmon_agent::storm` - sets node role (storm) on dmon
- `dmon_agent::spark` - configure spark (run after spark installation) and sets 
node role (spark) on dmon
- `dmon_agent::start` - starts the `dmon-agent` service


# Roles

### Storm

Use run list:
```
- recipe[apt::default]
- recipe[dice_common::host]
- recipe[dmon_agent::default]
- recipe[dmon_agent::collectd]
- recipe[dmon_agent::storm]
- recipe[dmon_agent::start]
```

Collectd is installed for system data collection. DMon gets most of the
additional information from the Storm REST API. Additionally, we start the
`dmon-agent` to have the DMon agent be able to server the log files to the
clients. Note that `dmon-agent` requires port 5222 to be open for inbound
traffic.

### Spark

Use run list:
```
- recipe[apt::default]
- recipe[dice_common::host]
- recipe[dmon_agent::default]
- recipe[dmon_agent::collectd]
- recipe[dmon_agent::spark]
```

Collectd is installed for system data collection. Additionally a 
`matrics.properties` file is configured so that spark himself is sending data to 
dmon.


# Attributes

* `['dmon_agent']['tarball']` - tar url of dmon_agent release

### Dmon
* `['dmon_agent']['dmon']['ip']` - ip of dmon
* `['dmon_agent']['dmon']['port']` - port of dmon

### Logstash 
* `['dmon_agent']['logstash']['ip']` - ip of Logstash
* `['dmon_agent']['logstash']['udp_port']` - udp port of Logstash
* `['dmon_agent']['logstash']['l_port']` - lumberjack port of Logstash
* `['dmon_agent']['logstash']['g_port']` - graphite port of Logstash
* `['dmon_agent']['logstash']['period']` - period (s) of data collection
* `['dmon_agent']['logstash']['lsf_crt']` - Logstash-forwarder certificate which
is created on Logstash installation on dmon
