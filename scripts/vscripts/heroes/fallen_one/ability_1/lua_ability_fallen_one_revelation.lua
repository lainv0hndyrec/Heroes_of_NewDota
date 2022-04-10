LinkLuaModifier( "lua_modifier_fallen_one_revelation_delay", "heroes/fallen_one/ability_1/lua_modifier_fallen_one_revelation", LUA_MODIFIER_MOTION_NONE )


lua_ability_fallen_one_revelation = class({})



function lua_ability_fallen_one_revelation:GetAOERadius()
    local cast_aoe = self:GetLevelSpecialValueFor("cast_aoe",0)
    return cast_aoe
end



function lua_ability_fallen_one_revelation:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_fallen_one_revelation:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_fallen_one_revelation:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end





function lua_ability_fallen_one_revelation:OnSpellStart()

    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_fallen_one_revelation_delay",
        {duration = 1.5},self:GetCursorPosition(),
        self:GetCaster():GetTeam(),false
    )

end
