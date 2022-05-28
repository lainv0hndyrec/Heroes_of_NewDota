--For Tracking Projectile it delete itself
lua_modifier_whistlepunk_oil_spill_thinker = class({})

function lua_modifier_whistlepunk_oil_spill_thinker:IsHidden()return true end

function lua_modifier_whistlepunk_oil_spill_thinker:IsPurgable() return false end

function lua_modifier_whistlepunk_oil_spill_thinker:IsPurgeException() return false end

function lua_modifier_whistlepunk_oil_spill_thinker:OnCreated( kv )
    if not IsServer() then return end
    self.parent = self:GetParent()
end


function lua_modifier_whistlepunk_oil_spill_thinker:OnDestroy()
    UTIL_Remove(self.parent)
end






--the Debuff
lua_modifier_whistlepunk_oil_spill_slowburn = class({})


function lua_modifier_whistlepunk_oil_spill_slowburn:IsHidden() return false end

function lua_modifier_whistlepunk_oil_spill_slowburn:IsDebuff() return true end

function lua_modifier_whistlepunk_oil_spill_slowburn:IsPurgable() return true end

function lua_modifier_whistlepunk_oil_spill_slowburn:GetStatusEffectName()
	return "particles/status_fx/status_effect_stickynapalm.vpcf"
end

function lua_modifier_whistlepunk_oil_spill_slowburn:OnCreated( kv )

    self.talent_ms_as_bonus = 0
    local talent_slow_amount = self:GetCaster():FindAbilityByName("special_bonus_whistlepunk_oil_spill_slow_amount")
    if not talent_slow_amount == false then
        if talent_slow_amount:GetLevel() > 0 then
            self.talent_ms_as_bonus = talent_slow_amount:GetSpecialValueFor("value")
        end
    end

    self.move_speed_percent = self:GetAbility():GetSpecialValueFor("move_speed_percent")+self.talent_ms_as_bonus
    self.attack_speed_percent = self:GetAbility():GetSpecialValueFor("attack_speed_percent")+self.talent_ms_as_bonus
    self.burn_dot = self:GetAbility():GetSpecialValueFor("burn_dot")
    self.oil_drip = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self.is_burning = false

end



function lua_modifier_whistlepunk_oil_spill_slowburn:OnRefresh( kv )
    self.move_speed_percent = self:GetAbility():GetSpecialValueFor("move_speed_percent")+self.talent_ms_as_bonus
    self.attack_speed_percent = self:GetAbility():GetSpecialValueFor("attack_speed_percent")+self.talent_ms_as_bonus
    self.burn_dot = self:GetAbility():GetSpecialValueFor("burn_dot")
end



function lua_modifier_whistlepunk_oil_spill_slowburn:DeclareFunctions()
    local dfuncs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP
    }
	return dfuncs
end



function lua_modifier_whistlepunk_oil_spill_slowburn:GetModifierMoveSpeedBonus_Percentage()
    return -self.move_speed_percent
end



function lua_modifier_whistlepunk_oil_spill_slowburn:GetModifierAttackSpeedPercentage()
    return -self.attack_speed_percent
end



function lua_modifier_whistlepunk_oil_spill_slowburn:OnTakeDamage(event)
    if event.attacker ~= self:GetCaster() then return end

    if event.unit:IsBaseNPC() == false then return end
    if event.unit:IsAlive() == false then return end
    if event.unit ~= self:GetParent() then return end

    if not event.inflictor then return end

    if event.inflictor:GetName() ~= "lua_ability_whistlepunk_rockets" then return end

    if self.is_burning == true then return end

    self.is_burning = true

    self.burning_particle = ParticleManager:CreateParticle(
        "particles/econ/items/huskar/huskar_2021_immortal/huskar_2021_immortal_burning_spear_debuff_flame_circulate.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )

    self:StartIntervalThink(1.0)
    self:OnIntervalThink()
end


function lua_modifier_whistlepunk_oil_spill_slowburn:OnIntervalThink()
    local burn_table = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.burn_dot,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(burn_table)
end




function lua_modifier_whistlepunk_oil_spill_slowburn:OnTooltip()
    return self.burn_dot
end





function lua_modifier_whistlepunk_oil_spill_slowburn:OnDestroy()
    self:StartIntervalThink(-1)

    ParticleManager:DestroyParticle(self.oil_drip,false)
    ParticleManager:ReleaseParticleIndex(self.oil_drip)

    if not self.burning_particle == false then
        ParticleManager:DestroyParticle(self.burning_particle,false)
        ParticleManager:ReleaseParticleIndex(self.burning_particle)
    end

end
