LinkLuaModifier( "lua_modifier_hidden_one_void_out_counter", "heroes/hidden_one/ability_4/lua_modifier_hidden_one_void_out", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_hidden_one_void_out_passive", "heroes/hidden_one/ability_4/lua_modifier_hidden_one_void_out", LUA_MODIFIER_MOTION_NONE )



lua_ability_hidden_one_void_out = class({})


function lua_ability_hidden_one_void_out:IsStealable() return false end



function lua_ability_hidden_one_void_out:ApplyVoidOutModifier(target,casted_ability)
    if not IsServer() then return end

    if not target then return end

    if not casted_ability then return end

    local debuff_duration = self:GetSpecialValueFor("debuff_duration")

    target:AddNewModifier(
        self:GetCaster(),self,"lua_modifier_hidden_one_void_out_counter",
        {
            duration = debuff_duration,
            ability = casted_ability:GetName()
        }
    )
end





function lua_ability_hidden_one_void_out:GetIntrinsicModifierName()
    if self:GetLevel() <= 0 then return end
    return "lua_modifier_hidden_one_void_out_passive"
end
