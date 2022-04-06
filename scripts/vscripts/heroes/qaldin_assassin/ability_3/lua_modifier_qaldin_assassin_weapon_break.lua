LinkLuaModifier( "lua_modifier_qaldin_assassin_weapon_break_disarm", "heroes/qaldin_assassin/ability_3/lua_modifier_qaldin_assassin_weapon_break", LUA_MODIFIER_MOTION_NONE )

lua_modifier_qaldin_assassin_weapon_break = class({})


function lua_modifier_qaldin_assassin_weapon_break:IsHidden() return true end
function lua_modifier_qaldin_assassin_weapon_break:IsDebuff() return false end
function lua_modifier_qaldin_assassin_weapon_break:IsPurgable() return false end
function lua_modifier_qaldin_assassin_weapon_break:IsPurgeException() return false end


function lua_modifier_qaldin_assassin_weapon_break:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return dfunc
end




function lua_modifier_qaldin_assassin_weapon_break:GetModifierPreAttack_CriticalStrike(event)
    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end

    if self:GetAbility():IsCooldownReady() == false then return end

    if self:GetParent():PassivesDisabled() == true then return end

    self.atk_record = event.record

    local crit = self:GetAbility():GetSpecialValueFor("crit_percent")
    local talent = self:GetCaster():FindAbilityByName("lua_ability_qaldin_assassin_weapon_break_crit_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            crit = crit + talent:GetSpecialValueFor("value")
        end
    end

    return crit
end




function lua_modifier_qaldin_assassin_weapon_break:OnAttackLanded(event)
    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end

    local cd = self:GetAbility():GetCooldownTime()
    local atk_cd = self:GetAbility():GetSpecialValueFor("cd_per_atk")

    if cd > 0 then
        self:GetAbility():EndCooldown()
        self:GetAbility():StartCooldown(cd-atk_cd)
    else

        if self.atk_record ~= event.record then return end

        self.atk_record = -1

        self:GetParent():EmitSound("Hero_BountyHunter.Jinada")

        local lvl = self:GetAbility():GetLevel()
        local e_cd = self:GetAbility():GetEffectiveCooldown(lvl-1)
        self:GetAbility():StartCooldown(e_cd)

        if event.target:IsAlive() == false then return end

        event.target:AddNewModifier(
            self:GetCaster(),self:GetAbility(),"lua_modifier_qaldin_assassin_weapon_break_disarm",
            {duration = self:GetAbility():GetSpecialValueFor("disarm_duration")}
        )

    end
end


























lua_modifier_qaldin_assassin_weapon_break_disarm = class({})

function lua_modifier_qaldin_assassin_weapon_break_disarm:IsHidden() return false end
function lua_modifier_qaldin_assassin_weapon_break_disarm:IsDebuff() return true end
function lua_modifier_qaldin_assassin_weapon_break_disarm:IsPurgable() return true end
function lua_modifier_qaldin_assassin_weapon_break_disarm:IsPurgeException() return true end


function lua_modifier_qaldin_assassin_weapon_break_disarm:CheckState()
    local cstate = {
        [MODIFIER_STATE_DISARMED] = true
    }
    return cstate
end


function lua_modifier_qaldin_assassin_weapon_break_disarm:GetEffectName()
    return "particles/units/heroes/hero_sniper/concussive_grenade_disarm.vpcf"
end


function lua_modifier_qaldin_assassin_weapon_break_disarm:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


-- function lua_modifier_qaldin_assassin_weapon_break_disarm:OnCreated(kv)
--     if not IsServer() then return end
--
--     if not self.particle then
--         self.particle = ParticleManager:CreateParticle(
--             "particles/units/heroes/hero_sniper/concussive_grenade_disarm.vpcf",
--             PATTACH_OVERHEAD_FOLLOW,self:GetParent()
--         )
--
--         ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
--     end
--
-- end
--
--
-- function lua_modifier_qaldin_assassin_weapon_break_disarm:OnRefresh(kv)
--     self:OnCreated(kv)
-- end
--
--
--
--
-- function lua_modifier_qaldin_assassin_weapon_break_disarm:OnDestroy()
--     if not self.particle == false then
--         ParticleManager:DestroyParticle(self.particle,false)
--         ParticleManager:ReleaseParticleIndex(self.particle)
--         self.particle = nil
--     end
-- end
