Helper = require("hubot-test-helper")
expect = require("chai").expect
nock = require("nock")
path = require("path")

helper = new Helper("./../src/index.coffee")

describe "hubot-fmg", ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    nock.disableNetConnect()

  afterEach ->
    room.destroy()
    nock.disableNetConnect()

  context "fetch domains", ->
    beforeEach (done) ->
      nock("http://fakemailgenerator.com")
        .get("/")
        .replyWithFile(200, path.join(__dirname, "/html/domains.html"))
      room.user.say("user", "hubot fmg domains")
      setTimeout(done, 100)

    it "should return all domains", ->
      expect(room.messages).to.eql([
        ["user", "hubot fmg domains"]
        ["hubot", "armyspy.com, cuvox.de, dayrep.com, einrot.com, fleckens.hu, gustr.com, jourrapide.com, rhyta.com, superrito.com, teleworm.us"]
      ])

  context "watch a email", ->
    domain = "dayrep.com"
    name = "brin1979"
    id = 80758939
    beforeEach (done) ->
      nock("http://www.fakemailgenerator.com")
        .get("/inbox/#{domain}/#{name}/")
        .replyWithFile(200, path.join(__dirname, "/html/emails.html"))
      nock("http://www.fakemailgenerator.com")
        .get("/email/#{domain}/#{name}/message-#{id}/")
        .replyWithFile(200, path.join(__dirname, "/html/email.html"))
      room.user.say("user", "hubot fmg watch brin1979@dayrep.com")
      setTimeout(done, 100)

    it "should return a new email", ->
      expect(room.messages).to.eql([
        ["user", "hubot fmg watch brin1979@dayrep.com"]
        ["hubot", "Got a :email:\n> Sender: Mailgun Sandbox <postmaster@sandbox001d115bba6a4420b95683d91ab467ab.mailgun.org>\n> Subject: Test\n> Body: \n    Test1\n    \n  "]
      ])
