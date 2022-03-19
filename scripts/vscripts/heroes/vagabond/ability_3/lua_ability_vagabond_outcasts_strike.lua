
LinkLuaModifier( "lua_modifier_vagabond_outcasts_strike", "heroes/vagabond/ability_3/lua_modifier_vagabond_outcasts_strike", LUA_MODIFIER_MOTION_NONE )

lua_ability_vagabond_outcasts_strike = class({})


function lua_ability_vagabond_outcasts_strike:IsStealable()
    return false
end



function lua_ability_vagabond_outcasts_strike:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_vagabond_outcasts_strike"
end
