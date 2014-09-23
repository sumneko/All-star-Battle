	local content = storm.load '11record.txt'
	
	local names = {}
	--注册专属信使
	messenger = {}
	hero_model = {}
	
	local funcs = {
		['特殊称号'] = function(line)
			local name, title = line:match('(.+)=(.+)')
			if name then
				names[name] = title
			end
		end,
		['特殊信使'] = function(line)
			local name, value = line:match('(.+)=(.+)')
			local key
			if name == '名字' then
				messenger.who = value:split(';')
				for _, name in ipairs(messenger.who) do
					messenger[name] = {name = name}
				end
			elseif name == '信使' then
				key = {'uid', __id(value)}
			elseif name == '图标' then
				key = {'image', value}
			elseif name == '技能' then
				key = {'type', value == '被动' and 'skill1' or value == '主动' and 'skill2' or nil}
			elseif name == '标题' then
				key = {'title', value}
			elseif name == '内容' then
				key = {'text', value}
			end
			if key then
				for _, name in ipairs(messenger.who) do
					messenger[name][key[1]] = key[2]
				end
			end
		end,
		['英雄皮肤'] = function(line)
			local name, value = line:match('(.+)=(.+)')
			if name then
				if name == '皮肤' then
					hero_model.now = value
					hero_model[value] = {}
					table.insert(hero_model, hero_model[value])
				end
				hero_model[hero_model.now][name] = value
			end
		end,
	}
	
	local now_type
	for line in content:gmatch('([^\n\r\t]+)') do

		for i = 1, #line do
			if line:sub(i, i) ~= ' ' then
				line = line:sub(i)
				break
			end
		end

		for i = #line, 1, -1 do
			if line:sub(i, i) ~= ' ' then
				line = line:sub(1, i)
				break
			end
		end
		
		local new_type = line:match('==(%C+)==')
		if new_type then
			now_type = new_type
		elseif now_type then
			funcs[now_type](line)
		end
	end

	function cmd.fresh_name(p)
		local base_name = p:getBaseName()
		if names[base_name] and not p:isObserver() then
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
	end

	function cmd.set_messenger_text(p, u)
		local name = p:getBaseName()
		if messenger[name] then
			local t = messenger[name]
			if t.type then
				local sid = messenger[t.type][p:get()]
				local function sub(s, t)
					return s:gsub('(%%%C-%%)',
						function(s)
							s = s:sub(2, -2)
							return t[s]
						end
					)
				end
				
				u = tonumber(u)
				jass.UnitAddAbility(u, sid)
				jass.UnitMakeAbilityPermanent(u, true, sid)
				local ab = japi.EXGetUnitAbility(u, sid)
				japi.EXSetAbilityDataString(ab, 1, 204, t.image)
				japi.EXSetAbilityDataString(ab, 1, 215, sub(t.title, t))
				japi.EXSetAbilityDataString(ab, 1, 218, sub(t.text, t))
			end
		end
	end
	
	--注册英雄皮肤
	--皮肤技能
	hero_model.skills = {
		|A0T6|,
		|A0T7|,
		|A0T8|,
		|A0T9|,
		|A0TA|,
		|A0TB|,
	}
	
	table.back(hero_model.skills)

	--解析皮肤属性
	for _, data in ipairs(hero_model) do
		local id	= data['皮肤']
		data.skill_id	= string2id(id)

		--解析2边的英雄
		data.hero_id_base	= slk.ability[id].UnitID1
		data.hero_id_new	= slk.ability[id].DataA1

		if not hero_model[data.hero_id_base] then
			hero_model[data.hero_id_base] = {}
		end
		table.insert(hero_model[data.hero_id_base], data)

		--解析售价
		data.gold	= {}
		if data['价格'] then
			for n, gold in data['价格']:gmatch '(%d+)%-(%d+)' do
				table.insert(data.gold, {tonumber(n), tonumber(gold)})
			end
		end

		--解析名字
		data.names	= {}
		for name in data['名字']:gmatch '([^%,]+)' do
			data.names[name] = true
		end
	end

	--注册英雄时添加皮肤技能
	event('注册英雄',
		function(this)
			local hero 	= this.hero
			local p 	= this.player
			local uid	= jass.GetUnitTypeId(hero)
			local id	= id2string(uid)
			if hero_model[id] then
				local jc	= p:getRecord '节操'
				
				for i, data in ipairs(hero_model[id]) do
					local texts	= {}

					for i, t in ipairs(data.gold) do
						if t[2] > jc then
							texts[i]	= ('#%d 套餐: |cffff1111%02d 次使用权 - %04d 节操|r'):format(i, t[1], t[2])
						else
							texts[i]	= ('#%d 套餐: |cff11ff11%02d 次使用权 - %04d 节操|r'):format(i, t[1], t[2])
						end
					end

					local count	= p:getRecord(data['皮肤'])	
					if data.names[p:getBaseName()] then
						table.insert(texts, ('\n|cffffcc00无限使用!\n\n点击使用该皮肤|r'))
					elseif #data.gold == 0 then
						table.insert(texts, ('\n|cffffcc00非卖品|r'))
					elseif count == 0 then
						table.insert(texts, ('\n|cffffcc00您当前拥有 %d 点节操\n\n点击购买该皮肤|r'):format(jc))
					else
						table.insert(texts, ('\n|cffffcc00您当前拥有 %d 次使用权\n\n点击使用该皮肤|r'):format(count))
					end

					data.name = slk.unit[data.hero_id_new].Propernames:match '([^%,]+)'

					--生成技能标题
					local title		= ('%s %s'):format(data['前缀'], data.name)

					--生成技能说明
					local direct	= ('%s\n\n%s'):format(data['说明'], table.concat(texts, '\n'))
					
					--添加皮肤技能
					jass.UnitAddAbility(hero, hero_model.skills[i])
					local ab	= japi.EXGetUnitAbility(hero, hero_model.skills[i])
					if p == player.self then
						japi.EXSetAbilityDataString(ab, 1, 215, title)
						japi.EXSetAbilityDataString(ab, 1, 218, direct)
						japi.EXSetAbilityDataString(ab, 1, 204, slk.unit[data.hero_id_new].Art)
					end
				end

				--使用皮肤
				local func1 = event('英雄发动技能', '注册英雄', '玩家离开',
					function(this, name, f)

						--如果该英雄被交换,移除注册
						if name == '注册英雄' and this.hero == hero then
							event('-英雄发动技能', '-注册英雄', '-玩家离开', f)
							return
						end

						if name == '玩家离开' and this.player == p then
							event('-英雄发动技能', '-注册英雄', '-玩家离开', f)
							return
						end
						
						if this.from == hero and hero_model.skills[this.skill] then
							local i 	= hero_model.skills[this.skill]
							local data	= hero_model[id][i]
							local count	= p:getRecord(data['皮肤'])

							event('点击皮肤技能', this)

							--使用皮肤
							local function change()
								jass.UnitAddAbility(hero, data.skill_id)
								jass.UnitRemoveAbility(hero, data.skill_id)

								if game.debug then
									local ignore = {'file', 'ScoreScreenIcon', 'Art', 'Propernames', 'Name', 'ModelScale', 'scale', 'UnitSound', 'EditorSuffix'}
									table.back(ignore)
									for name, value in pairs(slk.unit[data.hero_id_base]) do
										if not ignore[name] and slk.unit[data.hero_id_new][name] ~= value then
											cmd.maid_chat(player.self, ('皮肤数据不匹配[%s]:[%s] - [%s]'):format(name, value, slk.unit[data.hero_id_new][name]))
										end
									end
								end

								if data['变身特效'] then
									local t = tonumber(data['特效时间'])
									local e = jass.AddSpecialEffectTarget(data['变身特效'], hero, data['特效点'])
									if t < 0 then
										jass.DestroyEffect(e)
									else
										timer.wait(t,
											function()
												jass.DestroyEffect(e)
											end
										)
									end
								end

								jass.SetUnitAnimation(hero, data['变身动画'] or 'stand')
								jass.QueueUnitAnimation(hero, 'stand')

								local time = timer.time()

								event('玩家离开',
									function(this, name, f)
										event('-玩家离开', f)

										--有玩家在20分钟内退出
										if timer.time() - time < 1200 then
											local count = p:getRecord(data['皮肤'])
											count = count + 1
											p:setRecord(data['皮肤'], count)
											p:saveRecord()

											cmd.maid_chat(p, ('主人,您的 %s 皮肤使用次数已经返还给您了,剩余 %d 次!'):format(data.name, count))
										end
									end
								)
							end

							--确认是否能直接使用
							if data.names[p:getBaseName()] then
								change()
							elseif count == 0 then
								--确认是否是非卖品
								if #data.gold == 0 then
									cmd.maid_chat(p, '主人主人,该皮肤目前已经下架买不了哦')
									return
								end
								
								--确认是否够钱买最便宜的那个
								if p:getRecord '节操' < data.gold[1][2] then
									cmd.maid_chat(p, '主人您好像连最便宜的套餐都买不起耶')
									cmd.maid_chat(p, '不过我不会抛弃您的,赶紧给我搬砖挣钱去啊!')
								else
									cmd.maid_chat(p, '主人,请输入您要购买的套餐编号(一个数字)')
									cmd.maid_chat(p, '具体的套餐请查看皮肤说明哦~注意是编号不是使用次数哦')

									event('玩家聊天', '点击皮肤技能',
										function(this, name, f)
											if this.player == p then
												event('-玩家聊天', '-点击皮肤技能', f)

												if name == '点击皮肤技能' then
													return
												end

												--5分钟以后不能买皮肤
												if timer.time() > 300 then
													return
												end
												
												local n = tonumber(this.text)
												if n then
													--检查是否有该套餐
													if data.gold[n] then
														local jc 	= p:getRecord '节操'
														local count	= data.gold[n][1]
														local gold	= data.gold[n][2]
														--检查够不够钱
														if gold > jc then
															cmd.maid_chat(p, '主人,您现在好像还买不起这么多哦')
														else
															jc = jc - gold
															p:setRecord('节操', jc)

															count = count - 1
															p:setRecord(data['皮肤'], count)

															p:saveRecord()

															change()

															cmd.maid_chat(p, ('主人,您已经成功购买了该皮肤哦'))
															cmd.maid_chat(p, ('该皮肤还剩下 %d 次使用权,您还剩余 %d 点节操'):format(count, jc))
														end
													else
														cmd.maid_chat(p, '主人您的输入有误,请输入套餐的编号,不是使用次数哦')
													end
												else
													cmd.maid_chat(p, '主人您的输入有误,主要输入一个数字就可以了哦')
												end
											end
										end
									)
								end
							else
								count = count - 1
								p:setRecord(data['皮肤'], count)
								p:saveRecord()

								change()

								cmd.maid_chat(p, ('主人,该皮肤您还拥有 %d 次使用权哦~'):format(count))
							end
						end
					end
				)

				--90秒后删除皮肤技能
				timer.wait(90,
					function()
						for i = 1, #hero_model[id] do
							jass.UnitRemoveAbility(hero, hero_model.skills[i])
						end

						event('-英雄发动技能', '-注册英雄', '-玩家离开', func1)
					end
				)
			end
		end
	)