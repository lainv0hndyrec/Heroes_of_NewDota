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
        the_hero:SetBaseDamageMin(27)
        the_hero:SetBaseDamageMax(33)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(0)

        --HP regen
        the_hero:SetBaseHealthRegen(1.0)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.50

        --Stats
        the_hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
        the_hero:SetBaseStrength(22)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 3.0

        the_hero:SetBaseAgility(16)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.0

        the_hero:SetBaseIntellect(20)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.0

        the_hero:CalculateStatBonus(true)


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
        the_hero:SetPhysicalArmorBaseValue(2)

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
        str_gain.Strength_Gain = 2.0

        the_hero:SetBaseAgility(20)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.0

        the_hero:SetBaseIntellect(21)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 3.5

        the_hero:CalculateStatBonus(true)

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
        the_hero:SetPhysicalArmorBaseValue(-1)

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

        the_hero:SetBaseAgility(22)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2

        the_hero:SetBaseIntellect(18)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.5

        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 300

        the_hero:CalculateStatBonus(true)


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
        the_hero:SetBaseDamageMin(31)
        the_hero:SetBaseDamageMax(35)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(0)

        --HP regen
        the_hero:SetBaseHealthRegen(1)

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.33

        --Set Stats
        the_hero:SetBaseStrength(21)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2

        the_hero:SetBaseAgility(23)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 3.1

        the_hero:SetBaseIntellect(20)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.2

        the_hero:CalculateStatBonus(true)

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
        the_hero:AddAbility("special_bonus_whistlepunk_rockets_add_stacks")
        the_hero:AddAbility("special_bonus_whistlepunk_steam_barrier_purge_heal")
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
        the_hero:SetPhysicalArmorBaseValue(0)

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
        str_gain.Strength_Gain = 1.8

        the_hero:SetBaseAgility(20)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 1.7

        the_hero:SetBaseIntellect(25)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 3.3

        the_hero:CalculateStatBonus(true)

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
        the_hero:SetBaseDamageMin(28)
        the_hero:SetBaseDamageMax(36)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(300)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(0)


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
        the_hero:SetBaseStrength(25)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.9

        the_hero:SetBaseAgility(13)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.2

        the_hero:SetBaseIntellect(25)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 1.7

        the_hero:CalculateStatBonus(true)

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
        the_hero:SetBaseDamageMin(27)
        the_hero:SetBaseDamageMax(33)

        --Base Attack Time
        the_hero:SetBaseAttackTime(1.7)

        --Set Movespeed
        the_hero:SetBaseMoveSpeed(290)

        --Armor
        the_hero:SetPhysicalArmorBaseValue(1)


        --Change Attack Range
        local attack_range = the_hero:AddAbility("lua_ability_generic_change_attack_range")
        attack_range.Change_Attack_Range = 150

        --Change Turn Rate
        local turn_rate = the_hero:AddAbility("lua_ability_generic_change_turn_rate")
        turn_rate.Turn_Rate = 0.9000

        --Attack Point
        local atk_point = the_hero:AddAbility("lua_ability_generic_change_attack_point")
        atk_point.Attack_Point = 0.33

        --Change Stats
        the_hero:SetBaseStrength(20)
        local str_gain = the_hero:AddAbility("lua_ability_generic_strength_gain")
        str_gain.Strength_Gain = 2.4

        the_hero:SetBaseAgility(21)
        local agi_gain = the_hero:AddAbility("lua_ability_generic_agility_gain")
        agi_gain.Agility_Gain = 2.9

        the_hero:SetBaseIntellect(17)
        local int_gain = the_hero:AddAbility("lua_ability_generic_intelligence_gain")
        int_gain.Intelligence_Gain = 2.0

        the_hero:CalculateStatBonus(true)

        --NetTables
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
        the_hero:SetPhysicalArmorBaseValue(-1)

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
