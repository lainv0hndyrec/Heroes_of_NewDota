LinkLuaModifier( "lua_modifier_pope_of_pestilence_soul_explosion_thinker", "heroes/pope_of_pestilence/ability_2/lua_modifier_pope_of_pestilence_soul_explosion", LUA_MODIFIER_MOTION_NONE )


lua_ability_pope_of_pestilence_soul_explosion = class({})


function lua_ability_pope_of_pestilence_soul_explosion:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_pope_of_pestilence_soul_explosion:GetAOERadius()
    local aoe_radius = self:GetLevelSpecialValueFor("aoe_radius",0)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_pope_of_pestilence_soul_explosion_aoe_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            aoe_radius = aoe_radius+talent:GetSpecialValueFor("value")
        end
    end

    return aoe_radius
end


function lua_ability_pope_of_pestilence_soul_explosion:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_pope_of_pestilence_soul_explosion:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end





function lua_ability_pope_of_pestilence_soul_explosion:OnSpellStart()

    local skulls = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCursorPosition(),
        nil,self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_CLOSEST,false
    )

    local skull_count = 0

    for i=1, #skulls do
        if skulls[i]:GetUnitName() == "npc_custom_unit_pope_of_pestilence_soul_skull" then
            local mod_pick = skulls[i]:FindModifierByName("lua_modifier_pope_of_pestilence_banish_pickable")
            if not mod_pick == false then
                mod_pick:Destroy()
                skull_count = skull_count + 1
            end
        end
    end


    local base_dmg = self:GetSpecialValueFor("base_damage")
    local skull_dmg = self:GetSpecialValueFor("skull_damage")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_pope_of_pestilence_soul_explosion_dmg_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            skull_dmg = skull_dmg+talent:GetSpecialValueFor("value")
        end
    end

    local total_dmg = base_dmg+(skull_dmg*skull_count)


    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCursorPosition(),
        nil,self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )


    for i=1, #enemies do

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = total_dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }
        ApplyDamage(dtable)

    end


    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_pope_of_pestilence_soul_explosion_thinker",
        {},self:GetCursorPosition(),self:GetCaster():GetTeam(),false
    )

end
