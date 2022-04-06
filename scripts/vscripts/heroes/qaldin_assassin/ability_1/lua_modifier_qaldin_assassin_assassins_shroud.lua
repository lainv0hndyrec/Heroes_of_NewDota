LinkLuaModifier( "lua_modifier_qaldin_assassin_assassins_shroud_as", "heroes/qaldin_assassin/ability_1/lua_modifier_qaldin_assassin_assassins_shroud", LUA_MODIFIER_MOTION_NONE )


lua_modifier_qaldin_assassin_assassins_shroud = class({})


function lua_modifier_qaldin_assassin_assassins_shroud:IsHidden() return true end
function lua_modifier_qaldin_assassin_assassins_shroud:IsDebuff() return false end
function lua_modifier_qaldin_assassin_assassins_shroud:IsPurgable() return false end
function lua_modifier_qaldin_assassin_assassins_shroud:IsPurgeException() return false end




function lua_modifier_qaldin_assassin_assassins_shroud:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
    }
    return dfunc
end


function lua_modifier_qaldin_assassin_assassins_shroud:CheckState()
    local fade = false
    local fade_time = 1+self:GetAbility():GetSpecialValueFor("fade_time")

    if self:GetRemainingTime() <= -fade_time then
        fade = true
    end

    local cstate = {
        [MODIFIER_STATE_INVISIBLE] = fade,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return cstate
end


function lua_modifier_qaldin_assassin_assassins_shroud:GetModifierInvisibilityLevel()
    return 1
end


function lua_modifier_qaldin_assassin_assassins_shroud:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("ms_bonus_percent")
end


function lua_modifier_qaldin_assassin_assassins_shroud:OnAttack(event)
    if event.attacker:IsAlive() == false then return end
	if event.attacker ~= self:GetParent() then return end
	self:Destroy()
end


function lua_modifier_qaldin_assassin_assassins_shroud:OnAbilityFullyCast(event)
    if event.unit:IsAlive() == false then return end
	if event.unit ~= self:GetParent() then return end
	if event.ability == self:GetAbility() then return end
    if event.ability:GetName() == "lua_ability_qaldin_assassin_qaldin_eye" then return end
    if event.ability:GetName() == "lua_ability_qaldin_assassin_qaldin_eye_detonate_hero" then return end


	self:Destroy()
end


function lua_modifier_qaldin_assassin_assassins_shroud:OnCreated(kv)
    if not IsServer() then return end

    self:GetParent():EmitSound("Hero_BountyHunter.WindWalk")

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_bounty_hunter/bounty_loadout.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )

    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())


    self:GetParent():AddNewModifier(
        self:GetParent(),self:GetAbility(),
        "lua_modifier_qaldin_assassin_assassins_shroud_as",
        {}
    )

    self:StartIntervalThink(1.0)
end


function lua_modifier_qaldin_assassin_assassins_shroud:OnIntervalThink()
    if not IsServer() then return end

    local mana_per_sec = self:GetAbility():GetSpecialValueFor("mana_per_sec")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_qaldin_assassin_assassins_shroud_minus_mana_per_sec")
    if not talent == false then
        if talent:GetLevel() > 0 then
            mana_per_sec = mana_per_sec - talent:GetSpecialValueFor("value")
        end
    end


    local current_mana = self:GetParent():GetMana()

    if current_mana >= mana_per_sec then
        self:GetParent():ReduceMana(mana_per_sec)
    else
        self:Destroy()
    end

end



function lua_modifier_qaldin_assassin_assassins_shroud:OnDestroy()
    if not IsServer() then return end

    self:StartIntervalThink(-1)

    -- self:GetParent():AddNewModifier(
    --     self:GetParent(),self:GetAbility(),
    --     "lua_modifier_qaldin_assassin_assassins_shroud_as",
    --     {duration = self:GetAbility():GetSpecialValueFor("as_duration")}
    -- )

    local as_mod = self:GetParent():FindModifierByName("lua_modifier_qaldin_assassin_assassins_shroud_as")
    if not as_mod == false then
        as_mod:SetDuration(self:GetAbility():GetSpecialValueFor("as_duration"),true)
    end

    local lvl = self:GetAbility():GetLevel()-1
    local true_cd = self:GetAbility():GetEffectiveCooldown(lvl)
    self:GetAbility():StartCooldown(true_cd)

    local is_on = self:GetAbility():GetToggleState()
    if is_on == true then
        self:GetAbility():ToggleAbility()
    end

end























----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

lua_modifier_qaldin_assassin_assassins_shroud_as = class({})

function lua_modifier_qaldin_assassin_assassins_shroud_as:IsHidden() return false end
function lua_modifier_qaldin_assassin_assassins_shroud_as:IsDebuff() return false end
function lua_modifier_qaldin_assassin_assassins_shroud_as:IsPurgable() return true end
function lua_modifier_qaldin_assassin_assassins_shroud_as:IsPurgeException() return true end


function lua_modifier_qaldin_assassin_assassins_shroud_as:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK
    }
    return dfunc
end


function lua_modifier_qaldin_assassin_assassins_shroud_as:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("as_bonus")
end


function lua_modifier_qaldin_assassin_assassins_shroud_as:OnAttack(event)
    if not IsServer() then return end
    if event.attacker:IsAlive() == false then return end
	if event.attacker ~= self:GetParent() then return end

    self:DecrementStackCount()

    if self:GetStackCount() > 0 then return end

	self:Destroy()
end


function lua_modifier_qaldin_assassin_assassins_shroud_as:OnCreated(kv)
    if not IsServer() then return end

    local as_times = self:GetAbility():GetSpecialValueFor("as_times")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_qaldin_assassin_assassins_shroud_plus_as_times")
    if not talent == false then
        if talent:GetLevel() > 0 then
            as_times = as_times + talent:GetSpecialValueFor("value")
        end
    end

    self:SetStackCount(as_times)
end


function lua_modifier_qaldin_assassin_assassins_shroud_as:OnRefresh(kv)
    self:OnCreated(kv)
end
