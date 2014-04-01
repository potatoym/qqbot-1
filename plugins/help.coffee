###

插件支持两个方法调用
 init(robot)
 received(content,send,robot,message)
 stop(robot)
 
 1.直接使用 
 module.exports = func 为快捷隐式调用 received 方法
 2.或
 module.exports = {
   init:      init_func       # 初始化调用
   received:  received_func   # 接受消息
   stop:      init_func       # 停止插件（比如端口占用）
 }
 
 
###

HELP_INFO = """
    version/about   #版本信息和关于
    plugins         #查看载入的插件
    time            #显示时间
    echo 爱你        #重复后面的话
    help            #本内容
    uptime          #服务运行时间
    roll            #返回1-100随机值
    weather         #显示合肥当前天气
"""

fs = require 'fs'
Path = require 'path'
file_path = Path.join __dirname, "..", "package.json"
bundle = JSON.parse( fs.readFileSync file_path )

VERSION_INFO = """
    v#{bundle.version} qqbot
    http://github.com/xhan/qqbot
    本工具还由 糗事百科 热血赞助！
"""

# 毫秒亲
start_at = new Date().getTime()
###
 @param content 消息内容
 @param send(content)  回复消息
 @param robot qqbot instance
 @param message 原消息对象
###

# IMPROVE: 方式不优雅，应该是一个模式识别成功，别的就不应调用到
module.exports = (content ,send, robot, message)->

  if content.match /^help$/i
    send HELP_INFO

  if content.match /^VERSION|ABOUT$/i
    send VERSION_INFO

  if content.match /^plugins$/i
    send "插件列表：\n" + robot.dispatcher.plugins.join('\r\n')

  if content.match /^time$/i
    send "冥王星引力精准校时：" + new Date()

  ret = content.match /^echo (.*)/i
  if ret
    send "哈哈，" + ret[1]
      
  if content.match /^uptime$/i
    secs = (new Date().getTime() - start_at) / 1000
    aday  = 86400 
    ahour = 3600
    [day,hour,minute,second] = [secs/ aday,secs%aday/ ahour,secs%ahour/ 60,secs%60].map (i)-> parseInt(i)
    send "up #{day} days, #{hour}:#{minute}:#{second}"
    
  if content.match /^roll$/i
    # TODO:who? , need a reply method
    send Math.round( Math.random() * 100)

  if content.match /^-roll|-random|-repick|-apne|-apneng|-swap (.*)$/i
    send "醒醒，Dota打多了吧"

  if content.match /^weather$/i
    http = require 'http'
    data = ''
    http.get { hostname: 'www.weather.com.cn', path: '/data/sk/101220101.html'}, (res) ->
        res.on 'data', (chuck) ->
            data += chuck.toString()
        res.on 'end', () ->
            data = JSON.parse data
            data = data.weatherinfo
            send data.city + '当前天气：温度' + data.temp + ' 湿度：' + data.SD + ' ' + data.WD + data.WS + ' 更新时间：' + data.time
