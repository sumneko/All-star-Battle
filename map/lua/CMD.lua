	cmd = {}

	--�洢�Ѿ��㱨���Ĵ���
	cmd.errors = {}

	--����print
	cmd.print = print

	cmd.text_print = {}
	
	---[[
	function print(...)
		table.insert(cmd.text_print, table.concat({...}, '\t'))
	end

	--����ջ
	function runtime.error_handle(msg)
		if cmd.errors[msg] then
			return
		end
		if not runtime.console then
			cmd.errors[1] = 1
			jass.DisplayTimedTextToPlayer(jass.GetLocalPlayer(), 0, 0, 60, msg)
		end
		cmd.errors[msg] = true
		print(cmd.getMaidName() .. ":Lua����㱨��һ������,���˿��ͼ�㱨!")
		print("---------------------------------------")
		print(tostring(msg) .. "\n")
		print(debug.traceback())
		print("---------------------------------------")
	end
	--]]

	--cmdָ��ӿ�
	function cmd.start()
		local str = jass.GetPlayerName(jass.Player(12))
		local words = {}
		for word in str:gmatch('%S+') do
			table.insert(words, word)
		end
		local f_name = words[1]
		if f_name and cmd[f_name] then
			words[1] = player.j_player(jass.Lua_player)
			cmd[f_name](unpack(words))
		end
	end

	--��ʼ��
	function cmd.main()
		cmd.maid_name()
		cmd.hello_world()
		cmd.check_error()
		cmd.check_handles()
	end

	--��ȡŮ������
	cmd.maidNames_ansi = {
		'�ܸɵİ�˿����',
		'�ܸɵĺ�˿����',
		'�ɿ����ö�����',
		'�ɿ���è������',
		'�ɰ�����С����',
		'���ظ���С����',
		'��Ů��',
		'����Ů��',
		'�췢����',
		'��ëŮ��',
		'������',
		'������',
		'������',
		'�ɰ�����С����',
		'���ظ���С����',
		'�����ഺ��',
		'�ۺ��ִ΢�',
		'Ů����˿��',
		'Ů������',
		'Ů�ͷ���',
		'����Ů��',
		'����Ů��',
		'����è������β����',
		'��ɵ���ʿ��zz',
		'�ɹ��İ����ഺ��',
		'�ɰ������޹⻷��',
		'�ɰ�������Ů��Z',
		'��ǿ�������ͺ�',
		'���ڵĲ�ߣ������',
		'����Ľڲ�����',
		'����б������ʿ',
	}

	cmd.maidNames_utf8 = {
		'能干的白丝萝莉',
		'能干的黑丝萝莉',
		'可靠的兔耳萝莉',
		'可靠的猫耳萝莉',
		'可爱傲娇小萝莉',
		'哥特腹黑小萝莉',
		'金发女仆',
		'银发女仆',
		'红发萝莉',
		'金毛女王',
		'王尼玛',
		'王尼妹',
		'王尼美',
		'可爱傲娇小菠萝',
		'哥特腹黑小菠萝',
		'哥特青春姬',
		'粉红胖次⑤',
		'女仆螺丝妹',
		'女仆兔兔',
		'女仆罚妹',
		'傲娇女仆',
		'病娇女仆',
		'银发猫耳单马尾萝莉',
		'会飞的骑士王zz',
		'可攻的傲娇青春受',
		'可爱的人妻光环娜',
		'可爱的萝莉女仆Z',
		'最强的云霄猛喝',
		'腹黑的不撸死大妈',
		'猥琐的节操婶婶',
		'正义感爆棚的骑士',
	}
		
	function cmd.maid_name()
		for i = 0, 11 do
			local j = jass.GetRandomInt(1, #cmd.maidNames_utf8)
			if jass.Player(i) == jass.GetLocalPlayer() then
				cmd.maidNames_utf8[0] = cmd.maidNames_utf8[j]
				cmd.maidNames_ansi[0] = cmd.maidNames_ansi[j]
			end
		end
	end

	function cmd.getMaidName(utf8)
		return cmd['maidNames_' .. (utf8 and 'utf8' or 'ansi')][0]
	end

	function cmd.check_error()
		timer.loop(60,
	        function()
	            if cmd.errors[1] then
		            
					jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	                japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc刚才lua脚本汇报了一个错误,帮忙截图汇报一下错误可以嘛?|r')
	                japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc对了,主人可以输入",cmd"来打开cmd窗口查看错误哦,谢谢主人喵|r')
	                
	                cmd.errors[1] = cmd.errors[1] + 1
	                if cmd.errors[1] > 3 then
		                cmd.errors[1] = false
	                end
	            end
	        end
	    )
    end

    function cmd.maid_chat(p, s)
	    if p == player.self then
		    jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	        japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc' .. s .. '|r')
	    end
    end

    function cmd.cmd(p)
	    local open
	    if p == player.self then
            if runtime.console then
	            jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	            japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc已经帮主人关掉了喵|r')
	            runtime.console = false
            else
	            open = true
				jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	            japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cccmd窗口将在3秒后打开,如果主人想关掉的话只要|r')
	            japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc再次输入",cmd"就可以了,千万不要直接去关掉窗口哦|r')

	            cmd.errors[1] = false
            end
            
	    end
	    timer.wait(3,
	    	function()
		    	if open then
			    	runtime.console = true
			    	if print ~= cmd.print then
				    	--˵���ǵ�һ�ο���
				    	print = cmd.print
				    	for i = 1, #cmd.text_print do
					    	print(cmd.text_print[i])
				    	end
			    	end
				end
			end
	    )
	end

	--��ʼ�ı�
	function cmd.hello_world()
		print(cmd.getMaidName() .. ':��������,��������˽��ר��Ů��,�һ��ں�̨ĬĬ���ռ�һЩ��������,�����������Ϸ������ʱ����Խ�ͼչʾһ���һ�ܿ��ĵ�!\n')
	end

	--�����
	cmd.handle_data = {}
	
	function cmd.check_handles()
		timer.wait(5,
			function()
				local handles = {}
				for i = 1, 10 do
					handles[i] = jass.Location(0, 0)
				end
				cmd.handle_data[0] = math.max(unpack(handles)) - 1000000
				for i = 1, 10 do
					jass.RemoveLocation(handles[i])
				end

				print(('%s:����,�Ҳ�����һ����Ϸ��ʼ��ʱ����Ϸ����[%d]������Ŷ'):format(cmd.getMaidName(), cmd.handle_data[0]))
				timer.wait(2,
					function()
						print(('%s:��Щ����Խ��,��Ϸ������Ч�ʾͻ�Խ����.һ����˵������100000�Ļ����ǱȽϽ�����Ŷ'):format(cmd.getMaidName()))
					end
				)

				local count = 0
				timer.loop(300,
					function()
						count = count + 1

						local handles = {}
						for i = 1, 10 do
							handles[i] = jass.Location(0, 0)
						end
						cmd.handle_data[count] = math.max(unpack(handles)) - 1000000
						for i = 1, 10 do
							jass.RemoveLocation(handles[i])
						end
						print(('\n\n%s:����,��Ϸ�Ѿ���ȥ[%d]������Ŷ,�Ҳ�����һ��������Ϸ����[%d]������'):format(cmd.getMaidName(), count * 5, cmd.handle_data[count]))
						timer.wait(2,
							function()
								print(('%s:�����5������,��Ϸ�е�����������[%d]��,ƽ��ÿ������[%.2f]��!'):format(cmd.getMaidName(), cmd.handle_data[count] - cmd.handle_data[count - 1], (cmd.handle_data[count] - cmd.handle_data[count - 1]) / 300))

								if count > 1 then
									timer.wait(2,
										function()
											print(('%s:����Ϸ��ʼ��ʱ�����,��Ϸ�е�����������[%d]��,ƽ��ÿ������[%.2f]��!'):format(cmd.getMaidName(), cmd.handle_data[count] - cmd.handle_data[0], (cmd.handle_data[count] - cmd.handle_data[0]) / (count * 300)))
										end
									)
								end
							end
						)
						
					end
				)
				
			end
		)
	end

	--��¼�汾��
	function cmd.set_ver_name(_, s)
		cmd.ver_name = s
	end