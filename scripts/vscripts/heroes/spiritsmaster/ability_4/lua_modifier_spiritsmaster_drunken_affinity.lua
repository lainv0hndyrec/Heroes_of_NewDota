
lua_modifier_spiritsmaster_drunken_affinity_str = class({})

function lua_modifier_spiritsmaster_drunken_affinity_str:IsHidden() return false end
function lua_modifier_spiritsmaster_drunken_affinity_str:IsDebuff() return false end
function lua_modifier_spiritsmaster_drunken_affinity_str:IsPurgable() return false end
function lua_modifier_spiritsmaster_drunken_affinity_str:IsPurgeException() return true end
function lua_modifier_spiritsmaster_drunken_affinity_str:AllowIllusionDuplicate() return true end

function lua_modifier_spiritsmaster_drunken_affinity_str:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end


function lua_modifier_spiritsmaster_drunken_affinity_str:GetModifierBonusStats_Strength()
    return self:GetStackCount()
end


function lua_modifier_spiritsmaster_drunken_affinity_str:OnCreated(kv)

    if not IsServer() then return end

    if self:GetParent():IsIllusion() then
        local original = self:GetParent():GetReplicatingOtherHero()
        if not original then return end

        local mod = original:FindModifierByName("lua_modifier_spiritsmaster_drunken_affinity_str")
        if not mod then return end

        local stacks = mod:GetStackCount()
        self:SetStackCount(stacks)

        return
    end

    if not kv.target then return end

    self.target = EntIndexToHScript(kv.target)

    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH )

    local multiplier = self:GetAbility():GetSpecialValueFor("primary_stat_copy_percent")
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        multiplier = multiplier + self:GetAbility():GetSpecialValueFor("shard_copy_percent")
    end

    local copy_stat = self.target:GetStrength()*multiplier*0.01
    self:SetStackCount(copy_stat)

end


function lua_modifier_spiritsmaster_drunken_affinity_str:OnRefresh(kv)
    self:OnCreated(kv)
end















----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
lua_modifier_spiritsmaster_drunken_affinity_agi = class({})

function lua_modifier_spiritsmaster_drunken_affinity_agi:IsHidden() return false end
function lua_modifier_spiritsmaster_drunken_affinity_agi:IsDebuff() return false end
function lua_modifier_spiritsmaster_drunken_affinity_agi:IsPurgable() return false end
function lua_modifier_spiritsmaster_drunken_affinity_agi:IsPurgeException() return true end
function lua_modifier_spiritsmaster_drunken_affinity_agi:AllowIllusionDuplicate() return true end


function lua_modifier_spiritsmaster_drunken_affinity_agi:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end


function lua_modifier_spiritsmaster_drunken_affinity_agi:GetModifierBonusStats_Agility()
    return self:GetStackCount()
end


function lua_modifier_spiritsmaster_drunken_affinity_agi:OnCreated(kv)

    if not IsServer() then return end

    if self:GetParent():IsIllusion() then
        local original = self:GetParent():GetReplicatingOtherHero()
        if not original then return end

        local mod = original:FindModifierByName("lua_modifier_spiritsmaster_drunken_affinity_agi")
        if not mod then return end

        local stacks = mod:GetStackCount()
        self:SetStackCount(stacks)

        return
    end

    if not kv.target then return end

    self.target = EntIndexToHScript(kv.target)

    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)

    local multiplier = self:GetAbility():GetSpecialValueFor("primary_stat_copy_percent")
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        multiplier = multiplier + self:GetAbility():GetSpecialValueFor("shard_copy_percent")
    end

    local copy_stat = self.target:GetAgility()*multiplier*0.01
    self:SetStackCount(copy_stat)

end


function lua_modifier_spiritsmaster_drunken_affinity_agi:OnRefresh(kv)
    self:OnCreated(kv)
end















----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
lua_modifier_spiritsmaster_drunken_affinity_int = class({})

function lua_modifier_spiritsmaster_drunken_affinity_int:IsHidden() return false end
function lua_modifier_spiritsmaster_drunken_affinity_int:IsDebuff() return false end
function lua_modifier_spiritsmaster_drunken_affinity_int:IsPurgable() return false end
function lua_modifier_spiritsmaster_drunken_affinity_int:IsPurgeException() return true end
function lua_modifier_spiritsmaster_drunken_affinity_int:AllowIllusionDuplicate() return true end


function lua_modifier_spiritsmaster_drunken_affinity_int:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end


function lua_modifier_spiritsmaster_drunken_affinity_int:GetModifierBonusStats_Intellect()
    return self:GetStackCount()
end


function lua_modifier_spiritsmaster_drunken_affinity_int:OnCreated(kv)

    if not IsServer() then return end

    if self:GetParent():IsIllusion() then
        local original = self:GetParent():GetReplicatingOtherHero()
        if not original then return end

        local mod = original:FindModifierByName("lua_modifier_spiritsmaster_drunken_affinity_int")
        if not mod then return end

        local stacks = mod:GetStackCount()
        self:SetStackCount(stacks)

        return
    end

    if not kv.target then return end

    self.target = EntIndexToHScript(kv.target)

    self:GetParent():SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)

    local multiplier = self:GetAbility():GetSpecialValueFor("primary_stat_copy_percent")
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        multiplier = multiplier + self:GetAbility():GetSpecialValueFor("shard_copy_percent")
    end

    local copy_stat = self.target:GetIntellect()*multiplier*0.01
    self:SetStackCount(copy_stat)

end


function lua_modifier_spiritsmaster_drunken_affinity_int:OnRefresh(kv)
    self:OnCreated(kv)
end
