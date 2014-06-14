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
    
