LinkLuaModifier( "lua_modifier_fallen_one_revelation_heal", "heroes/fallen_one/ability_1/lua_modifier_fallen_one_revelation", LUA_MODIFIER_MOTION_NONE )


lua_modifier_fallen_one_revelation_delay = class({})

function lua_modifier_fallen_one_revelation_delay:IsDebuff() return false end
function lua_modifier_fallen_one_revelation_delay:IsHidden() return true end
function lua_modifier_fallen_one_revelation_delay:IsPurgable() return false end
function lua_modifier_fallen_one_revelation_delay:IsPurgeException() return false end



function lua_modifier_fallen_one_revelation_delay:OnCreated(kv)
    if not IsServer() then return end

    self:GetParent():EmitSound("Hero_DoomBringer.ScorchedEarthAura")

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/fallen_one/ability_1/fallen_one_revelation_aoe_sign.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,1,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,2,self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)


    local delay = self:GetAbility():GetSpecialValueFor("blast_delay")
    self:StartIntervalThink(delay)
    -- DebugDrawCircle(
    --     self:GetParent():GetAbsOrigin(),Vector(255,0,0),
    --     0.5, self:GetAbility():GetAOERadius(),false,delay
    -- )

end



function lua_modifier_fallen_one_revelation_delay:OnIntervalThink()
    if not IsServer() then return end

    self:StartIntervalThink(-1)

    self:GetParent():EmitSound("Hero_DoomBringer.DevourCast")

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/fallen_one/ability_1/fallen_one_revelation_blast.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    local aoe_range = self:GetAbility():GetAOERadius()
    local aoe_dmg = self:GetAbility():GetSpecialValueFor("blast_damage")
    local heal_time = self:GetAbility():GetSpecialValueFor("blast_heal_time")

    --talent
    local talent = self:GetCaster():FindAbilityByName("special_bonus_fallen_one_revelation_dmg_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            aoe_dmg = aoe_dmg + talent:GetSpecialValueFor("value")
        end
    end

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetParent():GetAbsOrigin(),
        nil,aoe_range,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,false
    )

    for i=1, #enemies do

        enemies[i]:AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "lua_modifier_fallen_one_revelation_heal",
            {duration = heal_time}
        )

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = aoe_dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self:GetAbility()
        }

        ApplyDamage(dtable)
    end
end


function lua_modifier_fallen_one_revelation_delay:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_DoomBringer.ScorchedEarthAura")
    UTIL_Remove(self:GetParent())




end
















----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
lua_modifier_fallen_one_revelation_heal = class({})


function lua_modifier_fallen_one_revelation_heal:IsDebuff() return true end
function lua_modifier_fallen_one_revelation_heal:IsHidden() return false end
function lua_modifier_fallen_one_revelation_heal:IsPurgable() return true end
function lua_modifier_fallen_one_revelation_heal:IsPurgeException() return true end

function lua_modifier_fallen_one_revelation_heal:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return dfunc
end


function lua_modifier_fallen_one_revelation_heal:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_burn_debuff_glow.vpcf"
end


function lua_modifier_fallen_one_revelation_heal:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end


function lua_modifier_fallen_one_revelation_heal:OnTakeDamage(event)

    if event.unit:IsBaseNPC() == false then return end
    if event.attacker:IsBaseNPC() == false then return end
    if event.unit ~= self:GetParent() then return end
    if event.attacker ~= self:GetCaster() then return end
    if event.inflictor ~= self:GetAbility() then return end

    local dmg_to_heal = self:GetAbility():GetSpecialValueFor("blast_heal_percent")*0.01

    self:SetStackCount((dmg_to_heal*event.damage)/self:GetDuration())
end


function lua_modifier_fallen_one_revelation_heal:GetModifierConstantHealthRegen()
    return self:GetStackCount()
end
