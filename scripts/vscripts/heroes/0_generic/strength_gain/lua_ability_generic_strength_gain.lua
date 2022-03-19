lua_ability_generic_strength_gain = class({})



function lua_ability_generic_strength_gain:Init()
    self.Strength_Gain = 0.0
end



function lua_ability_generic_strength_gain:OnHeroLevelUp()
    local diff = self.Strength_Gain - self:GetCaster():GetStrengthGain()
    self:GetCaster():ModifyStrength(diff)
end



function lua_ability_generic_strength_gain:IsStealable()
    return false
end
