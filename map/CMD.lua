	cmd = {}

	--�洢�Ѿ��㱨���Ĵ���
	cmd.errors = {}

	--����print
	cmd.print = print

	cmd.text_print = {}
	
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

	--cmdָ��ӿ�
	function cmd.start()
		cmd[jass.GetPlayerName(jass.Player(12)):sub(2)](player.j_player(jass.Lua_player))
	end

	--��ʼ��
	function cmd.main()
		cmd.maid_name()
		cmd.hello_world()
		cmd.check_error()
		cmd.check_handles()
	end

	--��ȡŮ������
	cmd.maidNames = {
		{'�ܸɵİ�˿����Ů��'},
		{'�ܸɵĺ�˿����Ů��'},
	}

	cmd.maidNames[1][2] = '能干的白丝萝莉女仆'
	cmd.maidNames[2][2] = '能干的黑丝萝莉女仆'
		
	function cmd.maid_name()
		for i = 0, 11 do
			local name = cmd.maidNames[jass.GetRandomInt(1, #cmd.maidNames)]
			if jass.Player(i) == jass.GetLocalPlayer() then
				cmd.maidNames[0] = name
			end
		end
	end

	function cmd.getMaidName(utf8)
		return cmd.maidNames[0][utf8 and 2 or 1]
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