local file_dir
local test_dir

local zip_files = {
	['war3map.j'] = true,
	['war3map.wtg'] = true,
	['war3map.wts'] = true,
	['war3map.w3a'] = true,
	['war3map.wpm'] = true,
	['war3map.shd'] = true,
	['war3map.w3u'] = true,
	['war3map.doo'] = true,
	['War3MapPreview.tga'] = true,
	['war3map.wct'] = true,
	['war3map.w3e'] = true
}

local imp_ignore = {
	['Tsukiko.mdx'] = true,
	['war3map.j'] = true,
	['war3map.doo'] = true,
	['war3map.imp'] = true,
	['war3map.mmp'] = true,
	['war3map.shd'] = true,
	['war3map.w3a'] = true,
	['war3map.w3b'] = true,
	['war3map.w3c'] = true,
	['war3map.w3d'] = true,
	['war3map.w3e'] = true,
	['war3map.w3h'] = true,
	['war3map.w3i'] = true,
	['war3map.w3q'] = true,
	['war3map.w3r'] = true,
	['war3map.w3s'] = true,
	['war3map.w3t'] = true,
	['war3map.w3u'] = true,
	['war3map.wct'] = true,
	['war3map.wpm'] = true,
	['war3map.wtg'] = true,
	['war3map.wts'] = true,
	['war3mapExtra.txt'] = true,
	['war3mapMap.blp'] = true,
	['war3mapMisc.txt'] = true,
	['war3mapSkin.txt'] = true,
	['war3mapUnits.doo'] = true,
}

local ext_ignore = {
	['11record.txt'] = true,
}

local function git_fresh(fname)
	if ext_ignore[fname] or fname:sub(-4) == '.lua' then
		return
	end
	
	local r, w = 'rb', 'wb'
	if fname:sub(-2) == '.j' then
		r, w = 'r', 'w'
	end
	if zip_files[fname] then
		fs.remove(file_dir / fname)
		os.execute(('%s\\unrar x -o+ -inul %s %s %s'):format((root_dir / 'build'):string(), (file_dir / fname):string() .. '.zip', fname, file_dir:string()))
	end
	local f = io.open((test_dir / fname):string(), r)
	local test_file = f:read('*a')
	f:close()
	local map_file
	f = io.open((file_dir / fname):string(), r)
	if f then
		map_file = f:read('*a')
		f:close()
	end
	if test_file ~= map_file then
		
		f = io.open((file_dir / fname):string(), w)
		f:write(test_file)
		f:close()
		if zip_files[fname] then
			os.execute(('%s\\rar a -ep -inul %s %s'):format((root_dir / 'build'):string(), (file_dir / fname):string() .. '.zip', (file_dir / fname):string(), fname))
		end
		print('[�ɹ�]: ���� ' .. fname)
	end
	if zip_files[fname] then
		fs.remove(file_dir / fname)
	end
end

