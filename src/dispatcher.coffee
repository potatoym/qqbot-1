Log = require 'log'
log = new Log('debug')

EventEmitter = require('events').EventEmitter

requireForce = (module_name) ->
  try
    delete require.cache[require.resolve(module_name)]
    log.debug "Loading module #{JSON.stringify module_name}..."
    require(module_name)
  catch error
    log.error "Load module #{JSON.stringify module_name} failed"
    log.error JSON.stringify error


class Dispatcher extends EventEmitter
    constructor: (@plugins=[], @robot) ->
      @listeners = []
      @obj_listeners = []
      
      @reload_plugin()

    dispatch: (params...)->
      try
        for plugin in @listeners
          plugin(params...)
        for plugin in @obj_listeners
          [obj,method] = plugin
          obj[method](params...)
      catch error
        log.error error
      

    ###
    针对 对象的方法
      请传入 [obj,'methodname']
      methodname 直接调用 methodname 会破坏内部变量 this.xxx
    ###
    add_listener: (listener)->
      if listener instanceof Function
        @listeners.push listener
      else
        @obj_listeners.push listener
    
    # 重新加载插件
    reload_plugin:->
      # 注销插件
      @stop_funcs ?= []
      func(@robot) for func in @stop_funcs
      
      @listeners = []
      for plugin_name in @plugins
        log.debug "Loading Plugin #{plugin_name}"
        plugin = requireForce "../plugins/#{plugin_name}"
        if plugin
          if plugin instanceof Function
            @listeners.push plugin
          else
            # init , received, stop  函数
            @listeners.push plugin.received if plugin.received
            plugin.init(@robot) if plugin.init
            @stop_funcs.push plugin.stop if plugin.stop


module.exports = Dispatcher