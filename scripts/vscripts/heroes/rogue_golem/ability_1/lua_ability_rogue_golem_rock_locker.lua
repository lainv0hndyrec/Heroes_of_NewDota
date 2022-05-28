LinkLuaModifier( "lua_modifier_rogue_golem_rock_locker_thinker", "heroes/rogue_golem/ability_1/lua_modifier_rogue_golem_rock_locker", LUA_MODIFIER_MOTION_NONE )

lua_ability_rogue_golem_rock_locker = class({})


function lua_ability_rogue_golem_rock_locker:GetAOERadius()
    local cast_aoe = self:GetLevelSpecialValueFor("cast_aoe",0)
    return cast_aoe
end


function lua_ability_rogue_golem_rock_locker:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_rogue_golem_rock_locker:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_rogue_golem_rock_locker:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_rogue_golem_rock_locker:OnSpellStart()

    local delay = self:GetSpecialValueFor("delay_time")
    local fx_time = self:GetSpecialValueFor("effect_duration")

    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_rogue_golem_rock_locker_thinker",
        {duration = delay+fx_time}, self:GetCursorPosition(),
        self:GetCaster():GetTeam(), false
    )

end
