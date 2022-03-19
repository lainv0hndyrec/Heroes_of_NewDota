
lua_modifier_whistlepunk_rockets_stacks = class({})


function lua_modifier_whistlepunk_rockets_stacks:DestroyOnExpire()
    return false
end

function lua_modifier_whistlepunk_rockets_stacks:IsPurgable()
    return false
end

function lua_modifier_whistlepunk_rockets_stacks:IsPurgeException()
    return false
end

function lua_modifier_whistlepunk_rockets_stacks:RemoveOnDeath()
    return false
end




function lua_modifier_whistlepunk_rockets_stacks:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.start_count = self.ability:GetSpecialValueFor("rocket_stacks")
    self.max_count = self.start_count

    self.talent_add_count = 0

    self:SetStackCount(self.max_count)

    if self.start_count ~= self.max_count then
        self:Update()
    end
end




function lua_modifier_whistlepunk_rockets_stacks:Update()


    if self.talent_add_count == 0 then
        local talent_add_rockets = self.parent:FindAbilityByName("special_bonus_whistlepunk_rockets_add_stacks")
        if not talent_add_rockets == false then
            if talent_add_rockets:GetLevel() > 0 then
                self.talent_add_count = talent_add_rockets:GetSpecialValueFor("value")
            end
        end
    end


    if not IsServer() then return end


    local ability_cd = self:GetAbility():GetEffectiveCooldown(1)



    if self:GetDuration() == -1 then
        self:SetDuration(ability_cd, true)
        self:StartIntervalThink(ability_cd)
    end


    if self:GetStackCount() == 0 then
        self.ability:StartCooldown(self:GetRemainingTime())
    end


end









function lua_modifier_whistlepunk_rockets_stacks:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
    }

    return funcs
end




function lua_modifier_whistlepunk_rockets_stacks:OnAbilityFullyCast(params)
    --if not IsServer() then return end
    if params.unit ~= self.parent then return end

    if params.ability ~= self.ability then return end

    self:DecrementStackCount()
    self.ability:EndCooldown()
    self:Update()


end



function lua_modifier_whistlepunk_rockets_stacks:OnIntervalThink()
    local stacks = self:GetStackCount()
    local total_rocket = self.max_count+self.talent_add_count

    if not IsServer() then return end

    local ability_cd = self:GetAbility():GetEffectiveCooldown(1)

    if stacks < total_rocket then
        self:SetDuration(ability_cd, true)
        self:StartIntervalThink(ability_cd)
        self:IncrementStackCount()

        if stacks == total_rocket - 1 then
            self:SetDuration(-1, true)
            self:StartIntervalThink(-1)
        end
    end
end
