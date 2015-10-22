# hubot-vmfarms

A hubot script to interact with the [VM Farms API](https://my.vmfarms.com/api/v1/docs/)

See [`src/vmfarms.coffee`](src/vmfarms.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-vmfarms --save`

Then add **hubot-vmfarms** to your `external-scripts.json`:

```json
[
  "hubot-vmfarms"
]
```

## Configuration
### Required

`HUBOT_VMF_API_TOKEN`

## Sample Interaction

```
user1>> hubot vmf price me
hubot>> .-----------------------------------------------------------.
        | VM Type | Memory | Disk |  CPU   |   Price   | Extra Disk |
        |---------|--------|------|--------|-----------|------------|
        | 1GB VM  | 1GB    | 50GB | 2 CPUs | $88/mo    | $3.00/GB   |
        | 2GB VM  | 2GB    | 50GB | 4 CPUs | $164/mo   | $1.50/GB   |
        | 4GB VM  | 4GB    | 50GB | 4 CPUs | $314/mo   | $0.75/GB   |
        | 8GB VM  | 8GB    | 50GB | 4 CPUs | $616/mo   | $0.50/GB   |
        | 16GB VM | 16GB   | 50GB | 4 CPUs | $1,218/mo | $0.50/GB   |
        | 32GB VM | 32GB   | 50GB | 8 CPUs | $2,225/mo | $0.50/GB   |
        '-----------------------------------------------------------'
```

```
user1>> hubot vmf server me [filter]
hubot>> .--------------------------------------------------------------------------------.
        |         Name         |  Public IPs   |  Private IPs  | # CPUs |    Package     |
        |----------------------|---------------|---------------|--------|----------------|
        | <server name 1>      | <public ip>   | <private ip>  | 4      | 4GB VM         |
        | <server name 2>      | <public ip>   | <private ip>  | 4      | 4GB VM         |
        | ...                  | ...           | ...           | ...    | ...            |
        .--------------------------------------------------------------------------------.
```

```
user1>> hubot vmf pause monitoring 15
hubot>> Ok, VM Farms monitoring is paused for 15 minutes. You can enable it again here: https://my.vmfarms.com/monitors/
```

## History

### 1.1.3 / 2015-10-22

  * Fix: Fix response code check

### 1.1.2 / 2015-10-22

  * Fix: Fix pause duration parameter

### 1.1.1 / 2015-08-13

  * Fix: Fix URLs in `package.json` to point to correct github repo

### 1.1.0 / 2015-08-13

  * Fix: Use pagination to get full list of servers, in case you have >100 servers
  * New: Add server count to response
  * New: Add `512MB` to price list

### 1.0.0 / 2015-06-30

  * Initial release
