irc = require 'irc'
# TODO: should be read from config.yaml
group_name = 'USTC_Linux'
channel_name = '#ustc_lug'
qqbot = null
class IrcClient
    constructor: () ->
        @client = new irc.Client 'irc.freenode.net', 'qqbot3', {
            channels: [channel_name],
        }
        @client.addListener 'message', (from, to, text, message) ->
            console.log ('got message from irc')
            group = qqbot.get_group({name:group_name})
            qqbot.send_message_to_group group, '[' + from + ']' + text, (ret,e)->
                'nothing'
        @client.addListener 'error', (message) ->
            console.log message

bot = null
exports.init = (qqbot1) ->
    qqbot = qqbot1
    bot = new IrcClient

exports.received = (content ,send, robot, message) ->
    bot.client.say channel_name, '['+message.from_user.nick+']' + content if bot

exports.stop = (qqbot) ->
    bot.client.disconnect