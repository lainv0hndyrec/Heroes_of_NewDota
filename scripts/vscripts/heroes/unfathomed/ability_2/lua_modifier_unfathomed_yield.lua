lua_modifier_unfathomed_yield_damage = class({})


function lua_modifier_unfathomed_yield_damage:IsHidden() return true end

function lua_modifier_unfathomed_yield_damage:IsDebuff() return false end

function lua_modifier_unfathomed_yield_damage:IsPurgable() return false end

function lua_modifier_unfathomed_yield_damage:IsPurgeException() return false end

function lua_modifier_unfathomed_yield_damage:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end




function lua_modifier_unfathomed_yield_damage:OnCreated(kv)
    local strength = self:GetParent():GetStrength()
    local percent_damage = self:GetAbility():GetSpecialValueFor("str_damage")*0.01
    self.damage = percent_damage*strength
end



function lua_modifier_unfathomed_yield_damage:GetModifierPreAttack_BonusDamage()
    return self.damage
end
