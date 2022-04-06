

lua_modifier_defiler_mimicry_hero = class({})

function lua_modifier_defiler_mimicry_hero:IsHidden() return false end
function lua_modifier_defiler_mimicry_hero:IsDebuff() return false end
function lua_modifier_defiler_mimicry_hero:IsPurgable() return false end
function lua_modifier_defiler_mimicry_hero:IsPurgeException() return false end


function lua_modifier_defiler_mimicry_hero:CheckState()
    local cstate = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
        --[MODIFIER_STATE_PROVIDES_VISION] = false,

    }
    return cstate
end





function lua_modifier_defiler_mimicry_hero:DeclareFunctions()
    local dfunc = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_DOMINATED,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
    return dfunc
end




function lua_modifier_defiler_mimicry_hero:GetModifierModelChange()
    return "models/items/lifestealer/ls_ti10_immortal_head/ls_ti10_infest_01.vmdl"
end




function lua_modifier_defiler_mimicry_hero:OnCreated(kv)
    self:StartIntervalThink(0.1)

    if not IsServer() then return end

    if not kv.host then self:Destroy() return end

    self.host = EntIndexToHScript(kv.host)

    --self:GetParent():AddNoDraw()
end



--
function lua_modifier_defiler_mimicry_hero:OnIntervalThink()
    if not IsServer() then return end

    local pos = self.host:GetAbsOrigin()
    self:GetParent():SetAbsOrigin(pos)

end
--


function lua_modifier_defiler_mimicry_hero:OnDeath(event)
    if not IsServer() then return end

    if event.unit ~=  self.host then return end

    self:Destroy()
    self:StartIntervalThink(-1)

end



function lua_modifier_defiler_mimicry_hero:OnDominated(event)
    if not IsServer() then return end

    if event.unit ~= self.host then return end

    self:Destroy()
    self:StartIntervalThink(-1)
end





function lua_modifier_defiler_mimicry_hero:OnDestroy()
    if not IsServer() then return end

    if self.host:IsNull() then return end

    local pos = self.host:GetAbsOrigin()
    local heal = self.host:GetMaxHealth()*self:GetAbility():GetSpecialValueFor("heal_percent")*0.01
    self:GetParent():Heal(heal,self:GetAbility())
    FindClearSpaceForUnit(self:GetParent(),pos,false)


    --self:GetParent():RemoveNoDraw()
end




















lua_modifier_defiler_mimicry_host = class({})

function lua_modifier_defiler_mimicry_host:IsHidden() return false end
function lua_modifier_defiler_mimicry_host:IsDebuff() return false end
function lua_modifier_defiler_mimicry_host:IsPurgable() return false end
function lua_modifier_defiler_mimicry_host:IsPurgeException() return false end


function lua_modifier_defiler_mimicry_host:GetStatusEffectName()
    return "particles/units/heroes/defiler/ability_2/defiler_mimicry.vpcf"
end



function lua_modifier_defiler_mimicry_host:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_DOMINATED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE

    }
    return dfunc
end




function lua_modifier_defiler_mimicry_host:OnCreated(kv)
    local host_max_hp = self:GetParent():GetMaxHealth()
    local dot_percent = self:GetAbility():GetSpecialValueFor("dot_hp_percent")
    -- if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
    --     dot_percent = dot_percent-self:GetAbility():GetSpecialValueFor("shard_dot_decrease")
    -- end

    self.dot = host_max_hp*dot_percent*0.01
    self:StartIntervalThink(1.0)

    if not IsServer() then return end

    if self:GetCaster():HasScepter() then
        local scepter_atk_percent = self:GetAbility():GetSpecialValueFor("scepter_atk_percent")*0.01
        local scepter_dmg = self:GetCaster():GetAverageTrueAttackDamage(nil)*scepter_atk_percent
        self:SetStackCount(scepter_dmg)
    end

end




function lua_modifier_defiler_mimicry_host:OnIntervalThink()
    if not IsServer() then return end
    local current_hp = self:GetParent():GetHealth() - self.dot
    self:GetParent():ModifyHealth(current_hp,self:GetAbility(),false,0)
end




function lua_modifier_defiler_mimicry_host:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("ms_bonus")
end



function lua_modifier_defiler_mimicry_host:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("atk_spd_bonus")
end



function lua_modifier_defiler_mimicry_host:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end


function lua_modifier_defiler_mimicry_host:OnDominated(event)
    if event.unit ~= self:GetParent() then return end
    local defiling_touch = self:GetParent():FindModifierByName("lua_modifier_defiler_defiling_touch_source")
    if not defiling_touch == false then
        defiling_touch:Destroy()
    end
    self:Destroy()
end



function lua_modifier_defiler_mimicry_host:OnDestroy()

    if not IsServer() then return end

    self:GetCaster():EmitSound("Hero_LifeStealer.Consume")

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetCaster():GetAbsOrigin())

    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")

    if shard == false then return end
    local aoe_range = self:GetAbility():GetSpecialValueFor("shard_explosion_aoe")
    local aoe_range = self:GetAbility():GetSpecialValueFor("shard_explosion_aoe")
    local aoe_damage = self:GetAbility():GetSpecialValueFor("shard_explosion_dmg")

    local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeam(),
		self:GetParent():GetAbsOrigin(),
		nil,
		aoe_range,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do

		if enemy:IsMagicImmune() == false then
            local dtable ={
                victim = enemy,
                attacker = self:GetCaster(),
                damage = aoe_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                ability = self:GetAbility()
            }
            ApplyDamage(dtable)
        end

	end




end
