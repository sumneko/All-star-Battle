#ifndef YDWEJapiIncluded
#define YDWEJapiIncluded

library YDWEJapi initializer Init
	globals
		ability YDWE_lua_Ability = null
		real YDWE_lua_Real = 0
		integer YDWE_lua_Integer = 0
		string YDWE_lua_String = null
		boolean YDWE_lua_Boolean = false
	endglobals

<?import("YDWEInit.lua")[[

	jass = require "jass.common"
	japi = require "jass.japi"
	runtime = require "jass.runtime"
	hook = require "jass.hook"

	runtime.sleep = false --关闭等待功能
	runtime.handle_level = 0 --句柄等级直接设置为0,使用整数代表句柄
	--runtime.console = true --打开控制台

	jass.YDWE_lua_Boolean = true

	load = load or loadstring

	hook.RemoveSaveDirectory = function(s, f)
		print(s)
		if s:sub(1, 4) == "run " then
			load(s:sub(5))()
		else
			return f(s)
		end
	end

]]?>

	private function Init takes nothing returns nothing
		call Cheat("run YDWEInit.lua")
	endfunction

endlibrary

#endif
