LinkLuaModifier( "lua_modifier_fallen_one_sadism_steal", "heroes/fallen_one/ability_3/lua_modifier_fallen_one_sadism", LUA_MODIFIER_MOTION_NONE )

lua_modifier_fallen_one_sadism_aura = class({})


function lua_modifier_fallen_one_sadism_aura:IsDebuff() return false end
function lua_modifier_fallen_one_sadism_aura:IsHidden() return false end
function lua_modifier_fallen_one_sadism_aura:IsPurgable() return false end
function lua_modifier_fallen_one_sadism_aura:IsPurgeException() return false end
function lua_modifier_fallen_one_sadism_aura:AllowIllusionDuplicate() return true end

function lua_modifier_fallen_one_sadism_aura:IsAura() return true end
function lua_modifier_fallen_one_sadism_aura:IsAuraActiveOnDeath() return false end
function lua_modifier_fallen_one_sadism_aura:GetAuraDuration() return 0.0 end
function lua_modifier_fallen_one_sadism_aura:GetModifierAura() return "lua_modifier_fallen_one_sadism_steal" end
function lua_modifier_fallen_one_sadism_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function lua_modifier_fallen_one_sadism_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function lua_modifier_fallen_one_sadism_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function lua_modifier_fallen_one_sadism_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC end
function lua_modifier_fallen_one_sadism_aura:GetAuraEntityReject(target)
    if target:GetName() == "npc_dota_roshan" then return true end
    return false
end


function lua_modifier_fallen_one_sadism_aura:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf"
end


function lua_modifier_fallen_one_sadism_aura:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end


function lua_modifier_fallen_one_sadism_aura:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return dfunc
end


function lua_modifier_fallen_one_sadism_aura:GetModifierConstantHealthRegen()
    return self:GetStackCount()
end


function lua_modifier_fallen_one_sadism_aura:OnCreated(kv)
    if not IsServer() then return end
    self.affected_enemies = 0
end

















---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
lua_modifier_fallen_one_sadism_steal = class({})


function lua_modifier_fallen_one_sadism_steal:IsDebuff() return true end
function lua_modifier_fallen_one_sadism_steal:IsHidden() return false end
function lua_modifier_fallen_one_sadism_steal:IsPurgable() return true end
function lua_modifier_fallen_one_sadism_steal:IsPurgeException() return true end


function lua_modifier_fallen_one_sadism_steal:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return dfunc
end


function lua_modifier_fallen_one_sadism_steal:OnCreated(kv)
    if not IsServer() then return end

    local current_hp_regen = self:GetParent():GetHealthRegen()
    local reduction = self:GetAbility():GetSpecialValueFor("regen_steal_percent")

    --talent
    local talent = self:GetCaster():FindAbilityByName("special_bonus_fallen_one_sadism_regen_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            reduction = reduction + talent:GetSpecialValueFor("value")
        end
    end

    local total_reduction = reduction*current_hp_regen*0.01
    self:SetStackCount(total_reduction)
    self.current_hp_regen = math.floor(current_hp_regen - self:GetStackCount())

    self:StartIntervalThink(0.5)

    local owner = self:GetAuraOwner()
    if not owner then return end
    if owner:IsAlive() == false then return end

    local aura = owner:FindModifierByName("lua_modifier_fallen_one_sadism_aura")
    if not aura then return end

    local new_stack = aura:GetStackCount()+self:GetStackCount()
    aura:SetStackCount(new_stack)
    aura.affected_enemies = math.max(0,aura.affected_enemies+1)
end


function lua_modifier_fallen_one_sadism_steal:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_fallen_one_sadism_steal:OnIntervalThink()
    if not IsServer() then return end

    if not self:GetAbility() then
        self:StartIntervalThink(-1)
        self:Destroy()
        return
    end


    if self:GetParent():IsAlive() == false then
        self:StartIntervalThink(-1)
        self:Destroy()
        return
    end

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_debuff.vpcf",
        PATTACH_POINT_FOLLOW,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    local owner = self:GetAuraOwner()
    if not owner then self:Destroy() return end
    if owner:IsAlive() == false then self:Destroy() return  end

    local aura = owner:FindModifierByName("lua_modifier_fallen_one_sadism_aura")
    if not aura then self:Destroy() return end
    if aura.affected_enemies == 0 then return end

    local min_dmg = self:GetAbility():GetSpecialValueFor("pure_dot_min_damage")
    local pure_dot = self:GetAbility():GetSpecialValueFor("pure_dot_damage")

    --talent
    local talent = self:GetCaster():FindAbilityByName("special_bonus_fallen_one_sadism_dmg_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            pure_dot = pure_dot + talent:GetSpecialValueFor("value")
        end
    end

    local pure_dmg = math.max(min_dmg,pure_dot/aura.affected_enemies)
    local dot = pure_dmg*0.5

    local dtable = {
        victim = self:GetParent(),
        attacker = owner,
        damage = dot,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)


    if math.floor(self:GetParent():GetHealthRegen()) == self.current_hp_regen then return end
    self:StartIntervalThink(-1)
    self:Destroy()
end


function lua_modifier_fallen_one_sadism_steal:GetModifierConstantHealthRegen()
    return -self:GetStackCount()
end


function lua_modifier_fallen_one_sadism_steal:OnDestroy()
    if not IsServer() then return end

    local owner = self:GetAuraOwner()
    if not owner then return end
    if owner:IsAlive() == false then return end

    local aura = owner:FindModifierByName("lua_modifier_fallen_one_sadism_aura")
    if not aura then return end

    local new_stack = aura:GetStackCount()-self:GetStackCount()

    aura:SetStackCount(new_stack)
    aura.affected_enemies = math.max(0,aura.affected_enemies-1)
end
