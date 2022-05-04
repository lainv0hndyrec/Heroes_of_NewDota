LinkLuaModifier( "lua_modifier_generic_illusion_correction", "heroes/0_generic/illusion_correction/lua_modifier_generic_illusion_correction", LUA_MODIFIER_MOTION_NONE )

lua_ability_generic_illusion_correction = class({})


function lua_ability_generic_illusion_correction:IsStealable()
    return false
end



function lua_ability_generic_illusion_correction:GetIntrinsicModifierName()
    return "lua_modifier_generic_illusion_correction"
end
