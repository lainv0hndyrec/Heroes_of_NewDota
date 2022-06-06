LinkLuaModifier( "lua_modifier_rogue_golem_rock_locker_root", "heroes/rogue_golem/ability_1/lua_modifier_rogue_golem_rock_locker", LUA_MODIFIER_MOTION_NONE )

lua_modifier_rogue_golem_rock_locker_thinker = class({})


function lua_modifier_rogue_golem_rock_locker_thinker:IsDebuff() return false end
function lua_modifier_rogue_golem_rock_locker_thinker:IsHidden() return true end
function lua_modifier_rogue_golem_rock_locker_thinker:IsPurgable() return false end
function lua_modifier_rogue_golem_rock_locker_thinker:IsPurgeException() return false end


function lua_modifier_rogue_golem_rock_locker_thinker:OnCreated(kv)
    if not IsServer() then return end
    self.phase = 0

    if not self.particle then
        self.particle = ParticleManager:CreateParticleForTeam(
            "particles/units/heroes/rogue_golem/ability_1/rogue_golem_rock_locker_delay.vpcf",
            PATTACH_ABSORIGIN,self:GetParent(),self:GetParent():GetTeam()
        )
        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    end


    local delay = self:GetAbility():GetSpecialValueFor("delay_time")
    self:StartIntervalThink(delay)

end



function lua_modifier_rogue_golem_rock_locker_thinker:OnIntervalThink()
    if not IsServer() then return end


    local aoe_radius = self:GetAbility():GetAOERadius()

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetParent():GetAbsOrigin(),
        nil,aoe_radius,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER ,false
    )

    local root_duration = self:GetRemainingTime()

    for i=1, #enemies do

        if enemies[i]:HasModifier("lua_modifier_rogue_golem_rock_locker_root") == false then
            enemies[i]:AddNewModifier(
                self:GetCaster(),self:GetAbility(),
                "lua_modifier_rogue_golem_rock_locker_root",
                {duration = root_duration}
            )
        end
    end

    if self.phase == 0 then
        if not self.particle == false then
            ParticleManager:DestroyParticle(self.particle,true)
            ParticleManager:ReleaseParticleIndex(self.particle)
            self.particle = nil
        end

        local particle = ParticleManager:CreateParticle(
            "particles/units/heroes/rogue_golem/ability_1/rogue_golem_rock_locker_pop.vpcf",
            PATTACH_ABSORIGIN,self:GetCaster()
        )
        ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())


        if not self.particle_rock then
            self.particle_rock = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_tiny/tiny_avalanche_lvl1.vpcf",
                PATTACH_ABSORIGIN,self:GetParent()
            )
            ParticleManager:SetParticleControl(self.particle_rock,0,self:GetParent():GetAbsOrigin()+Vector(160,0,0))
            ParticleManager:SetParticleControl(self.particle_rock,1,Vector(180,0,0))
        end

        self:GetParent():EmitSound("Ability.Avalanche")
        self:StartIntervalThink(0.25)
        self.phase = 1
        return
    end
end



function lua_modifier_rogue_golem_rock_locker_thinker:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)

    if not self.particle_rock == false then
        ParticleManager:DestroyParticle(self.particle_rock,true)
        ParticleManager:ReleaseParticleIndex(self.particle_rock)
        self.particle_rock = nil
    end

    UTIL_Remove(self:GetParent())
end











-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------



lua_modifier_rogue_golem_rock_locker_root = class({})


function lua_modifier_rogue_golem_rock_locker_root:IsDebuff() return true end
function lua_modifier_rogue_golem_rock_locker_root:IsHidden() return true end
function lua_modifier_rogue_golem_rock_locker_root:IsPurgable() return true end
function lua_modifier_rogue_golem_rock_locker_root:IsPurgeException() return true end



function lua_modifier_rogue_golem_rock_locker_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end



function lua_modifier_rogue_golem_rock_locker_root:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end



function lua_modifier_rogue_golem_rock_locker_root:GetModifierPhysicalArmorBonus(event)
    return -self:GetAbility():GetSpecialValueFor("armor_reduction")
end



function lua_modifier_rogue_golem_rock_locker_root:OnCreated(kv)
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor("effect_duration")
    local damage = self:GetAbility():GetSpecialValueFor("damage_over_time")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_rogue_golem_rock_locker_dmg_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            damage = damage + talent:GetSpecialValueFor("value")
        end
    end

    local tdamage = damage/duration
    self.interval_dmg = tdamage*0.25

    self:StartIntervalThink(0.25)
    self:OnIntervalThink()

    self:GetParent():InterruptMotionControllers(true)
end



function lua_modifier_rogue_golem_rock_locker_root:OnIntervalThink()
    if not IsServer() then return end

    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.interval_dmg,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)
end
