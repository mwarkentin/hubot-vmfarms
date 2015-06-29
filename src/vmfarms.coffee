# Description
#   A hubot script to interact with VMFarms API
#
# Configuration:
#   HUBOT_VMF_API_TOKEN - VMFarms API token
#
# Commands:
#   hubot vmf(arms) pause monitoring <15|30|60|120> - Pause VMF external monitoring for specified number of minutes
#   hubot vmf(arms) price me - Get a list of prices and configurations for VMFarms standard boxes
#   hubot vmf(arms) server me [filter term] - Get a list of VMFarms servers, with an optional filter
#
# Dependencies:
#   "ascii-table": "0.0.8"
#   "cheerio": "^0.18.0"
#
# Author:
#   Michael Warkentin <mwarkentin@gmail.com>

AsciiTable = require 'ascii-table'
cheerio = require 'cheerio'

urlMonitoring = "https://my.vmfarms.com/monitors/api/pause-monitors/"
urlPrices = "https://vmfarms.com/pricing/"
urlServers = "https://my.vmfarms.com/cloud/api/servers/"
auth = "Token #{process.env.HUBOT_VMF_API_TOKEN}"

module.exports = (robot) ->
  robot.respond /vmf(arms)? server me\s?([\w-]+)?/i, (msg) ->
    table = new AsciiTable()
    table.setHeading('Name', 'Public IPs', 'Private IPs', '# CPUs', 'Package')
    msg.http(urlServers).headers(Authorization: auth, Accept: 'application/json').get() (err, res, body) ->
      try
        json = JSON.parse(body)
        for server in json.results
          public_ips = server.public_interfaces[0]
          if server.public_interfaces.length > 1
            public_ips += ', ...'
          private_ips = server.private_interfaces[0]
          if server.private_interfaces.length > 1
            private_ips += ', ...'

          if msg.match[2] is undefined or server.name.indexOf(msg.match[2]) > -1
            table.addRow(server.name, public_ips, private_ips, server.virtual_cores, server.package)
      catch error
        msg.send(error, body, "Bleep bloop. Couldn't parse the response.")

      table.sortColumn(0, (a, b) -> a.localeCompare(b))
      msg.send "/code #{table.toString()}"

  robot.respond /vmf(arms)? pause monitoring (\d+)/i, (msg) ->
    data = JSON.stringify(pause_time: parseInt(msg.match[2], 10))
    msg.send "url: #{urlMonitoring}"
    msg.send "data: #{data}"
    msg.http(urlMonitoring).headers(Authorization: auth).post(data) (err, res, body) ->
      msg.send err, res, body

  robot.respond /vmf(arms)? price me/i, (msg) ->
    table = new AsciiTable()
    table.setHeading('VM Type', 'Memory', 'Disk', 'CPU', 'Price', 'Extra Disk')

    msg.http(urlPrices).get() (err, res, body) ->
      $ = cheerio.load body
      $('.section-four .tablecontainerrow').each (i, elem) ->
        if i != 0
          table.addRow $(elem).find('div').map (i, elem) ->
            return $(elem).text()
          .get()
          # table.addRow cells.text()
      msg.send "/code #{table.toString()}"
