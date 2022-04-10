LinkLuaModifier( "lua_modifier_spiritsmaster_storm_spirit_transform", "heroes/spiritsmaster/ability_3/lua_modifier_spiritsmaster_storm_spirit", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_spiritsmaster_storm_spirit_bolt", "heroes/spiritsmaster/ability_3/lua_modifier_spiritsmaster_storm_spirit", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_spiritsmaster_storm_spirit_sight", "heroes/spiritsmaster/ability_3/lua_modifier_spiritsmaster_storm_spirit", LUA_MODIFIER_MOTION_NONE )


lua_ability_spiritsmaster_storm_spirit = class({})



function lua_ability_spiritsmaster_storm_spirit:GetAOERadius()
    local aoe_range = self:GetLevelSpecialValueFor("cast_range",0)
    return aoe_range
end


function lua_ability_spiritsmaster_storm_spirit:GetCastRange(pos,target)
    return self:GetAOERadius()
end


function lua_ability_spiritsmaster_storm_spirit:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_spiritsmaster_storm_spirit:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end









function lua_ability_spiritsmaster_storm_spirit:OnSpellStart()


    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_storm_spirit_transform",
        {duration = self:GetSpecialValueFor("hero_effect_time")}
    )

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_storm_spirit_bolt",
        {duration = self:GetSpecialValueFor("atk_bolt_time")}
    )

    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_storm_spirit_sight",
        {duration = self:GetSpecialValueFor("vision_time")},
        self:GetCaster():GetAbsOrigin(),
        self:GetCaster():GetTeam(),false
    )

end
