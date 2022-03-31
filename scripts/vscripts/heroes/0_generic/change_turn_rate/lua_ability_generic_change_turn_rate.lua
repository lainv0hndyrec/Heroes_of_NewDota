LinkLuaModifier( "lua_modifier_generic_change_turn_rate", "heroes/0_generic/change_turn_rate/lua_modifier_generic_change_turn_rate", LUA_MODIFIER_MOTION_NONE )

lua_ability_generic_change_turn_rate = class({})



function lua_ability_generic_change_turn_rate:Init()
    self.Turn_Rate = 0.0
end




function lua_ability_generic_change_turn_rate:IsStealable()
    return false
end



function lua_ability_generic_change_turn_rate:GetIntrinsicModifierName()
    return "lua_modifier_generic_change_turn_rate"
end
