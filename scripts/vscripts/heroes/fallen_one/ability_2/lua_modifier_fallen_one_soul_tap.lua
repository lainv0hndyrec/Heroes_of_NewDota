

lua_modifier_fallen_one_soul_tap_slow = class({})


function lua_modifier_fallen_one_soul_tap_slow:IsHidden() return false end
function lua_modifier_fallen_one_soul_tap_slow:IsDebuff() return true end
function lua_modifier_fallen_one_soul_tap_slow:IsPurgable() return true end
function lua_modifier_fallen_one_soul_tap_slow:IsPurgeException() return true end


function lua_modifier_fallen_one_soul_tap_slow:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end


function lua_modifier_fallen_one_soul_tap_slow:OnCreated(kv)
    self.ms_slow = self:GetAbility():GetSpecialValueFor("aoe_tappering_slow_percent")
    self.interval = (self.ms_slow/self:GetDuration())*0.1
    self:StartIntervalThink(0.1)
end


function lua_modifier_fallen_one_soul_tap_slow:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_fallen_one_soul_tap_slow:OnIntervalThink()
    self.ms_slow = math.max(self.ms_slow-self.interval,0)
end


function lua_modifier_fallen_one_soul_tap_slow:GetModifierMoveSpeedBonus_Percentage()
    if not self.ms_slow then return end
    return -self.ms_slow
end


function lua_modifier_fallen_one_soul_tap_slow:GetEffectName()
    return "particles/units/heroes/hero_mars/mars_spear_impact_debuff_embers.vpcf"
end


function lua_modifier_fallen_one_soul_tap_slow:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

















--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
lua_modifier_fallen_one_soul_tap_buff = class({})


function lua_modifier_fallen_one_soul_tap_buff:IsHidden() return false end
function lua_modifier_fallen_one_soul_tap_buff:IsDebuff() return false end
function lua_modifier_fallen_one_soul_tap_buff:IsPurgable() return true end
function lua_modifier_fallen_one_soul_tap_buff:IsPurgeException() return true end


function lua_modifier_fallen_one_soul_tap_buff:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
    return dfunc
end


function lua_modifier_fallen_one_soul_tap_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_ms_bonus")
end


function lua_modifier_fallen_one_soul_tap_buff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("attack_bonus")
end


function lua_modifier_fallen_one_soul_tap_buff:OnTakeDamage(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    if event.attacker:IsAlive() == false then return end
    if event.unit:IsAlive() == false then return end
    if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end

    self:GetParent():EmitSound("Hero_DoomBringer.LvlDeath")

    local slash = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf",
        PATTACH_POINT_FOLLOW,self:GetParent()
    )
    ParticleManager:SetParticleControl(slash,0,self:GetParent():GetAbsOrigin())

    local lf_particle = ParticleManager:CreateParticle(
        "particles/generic_gameplay/generic_lifesteal.vpcf",
        PATTACH_POINT_FOLLOW,self:GetParent()
    )
    ParticleManager:SetParticleControl(lf_particle,0,self:GetParent():GetAbsOrigin())



    local lifesteal = self:GetAbility():GetSpecialValueFor("life_steal")*0.01
    local heal = event.damage*lifesteal
    self:GetParent():Heal(heal,self:GetAbility())

    self:Destroy()
end



function lua_modifier_fallen_one_soul_tap_buff:GetActivityTranslationModifiers()
    return "infernal_blade"
end
