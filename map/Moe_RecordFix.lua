 
    --分割字符串
    string.split = function(str, tos)
        local x = 1
        local strl = string.len(str)
        local tosl = string.len(tos)
        local strs = {}
        for y = 1, strl do
            if string.sub(str, y, y+tosl-1) == tos then
                table.insert(strs, string.sub(str, x, y-1))
                x = y + tosl
            end
        end
        if strl >= x then
            table.insert(strs, string.sub(str, x, strl))
        end
        return strs
    end

    --连接字符串
    string.concat = function(t, cs)
        cs = cs or ""
        rs = ""
        for _,s in ipairs(t) do
            if rs == "" then
                rs = rs .. s
            else
                rs = rs .. cs .. s
            end
        end
        return rs
    end
    
    setmetatable(_G, { __index = jass })
    
    print = function(i, s)
        if s then
            DisplayTimedTextToPlayer(Player(i), 0, 0, 60, s)
        else
            DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, i)
        end
    end

    local hash = function(t)
        local r = 1
        for i, v in ipairs(t) do
            r = (v*r+r*i)%7619149571
        end
        return r
    end

    local nameHash = function(v)
        local r = {}
        local l = string.len(v)
        for i = 1, l do
            local c = string.sub(v, i, i)
            table.insert(r, string.byte(c))
        end
        return hash(r)
    end

    local ks = "校验,杀敌,助攻,经验,荣誉,MVP,局数,助攻王,战神,胜率"
    local name = {}
    local trg = CreateTrigger()
    for i = 0, 11 do
        name[i] = GetPlayerName(Player(i))
        TriggerRegisterPlayerChatEvent(trg, Player(i), "run ", false)
    end
    TriggerAddCondition(trg, Condition(
        function()
            if LoadBoolean(Lua_HT, 0, 0) then return end
            local s = string.sub(GetEventPlayerChatString(), 5)
            local i = GetPlayerId(GetTriggerPlayer())
            if LoadInteger(Lua_HT, i, Lua_rf) >= 1 then
                print(i, "你已经恢复过积分了")
                return
            end
            local k = string.split(ks, ",")
            local v = string.split(s, ",")
            for j, key in ipairs(k) do
                if key == "校验" then
                    local h = v[1]
                    v[1] = nameHash(name[i])
                    local hash = hash(v)
                    if math.floor(hash) ~= math.floor(h) then
                        print(i, "积分校验失败,请确认输入")
                        return
                    end
                else
                    print(i, string.format("(%s, %s, %s)", i, key, v[j]))
                    SaveStr(Lua_HT, Lua_key, j, key)
                    SaveInteger(Lua_HT, Lua_value, j, v[j])
                end
            end
            SaveBoolean(Lua_HT, 0, 0, true)
            print(i, "积分恢复成功")
            SaveInteger(Lua_HT, i, Lua_rf, 1 + LoadInteger(Lua_HT, i, Lua_rf))
            SaveInteger(Lua_HT, 0, 0, i)
            TimerStart(Lua_timer, 0, false, nil)
        end
    ))
