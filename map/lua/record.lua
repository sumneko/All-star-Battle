
	record = {}

	local record = record

	setmetatable(record, record)

	if not japi.InitGameCache then
		local names	= {
			'InitGameCache',
			'StoreInteger',
			'GetStoredInteger',
			'StoreString',
			'SaveGameCache'
		}
		
		for _, name in ipairs(names) do
			rawset(japi, name, jass[name])
		end

	end

	function record.i2s(i)
		return ('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/*-+=,.<>\\|[]{};:!@#$%^&()'):sub(i, i)
	end

	function record.init()
		for i = 1, 16 do
			record[i] = jass.GC[i - 1]
			player[i].record = record[i]
			player[i].record_data = {}
		end
	end

	timer.wait(1, record.init)

	function player.__index.getRecord(this, name)
		--print(('load record: %s = %s'):format(name, japi.GetStoredInteger(this.record, '', name)))
		return japi.GetStoredInteger(this.record, '', name) or 0
	end

	function player.__index.setRecord(this, name, value)
		--print(('save record: %s = %s'):format(name, value))
		return japi.StoreInteger(this.record, '', name, value)
	end

	function player.__index.saveRecord(this)
		return japi.SaveGameCache(this.record)
	end

	--保存名字
	function record.saveName(first, name, value)
		player.self:setRecord(first .. 0, value)
		
		--将名字拆成4个整数
		player.self:setRecord(first .. 1, __id(name:sub(1, 4)) - 2 ^ 31)
		player.self:setRecord(first .. 2, __id(name:sub(5, 8)) - 2 ^ 31)
		player.self:setRecord(first .. 3, __id(name:sub(9, 12)) - 2 ^ 31)
		player.self:setRecord(first .. 4, __id(name:sub(13, 16)) - 2 ^ 31)
	end

	--读取名字
	function record.loadName(first)
		local value = player.self:getRecord(first .. 0)
		
		--将4个整数组装成名字
		local name	= _id(player.self:getRecord(first .. 1) + 2 ^ 31) .. _id(player.self:getRecord(first .. 2) + 2 ^ 31) .. _id(player.self:getRecord(first .. 3) + 2 ^ 31) .. _id(player.self:getRecord(first .. 4) + 2 ^ 31)
		--print(name)
		return name:match '(%Z+)', value
	end

	--本地记录玩家
	--解析本地文件
	function record.read_players(text)
		for line in text:gmatch '(%C+)' do
			local name, value	= line:match '(.+)%=(%d+)'
			if name then
				table.insert(player.self.record_data, name)
				player.self.record_data[name] = tonumber(value)
			end
		end
	end
	
	function record.save_players()
		local text	= storm.load 'save\\Profile1\\Campaigns.mu'
		if text then
			record.read_players(text)
		end
		local data = player.self.record_data

		--取出局数最多的一个名字
		local name, value	= record.loadName('mt')
		if value > 0 then
			if not data[name] then
				table.insert(data, name)
			end
			data[name] = math.max(data[name], value)
		end

		--保存当前名字
		local name = player.self:getBaseName()
		
		if not data[name] then
			table.insert(data, name)
		end
		data[name] = player.self:getRecord '局数'
		
		--生成新的本地记录
		local texts = {}
		for _, name in ipairs(data) do
			table.insert(texts, ('%s=%d'):format(name, data[name]))
		end
		--保存到本地
		--print(table.concat(texts, '\n'))
		storm.save('save\\Profile1\\Campaigns.mu', table.concat(texts, '\n'))

		--找到局数最多的一个名字
		local name	= table.pick(data,
			function(name1, name2)
				return data[name1] > data[name2]
			end
		)

		--保存该名字
		record.saveName('mt', name, data[name])
		--print(name, player.self:getBaseName())

		player.self:saveRecord()

		--判定是不是在开小号
		if name ~= player.self:getBaseName() then
			cmd.maid_chat(player.self, '主人您又在开小号虐菜了')
			cmd.maid_chat(player.self, '主人您的大号是 [' .. name .. '] 没错吧~')
		end
		
	end
	
	timer.wait(1, record.save_players)