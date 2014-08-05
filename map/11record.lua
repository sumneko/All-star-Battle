	local suc, content = pcall(storm.load, '11record.txt')
	
	if suc then
		local names = {}
		--注册专属信使
		messenger = {}
		
		local funcs = {
			['特殊称号'] = function(line)
				local name, title = line:match('([%C%S]+)=([%C%S]+)')
				if name then
					names[name] = title
				end
			end,
			['特殊信使'] = function(line)
				local name, value = line:match('([%C%S]+)=([%C%S]+)')
				if name == '名字' then
					messenger.who = value
					messenger[messenger.who] = {}
				elseif name == '信使' then
					messenger[messenger.who].uid = __id(value)
				elseif name == '图标' then
					messenger[messenger.who].image = value
				elseif name == '技能' then
					messenger[messenger.who].type = value == '被动' and 'skill1' or 'skill2'
				elseif name == '标题' then
					messenger[messenger.who].title = value
				elseif name == '内容' then
					messenger[messenger.who].text = value
				end
			end,
		}
		
		local now_type
		for line in content:gmatch('([^\n\r]+)') do
			now_type = line:match('==(%C+)==') or now_type

			if now_type then
				funcs[now_type](line)
			end
		end

		function cmd.fresh_name(p)
			local base_name = p:getBaseName()
			if names[base_name] then
				local name = p:getName()
				name = names[base_name] .. name
				p:setName(name)
			end
		end

		--信使被动专属技能
		messenger.skill1 = {
			|A0RK|,
			|A0RL|,
			|A0RM|,
			|A0RN|,
			|A0RO|,
			|A0RP|,
			|A0RQ|,
			|A0RR|,
			|A0RS|,
			|A0RT|,
		}
		--信使主动专属技能
		messenger.skill2 = {
			|A0RI|,
			|A0RU|,
			|A0RV|,
			|A0RW|,
			|A0RX|,
			|A0RY|,
			|A0RZ|,
			|A0S0|,
			|A0S1|,
			|A0S2|,
		}
		
		function cmd.get_messenger_type(p)
			jass.udg_Lua_integer = |n008|
			local name = p:getBaseName()
			if messenger[name] then
				jass.udg_Lua_integer = messenger[name].uid
			end
		end

		function cmd.set_messenger_text(p, u)
			local name = p:getBaseName()
			if messenger[name] then
				local t = messenger[name]
				local sid = messenger[t.type][p:get()]
				u = tonumber(u)
				jass.UnitAddAbility(u, sid)
				jass.UnitMakeAbilityPermanent(u, true, sid)
				local ab = japi.EXGetUnitAbility(u, sid)
				japi.EXSetAbilityDataString(ab, 1, 204, t.image)
				japi.EXSetAbilityDataString(ab, 1, 215, t.title)
				japi.EXSetAbilityDataString(ab, 1, 218, t.text)
			end
		end
	end