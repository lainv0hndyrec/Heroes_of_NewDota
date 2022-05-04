LinkLuaModifier( "lua_modifier_pope_of_pestilence_the_rite_thinker", "heroes/pope_of_pestilence/ability_4/lua_modifier_pope_of_pestilence_the_rite", LUA_MODIFIER_MOTION_NONE )


lua_ability_pope_of_pestilence_the_rite = class({})


function lua_ability_pope_of_pestilence_the_rite:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_pope_of_pestilence_the_rite:GetAOERadius()
    local aoe_radius = self:GetLevelSpecialValueFor("aoe_radius",0)
    return aoe_radius
end


function lua_ability_pope_of_pestilence_the_rite:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_pope_of_pestilence_the_rite:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end





function lua_ability_pope_of_pestilence_the_rite:OnSpellStart()

    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_pope_of_pestilence_the_rite_thinker",
        {},self:GetCursorPosition(),
        self:GetCaster():GetTeam(),false
    )

end
