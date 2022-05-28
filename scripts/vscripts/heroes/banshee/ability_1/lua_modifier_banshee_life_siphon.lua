lua_modifier_banshee_life_siphon = class({})

function lua_modifier_banshee_life_siphon:IsDebuff() return false end
function lua_modifier_banshee_life_siphon:IsHidden() return false end
function lua_modifier_banshee_life_siphon:IsPurgable() return false end
function lua_modifier_banshee_life_siphon:IsPurgeException() return false end


function lua_modifier_banshee_life_siphon:OnCreated(kv)
    if not IsServer() then return end

    if not kv.target then return end

    self.target = EntIndexToHScript(kv.target)

    if not self.particle then

        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_death_prophet/death_prophet_spiritsiphon.vpcf",
            PATTACH_POINT_FOLLOW,self:GetParent()
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,0,self:GetParent(),
            PATTACH_POINT_FOLLOW,"attach_hitloc",
            Vector(0,0,0),false
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,1,self.target,
            PATTACH_POINT_FOLLOW,"attach_hitloc",
            Vector(0,0,0),false
        )

        ParticleManager:SetParticleControl(
        self.particle,5,Vector(self:GetDuration(),0,0)
        )

    end

    self:GetParent():EmitSound("Hero_DeathProphet.SpiritSiphon.Cast")

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end


function lua_modifier_banshee_life_siphon:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_banshee_life_siphon:OnIntervalThink()
    if not IsServer() then return end

    if self.target:IsAlive() == false then
        self:Destroy()
        return
    end

    if self.target:IsMagicImmune() then
        self:Destroy()
        return
    end

    if self.target:IsInvulnerable() then
        self:Destroy()
        return
    end

    if self.target:IsOutOfGame() then
        self:Destroy()
        return
    end



    if self:GetParent():IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetParent():IsInvulnerable() then
        self:Destroy()
        return
    end

    if self:GetParent():IsOutOfGame() then
        self:Destroy()
        return
    end


    local diff = self:GetParent():GetAbsOrigin() - self.target:GetAbsOrigin()
    local length = diff:Length2D()
    local cast_range = self:GetAbility():GetEffectiveCastRange(self:GetParent():GetAbsOrigin(),self:GetParent())
    local snap_range = self:GetAbility():GetSpecialValueFor("snap_range")
    local max_tether = cast_range + snap_range


    if length > max_tether then
        self.target:AddNewModifier(
            self:GetParent(),self:GetAbility(),"modifier_stunned",
            {duration = self:GetAbility():GetSpecialValueFor("snap_stun_duration")}
        )

        self:Destroy()

        self:GetParent():EmitSound("DOTA_Item.SkullBasher")

        return
    end


    local dps = self:GetAbility():GetSpecialValueFor("damage_per_second")
    local talent = self:GetParent():FindAbilityByName("special_bonus_banshee_life_siphon_dmg_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            dps = dps + talent:GetSpecialValueFor("value")
        end
    end

    dps = math.ceil(dps*0.1)

    local dtable = {
        victim = self.target,
        attacker = self:GetParent(),
        damage = dps,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)

    self:GetParent():Heal(dps,self:GetAbility())

end



function lua_modifier_banshee_life_siphon:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
    self:GetParent():StopSound("Hero_DeathProphet.SpiritSiphon.Cast")
    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end
