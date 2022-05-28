lua_modifier_generic_illusion_correction = class({})

function lua_modifier_generic_illusion_correction:IsHidden() return true end
function lua_modifier_generic_illusion_correction:IsDebuff() return false end
function lua_modifier_generic_illusion_correction:IsPurgable() return false end
function lua_modifier_generic_illusion_correction:IsPurgeException() return false end
function lua_modifier_generic_illusion_correction:AllowIllusionDuplicate() return true end
function lua_modifier_generic_illusion_correction:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end



function lua_modifier_generic_illusion_correction:RemoveOnDeath()
    if self:GetParent():IsIllusion() then
        return true
    end
    return false
end


function lua_modifier_generic_illusion_correction:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end



function lua_modifier_generic_illusion_correction:OnIntervalThink()

    if not IsServer() then return end

    if self:GetParent():IsIllusion() == false then return end

    local original_hero = self:GetParent():GetReplicatingOtherHero()

    local new_str = original_hero:GetBaseStrength()
    self:GetParent():SetBaseStrength(new_str)

    local new_agi = original_hero:GetBaseAgility()
    self:GetParent():SetBaseAgility(new_agi)

    local new_int = original_hero:GetBaseIntellect()
    self:GetParent():SetBaseIntellect(new_int)

    local new_primary = original_hero:GetPrimaryAttribute()
    self:GetParent():SetPrimaryAttribute(new_primary)

    local new_ms = original_hero:GetBaseMoveSpeed()
    self:GetParent():SetBaseMoveSpeed(new_ms)

    local atk_cap = original_hero:GetAttackCapability()
    self:GetParent():SetAttackCapability(atk_cap)

    local proj_name = original_hero:GetRangedProjectileName()
    self:GetParent():SetRangedProjectileName(proj_name)


    --str
    if new_primary == 0 then
        local min_val = original_hero:GetBaseDamageMin() - original_hero:GetStrength()
        local max_val = original_hero:GetBaseDamageMax() - original_hero:GetStrength()
        self:GetParent():SetBaseDamageMin(math.ceil(min_val))
        self:GetParent():SetBaseDamageMax(math.ceil(max_val))
    end

    --agi
    if new_primary == 1 then
        local min_val = original_hero:GetBaseDamageMin() - original_hero:GetAgility()
        local max_val = original_hero:GetBaseDamageMax() - original_hero:GetAgility()
        self:GetParent():SetBaseDamageMin(math.ceil(min_val))
        self:GetParent():SetBaseDamageMax(math.ceil(max_val))
    end

    --int
    if new_primary == 2 then
        local min_val = original_hero:GetBaseDamageMin() - original_hero:GetIntellect()
        local max_val = original_hero:GetBaseDamageMax() - original_hero:GetIntellect()
        self:GetParent():SetBaseDamageMin(math.ceil(min_val))
        self:GetParent():SetBaseDamageMax(math.ceil(max_val))
    end

    --health
    local percent_hp = original_hero:GetHealth() / original_hero:GetMaxHealth()
    local max_hp = self:GetParent():GetMaxHealth()
    self:GetParent():ModifyHealth(max_hp*percent_hp,nil,false,-1)

    local min_armor = original_hero:GetPhysicalArmorBaseValue()
    local agi_armor = original_hero:GetAgility()/6
    self:GetParent():SetPhysicalArmorBaseValue(min_armor-agi_armor)


    --remove old abilities
    local mod = self:GetParent():FindAllModifiers()

    for i=0,30 do
        local remove_ability = self:GetParent():GetAbilityByIndex(i)
        if not remove_ability == false then

            local name = remove_ability:GetAbilityName()

            for j=1, #mod do
                local check  = mod[j]:GetAbility()
                if not check == false then
                    if check:GetAbilityName() == name then
                        self:GetParent():RemoveModifierByName(mod[j]:GetName())
                    end
                end
            end

            self:GetParent():RemoveAbilityByHandle(remove_ability)
        end
    end

    --add new abilities
    for i=0,30 do
        local to_add = original_hero:GetAbilityByIndex(i)
        if not to_add == false then
            local lvl = to_add:GetLevel()
            local new = self:GetParent():AddAbility(to_add:GetAbilityName())
            new:SetLevel(lvl)
            new:SetHidden(to_add:IsHidden())
        end
    end

    --reset talents
    mod = self:GetParent():FindAllModifiers()

    for i=1, #mod do

        local check = string.sub(mod[i]:GetName(),1,16)
        if check == "modifier_special" then

            local ability = mod[i]:GetAbility()
            self:GetParent():RemoveModifierByName(mod[i]:GetName())

            if not ability == false then
                local ori_talent = original_hero:FindAbilityByName(ability:GetAbilityName())
                local talent = self:GetParent():FindAbilityByName(ability:GetAbilityName())

                if ori_talent:GetLevel() > 0 then
                    talent:SetLevel(ori_talent:GetLevel())
                end
            end
        end
    end


    self:StartIntervalThink(-1)
end
