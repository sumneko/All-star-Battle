    
    jass.hasLua = true
    
    cmd.main()
    
    timer.wait(5,
        function()
    
            local name = jass.GetPlayerName(jass.Player(12))
            
            jass.SetPlayerName(jass.Player(12), '|cffff1111小神|r')
            japi.EXDisplayChat(jass.Player(12), 0, '                                                                   |cFFFFFF00全明星战役2.6F正式版|r')
            
            jass.SetPlayerName(jass.Player(12), '|cffffff11幻雷|r')
            japi.EXDisplayChat(jass.Player(12), 0, '                                                                   |cFFFF6600作者：小神 幻雷 最萌小汐 裂魂|r')
            
            jass.SetPlayerName(jass.Player(12), '|cffff11cc小汐|r')
            japi.EXDisplayChat(jass.Player(12), 0, '                                                                   |cFF00CCFF感谢玩家s芙兰朵露z和东风谷早面对本地图的支持！|r')
            
            jass.SetPlayerName(jass.Player(12), '|cff11ffff裂魂|r')
            japi.EXDisplayChat(jass.Player(12), 0, '                                                                   |cFFFFFF00游戏指令.更新内容.游戏专房请查看F9|r')
            
            jass.SetPlayerName(jass.Player(12), name)
        end
    )
    
    pcall(require, 'MoeUshio\\All-Star-Battle\\init.lua')
    
