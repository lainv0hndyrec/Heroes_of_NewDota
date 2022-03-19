LinkLuaModifier( "lua_modifier_kalligromancer_heavy_blot", "heroes/kalligromancer/ability_3/lua_modifier_kalligromancer_heavy_blot", LUA_MODIFIER_MOTION_NONE )

lua_ability_kalligromancer_heavy_blot = class({})



function lua_ability_kalligromancer_heavy_blot:IsStealable()
    return false
end



function lua_ability_kalligromancer_heavy_blot:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_kalligromancer_heavy_blot"
end
