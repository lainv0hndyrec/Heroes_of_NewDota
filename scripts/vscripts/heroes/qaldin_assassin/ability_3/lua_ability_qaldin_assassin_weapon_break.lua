
LinkLuaModifier( "lua_modifier_qaldin_assassin_weapon_break", "heroes/qaldin_assassin/ability_3/lua_modifier_qaldin_assassin_weapon_break", LUA_MODIFIER_MOTION_NONE )


lua_ability_qaldin_assassin_weapon_break = class({})


function lua_ability_qaldin_assassin_weapon_break:IsStealable()
    return false
end



function lua_ability_qaldin_assassin_weapon_break:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_qaldin_assassin_weapon_break"
end


function lua_ability_qaldin_assassin_weapon_break:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end
