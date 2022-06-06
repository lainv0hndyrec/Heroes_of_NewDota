LinkLuaModifier( "lua_modifier_boogeyman_depravity_lifesteal", "heroes/boogeyman/ability_3/lua_modifier_boogeyman_depravity", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_boogeyman_fright_night_anim", "heroes/boogeyman/ability_3/lua_modifier_boogeyman_depravity", LUA_MODIFIER_MOTION_NONE )



lua_modifier_boogeyman_depravity_aura = class({})


function lua_modifier_boogeyman_depravity_aura:IsDebuff() return false end
function lua_modifier_boogeyman_depravity_aura:IsHidden() return true end
function lua_modifier_boogeyman_depravity_aura:IsPurgable() return false end
function lua_modifier_boogeyman_depravity_aura:IsPurgeException() return false end
function lua_modifier_boogeyman_depravity_aura:AllowIllusionDuplicate() return true end
function lua_modifier_boogeyman_depravity_aura:RemoveOnDeath() return false end
function lua_modifier_boogeyman_depravity_aura:IsAura() return true end
function lua_modifier_boogeyman_depravity_aura:IsAuraActiveOnDeath() return false end
function lua_modifier_boogeyman_depravity_aura:GetAuraDuration() return 0.0 end
function lua_modifier_boogeyman_depravity_aura:GetModifierAura() return "lua_modifier_boogeyman_depravity_lifesteal" end
function lua_modifier_boogeyman_depravity_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function lua_modifier_boogeyman_depravity_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function lua_modifier_boogeyman_depravity_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function lua_modifier_boogeyman_depravity_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC end
function lua_modifier_boogeyman_depravity_aura:GetAuraEntityReject(target)
    if target:IsCreep() then
        return self:GetAbility():GetToggleState()
    end
    return self:GetCaster():PassivesDisabled()
end


function lua_modifier_boogeyman_depravity_aura:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end


function lua_modifier_boogeyman_depravity_aura:GetModifierAttackSpeedBonus_Constant()

    if self:GetCaster():PassivesDisabled() then
        return 0
    end

    if IsServer() then
        local atkspd_stacks = self:GetAbility():GetSpecialValueFor("devour_stack_atkspd")
        local talent = self:GetParent():FindAbilityByName("special_bonus_boogeyman_depravity_atk_sped_per_stack_up")
        if not talent == false then
            if talent:GetLevel() > 0 then
                atkspd_stacks = atkspd_stacks+talent:GetSpecialValueFor("value")
            end
        end


        local d_stacks = self:GetParent():FindModifierByName("lua_modifier_boogeyman_devour_stacks")
        if not d_stacks == false then
            local count = atkspd_stacks*d_stacks:GetStackCount()
            self:SetStackCount(count)
        end
    end

    return self:GetStackCount()
end













---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
lua_modifier_boogeyman_depravity_lifesteal = class({})


function lua_modifier_boogeyman_depravity_lifesteal:IsDebuff() return false end
function lua_modifier_boogeyman_depravity_lifesteal:IsHidden() return false end
function lua_modifier_boogeyman_depravity_lifesteal:IsPurgable() return false end
function lua_modifier_boogeyman_depravity_lifesteal:IsPurgeException() return false end

function lua_modifier_boogeyman_depravity_lifesteal:DeclareFunctions()
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function lua_modifier_boogeyman_depravity_lifesteal:OnTakeDamage(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end
    if event.unit:IsBuilding() then return end
    if event.unit:IsBaseNPC() == false then return end

    --illusion dying leaves the modifier bugging out
    if not self:GetAbility() then
        self:Destroy()
        return
    end

    local lifesteal = self:GetAbility():GetSpecialValueFor("melee_lifesteal_percent")
    if self:GetParent():GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
        lifesteal = self:GetAbility():GetSpecialValueFor("range_lifesteal_percent")
    end

    local talent = self:GetCaster():FindAbilityByName("special_bonus_boogeyman_depravity_lifesteal_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            lifesteal = lifesteal + talent:GetSpecialValueFor("value")
        end
    end

    local heal = event.damage*lifesteal*0.01

    self:GetParent():Heal(heal,self:GetAbility())


    local particle = ParticleManager:CreateParticle(
        "particles/generic_gameplay/generic_lifesteal.vpcf",
        PATTACH_POINT_FOLLOW,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
end

function lua_modifier_boogeyman_depravity_lifesteal:OnCreated(kv)
    if not IsServer() then return end
    self:OnIntervalThink()
    self:StartIntervalThink(1.0)
end



function lua_modifier_boogeyman_depravity_lifesteal:OnIntervalThink()
    if not IsServer() then return end

    --illusion dying leaves the modifier bugging out
    if not self:GetAbility() then
        self:Destroy()
        return
    end

    if not self.sigil_particle == false then
        ParticleManager:DestroyParticle(self.sigil_particle,false)
        ParticleManager:ReleaseParticleIndex(self.sigil_particle)
        self.sigil_particle = nil
    end

    if not self.sigil_particle then
        self.sigil_particle = ParticleManager:CreateParticle(
            "particles/econ/items/doom/doom_f2p_death_effect/doom_bringer_f2p_death_sigil_c.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
        ParticleManager:SetParticleControl(self.sigil_particle,0,self:GetParent():GetAbsOrigin())
    end

end


function lua_modifier_boogeyman_depravity_lifesteal:OnDestroy()
    if not IsServer() then return end
    if not self.sigil_particle == false then
        ParticleManager:DestroyParticle(self.sigil_particle,false)
        ParticleManager:ReleaseParticleIndex(self.sigil_particle)
        self.sigil_particle = nil
    end
end









---------------------------------------------------------------------------------
--------------------------//SHARD//----------------------------------------------
---------------------------------------------------------------------------------
lua_modifier_boogeyman_fright_night = class({})



function lua_modifier_boogeyman_fright_night:IsDebuff() return false end
function lua_modifier_boogeyman_fright_night:IsHidden() return true end
function lua_modifier_boogeyman_fright_night:IsPurgable() return false end
function lua_modifier_boogeyman_fright_night:IsPurgeException() return false end
function lua_modifier_boogeyman_fright_night:AllowIllusionDuplicate() return true end
function lua_modifier_boogeyman_fright_night:RemoveOnDeath() return false end





function lua_modifier_boogeyman_fright_night:CheckState()
    local active = false

    if self:GetStackCount() == 1 then
        active = true
    end

    local cstate = {
        [MODIFIER_STATE_FLYING] = active,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = active,
        [MODIFIER_STATE_FORCED_FLYING_VISION] = active
    }
    return cstate
end


function lua_modifier_boogeyman_fright_night:DeclareFunctions()
    local dfunc = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return dfunc
end


function lua_modifier_boogeyman_fright_night:OnTakeDamage(event)
    if not IsServer() then return end

    if event.unit ~= self:GetParent() then return end
    if event.attacker == self:GetParent() then return end

    local cd = self:GetAbility():GetCooldown(1)
    self:GetAbility():StartCooldown(cd)
    self:StartIntervalThink(-1)
    self:StartIntervalThink(cd+0.1)
    self:SetStackCount(0)

    local anim_mod = self:GetParent():FindModifierByName("lua_modifier_boogeyman_fright_night_anim")
    if not anim_mod == false then
        anim_mod:Destroy()
    end
end


function lua_modifier_boogeyman_fright_night:OnCreated(kv)
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end


function lua_modifier_boogeyman_fright_night:OnIntervalThink()
    if not IsServer() then return end

    self:StartIntervalThink(-1)
    self:StartIntervalThink(0.1)
    self:SetStackCount(0)

    local anim_mod = self:GetParent():FindModifierByName("lua_modifier_boogeyman_fright_night_anim")

    if GameRules:IsDaytime() == false then

        if self:GetAbility():IsCooldownReady() then

            local mod = self:GetParent():FindModifierByName("lua_modifier_boogeyman_devour_stacks")
            if not mod == false then

                if mod:GetStackCount() >= 3 then

                    if not anim_mod then
                        self:GetParent():AddNewModifier(
                            self:GetParent(),self:GetAbility(),
                            "lua_modifier_boogeyman_fright_night_anim",{}
                        )
                    end

                    self:SetStackCount(1)
                    return
                end
            end
        end
    end

    if not anim_mod == false then
        anim_mod:Destroy()
    end
end


















---------------------------------------------------------------------------------
--------------------------//Anim//----------------------------------------------
---------------------------------------------------------------------------------
lua_modifier_boogeyman_fright_night_anim = class({})



function lua_modifier_boogeyman_fright_night_anim:IsDebuff() return false end
function lua_modifier_boogeyman_fright_night_anim:IsHidden() return true end
function lua_modifier_boogeyman_fright_night_anim:IsPurgable() return false end
function lua_modifier_boogeyman_fright_night_anim:IsPurgeException() return false end
function lua_modifier_boogeyman_fright_night_anim:AllowIllusionDuplicate() return true end



function lua_modifier_boogeyman_fright_night_anim:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
    return dfunc
end


function lua_modifier_boogeyman_fright_night_anim:GetActivityTranslationModifiers()
    return "hunter_night"
end
