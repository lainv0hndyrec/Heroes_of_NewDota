LinkLuaModifier( "lua_modifier_generic_agility_gain", "heroes/0_generic/agility_gain/lua_modifier_generic_agility_gain", LUA_MODIFIER_MOTION_NONE )

lua_ability_generic_agility_gain = class({})



function lua_ability_generic_agility_gain:Init()
    self.Agility_Gain = 0.0
end




function lua_ability_generic_agility_gain:IsStealable()
    return false
end



function lua_ability_generic_agility_gain:OnHeroLevelUp()
    local diff = self.Agility_Gain - self:GetCaster():GetAgilityGain()
    self:GetCaster():ModifyAgility(diff)
end
