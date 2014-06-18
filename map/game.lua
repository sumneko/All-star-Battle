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
    
