LinkLuaModifier( "lua_modifier_generic_change_attack_range", "heroes/0_generic/change_attack_range/lua_modifier_generic_change_attack_range", LUA_MODIFIER_MOTION_NONE )

lua_ability_generic_change_attack_range = class({})



function lua_ability_generic_change_attack_range:Init()
    self.Change_Attack_Range = 0.0
end




function lua_ability_generic_change_attack_range:IsStealable()
    return false
end



function lua_ability_generic_change_attack_range:GetIntrinsicModifierName()
    return "lua_modifier_generic_change_attack_range"
end
