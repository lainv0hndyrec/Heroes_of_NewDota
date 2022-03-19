LinkLuaModifier( "lua_modifier_corruptedlord_demonic_scars", "heroes/corruptedlord/ability_3/lua_modifier_corruptedlord_demonic_scars", LUA_MODIFIER_MOTION_NONE )

lua_ability_corruptedlord_demonic_scars = class({})


function lua_ability_corruptedlord_demonic_scars:IsStealable()
    return false
end



function lua_ability_corruptedlord_demonic_scars:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_corruptedlord_demonic_scars"
end
