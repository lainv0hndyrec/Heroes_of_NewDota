lua_modifier_generic_change_attack_range = class({})

function lua_modifier_generic_change_attack_range:IsHidden() return true end
function lua_modifier_generic_change_attack_range:IsDebuff() return false end
function lua_modifier_generic_change_attack_range:IsPurgable() return false end
function lua_modifier_generic_change_attack_range:IsPurgeException() return false end
function lua_modifier_generic_change_attack_range:RemoveOnDeath() return false end
function lua_modifier_generic_change_attack_range:AllowIllusionDuplicate() return true end



function lua_modifier_generic_change_attack_range:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE}
end



function lua_modifier_generic_change_attack_range:GetModifierAttackRangeOverride()

    if IsServer() then
        local new_attack_range = self:GetAbility().Change_Attack_Range
        if not new_attack_range then return end
        self:SetStackCount(new_attack_range)
    end

    return self:GetStackCount()
end
