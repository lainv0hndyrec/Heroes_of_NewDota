LinkLuaModifier( "lua_modifier_generic_change_attack_point", "heroes/0_generic/change_attack_point/lua_modifier_generic_change_attack_point", LUA_MODIFIER_MOTION_NONE )

lua_ability_generic_change_attack_point = class({})



function lua_ability_generic_change_attack_point:Init()
    self.Attack_Point = 0.0
end




function lua_ability_generic_change_attack_point:IsStealable()
    return false
end



function lua_ability_generic_change_attack_point:GetIntrinsicModifierName()
    return "lua_modifier_generic_change_attack_point"
end
