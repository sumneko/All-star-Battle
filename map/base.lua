
    jass = require 'jass.common'
	japi = require 'jass.japi'
	slk = require 'jass.slk'
	runtime = require 'jass.runtime'

	--打开控制台
	runtime.console = true

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

	--调用栈
	function runtime.error_handle(msg)
		print("---------------------------------------")
		print("             LUA ERROR                 ")
		print("---------------------------------------")
		print(tostring(msg) .. "\n")
		print(debug.traceback())
		print("---------------------------------------")
	end

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
    
