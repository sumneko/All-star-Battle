local file_dir
local test_dir

local function git_fresh(fname)
	local r, w = 'rb', 'wb'
	if fname:sub(-2) == '.j' or fname:sub(-4) == '.lua' then
		r, w = 'r', 'w'
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
		print('[�ɹ�]: ���� ' .. fname)
	end
end

local function main()

	--������ arg[1]Ϊ��ͼ, arg[2]Ϊ����·��
	local flag_newmap
	
	if (not arg) or (#arg < 2) then
		flag_newmap = true
	end
	
	local input_map  = flag_newmap and (arg[1] .. 'build\\map.w3x') or arg[1]
	local root_dir   = flag_newmap and arg[1] or arg[2]
	
	--���require��Ѱ·��
	package.path = package.path .. ';' .. root_dir .. 'src\\?.lua'
	package.cpath = package.cpath .. ';' .. root_dir .. 'build\\?.dll'
	require 'luabind'
	require 'filesystem'
	require 'utility'

	--����·��
	git_path = root_dir
	local input_map    = fs.path(input_map)
	local root_dir     = fs.path(root_dir)
	file_dir           = root_dir / 'map'
	
	fs.create_directories(root_dir / 'test')

	test_dir           = root_dir / 'test'
	local output_map   = test_dir / input_map:filename():string()
	
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
					if name ~= '(map_head)' then
						--���ļ���������files��
						table.insert(files, name)
					end
				end
			end
		end

		dir_scan(file_dir)

		--�����µ�listfile
		fname = '(listfile)'
		local listfile_path = test_dir / fname
		local listfile = io.open(listfile_path:string(), 'w')
		listfile:write(table.concat(files, '\n') .. "\n")
		listfile:close()
		git_fresh(fname)

		local map_dir = root_dir / 'build' / 'map.w3x'
		local new_dir = root_dir / 'output' / 'map.w3x'

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

		for _, name in ipairs(files) do
			if inmap:import(name, file_dir / name) then
				print('[�ɹ�]: ���� ' .. name)
			else
				print('[ʧ��]: ���� ' .. name)
			end
		end

		inmap:close()

	end
	
	print('[���]: ��ʱ ' .. os.clock() .. ' ��') 

end

main()