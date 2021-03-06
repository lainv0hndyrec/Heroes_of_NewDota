if HeroAlternativePath == nil then
  HeroAlternativePath = class({})
end

---------------------------------------------------------------
----------------------HELPER FUNCTIONS--------------------
---------------------------------------------------------------

function HeroAlternativePath:RemoveOriginalAbilities(the_hero)
    --remove abilities
    for i=0,16 do
        local remove_ability = the_hero:GetAbilityByIndex(i)
        if remove_ability:GetName() == "special_bonus_attributes" then
            break
        end
        the_hero:RemoveAbilityByHandle(remove_ability)
    end
end


function HeroAlternativePath:RemoveAllTalentModifiers(the_hero)
    --remove the talent modifiers
    local talent_mods = the_hero:FindAllModifiers()
    for i = 1, #talent_mods do
        talent_mods[i]:Destroy()
    end

    --Illusion Correction
    the_hero:AddAbility("lua_ability_generic_illusion_correction")
end






---------------------------------------------------------------
----------------------MAIN FUNCTION---------------------------
---------------------------------------------------------------
function HeroAlternativePath:Initialize(hero_string,hero_path,hero_list)

    local the_hero = nil

    for i=1, #hero_list do
        if hero_list[i]:GetName() == hero_string then
            the_hero = hero_list[i]
            break
        end
    end

    --check if the hero exist and if its original
    if not the_hero then return end


    if hero_string == "npc_dota_hero_terrorblade" then
        self:Path_Terrorblade(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_grimstroke" then
        self:Path_Grimstroke(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_enigma" then
        self:Path_Enigma(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_phantom_lancer" then
        self:Path_Phantom_Lancer(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_shredder" then
        self:Path_Shredder(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_razor" then
        self:Path_Razor(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_monkey_king" then
        self:Path_MonkeyKing(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_life_stealer" then
        self:Path_LifeStealer(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_bounty_hunter" then
        self:Path_BountyHunter(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_brewmaster" then
        self:Path_Brewmaster(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_doom_bringer" then
        self:Path_DoomBringer(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_night_stalker" then
        self:Path_NightStlaker(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_necrolyte" then
        self:Path_Necrolyte(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_oracle" then
        self:Path_Oracle(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_lone_druid" then
        self:Path_LoneDruid(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_death_prophet" then
        self:Path_DeathProphet(hero_string,hero_path,the_hero)
        return
    end

    if hero_string == "npc_dota_hero_tiny" then
        self:Path_Tiny(hero_string,hero_path,the_hero)
        return
    end

end




---------------------------------------------------------------
----------------------ALTERNATE HERO PATH--------------------
---------------------------------------------------------------

function HeroAlternativePath:Path_Terrorblade(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_corruptedlord_throw_glaive")
        the_hero:AddAbility("lua_ability_corruptedlord_duality_chaos")
        the_hero:AddAbility("lua_ability_corruptedlord_duality_solace")
        the_hero:AddAbility("lua_ability_corruptedlord_throw_glaive_blink")
        the_hero:AddAbility("lua_ability_corruptedlord_demonic_scars")
        the_hero:AddAbility("lua_ability_corruptedlord_unleashed")
        the_hero:AddAbility("special_bonus_corruptedlord_throw_glaive_reduce_cd")
        the_hero:AddAbility("special_bonus_evasion_16")
        the_hero:AddAbility("special_bonus_hp_275")
        the_hero:AddAbility("special_bonus_attack_speed_30")
        the_hero:AddAbility("special_bonus_all_stats_8")
        the_hero:AddAbility("special_bonus_corruptedlord_unleashed_armor_duration")
        the_hero:AddAbility("special_bonus_corruptedlord_unleashed_cooldown")
        the_hero:AddAbility("special_bonus_corruptedlord_throw_glaive_blink_fear")
        self:RemoveAllTalentModifiers(the_hero)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(29)
        the_hero:SetBaseDamageMax(35)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-2)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.50

        --Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
        the_hero:SetBaseStrength(20)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 3.5

        the_hero:SetBaseAgility(15)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.5

        the_hero:SetBaseIntellect(18)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.7

        the_hero:CalculateStatBonus(true)

        local title = "CORRUPTED LORD"
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_corruptedlord_throw_glaive"}
        info["scepter"] = {"lua_ability_corruptedlord_unleashed"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)



    end
end


function HeroAlternativePath:Path_Grimstroke(hero_string,hero_path,the_hero)
    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_kalligromancer_captivate")
        the_hero:AddAbility("lua_ability_kalligromancer_stroked_inspiration")
        the_hero:AddAbility("lua_ability_kalligromancer_heavy_blot")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_kalligromancer_death_portrait")
        the_hero:AddAbility("special_bonus_movement_speed_20")
        the_hero:AddAbility("special_bonus_kalligromancer_captivate_plus_duration")
        the_hero:AddAbility("special_bonus_attack_speed_25")
        the_hero:AddAbility("special_bonus_kalligromancer_heavy_blot_aoe_range")
        the_hero:AddAbility("special_bonus_hp_400")
        the_hero:AddAbility("special_bonus_kalligromancer_stroked_inspiration_minus_cd")
        the_hero:AddAbility("special_bonus_kalligromancer_heavy_blot_aoe_plus_crit")
        the_hero:AddAbility("special_bonus_kalligromancer_stroked_inspiration_plus_damage")
        self:RemoveAllTalentModifiers(the_hero)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(27)
        the_hero:SetBaseDamageMax(35)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(295)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-0.5)

        --HP regen
        the_hero:SetBaseHealthRegen(0.25)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.40

        --Attack projectile Speed
        local proj_speed = the_hero:AddAbility("lua_ability_generic_change_projectile_speed")
        proj_speed.Projectile_Speed = 1125

        --MAIN STATS
        the_hero:SetBaseStrength(18)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 1.9

        the_hero:SetBaseAgility(20)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.0

        the_hero:SetBaseIntellect(21)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 3.1

        the_hero:CalculateStatBonus(true)

        local title = {"KALIGROMANCER"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_kalligromancer_captivate"}
        info["scepter"] = {"lua_ability_kalligromancer_death_portrait"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_Enigma(hero_string,hero_path,the_hero)

    --unfathomed
    if hero_path == 1 then
        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_unfathomed_overwhelming_presence")
        the_hero:AddAbility("lua_ability_unfathomed_yield")
        the_hero:AddAbility("lua_ability_unfathomed_ethereal_order")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_unfathomed_spatial_manipulation")

        the_hero:AddAbility("special_bonus_armor_5")
        the_hero:AddAbility("special_bonus_mp_regen_2")

        the_hero:AddAbility("special_bonus_attack_speed_30")
        the_hero:AddAbility("special_bonus_unfathomed_ethereal_order_range")

        the_hero:AddAbility("special_bonus_strength_20")
        the_hero:AddAbility("special_bonus_unfathomed_overwhelming_presence_range")

        the_hero:AddAbility("special_bonus_unfathomed_overwhelming_presence_effect")
        the_hero:AddAbility("special_bonus_unfathomed_yield_range")
        self:RemoveAllTalentModifiers(the_hero)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(30)
        the_hero:SetBaseDamageMax(33)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(295)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-0.4)

        --HP regen
        the_hero:SetBaseHealthRegen(0.25)

        --Attack projectile Speed
        local proj_speed = the_hero:AddAbility("lua_ability_generic_change_projectile_speed")
        proj_speed.Projectile_Speed = 1100

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.40


        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
        the_hero:SetBaseStrength(23)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 3.5

        the_hero:SetBaseAgility(21)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2

        the_hero:SetBaseIntellect(18)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.4

        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 400

        the_hero:CalculateStatBonus(true)

        local title = {"UNFATHOMED"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_unfathomed_yield"}
        info["scepter"] = {"lua_ability_unfathomed_spatial_manipulation"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)

    end
end


function HeroAlternativePath:Path_Phantom_Lancer(hero_string,hero_path,the_hero)
    --vagabond
    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_vagabond_prismatic_mist")
        the_hero:AddAbility("lua_ability_vagabond_phantom_charge")
        the_hero:AddAbility("lua_ability_vagabond_phantom_charge_fragment")
        the_hero:AddAbility("lua_ability_vagabond_outcasts_strike")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_vagabond_death_light")
        the_hero:AddAbility("special_bonus_hp_150")
        the_hero:AddAbility("special_bonus_attack_speed_15")
        the_hero:AddAbility("special_bonus_evasion_16")
        the_hero:AddAbility("special_bonus_vagabond_prismatic_mist_duration")
        the_hero:AddAbility("special_bonus_vagabond_phantom_charge_range")
        the_hero:AddAbility("special_bonus_vagabond_phantom_death_light_damage")
        the_hero:AddAbility("special_bonus_vagabond_phantom_charge_cd_reduction")
        the_hero:AddAbility("special_bonus_vagabond_phantom_outcasts_strike_max_crit")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(32)
        the_hero:SetBaseDamageMax(36)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-1.1)

        --HP regen
        the_hero:SetBaseHealthRegen(1)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.33

        --Set Stats
        the_hero:SetBaseStrength(18)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.0

        the_hero:SetBaseAgility(22)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 3.0

        the_hero:SetBaseIntellect(20)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.2

        the_hero:CalculateStatBonus(true)


        local title = {"VAGABOND"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_vagabond_phantom_charge"}
        info["scepter"] = {"lua_ability_vagabond_prismatic_mist"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)


        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)

    end
end


function HeroAlternativePath:Path_Shredder(hero_string,hero_path,the_hero)
    --whistlepunk
    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_whistlepunk_rockets")
        the_hero:AddAbility("lua_ability_whistlepunk_oil_spill")
        the_hero:AddAbility("lua_ability_whistlepunk_steam_barrier")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_whistlepunk_sawprise")

        the_hero:AddAbility("special_bonus_mp_regen_150")
        the_hero:AddAbility("special_bonus_hp_200")

        the_hero:AddAbility("special_bonus_spell_amplify_8")
        the_hero:AddAbility("special_bonus_whistlepunk_oil_spill_slow_duration")

        the_hero:AddAbility("special_bonus_intelligence_16")
        the_hero:AddAbility("special_bonus_whistlepunk_oil_spill_slow_amount")

        the_hero:AddAbility("special_bonus_whistlepunk_steam_barrier_purge_heal")
        the_hero:AddAbility("special_bonus_whistlepunk_rockets_add_stacks")
        self:RemoveAllTalentModifiers(the_hero)



        --HP regen
        the_hero:SetBaseHealthRegen(0.25)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(20)
        the_hero:SetBaseDamageMax(27)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(295)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-1)

        --Change to Attack Ranger
        the_hero:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 550

        --Attack Range Effect
        the_hero:SetRangedProjectileName("particles/units/heroes/whisltepunk/projectile/spinning_glaive.vpcf")

        --AttackAcquisitionRange
        the_hero:SetAcquisitionRange(800)

        --Attack projectile Speed
        local proj_speed = the_hero:AddAbility("lua_ability_generic_change_projectile_speed")
        proj_speed.Projectile_Speed = 1500

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.45


        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)
        the_hero:SetBaseStrength(19)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 1.6

        the_hero:SetBaseAgility(20)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.5

        the_hero:SetBaseIntellect(25)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 3.0

        the_hero:CalculateStatBonus(true)


        local title = {"WHISTLEPUNK"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_whistlepunk_rockets"}
        info["scepter"] = {"lua_ability_whistlepunk_sawprise"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_Razor(hero_string,hero_path,the_hero)
    --whistlepunk
    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_soul_warden_restrain")
        the_hero:AddAbility("lua_ability_soul_warden_static_barrier")
        the_hero:AddAbility("lua_ability_soul_warden_ionic_absorption")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_soul_warden_wardens_purge")
        the_hero:AddAbility("special_bonus_mp_regen_150")
        the_hero:AddAbility("special_bonus_soul_warden_restrain_add_range")
        the_hero:AddAbility("special_bonus_soul_warden_static_barrier_damage")
        the_hero:AddAbility("special_bonus_mp_250")
        the_hero:AddAbility("special_bonus_soul_warden_ionic_absorption_range")
        the_hero:AddAbility("special_bonus_spell_lifesteal_15")
        the_hero:AddAbility("special_bonus_attack_speed_80")
        the_hero:AddAbility("special_bonus_soul_warden_ionic_absorption_reduce_cd")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(30)
        the_hero:SetBaseDamageMax(38)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(0.3)


        --Change to Attack Ranger
        the_hero:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 150

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.5

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
        the_hero:SetBaseStrength(23)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.4

        the_hero:SetBaseAgility(13)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.0

        the_hero:SetBaseIntellect(25)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.8

        the_hero:CalculateStatBonus(true)


        local title = {"SOUL WARDEN"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_soul_warden_restrain"}
        info["scepter"] = {"lua_ability_soul_warden_wardens_purge"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_MonkeyKing(hero_string,hero_path,the_hero)
    --whistlepunk
    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_great_sage_flurry_strike")
        the_hero:AddAbility("lua_ability_great_sage_ruyi_jingu_bang")
        the_hero:AddAbility("lua_ability_great_sage_earth_driver")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_great_sage_somersault_cloud")
        the_hero:AddAbility("special_bonus_great_sage_ruyi_jingu_bang_cd_reduction")
        the_hero:AddAbility("special_bonus_great_sage_flurry_strike_freecast_duration")
        the_hero:AddAbility("special_bonus_strength_12")
        the_hero:AddAbility("special_bonus_great_sage_ruyi_jingu_bang_slow_duration")
        the_hero:AddAbility("special_bonus_great_sage_somersault_cloud_ms_bonus")
        the_hero:AddAbility("special_bonus_mp_250")
        the_hero:AddAbility("special_bonus_great_sage_flurry_strike_damage")
        the_hero:AddAbility("special_bonus_hp_475")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(28)
        the_hero:SetBaseDamageMax(34)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(290)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-0.1)


        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 150

        --Change Turn Rate
        local turn_rate = the_hero:AddAbility("lua_ability_generic_change_turn_rate")
        turn_rate.Turn_Rate = 3.1416

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.33

        --Change Stats
        the_hero:SetBaseStrength(20)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.0

        the_hero:SetBaseAgility(20)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.5

        the_hero:SetBaseIntellect(17)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.0

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"GREAT SAGE"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_great_sage_somersault_cloud"}
        info["scepter"] = {"lua_ability_great_sage_earth_driver"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_LifeStealer(hero_string,hero_path,the_hero)
    --whistlepunk
    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_defiler_fetid_slime")
        the_hero:AddAbility("lua_ability_defiler_mimicry")
        the_hero:AddAbility("lua_ability_defiler_defiling_touch")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_defiler_life_grasp")

        the_hero:AddAbility("special_bonus_defiler_fetid_slime_slow_time")
        the_hero:AddAbility("special_bonus_defiler_fetid_slime_damage")
        the_hero:AddAbility("special_bonus_hp_250")
        the_hero:AddAbility("special_bonus_intelligence_10")
        the_hero:AddAbility("special_bonus_lifesteal_15")
        the_hero:AddAbility("special_bonus_attack_damage_30")
        the_hero:AddAbility("special_bonus_defiler_defiling_touch_bonus_dmg")
        the_hero:AddAbility("special_bonus_defiler_defiling_touch_decrease_dmg")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(30)
        the_hero:SetBaseDamageMax(36)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(290)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(0.7)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.5

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)

        the_hero:SetBaseStrength(21)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.6

        the_hero:SetBaseAgility(17)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.7

        the_hero:SetBaseIntellect(20)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.3

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"DEFILER"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_defiler_mimicry"}
        info["scepter"] = {"lua_ability_defiler_mimicry"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_BountyHunter(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_qaldin_assassin_assassins_shroud")
        the_hero:AddAbility("lua_ability_qaldin_assassin_qaldin_eye")
        the_hero:AddAbility("lua_ability_qaldin_assassin_weapon_break")
        the_hero:AddAbility("lua_ability_qaldin_assassin_qaldin_eye_detonate_hero")
        the_hero:AddAbility("lua_ability_qaldin_assassin_snipe_blink")
        the_hero:AddAbility("lua_ability_qaldin_assassin_snipe")

        the_hero:AddAbility("special_bonus_qaldin_assassin_assassins_shroud_minus_mana_per_sec")
        the_hero:AddAbility("special_bonus_mana_break_20")
        the_hero:AddAbility("special_bonus_strength_15")
        the_hero:AddAbility("special_bonus_lifesteal_15")
        the_hero:AddAbility("special_bonus_qaldin_assassin_qaldin_eye_max")
        the_hero:AddAbility("special_bonus_cleave_25")
        the_hero:AddAbility("special_bonus_qaldin_assassin_assassins_shroud_plus_as_times")
        the_hero:AddAbility("special_bonus_qaldin_assassin_weapon_break_crit_up")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(29)
        the_hero:SetBaseDamageMax(33)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(310)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-1)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.4

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)

        the_hero:SetBaseStrength(20)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 1.7

        the_hero:SetBaseAgility(21)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 3.0

        the_hero:SetBaseIntellect(16)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.6

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"QALDIN ASSASSIN"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_qaldin_assassin_snipe","lua_ability_qaldin_assassin_snipe_blink"}
        info["scepter"] = {"lua_ability_qaldin_assassin_snipe"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_Brewmaster(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_spiritsmaster_earth_spirit")
        the_hero:AddAbility("lua_ability_spiritsmaster_fire_spirit")
        the_hero:AddAbility("lua_ability_spiritsmaster_storm_spirit")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_spiritsmaster_drunken_affinity")

        the_hero:AddAbility("special_bonus_spiritsmaster_earth_spirit_slow_up")
        the_hero:AddAbility("special_bonus_spiritsmaster_fire_spirit_speed_up")
        the_hero:AddAbility("special_bonus_attack_speed_15")
        the_hero:AddAbility("special_bonus_spiritsmaster_storm_spirit_atk_range_up")
        the_hero:AddAbility("special_bonus_spiritsmaster_earth_spirit_slow_time_up")
        the_hero:AddAbility("special_bonus_spiritsmaster_storm_spirit_stun_time_up")
        the_hero:AddAbility("special_bonus_spiritsmaster_fire_spirit_steal_up")
        the_hero:AddAbility("special_bonus_hp_475")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(25)
        the_hero:SetBaseDamageMax(28)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(305)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(0.3)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.5

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)

        the_hero:SetBaseStrength(22)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.2

        the_hero:SetBaseAgility(22)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.2

        the_hero:SetBaseIntellect(22)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.2

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"SPIRITSMASTER"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_spiritsmaster_drunken_affinity"}
        info["scepter"] = {
            "lua_ability_spiritsmaster_earth_spirit",
            "lua_ability_spiritsmaster_fire_spirit",
            "lua_ability_spiritsmaster_storm_spirit"
        }
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_DoomBringer(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_fallen_one_revelation")
        the_hero:AddAbility("lua_ability_fallen_one_soul_tap")
        the_hero:AddAbility("lua_ability_fallen_one_sadism")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_fallen_one_eternal_suffering")

        the_hero:AddAbility("special_bonus_magic_resistance_10")
        the_hero:AddAbility("special_bonus_fallen_one_soul_tap_slow_up")
        the_hero:AddAbility("special_bonus_strength_12")
        the_hero:AddAbility("special_bonus_fallen_one_revelation_dmg_up")
        the_hero:AddAbility("special_bonus_status_resistance_15")
        the_hero:AddAbility("special_bonus_fallen_one_sadism_dmg_up")
        the_hero:AddAbility("special_bonus_fallen_one_soul_tap_dmg_up")
        the_hero:AddAbility("special_bonus_fallen_one_sadism_regen_up")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(28)
        the_hero:SetBaseDamageMax(32)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(305)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(1.2)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.375

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)

        the_hero:SetBaseStrength(25)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.6

        the_hero:SetBaseAgility(10)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.2

        the_hero:SetBaseIntellect(20)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.0

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"FALLEN ONE"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_fallen_one_soul_tap"}
        info["scepter"] = {"lua_ability_fallen_one_eternal_suffering"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_NightStlaker(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_boogeyman_fear")
        the_hero:AddAbility("lua_ability_boogeyman_lunge")
        the_hero:AddAbility("lua_ability_boogeyman_depravity")
        the_hero:AddAbility("lua_ability_boogeyman_fright_night")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_boogeyman_devour")

        the_hero:AddAbility("special_bonus_mp_regen_150")
        the_hero:AddAbility("special_bonus_boogeyman_fear_range_up")

        the_hero:AddAbility("special_bonus_boogeyman_depravity_lifesteal_up")
        the_hero:AddAbility("special_bonus_intelligence_15")

        the_hero:AddAbility("special_bonus_hp_225")
        the_hero:AddAbility("special_bonus_boogeyman_lunge_range_up")

        the_hero:AddAbility("special_bonus_boogeyman_depravity_atk_sped_per_stack_up")
        the_hero:AddAbility("special_bonus_spell_amplify_20")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(27)
        the_hero:SetBaseDamageMax(33)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(305)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-1.32)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.33

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)

        the_hero:SetBaseStrength(21)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.0

        the_hero:SetBaseAgility(24)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.9

        the_hero:SetBaseIntellect(16)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.4

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"BOOGEYMAN"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_boogeyman_fright_night"}
        info["scepter"] = {"lua_ability_boogeyman_devour"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_Necrolyte(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_pope_of_pestilence_exorcismus")
        the_hero:AddAbility("lua_ability_pope_of_pestilence_soul_explosion")
        the_hero:AddAbility("lua_ability_pope_of_pestilence_banish")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_pope_of_pestilence_the_rite")

        the_hero:AddAbility("special_bonus_pope_of_pestilence_banish_slow_up")
        the_hero:AddAbility("special_bonus_mp_regen_175")
        the_hero:AddAbility("special_bonus_corruption_25")
        the_hero:AddAbility("special_bonus_pope_of_pestilence_soul_explosion_aoe_up")
        the_hero:AddAbility("special_bonus_attack_range_125")
        the_hero:AddAbility("special_bonus_lifesteal_25")
        the_hero:AddAbility("special_bonus_pope_of_pestilence_soul_explosion_dmg_up")
        the_hero:AddAbility("special_bonus_pope_of_pestilence_exorcismus_stacks_up")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(22)
        the_hero:SetBaseDamageMax(26)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(310)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-1.1)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.4

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)

        the_hero:SetBaseStrength(18)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 1.6

        the_hero:SetBaseAgility(16)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.6

        the_hero:SetBaseIntellect(24)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 3.0

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"POPE OF PESTILENCE"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_pope_of_pestilence_the_rite"}
        info["scepter"] = {"lua_ability_pope_of_pestilence_the_rite"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_Oracle(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_diviner_karma")
        the_hero:AddAbility("lua_ability_diviner_chaotic_insight")
        the_hero:AddAbility("lua_ability_diviner_altered_fate")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_diviner_shared_fate")

        the_hero:AddAbility("special_bonus_attack_damage_60")
        the_hero:AddAbility("special_bonus_diviner_karma_max_dmg_up")

        the_hero:AddAbility("special_bonus_diviner_chaotic_insight_cd_down")
        the_hero:AddAbility("special_bonus_movement_speed_20")

        the_hero:AddAbility("special_bonus_diviner_altered_fate_passive_up")
        the_hero:AddAbility("special_bonus_diviner_altered_fate_cd_down")

        the_hero:AddAbility("special_bonus_diviner_karma_cd_down")
        the_hero:AddAbility("special_bonus_attack_speed_100")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(28)
        the_hero:SetBaseDamageMax(32)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-0.37)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.4

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)

        the_hero:SetBaseStrength(21)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.5

        the_hero:SetBaseAgility(14)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.4

        the_hero:SetBaseIntellect(22)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.5

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"DIVINER"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_diviner_altered_fate"}
        info["scepter"] = {"lua_ability_diviner_shared_fate"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_LoneDruid(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_atniw_druid_tangling_roots")
        the_hero:AddAbility("lua_ability_atniw_druid_dream_flies")
        the_hero:AddAbility("lua_ability_atniw_druid_bear_rush")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_atniw_druid_atniws_calling")

        the_hero:AddAbility("special_bonus_atniw_druid_dream_flies_slow_time_up")
        the_hero:AddAbility("special_bonus_spell_amplify_6")

        the_hero:AddAbility("special_bonus_atniw_druid_dream_flies_slow_up")
        the_hero:AddAbility("special_bonus_atniw_druid_bear_rush_range_up")

        the_hero:AddAbility("special_bonus_strength_30")
        the_hero:AddAbility("special_bonus_spell_lifesteal_15")

        the_hero:AddAbility("special_bonus_attack_speed_100")
        the_hero:AddAbility("special_bonus_atniw_druid_tangling_roots_range_up")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(24)
        the_hero:SetBaseDamageMax(31)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(290)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(2)

        --Attack projectile Speed
        local proj_speed = the_hero:AddAbility("lua_ability_generic_change_projectile_speed")
        proj_speed.Projectile_Speed = 900

        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 475

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.4

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)

        the_hero:SetBaseStrength(19)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 1.8

        the_hero:SetBaseAgility(15)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.2

        the_hero:SetBaseIntellect(24)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.9

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"ATNIW DRUID"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_atniw_druid_atniws_calling"}
        info["scepter"] = {"lua_ability_atniw_druid_atniws_calling"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_DeathProphet(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_banshee_life_siphon")
        the_hero:AddAbility("lua_ability_banshee_death_veil")
        the_hero:AddAbility("lua_ability_banshee_soothsayer")
        the_hero:AddAbility("lua_ability_banshee_possess_death_rush")
        the_hero:AddAbility("lua_ability_banshee_possess_release")
        the_hero:AddAbility("lua_ability_banshee_possess")

        the_hero:AddAbility("special_bonus_intelligence_12")
        the_hero:AddAbility("special_bonus_banshee_possess_mana_regen_up")

        the_hero:AddAbility("special_bonus_banshee_life_siphon_dmg_up")
        the_hero:AddAbility("special_bonus_attack_damage_70")

        the_hero:AddAbility("special_bonus_movement_speed_30")
        the_hero:AddAbility("special_bonus_banshee_possess_death_rush_ms_bonus_up")

        the_hero:AddAbility("special_bonus_banshee_death_veil_length_up")
        the_hero:AddAbility("special_bonus_banshee_death_veil_dmg_up")
        self:RemoveAllTalentModifiers(the_hero)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(22)
        the_hero:SetBaseDamageMax(30)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(-0.08)

        --Attack projectile Speed
        local proj_speed = the_hero:AddAbility("lua_ability_generic_change_projectile_speed")
        proj_speed.Projectile_Speed = 1100

        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 600

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.5

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)

        the_hero:SetBaseStrength(19)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 1.7

        the_hero:SetBaseAgility(18)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.5

        the_hero:SetBaseIntellect(24)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.5

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"BANSHEE"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_banshee_possess_death_rush"}
        info["scepter"] = {"lua_ability_banshee_possess"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end


function HeroAlternativePath:Path_Tiny(hero_string,hero_path,the_hero)

    if hero_path == 1 then

        self:RemoveOriginalAbilities(the_hero)
        the_hero:AddAbility("lua_ability_rogue_golem_rock_locker")
        the_hero:AddAbility("lua_ability_rogue_golem_tree_club")
        the_hero:AddAbility("lua_ability_rogue_golem_run_forest")
        the_hero:AddAbility("lua_ability_rogue_golem_tree_chuck")
        the_hero:AddAbility("generic_hidden")
        the_hero:AddAbility("lua_ability_rogue_golem_haymaker")

        the_hero:AddAbility("special_bonus_rogue_golem_rock_locker_dmg_up")
        the_hero:AddAbility("special_bonus_hp_200")

        the_hero:AddAbility("special_bonus_rogue_golem_run_forest_break_speed_up")
        the_hero:AddAbility("special_bonus_corruption_25")

        the_hero:AddAbility("special_bonus_attack_speed_80")
        the_hero:AddAbility("special_bonus_rogue_golem_tree_club_max_up")

        the_hero:AddAbility("special_bonus_rogue_golem_run_forest_break_heal")
        the_hero:AddAbility("special_bonus_cleave_175")
        self:RemoveAllTalentModifiers(the_hero)

        --SPECIAL TINY PARTICLE
        local tiny_special = the_hero:AddAbility("lua_ability_rogue_golem_hidden_passive_death_particle")

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Set Min/Max Damage
        the_hero:SetBaseDamageMin(31)
        the_hero:SetBaseDamageMax(36)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(0.09)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.4

        --Change Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)

        the_hero:SetBaseStrength(25)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.7

        the_hero:SetBaseAgility(16)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.5

        the_hero:SetBaseIntellect(16)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.5

        the_hero:CalculateStatBonus(true)

        --NetTables
        local title = {"ROGUE GOLEM"}
        CustomNetTables:SetTableValue("new_hero_title", hero_string, title)

        local info =  {}
        info["shard"] = {"lua_ability_rogue_golem_tree_chuck"}
        info["scepter"] = {"lua_ability_rogue_golem_haymaker"}
        CustomNetTables:SetTableValue("scepter_shard_info", hero_string, info)

        local stats_gain = {}
        stats_gain["str_gain"] = str_gain.Strength_Gain
        stats_gain["agi_gain"] = agi_gain.Agility_Gain
        stats_gain["int_gain"] = int_gain.Intelligence_Gain
        CustomNetTables:SetTableValue("custom_stats_gain", hero_string, stats_gain)
    end
end
