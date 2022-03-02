if GameSetup == nil then
  GameSetup = class({})
end

--nil will not force a hero selection
local forceHero = nil--"shredder"

local test_on = false --manually turn it on or off


function GameSetup:ready()

    local GameMode = GameRules:GetGameModeEntity()
    GameMode:SetFreeCourierModeEnabled(true)

    --Selection and PenaltyTime
    GameRules:SetHeroSelectionTime(60)
    GameRules:SetHeroSelectPenaltyTime(30)


    --force single hero selection (optional)
    if not forceHero == false then
      GameMode:SetCustomGameForceHero(forceHero)
    end

    --listen to game state event
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnChangedGameState"), self)
    CustomGameEventManager:RegisterListener("update_server_of_the_player_pick_path", Dynamic_Wrap(self, "OnPlayerPickPathSave"))
    


    if IsInToolsMode() then  --debug build
        if test_on == false then return end
        --skip all the starting game mode stages e.g picking screen, showcase, etc
        GameRules:EnableCustomGameSetupAutoLaunch(true)
        GameRules:SetCustomGameSetupAutoLaunchDelay(0)
        GameRules:SetHeroSelectionTime(10)
        GameRules:SetStrategyTime(0)
        GameRules:SetPreGameTime(0)
        GameRules:SetShowcaseTime(0)
        GameRules:SetPostGameTime(5)
        GameRules:SetStartingGold(69420)

        --disable some setting which are annoying then testing

        GameMode:SetAnnouncerDisabled(true)
        GameMode:SetKillingSpreeAnnouncerDisabled(true)
        GameMode:SetDaynightCycleDisabled(true)
        GameMode:DisableHudFlip(true)
        GameMode:SetDeathOverlayDisabled(true)
        GameMode:SetWeatherEffectsDisabled(true)

        --disable music events
        GameRules:SetCustomGameAllowHeroPickMusic(false)
        GameRules:SetCustomGameAllowMusicAtGameStart(false)
        GameRules:SetCustomGameAllowBattleMusic(false)

        --multiple players can pick the same hero
        GameRules:SetSameHeroSelectionEnabled(true)

    end

end


-----------------------------------------------------------
--EVENTS
-----------------------------------------------------------

function GameSetup:OnChangedGameState()

  --random hero once we reach strategy phase
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        local maxPlayers = 5
        for teamNum = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
            for i=1, maxPlayers do
                local playerID = PlayerResource:GetNthPlayerIDOnTeam(teamNum, i)
                if playerID ~= -1 then
                    if not PlayerResource:HasSelectedHero(playerID) then
                        local hPlayer = PlayerResource:GetPlayer(playerID)
                        if hPlayer ~= nil then
                          hPlayer:MakeRandomHeroSelection()
                        end
                    end
                end
            end
        end
    end


    --add test rubick
    if test_on == false then return end



    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        local maxPlayers = 5
        for teamNum = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
            for i=1, maxPlayers do
                local playerID = PlayerResource:GetNthPlayerIDOnTeam(teamNum, i)
                if playerID ~= -1 then
                    local hPlayer = PlayerResource:GetPlayer(playerID)
                    local enemy_dummy = CreateUnitByName(
                        "npc_dota_hero_rubick",
                        Vector(-5045.713867, -6574.284668, 256.000000),
                        true,
                        hPlayer,
                        hPlayer,
                        DOTA_TEAM_BADGUYS
                    )
                    enemy_dummy:SetControllableByPlayer(playerID,true)
                    enemy_dummy:AddItemByName("item_tome_of_knowledge")
                    enemy_dummy:AddItemByName("item_black_king_bar")
                    enemy_dummy:AddItemByName("item_lotus_orb")
                    enemy_dummy:AddItemByName("item_sphere")
                    enemy_dummy:AddItemByName("item_ultimate_scepter")
                    enemy_dummy:AddItemByName("item_ethereal_blade")
                    break
                end
            end
        end
    end
end





function GameSetup:OnPlayerPickPathSave(args)
    print(args)
    if args.PlayerID == -1 then return end

    local cdotaplayer = PlayerResource:GetPlayer(args.PlayerID)

    local hero_string = args.HeroString

    cdotaplayer:SetSelectedHero(hero_string)



    --local lock_in = "" --npc_dota_hero_name
    --local chosen_path = 0 --original dota hero = 0, alternate universe = 1..



end
