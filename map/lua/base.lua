    jass = require 'jass.common'
	japi = require 'jass.japi'
	slk = require 'jass.slk'
	runtime = require 'jass.runtime'
    hook = require 'jass.hook'
	storm = require 'jass.storm'
    
	--打开控制台
	--runtime.console = true
	--设置句柄等级为0(地图中所有的句柄均使用table封装)
	runtime.handle_level = 0
	--关闭等待功能
	runtime.sleep = false
	--拆解table
	local function sub(t)
		local meta = getmetatable(t)
		local __index = meta.__index
		local function new__index(t, k)
			local r = __index(t, k)
			t[k] = r
			return r
		end
		meta.__index = new__index
	end
	sub(jass)
	sub(japi)
    
    print 'hello world'
    
	--汇报错误啦
	function debug.info(s, this)
		local t = {}
		for name, v in pairs(this) do
			table.insert(t, ('[%s] %s'):format(name, v))
		end
		print(('%s\n=======================\n%s\n=======================\n'):format(s, table.concat(t, '\n')))
	end
    
    unpack = unpack or table.unpack
    load = load or loadstring
    
	require 'lua\\util.lua'
	require 'lua\\event.lua'
	require 'lua\\table.lua'
	require 'lua\\timer.lua'
	require 'lua\\player.lua'
	require 'lua\\cmd.lua'
	require 'lua\\game.lua'
	require 'lua\\text.lua'
	require 'lua\\check11.lua'

	require 'lua\\record.lua'