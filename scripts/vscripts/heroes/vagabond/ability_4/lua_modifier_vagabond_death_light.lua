

lua_modifier_vagabond_death_light = class({})

function lua_modifier_vagabond_death_light:IsHidden()
    return false
end

function lua_modifier_vagabond_death_light:IsPurgable()
    return false
end

function lua_modifier_vagabond_death_light:IsDebuff()
	return false
end

function lua_modifier_vagabond_death_light:IsPurgeException()
	return false
end

function lua_modifier_vagabond_death_light:DeclareFunctions()
    local defuncs = {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
        --MODIFIER_EVENT_ON_DEATH_PREVENTED,
        MODIFIER_EVENT_ON_MODIFIER_ADDED
    }
    return defuncs
end

function lua_modifier_vagabond_death_light:CheckState()
    local state ={
        [MODIFIER_STATE_STUNNED] = true
    }
    return state
end




function lua_modifier_vagabond_death_light:OnCreated(event)
    self.mod_active = true

    if not IsServer() then return end

    self:GetParent():StartGesture(ACT_DOTA_VICTORY)

    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_legion_commander/legion_commander_press_owner.vpcf",
        PATTACH_ABSORIGIN,
        self:GetParent()
    )

    ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle,1,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle,2,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle,3,self:GetParent():GetAbsOrigin())



end





function lua_modifier_vagabond_death_light:OnRefresh(kv)
    self.mod_active = true

    if not IsServer() then return end

    self:GetParent():StartGesture(ACT_DOTA_VICTORY)

    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_legion_commander/legion_commander_press_owner.vpcf",
        PATTACH_ABSORIGIN,
        self:GetParent()
    )
end




function lua_modifier_vagabond_death_light:OnModifierAdded(event)

    if event.unit ~= self:GetParent() then return end
    if event.added_buff:IsDebuff() == false then return end

    local caster = event.added_buff:GetCaster()

    if caster:IsHero() == false then return end

    if caster:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end

    if self.mod_active == false then return end

    self:execute_frame_skip(caster)
end





function lua_modifier_vagabond_death_light:GetModifierStatusResistance()
    return 999
end




function lua_modifier_vagabond_death_light:GetAbsoluteNoDamagePhysical(event)
    if event.target:IsBaseNPC() == false then return 0 end

    if event.target ~= self:GetParent() then return 0 end

    if event.damage_type ~= DAMAGE_TYPE_PHYSICAL then return 0 end

    if event.attacker:IsHero() == false then return 0 end

    if event.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then return 0 end

    if self.mod_active == true then
        self:execute_frame_skip(event.attacker)
    end

    return 1
end




function lua_modifier_vagabond_death_light:GetAbsoluteNoDamageMagical(event)
    if event.target:IsBaseNPC() == false then return end

    if event.target ~= self:GetParent() then return 0 end

    if event.damage_type ~= DAMAGE_TYPE_MAGICAL then return 0 end

    if event.attacker:IsHero() == false then return 0 end

    if event.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then return 0 end

    if self.mod_active == true then
        self:execute_frame_skip(event.attacker)
    end

    return 1
end




function lua_modifier_vagabond_death_light:GetAbsoluteNoDamagePure(event)
    if event.target:IsBaseNPC() == false then return end

    if event.target ~= self:GetParent() then return 0 end

    if event.damage_type ~= DAMAGE_TYPE_PURE then return 0 end

    if event.attacker:IsHero() == false then return 0 end

    if event.attacker:GetTeamNumber() == self:GetParent():GetTeamNumber() then return 0 end

    if self.mod_active == true then
        self:execute_frame_skip(event.attacker)
    end

    return 1
end




function lua_modifier_vagabond_death_light:execute_frame_skip(caster)
    self.mod_active = false
    self:GetAbility():create_projectile_when_you_are_hit(caster:GetAbsOrigin())
    self:StartIntervalThink(FrameTime())
    local flash_particle = ParticleManager:CreateParticle(
        "particles/econ/events/ti6/hero_levelup_ti6_flash_hit_magic.vpcf",
        PATTACH_ABSORIGIN,
        self:GetParent()
    )
    ParticleManager:ReleaseParticleIndex(flash_particle)

    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_PhantomLancer.SpiritLance.Throw")

end





function lua_modifier_vagabond_death_light:OnIntervalThink()
    local responses = {
        "phantom_lancer_plance_ability_doppelwalk_03",
        "phantom_lancer_plance_cast_01",
        "phantom_lancer_plance_cast_02",
        "phantom_lancer_plance_cast_03",
        "phantom_lancer_plance_attack_clone_22"
    }


    self:GetCaster():EmitSound(responses[RandomInt(1, #responses)])



    self:Destroy()
    self:StartIntervalThink(-1)
end




function lua_modifier_vagabond_death_light:OnDestroy()
    if not IsServer() then return end

    self:GetParent():FadeGesture(ACT_DOTA_VICTORY)

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    self:GetParent():Purge(false,true,false,true,true)
end
