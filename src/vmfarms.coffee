# Description
#   A hubot script to interact with VM Farms API
#
# Configuration:
#   HUBOT_VMF_API_TOKEN - VM Farms API token
#
# Commands:
#   hubot vmf(arms) pause monitoring <15|30|60|120> - Pause VM Farms external monitoring for specified number of minutes
#   hubot vmf(arms) price me - Get a list of prices and configurations for VM Farms standard boxes
#   hubot vmf(arms) server me [filter term] - Get a list of VM Farms servers, with an optional filter
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
    servers = []
    completed_requests = 0

    table = new AsciiTable()
    table.setHeading('Name', 'Public IPs', 'Private IPs', '# CPUs', 'Disk', 'Package')

    msg.http(urlServers).headers(Authorization: auth, Accept: 'application/json').get() (err, res, body) ->
      if res.statusCode == 200
        try
          json = JSON.parse(body)
        catch error
          msg.send(error, body, "Bleep bloop. Couldn't parse the JSON response.")

        numPages = Math.ceil json.count / 100
        urlsServers = [1..numPages].map (num) -> "https://my.vmfarms.com/cloud/api/servers/?page=#{num}"

        for url in urlsServers
          msg.http(url).headers(Authorization: auth, Accept: 'application/json').get() (err, res, body) ->
            if res.statusCode == 200
              try
                json = JSON.parse(body)
              catch error
                msg.send(error, body, "Bleep bloop. Couldn't parse the JSON response.")

              servers = servers.concat json.results
              completed_requests++

              if completed_requests == urlsServers.length
                for server in servers
                  public_ips = server.public_interfaces[0]
                  if server.public_interfaces.length > 1
                    public_ips += ', ...'
                  private_ips = server.private_interfaces[0]
                  if server.private_interfaces.length > 1
                    private_ips += ', ...'

                  # if no filter defined or the filter is found in the server name
                  if msg.match[2] is undefined or server.name.indexOf(msg.match[2]) > -1
                    table.addRow(server.name, public_ips, private_ips, server.virtual_cores, "#{server.virtual_drive_size}GB", server.package)
                table.sortColumn(0, (a, b) -> a.localeCompare(b))
                msg.send "/code #{table.__rows.length} servers:\n\n#{table.toString()}"
            else
              msg.send "#{res.statusCode} error", body
      else
          msg.send "#{res.statusCode} error", body

  robot.respond /vmf(arms)? pause monitoring (\d+)/i, (msg) ->
    pauseMinutes = parseInt(msg.match[2], 10)
    data = "pause_duration=#{pauseMinutes}"
    msg.http(urlMonitoring).headers('Authorization': auth, 'Content-Type': 'application/x-www-form-urlencoded').post(data) (err, res, body) ->
      if res.statusCode == 201
        msg.send "Ok, VM Farms monitoring is paused for #{pauseMinutes} minutes. You can enable it again here: https://my.vmfarms.com/monitors/"
      else if res.statusCode == 404
        msg.send "You can only pause monitoring for the following number of minutes: 15, 30, 60, 120"
      else
        msg.send "#{res.statusCode} error", body

  robot.respond /vmf(arms)? price me/i, (msg) ->
    table = new AsciiTable()
    table.setHeading('VM Type', 'Memory', 'Disk', 'CPU', 'Price', 'Extra Disk')
    table.addRow(['512MB VM', '512MB', '50GB', '2 CPUs', '$51/mo', '$3.00/GB'])

    msg.http(urlPrices).get() (err, res, body) ->
      $ = cheerio.load body
      $('.section-four .tablecontainerrow').each (i, elem) ->
        if i != 0
          table.addRow $(elem).find('div').map (i, elem) ->
            return $(elem).text()
          .get()

      msg.send "/code #{table.toString()}"
