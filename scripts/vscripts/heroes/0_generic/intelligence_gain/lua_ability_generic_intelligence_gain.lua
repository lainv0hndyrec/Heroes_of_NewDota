LinkLuaModifier( "lua_modifier_generic_intelligence_gain", "heroes/0_generic/intelligence_gain/lua_modifier_generic_intelligence_gain", LUA_MODIFIER_MOTION_NONE )

lua_ability_generic_intelligence_gain = class({})



function lua_ability_generic_intelligence_gain:Init()
    self.Intelligence_Gain = 0.0
end




function lua_ability_generic_intelligence_gain:IsStealable()
    return false
end



function lua_ability_generic_intelligence_gain:OnHeroLevelUp()
    local diff = self.Intelligence_Gain - self:GetCaster():GetIntellectGain()
    self:GetCaster():ModifyIntellect(diff)
end
