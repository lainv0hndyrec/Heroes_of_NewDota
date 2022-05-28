lua_modifier_generic_change_attack_point= class({})

function lua_modifier_generic_change_attack_point:IsHidden() return true end
function lua_modifier_generic_change_attack_point:IsDebuff() return false end
function lua_modifier_generic_change_attack_point:IsPurgable() return false end
function lua_modifier_generic_change_attack_point:IsPurgeException() return false end
function lua_modifier_generic_change_attack_point:RemoveOnDeath() return false end
function lua_modifier_generic_change_attack_point:AllowIllusionDuplicate() return true end


function lua_modifier_generic_change_attack_point:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT}
end



function lua_modifier_generic_change_attack_point:GetAttackAnimationPoint()
    if not IsServer() then return end
    if self:GetParent():IsIllusion() then
        local original_hero = self:GetParent():GetReplicatingOtherHero()
        if not original_hero then return end

        local original_ability = original_hero:FindAbilityByName("lua_ability_generic_change_attack_point")
        if not original_ability then return end

        return original_ability.Attack_Point
    end
    return self:GetAbility().Attack_Point
end
