LinkLuaModifier( "lua_modifier_banshee_death_veil_dot", "heroes/banshee/ability_2/lua_modifier_banshee_death_veil", LUA_MODIFIER_MOTION_NONE )

lua_modifier_banshee_death_veil_wall = class({})

function lua_modifier_banshee_death_veil_wall:IsDebuff() return false end
function lua_modifier_banshee_death_veil_wall:IsHidden() return true end
function lua_modifier_banshee_death_veil_wall:IsPurgable() return false end
function lua_modifier_banshee_death_veil_wall:IsPurgeException() return false end



function lua_modifier_banshee_death_veil_wall:OnCreated(kv)
    if not IsServer() then return end

    if not kv.wall_radius then return end

    self.wall_radius = kv.wall_radius

    self:OnIntervalThink()
    self:StartIntervalThink(FrameTime())

    local vision = self:GetAbility():GetSpecialValueFor("vision_range")

    AddFOWViewer(
        self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(),
        vision,self:GetDuration(),false
    )

end



function lua_modifier_banshee_death_veil_wall:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end



function lua_modifier_banshee_death_veil_wall:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetParent():GetAbsOrigin(),
        nil,self.wall_radius,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false
    )

    for i=1, #enemies do
        local diff = enemies[i]:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
        diff.z = 0
        local normal = diff:Normalized()
        local enemy_hull = enemies[i]:GetHullRadius()
        local push = enemy_hull+self.wall_radius
        local new_pos = self:GetParent():GetAbsOrigin()+(push*normal)

        FindClearSpaceForUnit(enemies[i],new_pos,false)

        enemies[i]:AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "lua_modifier_banshee_death_veil_dot",
            {duration = 0.2}
        )
    end

end













----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


lua_modifier_banshee_death_veil_particle = class({})

function lua_modifier_banshee_death_veil_particle:IsDebuff() return false end
function lua_modifier_banshee_death_veil_particle:IsHidden() return true end
function lua_modifier_banshee_death_veil_particle:IsPurgable() return false end
function lua_modifier_banshee_death_veil_particle:IsPurgeException() return false end



function lua_modifier_banshee_death_veil_particle:OnCreated(kv)
    if not IsServer() then return end

    if not kv.end_x then return end

    if not self.particle then

        local end_pos = Vector(kv.end_x,kv.end_y,kv.end_z)

        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_dark_seer/dark_seer_wall_of_replica.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,self:GetParent()
        )

        ParticleManager:SetParticleControl(self.particle,1,end_pos)
        ParticleManager:SetParticleControl(self.particle,2,Vector(0,90,0))
        ParticleManager:SetParticleControl(self.particle,60,Vector(225,0,225))
        ParticleManager:SetParticleControl(self.particle,61,Vector(1,0,0))

    end

    self:GetParent():EmitSound("Hero_DeathProphet.Silence.Cast")
    self:GetParent():EmitSound("Hero_DeathProphet.SpiritSiphon.Target")

end



function lua_modifier_banshee_death_veil_particle:OnDestroy()
    if not IsServer() then return end

    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end

    self:GetParent():StopSound("Hero_DeathProphet.SpiritSiphon.Target")
    UTIL_Remove(self:GetParent())
end





























----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

lua_modifier_banshee_death_veil_dot = class({})

function lua_modifier_banshee_death_veil_dot:IsDebuff() return true end
function lua_modifier_banshee_death_veil_dot:IsHidden() return true end
function lua_modifier_banshee_death_veil_dot:IsPurgable() return false end
function lua_modifier_banshee_death_veil_dot:IsPurgeException()return false end

function lua_modifier_banshee_death_veil_dot:GetEffectName()
    return "particles/units/heroes/banshee/ability_2/banshee_death_veil_wall_burn.vpcf"
end


function lua_modifier_banshee_death_veil_dot:DamageOverTime()
    local dps = self:GetAbility():GetSpecialValueFor("wall_damage")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_banshee_death_veil_dmg_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            dps = dps + talent:GetSpecialValueFor("value")
        end
    end


    local dmg = math.ceil(dps*0.2)
    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)
end


function lua_modifier_banshee_death_veil_dot:OnCreated(kv)
    if not IsServer() then return end
    self:OnIntervalThink()
    self:StartIntervalThink(0.2)
end


function lua_modifier_banshee_death_veil_dot:OnIntervalThink()
    if not IsServer() then return end
    self:DamageOverTime()
end


function lua_modifier_banshee_death_veil_dot:OnDestroy()
    if not IsServer() then return end
    self:StartIntervalThink(-1)
end
