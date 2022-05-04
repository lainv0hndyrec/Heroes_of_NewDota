lua_modifier_unfathomed_overwhelming_presence = class({})


function lua_modifier_unfathomed_overwhelming_presence:IsHidden() return false end

function lua_modifier_unfathomed_overwhelming_presence:IsDebuff() return true end

function lua_modifier_unfathomed_overwhelming_presence:IsPurgable() return true end

function lua_modifier_unfathomed_overwhelming_presence:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return dfunc
end





function lua_modifier_unfathomed_overwhelming_presence:OnCreated(kv)
    self.is_push = false --pull if false
    self.eorder_ability = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_ethereal_order")

    if not self.eorder_ability == false then
        self.is_push = self.eorder_ability:GetToggleState()
    end

    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/unfathomed/ability_1/overwhelming_presence_wave_modifier.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControl(self.particle ,0,self:GetParent():GetAbsOrigin())
    if self.is_push == true then
        ParticleManager:SetParticleControl(self.particle ,60,Vector(255,0,255))
    else
        ParticleManager:SetParticleControl(self.particle ,60,Vector(0,255,255))
    end

end





function lua_modifier_unfathomed_overwhelming_presence:OnRefresh(kv)
    self.is_push = false --pull if false
    self.eorder_ability = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_ethereal_order")

    if not self.eorder_ability == false then
        self.is_push = self.eorder_ability:GetToggleState()
    end

    if not self.particle == false then
        if self.is_push == true then
            ParticleManager:SetParticleControl(self.particle ,60,Vector(255,0,255))
        else
            ParticleManager:SetParticleControl(self.particle ,60,Vector(0,255,255))
        end
    end

end





function lua_modifier_unfathomed_overwhelming_presence:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow_effect")
end



function lua_modifier_unfathomed_overwhelming_presence:GetModifierDamageOutgoing_Percentage(event)
    if self.is_push == false then return end

    if not event.attacker then return end

    if event.attacker:IsAlive() == false then return end

    if event.attacker ~= self:GetParent() then return end

    local teffect = self:GetAbility():GetSpecialValueFor("toggle_effect")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unfathomed_overwhelming_presence_effect")
    if not talent == false then
        if talent:GetLevel() > 0 then
            teffect = teffect+talent:GetSpecialValueFor("value")
        end
    end

    return -teffect
end




function lua_modifier_unfathomed_overwhelming_presence:GetModifierIncomingDamage_Percentage(event)
    if self.is_push == true then return end

    if not event.attacker then return end

    if event.attacker:IsAlive() == false then return end

    if event.attacker ~= self:GetCaster() then return end

    local teffect = self:GetAbility():GetSpecialValueFor("toggle_effect")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unfathomed_overwhelming_presence_effect")
    if not talent == false then
        if talent:GetLevel() > 0 then
            teffect = teffect+talent:GetSpecialValueFor("value")
        end
    end

    return teffect
end




function lua_modifier_unfathomed_overwhelming_presence:OnDestroy()
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end
