LinkLuaModifier( "lua_modifier_generic_change_projectile_speed", "heroes/0_generic/change_projectile_speed/lua_modifier_generic_change_projectile_speed", LUA_MODIFIER_MOTION_NONE )

lua_ability_generic_change_projectile_speed = class({})



function lua_ability_generic_change_projectile_speed:Init()
    self.Projectile_Speed = 0.0
end




function lua_ability_generic_change_projectile_speed:IsStealable()
    return false
end



function lua_ability_generic_change_projectile_speed:GetIntrinsicModifierName()
    return "lua_modifier_generic_change_projectile_speed"
end
