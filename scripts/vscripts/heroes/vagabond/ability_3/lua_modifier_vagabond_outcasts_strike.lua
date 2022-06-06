lua_modifier_vagabond_outcasts_strike = class({})

function lua_modifier_vagabond_outcasts_strike:IsHidden()
    return false
end

function lua_modifier_vagabond_outcasts_strike:IsPurgable()
    return false
end

function lua_modifier_vagabond_outcasts_strike:IsDebuff()
	return false
end


function lua_modifier_vagabond_outcasts_strike:AllowIllusionDuplicate()
	return true
end


function lua_modifier_vagabond_outcasts_strike:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end




function lua_modifier_vagabond_outcasts_strike:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_UNIT_MOVED,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED

	}
	return funcs
end


function lua_modifier_vagabond_outcasts_strike:OnCreated(kv)
    self:SetStackCount(0)
    self.previous_position = self:GetParent():GetAbsOrigin()
    self.distance_created = 0


    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/vagabond/ability_3/vagabond_sparkle.vpcf",
        PATTACH_POINT_FOLLOW ,
        self:GetParent()
    )
    ParticleManager:SetParticleControl(
        self.particle,0,self:GetParent():GetAbsOrigin()
    )
    ParticleManager:SetParticleControl(
        self.particle,1,Vector(0,0,0)
    )

    if not IsServer() then return end

    if self:GetParent():IsIllusion() == false then return end
    local playerid = self:GetParent():GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerid)
    local mod = hero:FindModifierByName("lua_modifier_vagabond_outcasts_strike")
    local copy_stacks = mod:GetStackCount()

    self.previous_position = mod.previous_position
    self.distance_created = mod.distance_created
    self:SetStackCount(copy_stacks)
end

--function lua_modifier_vagabond_charged_lance:OnUnitMoved(event)

--end


function lua_modifier_vagabond_outcasts_strike:GetModifierPreAttack_CriticalStrike(event)
    if event.attacker ~= self:GetParent() then return end

    if event.target:IsBaseNPC() == false then return end

    if event.target:IsBuilding() == true then return end

    if self:GetParent():PassivesDisabled() == true then return end


    local trigger_stacks = self:GetAbility():GetSpecialValueFor("trigger_stacks")
    if self:GetStackCount() < trigger_stacks then return end

    local add_max_crit = 0
    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_outcasts_strike_max_crit")

    if not talent == false then
        if talent:GetLevel() > 0 then
            add_max_crit = talent:GetSpecialValueFor("value")
        end
    end





    local max_crit = self:GetAbility():GetSpecialValueFor("max_crit") + add_max_crit
    local scale_crit = ((max_crit - 100) * 0.01 *self:GetStackCount())
    local crit_damage = 100 + scale_crit

    --self:SetStackCount(self:GetStackCount()*half_stacks)
    return crit_damage
end




function lua_modifier_vagabond_outcasts_strike:OnAttackLanded(event)
    if event.attacker ~= self:GetParent() then return end

    if event.target:IsBaseNPC() == false then return end

    if event.target:IsBuilding() == true then return end

    if self:GetParent():PassivesDisabled() == true then return end

    local trigger_stacks = self:GetAbility():GetSpecialValueFor("trigger_stacks")

    if self:GetStackCount() >= trigger_stacks then

        self:SetStackCount(0)
        ParticleManager:SetParticleControl(
            self.particle,1,Vector(0,0,0)
        )

    else

        if event.target:IsHero() == false then return end

        local gain_stacks = self:GetAbility():GetSpecialValueFor("hero_attack_stacks")
        self:SetStackCount(self:GetStackCount()+gain_stacks)
        ParticleManager:SetParticleControl(
            self.particle,1,Vector(self:GetStackCount(),0,0)
        )
    end
end




function lua_modifier_vagabond_outcasts_strike:OnUnitMoved(event)
    if event.unit ~= self:GetParent() then return end

    if self:GetParent():PassivesDisabled() == true then return end

    local previous_position = self.previous_position
    local current_position = event.new_pos
    local distance_created = (current_position - previous_position):Length2D()

    self.distance_created  = self.distance_created + distance_created

    local add_stacks = math.floor(self.distance_created/10)

    self.distance_created = self.distance_created - (add_stacks*10)

    self.previous_position = event.new_pos

    local max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
    local new_stacks = math.min(max_stacks,self:GetStackCount()+add_stacks)


    self:SetStackCount(new_stacks)
    ParticleManager:SetParticleControl(
        self.particle,1,Vector(self:GetStackCount(),0,0)
    )
end



function lua_modifier_vagabond_outcasts_strike:OnDestroy()
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end
