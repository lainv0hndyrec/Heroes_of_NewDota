LinkLuaModifier( "lua_modifier_defiler_defiling_touch_source", "heroes/defiler/ability_3/lua_modifier_defiler_defiling_touch", LUA_MODIFIER_MOTION_NONE )


lua_ability_defiler_defiling_touch = class({})


function lua_ability_defiler_defiling_touch:IsStealable()
    return false
end



function lua_ability_defiler_defiling_touch:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
	return "lua_modifier_defiler_defiling_touch_source"
end
