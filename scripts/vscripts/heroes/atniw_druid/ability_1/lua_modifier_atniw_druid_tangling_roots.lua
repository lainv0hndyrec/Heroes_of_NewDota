LinkLuaModifier( "lua_modifier_atniw_druid_tangling_roots_debuff", "heroes/atniw_druid/ability_1/lua_modifier_atniw_druid_tangling_roots", LUA_MODIFIER_MOTION_NONE )




lua_modifier_atniw_druid_tangling_roots_thinker = class({})

function lua_modifier_atniw_druid_tangling_roots_thinker:IsDebuff() return false end
function lua_modifier_atniw_druid_tangling_roots_thinker:IsHidden() return true end
function lua_modifier_atniw_druid_tangling_roots_thinker:IsPurgable() return false end
function lua_modifier_atniw_druid_tangling_roots_thinker:IsPurgeException() return false end



function lua_modifier_atniw_druid_tangling_roots_thinker:OnCreated(kv)
    if not IsServer() then return end

    if not kv.norm_x then return end

    self.enemies = {}
    self.phase = 0
    self.direction = Vector(kv.norm_x,kv.norm_y,kv.norm_z)
    self.aoe = self:GetAbility():GetAOERadius()
    self.length = self:GetAbility():GetEffectiveCastRange(self:GetParent():GetAbsOrigin(),self:GetParent())
    self.loop = math.floor(self.length/self.aoe)
    self.debuff_duration = self:GetAbility():GetSpecialValueFor("stun_duration")

    self.particles = {}
    for i=1,self.loop do
        self.particles[i] = ParticleManager:CreateParticle(
            "particles/units/heroes/atniw_druid/ability_1/tangling_roots_delay.vpcf",
            PATTACH_ABSORIGIN,self:GetParent()
        )
        local pos = self:GetParent():GetAbsOrigin()+(self.direction*self.aoe*i)
        pos = GetGroundPosition(pos,self:GetCaster())
        ParticleManager:SetParticleControl(self.particles[i],0,pos)
    end

    self:StartIntervalThink(1.0)
end



function lua_modifier_atniw_druid_tangling_roots_thinker:OnIntervalThink()

    if self.phase == 0 then

        for i=1,self.loop do
            ParticleManager:DestroyParticle(self.particles[i],false)
            ParticleManager:ReleaseParticleIndex(self.particles[i])
            self.particles[i] = nil

            self.particles[i] = ParticleManager:CreateParticle(
                "particles/units/heroes/atniw_druid/ability_1/tangling_roots.vpcf",
                PATTACH_ABSORIGIN,self:GetParent()
            )
            local pos = self:GetParent():GetAbsOrigin()+(self.direction*self.aoe*i)
            pos = GetGroundPosition(pos,self:GetCaster())
            ParticleManager:SetParticleControl(self.particles[i],0,pos)


            local enemies = FindUnitsInRadius(
                self:GetParent():GetTeam(),pos,nil,
                self.aoe,DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
            )

            for j=1, #enemies do
                local pass = true

                for k=1, #self.enemies do
                    if self.enemies[k] == enemies[j] then
                        pass = false
                        break
                    end
                end

                if pass == true then
                    table.insert(self.enemies,enemies[j])

                    enemies[j]:AddNewModifier(
                        self:GetCaster(),self:GetAbility(),
                        "lua_modifier_atniw_druid_tangling_roots_debuff",
                        {duration = self.debuff_duration}
                    )

                end

            end

        end

        self.phase = 1
        return
    end


    if self.phase == 1 then
        for i=1,self.loop do
            ParticleManager:DestroyParticle(self.particles[i],false)
            ParticleManager:ReleaseParticleIndex(self.particles[i])
            self.particles[i] = nil
        end
        self.phase = 2
        return
    end

    self:StartIntervalThink(-1.0)
end














--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


lua_modifier_atniw_druid_tangling_roots_debuff = class({})

function lua_modifier_atniw_druid_tangling_roots_debuff:IsDebuff() return true end
function lua_modifier_atniw_druid_tangling_roots_debuff:IsHidden() return true end
function lua_modifier_atniw_druid_tangling_roots_debuff:IsPurgable() return true end
function lua_modifier_atniw_druid_tangling_roots_debuff:IsPurgeException() return true end
function lua_modifier_atniw_druid_tangling_roots_debuff:GetPriority() return MODIFIER_PRIORITY_ULTRA end
function lua_modifier_atniw_druid_tangling_roots_debuff:GetEffectName() return "particles/units/heroes/atniw_druid/ability_1/tangling_roots_hold.vpcf" end
function lua_modifier_atniw_druid_tangling_roots_debuff:GetModifierProvidesFOWVision() return 1 end

function lua_modifier_atniw_druid_tangling_roots_debuff:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }
end


function lua_modifier_atniw_druid_tangling_roots_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
    }
end


function lua_modifier_atniw_druid_tangling_roots_debuff:GetOverrideAnimation()
    return ACT_DOTA_DISABLED
end


function lua_modifier_atniw_druid_tangling_roots_debuff:OnCreated(kv)
    if not IsServer() then return end
    self.damage = self:GetAbility():GetSpecialValueFor("damage_per_sec")*0.1

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end


function lua_modifier_atniw_druid_tangling_roots_debuff:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():IsAlive() == false then return end

    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)
end


function lua_modifier_atniw_druid_tangling_roots_debuff:OnDestroy()
    if not IsServer() then return end

    self:StartIntervalThink(-1)

    self:OnIntervalThink()
end
