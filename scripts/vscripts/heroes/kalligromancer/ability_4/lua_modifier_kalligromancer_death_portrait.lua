LinkLuaModifier( "lua_modifier_kalligromancer_death_portrait_thinker", "heroes/kalligromancer/ability_4/lua_modifier_kalligromancer_death_portrait", LUA_MODIFIER_MOTION_NONE )


lua_modifier_kalligromancer_death_portrait = class({})

function lua_modifier_kalligromancer_death_portrait:IsHidden() return false end

function lua_modifier_kalligromancer_death_portrait:IsDebuff() return true end

function lua_modifier_kalligromancer_death_portrait:IsPurgable() return false end

function lua_modifier_kalligromancer_death_portrait:IsPurgeException() return false end

function lua_modifier_kalligromancer_death_portrait:GetDisableHealing() return 1 end

function lua_modifier_kalligromancer_death_portrait:GetModifierHealthRegenPercentage() return -100 end


function lua_modifier_kalligromancer_death_portrait:CheckState()
    local cstate = {
        [MODIFIER_STATE_STUNNED] = true
    }
    return cstate
end




function lua_modifier_kalligromancer_death_portrait:DeclareFunctions()
    local dfunc = {
        --MODIFIER_PROPERTY_ABSORB_SPELL
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_MODIFIER_ADDED,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_EVENT_ON_UNIT_MOVED
    }

    return dfunc

end




function lua_modifier_kalligromancer_death_portrait:OnCreated(kv)

    if not IsServer() then return end

    self:GetParent():Hold()
    self:GetParent():SetBaseAttackTime(0)

    local image_hp = self:GetAbility():GetSpecialValueFor("portrait_hp")
    local scepter_hp = self:GetAbility():GetSpecialValueFor("scepter_hp")
    if self:GetCaster():HasScepter() then
        image_hp = image_hp + scepter_hp
    end
    self:GetParent():SetHealth(image_hp)


    self.target = self:GetAbility():GetCursorTarget()
    self.transfer_mod = {}


    self.thinker = CreateModifierThinker(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_kalligromancer_death_portrait_thinker",
        { duration = self:GetDuration() },
        self:GetParent():GetAbsOrigin(),
        self:GetCaster():GetTeamNumber(),
        false
    )

    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )

    self:GetParent():EmitSound("Hero_Grimstroke.DarkArtistry.Projectile")

    ParticleManager:SetParticleControlEnt(self.particle,2,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,"follow_origin",self:GetParent():GetAbsOrigin(),false)
    ParticleManager:SetParticleControl(self.particle,60,Vector(255,0,0))
    ParticleManager:SetParticleControl(self.particle,61,Vector(1,0,0))

end




function lua_modifier_kalligromancer_death_portrait:GetModifierIncomingDamage_Percentage(event)

    if not IsServer() then return end

    if event.target:IsAlive() == false then return end
    if event.target ~= self:GetParent() then return end

    local scepter_damage = 0
    if self:GetCaster():HasScepter() then
        scepter_damage = self:GetAbility():GetSpecialValueFor("scepter_damage")
    end


    local additional_damage = (self:GetAbility():GetSpecialValueFor("magic_damage")+scepter_damage)*0.01

    local dtable = {
        victim = self.target,
        attacker = self.thinker,
        damage = additional_damage*event.original_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    if self.target:IsMagicImmune() == false then
        ApplyDamage(dtable)
    end


    local current_hp = event.target:GetHealth()
    event.target:ModifyHealth(current_hp-event.original_damage,self:GetAbility(),true,0)

    if self.target:IsAlive() == false then
        self:Destroy()
    end

    return -100
end




function lua_modifier_kalligromancer_death_portrait:OnModifierAdded(event)
    if event.unit:IsAlive() == false then return end

    if event.unit ~= self:GetParent() then return end

    if event.added_buff == self then return end

    if event.added_buff:IsDebuff() == false then return end

    if self.target:IsAlive() == false then return end

    local mod_name = event.added_buff:GetName()
    local caster = event.added_buff:GetCaster()
    local ability = event.added_buff:GetAbility()
    local d_duration = event.added_buff:GetDuration()

    if d_duration <= 0.0 then return end

    local mod = {caster,ability,mod_name,d_duration}
    table.insert(self.transfer_mod,mod)

    self:GetParent():Purge(false,true,false,false,false)
    self:StartIntervalThink(FrameTime())
end




function lua_modifier_kalligromancer_death_portrait:OnIntervalThink()

    if not IsServer() then return end

    if self.target:IsAlive() == false then return end

    for i=1, #self.transfer_mod do
        local mod = self.transfer_mod[i]

        if self:GetParent():HasModifier(mod[3]) == false then
            self.target:AddNewModifier(
                mod[1],mod[2],mod[3],
                {duration = mod[4]}
            )
        end

    end

    self.transfer_mod = {}
    self:StartIntervalThink(-1)

end




function lua_modifier_kalligromancer_death_portrait:OnUnitMoved(event)
    if not IsServer() then return end

    if self.target:IsAlive() == false then return end

    if event.unit ~= self.target then return end

    local distance = (self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
    local leash_range = self:GetAbility():GetSpecialValueFor("leash_range")

    if distance > leash_range then
        self:Destroy()
    end
end




function lua_modifier_kalligromancer_death_portrait:OnDestroy()
    if not IsServer() then return end
    self:GetParent():ForceKill(false)
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

















lua_modifier_kalligromancer_death_portrait_thinker = class({})

function lua_modifier_kalligromancer_death_portrait_thinker:IsHidden() return true end

function lua_modifier_kalligromancer_death_portrait_thinker:IsDebuff() return false end

function lua_modifier_kalligromancer_death_portrait_thinker:IsPurgable() return false end

function lua_modifier_kalligromancer_death_portrait_thinker:CheckState()
    return {MODIFIER_STATE_INVULNERABLE = true}
end

function lua_modifier_kalligromancer_death_portrait_thinker:OnDestroy()
    UTIL_Remove(self:GetParent())
end
