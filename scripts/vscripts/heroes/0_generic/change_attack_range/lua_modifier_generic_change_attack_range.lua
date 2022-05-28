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

        if self:GetParent():IsIllusion() then
            local original_hero = self:GetParent():GetReplicatingOtherHero()
            if not original_hero then return end

            local original_modifier = original_hero:FindModifierByName("lua_modifier_generic_change_attack_range")
            if not original_modifier then return end

            new_attack_range = original_modifier:GetStackCount()
        end

        self:SetStackCount(new_attack_range)
    end

    return self:GetStackCount()
end
