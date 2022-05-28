LinkLuaModifier( "lua_modifier_banshee_soothsayer_aura", "heroes/banshee/ability_3/lua_modifier_banshee_soothsayer", LUA_MODIFIER_MOTION_NONE )



lua_ability_banshee_soothsayer = class({})



function lua_ability_banshee_soothsayer:IsStealable()
    return false
end



function lua_ability_banshee_soothsayer:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_banshee_soothsayer_aura"
end
