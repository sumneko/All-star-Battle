    game = {}
    
    local game = game
    
    function game.heros()
        return jass[game.jHero]
    end
    
    function game.self()
        return game.heros()[player.self:get()]
    end
    
    function game.init()
        game.jHero = 'udg_player'
    end
    
    game.init()
    
