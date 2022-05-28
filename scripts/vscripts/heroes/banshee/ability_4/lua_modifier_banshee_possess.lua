LinkLuaModifier( "lua_modifier_banshee_possess_buff", "heroes/banshee/ability_4/lua_modifier_banshee_possess", LUA_MODIFIER_MOTION_NONE )


lua_modifier_banshee_possess_ride = class({})


function lua_modifier_banshee_possess_ride:IsDebuff() return false end
function lua_modifier_banshee_possess_ride:IsHidden() return false end
function lua_modifier_banshee_possess_ride:IsPurgable() return false end
function lua_modifier_banshee_possess_ride:IsPurgeException() return false end



function lua_modifier_banshee_possess_ride:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
    }
end


function lua_modifier_banshee_possess_ride:GetModifierConstantManaRegen()
    local regen = 1.0

    local talent = self:GetParent():FindAbilityByName("special_bonus_banshee_possess_mana_regen_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            regen = regen + talent:GetSpecialValueFor("value")
        end
    end

    return regen
end


function lua_modifier_banshee_possess_ride:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true
    }
end


function lua_modifier_banshee_possess_ride:OnCreated(kv)
    if not IsServer() then return end

    if not kv.target then return end

    local possess = self:GetParent():FindAbilityByName("lua_ability_banshee_possess")
    if not possess == false then
        possess:SetHidden(true)
    end

    local death_rush = self:GetParent():FindAbilityByName("lua_ability_banshee_possess_death_rush")
    if not death_rush == false then
        death_rush:SetHidden(false)
        if not possess == false then
            death_rush:SetLevel(possess:GetLevel())
        end
    end

    local eject = self:GetParent():FindAbilityByName("lua_ability_banshee_possess_release")
    if not eject == false then
        eject:SetHidden(false)
        if not possess == false then
            eject:SetLevel(possess:GetLevel())
        end
    end


    self.target = EntIndexToHScript(kv.target)


    self:GetParent():EmitSound("Hero_DeathProphet.Exorcism")

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_death_prophet/death_prophet_spirit_model.vpcf",
            PATTACH_POINT_FOLLOW,self.target
        )
        ParticleManager:SetParticleControlEnt(
            self.particle,0,self.target,PATTACH_POINT_FOLLOW,
            "attach_hitloc",Vector(0,0,0),true
        )
    end


    self.target:AddNewModifier(
        self:GetParent(),self:GetAbility(),
        "lua_modifier_banshee_possess_buff",
        {duration = self:GetDuration()}
    )


    self:GetParent():AddNoDraw()
    self:StartIntervalThink(FrameTime())
    self:OnIntervalThink()
end


function lua_modifier_banshee_possess_ride:OnIntervalThink()

    if not IsServer() then return end

    if self.target:IsAlive() == false then
        self:Destroy()
        return
    end

    self:GetParent():SetAbsOrigin(self.target:GetAbsOrigin())
end


function lua_modifier_banshee_possess_ride:OnDestroy()
    if not IsServer() then return end

    --hide and unhide
    local possess = self:GetParent():FindAbilityByName("lua_ability_banshee_possess")
    if not possess == false then
        possess:SetHidden(false)
    end

    local death_rush = self:GetParent():FindAbilityByName("lua_ability_banshee_possess_death_rush")
    if not death_rush == false then
        death_rush:SetHidden(true)
    end

    local eject = self:GetParent():FindAbilityByName("lua_ability_banshee_possess_release")
    if not eject == false then
        eject:SetHidden(true)
    end

    self:GetParent():StopSound("Hero_DeathProphet.Exorcism")

    --particles
    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,true)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end

    if self.target:IsAlive() then
        local possess_buff = self.target:FindModifierByName("lua_modifier_banshee_possess_buff")
        if not possess_buff == false then
            possess_buff:Destroy()
        end

        local siphon_buff = self.target:FindModifierByName("lua_modifier_banshee_life_siphon")
        if not siphon_buff == false then
            siphon_buff:Destroy()
        end
    end

    FindClearSpaceForUnit(self:GetParent(),self:GetParent():GetAbsOrigin(),true)

    self:GetParent():RemoveNoDraw()
    self:StartIntervalThink(-1)
    self.target = nil
end


















------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

lua_modifier_banshee_possess_buff = class({})


function lua_modifier_banshee_possess_buff:IsDebuff() return false end
function lua_modifier_banshee_possess_buff:IsHidden() return false end
function lua_modifier_banshee_possess_buff:IsPurgable() return false end
function lua_modifier_banshee_possess_buff:IsPurgeException() return false end


function lua_modifier_banshee_possess_buff:GetEffectName()
    return "particles/econ/items/rubick/rubick_puppet_master/rubick_telekinesis_puppet_debuff_glow.vpcf"
end


function lua_modifier_banshee_possess_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end


function lua_modifier_banshee_possess_buff:OnCreated(kv)
    if not IsServer() then return end

    if self:GetCaster():HasScepter() then
        if self:GetParent():HasScepter() == false then
            self:GetParent():AddNewModifier(
                self:GetCaster(),self:GetAbility(),
                "modifier_item_ultimate_scepter",
                {duration = self:GetDuration()}
            )
        end
    end

end


function lua_modifier_banshee_possess_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end


function lua_modifier_banshee_possess_buff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("attack_damage_bonus")
end


function lua_modifier_banshee_possess_buff:OnDestroy()
    if not IsServer() then return end
    local scepter_buff = self:GetParent():FindModifierByNameAndCaster("modifier_item_ultimate_scepter",self:GetCaster())
    if not scepter_buff == false then
        scepter_buff:Destroy()
    end
end



















------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

lua_modifier_banshee_possess_rush = class({})

function lua_modifier_banshee_possess_rush:IsDebuff() return false end
function lua_modifier_banshee_possess_rush:IsHidden() return false end
function lua_modifier_banshee_possess_rush:IsPurgable() return true end
function lua_modifier_banshee_possess_rush:IsPurgeException() return true end


function lua_modifier_banshee_possess_rush:GetEffectName()
    return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_buff_i_rubick.vpcf"
end


function lua_modifier_banshee_possess_rush:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end


function lua_modifier_banshee_possess_rush:OnCreated(kv)

    if not IsServer() then return end

    self:GetParent():EmitSound("Hero_DeathProphet.CarrionSwarm.Mortis")

    local ms_bonus = self:GetAbility():GetSpecialValueFor("tapering_ms_bonus")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_banshee_possess_death_rush_ms_bonus_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            ms_bonus = ms_bonus + talent:GetSpecialValueFor("value")
        end
    end

    self:SetStackCount(ms_bonus)

    self.interval  = (self:GetStackCount()/self:GetDuration())*0.1

    self:StartIntervalThink(0.1)

end


function lua_modifier_banshee_possess_rush:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_banshee_possess_rush:OnIntervalThink()
    local stacks = self:GetStackCount() - self.interval
    self:SetStackCount(stacks)
end


function lua_modifier_banshee_possess_rush:GetModifierMoveSpeedBonus_Constant()
    return self:GetStackCount()
end


function lua_modifier_banshee_possess_rush:GetModifierAttackSpeedBonus_Constant()
    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if not shard then return end
    return self:GetStackCount()
end
