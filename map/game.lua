    game = {}
    
    local game = game
    
    game.heroes = {}
    
    function game.initHero(u)
        table.insert(game.heroes, u)
        if jass.GetOwningPlayer(u) == jass.GetLocalPlayer() then
            game.selfHero = u
        end
    end
    
    function game.self()
        return game.selfHero
    end
    
    function hook.UnitWakeUp(u, f)
        game.initHero(u)
    end
    
    function hook.SetUnitRescueRange(u, r, f)
        if jass.GetUnitTypeId(u) == 0 then
            return
        end
        if r < 0 then
            game[math.floor(0 - r)](u)
        else
            return f(u, r)
        end
    end
    
    --重力移动冷却2秒
    game[1] = function(u)
        local ab = japi.EXGetUnitAbility(u, |A0II|)
        local lv = jass.GetUnitAbilityLevel(u, |A0II|)
        japi.EXSetAbilityDataReal(ab, lv, 105, 2)
        japi.EXSetAbilityState(ab, 1, 2)
        japi.EXSetAbilityDataReal(ab, lv, 105, 0)
    end
    
    --重力移动冷却1秒
    game[2] = function(u)
        local ab = japi.EXGetUnitAbility(u, |A0II|)
        local lv = jass.GetUnitAbilityLevel(u, |A0II|)
        japi.EXSetAbilityDataReal(ab, lv, 105, 1)
        japi.EXSetAbilityState(ab, 1, 1)
        japi.EXSetAbilityDataReal(ab, lv, 105, 0)
    end
    
    --技能耗蓝增加50%
    game.table_3 = {}
    game.table_4 = {
        [|A0PX|] = true,
        [|A0PZ|] = true,
        [|A0Q0|] = true,
        [|A0Q1|] = true,
    }
    
    game[3] = function(u)
        local data = {}
        local t = timer.loop(0.1, true,
            function()
                for i = 0, 99 do
                    local ab = japi.EXGetUnitAbilityByIndex(u, i)
                    if ab == 0 then
                        return
                    end
                    local id = japi.EXGetAbilityId(ab)
                    local lv = jass.GetUnitAbilityLevel(u, id)
                    local mp = japi.EXGetAbilityDataInteger(ab, lv, 104)
                    if mp > 0 and game.table_4[id] then
                        if data[id] then
                            mp = mp - (data[id][lv] or 0)
                        end
                        data[id] = {}
                        data[id][lv] = math.floor(mp * 0.5)
                        mp = mp + data[id][lv]
                        japi.EXSetAbilityDataInteger(ab, lv, 104, mp)
                    end
                end
            end
        )
        game.table_3[u] = {t, data}
    end
    
    game[4] = function(u)
        if not game.table_3[u] then
            return
        end
        local t = game.table_3[u][1]
        local data = game.table_3[u][2]
        t:destroy()
        for i = 0, 99 do
            local ab = japi.EXGetUnitAbilityByIndex(u, i)
            if ab == 0 then
                return
            end
            local id = japi.EXGetAbilityId(ab)
            local lv = jass.GetUnitAbilityLevel(u, id)
            local mp = japi.EXGetAbilityDataInteger(ab, lv, 104)
            if mp > 0 and game.table_4[id] then
                if data[id] then
                    mp = mp - (data[id][lv] or 0)
                end
                japi.EXSetAbilityDataInteger(ab, lv, 104, mp)
            end
        end
    end
    
    game[5] = function(u)
        local name = jass.GetPlayerName(jass.Player(12))
        local p = jass.GetOwningPlayer(u)
    
        jass.SetPlayerName(jass.Player(12), '阎魔爱')
        if p == jass.GetLocalPlayer() then
            japi.EXDisplayChat(jass.Player(12), 3, '|cff505050充满罪恶的灵魂、想死一遍看看吗？|r')
        end
        
        jass.SetPlayerName(jass.Player(12), name)
    end
    
