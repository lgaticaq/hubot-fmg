# Description
#   A Hubot script to generate a fake email with FakeMailGenerator
#
# Dependencies:
#   "fmg2": "0.0.4"
#
# Configuration:
#   None
#
# Commands:
#   hubot fmg domains - Grab all domains availables
#   hubot fmg watch <email> - Watch new emails from <email> inbox
#
# Author:
#   lgaticaq

fmg = require "fmg2"

module.exports = (robot) ->
  watcher = null

  robot.respond /fmg domains/, (res) ->
    fmg.fetchDomains (err, domains) ->
      if err
        res.reply "an error occurred while fetch available domains"
        robot.emit "error", err
        return
      res.send domains.join ", "
      return

  robot.respond /fmg watch ([a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,})/i, (res) ->
    watcher = fmg.watch(res.match[1])
    watcher.once "email", (email) ->
      message = "Got a :email:\n"
      message += "> Sender: #{email.sender}\n"
      message += "> Subject: #{email.subject}\n"
      message += "> Body: #{email.body}"
      robot.send {room: res.message.user.name}, message
      watcher.stop()
    watcher.on "error", (err) ->
      res.reply "an error occurred while watch emails"
      robot.emit "error", err
