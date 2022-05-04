
lua_modifier_pope_of_pestilence_exorcismus_stacks = class({})

function lua_modifier_pope_of_pestilence_exorcismus_stacks:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_exorcismus_stacks:IsHidden() return false end
function lua_modifier_pope_of_pestilence_exorcismus_stacks:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_exorcismus_stacks:IsPurgeException() return false end
function lua_modifier_pope_of_pestilence_exorcismus_stacks:RemoveOnDeath() return false end
function lua_modifier_pope_of_pestilence_exorcismus_stacks:DestroyOnExpire() return false end
function lua_modifier_pope_of_pestilence_exorcismus_stacks:AllowIllusionDuplicate() return true end



function lua_modifier_pope_of_pestilence_exorcismus_stacks:OnCreated(kv)
    if not IsServer() then return end

    if self:GetParent():IsIllusion() == false then return end

    local original_hero = self:GetParent():GetReplicatingOtherHero()
    if not original_hero then return end

    local original_ability = original_hero:FindAbilityByName("lua_ability_pope_of_pestilence_exorcismus")
    if not original_ability then return end

    local max_stacks = original_ability:GetSpecialValueFor("ability_stacks")

    self:SetStackCount(max_stacks)

end


function lua_modifier_pope_of_pestilence_exorcismus_stacks:OnStackCountChanged(count)
    if not IsServer() then return end

    if self:GetParent():IsIllusion() then return end

    local lvl = self:GetAbility():GetLevel()-1
    local cd = self:GetAbility():GetEffectiveCooldown(lvl)
    local max_stack = self:GetAbility():GetSpecialValueFor("ability_stacks")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_pope_of_pestilence_exorcismus_stacks_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            max_stack = max_stack+talent:GetSpecialValueFor("value")
        end
    end

    if self:GetStackCount() >= max_stack then return end

    if self:GetRemainingTime() > 0.5 then return end

    self:SetDuration(cd,true)
    self:StartIntervalThink(cd)

end



function lua_modifier_pope_of_pestilence_exorcismus_stacks:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():IsIllusion() then return end
    self:StartIntervalThink(-1)
    self:IncrementStackCount()
end