local function main()

	--������ arg[1]Ϊ��ͼ, arg[2]Ϊ����·��
	local flag_newmap
	
	if (not arg) or (#arg < 2) then
		flag_newmap = true
	end
	
	input_map  = flag_newmap and (arg[1] .. 'build\\map.w3x') or arg[1]
	root_dir   = flag_newmap and arg[1] or arg[2]
	
	--���require��Ѱ·��
	package.path = package.path .. ';' .. root_dir .. 'src\\?.lua'
	package.cpath = package.cpath .. ';' .. root_dir .. 'build\\?.dll'
	require 'luabind'
	require 'filesystem'
	require 'utility'

	--����·��
	git_path = root_dir
	input_map    = fs.path(input_map)
	root_dir     = fs.path(root_dir)
	file_dir           = root_dir / 'map'
	
	fs.create_directories(root_dir / 'test')

	test_dir           = root_dir / 'test'
	output_map   = test_dir / input_map:filename():string()
	
	local fname

	if not flag_newmap then
		--����һ�ݵ�ͼ
		pcall(fs.copy_file, input_map, output_map, true)

		--������ͼͷ
		local map_f = io.open(output_map:string(), 'rb')
		if map_f then
			print('[�ɹ�]: �� ' .. input_map:string())
			local head = map_f:read('*a'):match('(HM3W.-MPQ)')
			map_f:close()
			local head_f = io.open((test_dir / '(map_head)'):string(), 'wb')
			head_f:write(head)
			head_f:close()
			git_fresh('(map_head)')
		else
			print('[ʧ��]: �� ' .. input_map:string())
			return
		end

		--�����ͼ����
		local map_name = output_map:filename():string()
		local map_name_f = io.open((test_dir / '(map_name)'):string(), 'wb')
		map_name_f:write(map_name)
		map_name_f:close()
		git_fresh('(map_name)')

		--�򿪵�ͼ
		local inmap = mpq_open(output_map)
		if inmap then
			print('[�ɹ�]: �� ' .. input_map:string())
		else
			print('[ʧ��]: �� ' .. input_map:string())
			return
		end
		
		--����listfile
		fname = '(listfile)'
		if inmap:extract(fname, test_dir / fname) then
			print('[�ɹ�]: ���� ' .. fname)
		else
			print('[ʧ��]: ���� ' .. fname)
			return
		end

		--��listfile	
		for line in io.lines((test_dir / fname):string()) do
			--����������listfile���оٵ�ÿһ���ļ�
			local dir = fs.path(test_dir:string() .. '\\' .. line)
			local map_dir = fs.path(file_dir:string() .. '\\' .. line)
			local dir_par = dir:parent_path()
			local map_dir_par = map_dir:parent_path()
			fs.create_directories(dir_par)
			fs.create_directories(map_dir_par)
			if inmap:extract(line, dir) then
				--print('[�ɹ�]: ���� ' .. line)
				git_fresh(line)
			else
				print('[ʧ��]: ���� ' .. line)
				return
			end
		end
		
		inmap:close()
	else
		--����dir�µ������ļ�,�����ͼ
		local files = {}

		local path_len = #file_dir:string() + 2
		
		local function dir_scan(dir)
			for full_path in dir:list_directory() do
				if fs.is_directory(full_path) then
					-- �ݹ鴦��
					dir_scan(full_path)
				else
					local name = full_path:string():sub(path_len)
					if name:sub(1, 1) ~= '(' and not zip_files[name] then
						--���ļ���������files��
						if name:sub(-4, -1) == '.zip' then
							name = name:sub(1, -5)
						end
						table.insert(files, name)
					end
				end
			end
		end

		dir_scan(file_dir)

		--�����µ�war3map.imp
		fname = 'war3map.imp'
		local file_path = test_dir / fname
		local file = io.open(file_path:string(), 'wb')
		local imp = {}
		for i, v in ipairs(files) do
			if not imp_ignore[v] then
				table.insert(imp, v)
			end
		end
		
		local fcount = #imp
		file:write(string.char(1, 0, 0, 0, fcount % 256, math.floor(fcount / 256), 0, 0, 0x0D) .. table.concat(imp, string.char(0, 13)) .. string.char(0))
		file:close()
		git_fresh(fname)

		local map_dir = root_dir / 'build' / 'map.w3x'

		--��ȡ��ͼ����
		local map_name_f = io.open((file_dir / '(map_name)'):string(), 'rb')
		local map_name = map_name_f:read('*a')
		map_name_f:close()

		--����봴��Ŀ¼
		fs.create_directories(root_dir / 'output')
		
		local new_dir = root_dir / 'output' / map_name

		--��ģ���ͼ���Ƶ�output·��
		pcall(fs.copy_file, map_dir, new_dir, true)
		
		--�޸��ļ�ͷ
		local head_f = io.open((file_dir / '(map_head)'):string(), 'rb')
		local head_hex = head_f:read('*a')
		head_f:close()
		
		local map_f = io.open(new_dir:string(), 'rb')
		local map_hex = map_f:read('*a'):gsub('HM3W.-MPQ', head_hex)
		map_f:close()

		local map_f = io.open(new_dir:string(), 'wb')
		if not map_f then
			print '[����]: ��ͼ�ļ���ռ��,�Ȱѱ༭���ص��ٴ����ͼ������!'
			return
		end
		map_f:write(map_hex)
		map_f:close()

		--���ļ�ȫ�������ȥ
		local inmap = mpq_open(new_dir)

		if inmap then
			print('[�ɹ�]: �� ' .. new_dir:string())
		else
			print('[ʧ��]: �� ' .. new_dir:string())
			return
		end

		local count = 0
		local fail_files = {}
		for _, name in ipairs(files) do
			if zip_files[name] then
				os.execute(('%s\\unrar x -o+ -inul %s %s %s'):format((root_dir / 'build'):string(), (file_dir / name):string() .. '.zip', name, file_dir:string()))
				if inmap:import(name, file_dir / name) then
					--print('[�ɹ�]: ���� ' .. name)
					count = count + 1
				else
					print('[ʧ��]: ���� ' .. name)
					table.insert(fail_files, name)
				end
				fs.remove(file_dir / name)
			else
				if inmap:import(name, file_dir / name) then
					--print('[�ɹ�]: ���� ' .. name)
					count = count + 1
				else
					print('[ʧ��]: ���� ' .. name)
					table.insert(fail_files, name)
				end
			end
			
		end

		inmap:close()

		print('[�ɹ�]: һ�������� ' .. count .. ' ���ļ�')
		if #fail_files > 0 then
			print(('[����]: ���� %s ���ļ�����ʧ��!!!'):format(#fail_files))
		end

		--��ȡ������ini�ļ�
		local config_dir = root_dir / 'config.ini'
		if not fs.exists(config_dir) then
			local f = io.open(config_dir:string(), 'wb')
			local lines = {}
			table.insert(lines, 'ver = 1.0')
			table.insert(lines, 'YDWE = D:\\ħ������III\\YDWE1.27.5���԰�(ȫ����)')
			f:write(table.concat(lines, '\n'))
			f:close()
		end

		local f = io.open(config_dir:string(), 'rb')
		local ini = f:read('*a')
		for name, value in ini:gmatch('(%C-) = (%C+)') do
			if name == 'YDWE' then
				local path_len = #(root_dir / 'YDWE'):string() + 2
				local ydwe_dir = fs.path(value)
				if fs.exists(ydwe_dir) then
					local function dir_scan(dir)
						for full_path in dir:list_directory() do
							if fs.is_directory(full_path) then
								-- �ݹ鴦��
								dir_scan(full_path)
							else
								local path = full_path:string():sub(path_len)
								local yd_path = ydwe_dir / path
								local f1 = io.open(full_path:string(), 'rb')
								local con1 = f1:read('*a')
								local f2 = io.open(yd_path:string(), 'rb')
								local con2 = f2:read('*a')
								f1:close()
								f2:close()
								if con1 ~= con2 then
									fs.copy_file(full_path, yd_path, true)
									print('[����]: ' .. yd_path:string())
								end
							end
						end
					end
					dir_scan(root_dir / 'YDWE')
				else
					print('[����]: YDWE·��������!���޸�config.ini')
				end
			end
		end

	end
	
	print('[���]: ��ʱ ' .. os.clock() .. ' ��') 

end

main()