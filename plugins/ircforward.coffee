irc = require 'irc'
// TODO: should be read from config.yaml
group_name = 'USTC_Linux'
channel_name = '#ustc_lug'

class IrcClient
    constructor: (@qqbot) ->
        @client = new irc.Client 'irc.freenode.net', 'qqbot2', {
            channels: [channel_name],
        }
        @client.addListener 'message', (from, to, text, message) ->
            group = @qqbot.get_group {name:group_name}
            @qqbot.send_message_to_group group, '[' + from + ']' + text, (ret,e)->
                'nothing'

bot = null
exports.init = (qqbot) ->
    bot = new IrcClient qqbot

exports.received = (content ,send, robot, message) ->
    bot.say channel_name, '[qqbot]['+send+']' + content
