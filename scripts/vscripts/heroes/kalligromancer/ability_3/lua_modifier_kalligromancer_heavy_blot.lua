lua_modifier_kalligromancer_heavy_blot = class({})


function lua_modifier_kalligromancer_heavy_blot:DestroyOnExpire() return false end

function lua_modifier_kalligromancer_heavy_blot:IsDebuff() return false end

function lua_modifier_kalligromancer_heavy_blot:IsPurgable() return false end

function lua_modifier_kalligromancer_heavy_blot:IsPurgeException() return false end

function lua_modifier_kalligromancer_heavy_blot:RemoveOnDeath() return false end


function lua_modifier_kalligromancer_heavy_blot:DeclareFunctions()
    local dfunc = {
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
    return dfunc
end



function lua_modifier_kalligromancer_heavy_blot:OnCreated(kv)

    if not IsServer() then return end

    local stacks = self:GetAbility():GetSpecialValueFor("stacks")
    local helper_count = self:GetAbility():GetSpecialValueFor("helper_count")
    self:SetStackCount(stacks)
    self:StartIntervalThink(helper_count)
    self:SetDuration(helper_count,true)

    self.blot = false
    self.attack_record = {}

    if self:GetParent():IsIllusion() == false then return end

    local original_hero = self:GetParent():GetReplicatingOtherHero()
    if not original_hero then return end

    local mod = original_hero:FindModifierByName("lua_modifier_kalligromancer_heavy_blot")
    if not mod then return end

    self:SetStackCount(mod:GetStackCount())
    self.blot = mod.blot
    self.attack_record = mod.attack_record


end



function lua_modifier_kalligromancer_heavy_blot:OnIntervalThink()

    if not IsServer() then return end

    local helper_count = self:GetAbility():GetSpecialValueFor("helper_count")

    if self:GetStackCount() > 0 then
        self:StartIntervalThink(helper_count)
        self:SetDuration(helper_count,true)
        self:DecrementStackCount()
        self.blot = false
    end

    if self:GetStackCount() == 0 then
        self:StartIntervalThink(-1)
        self:SetDuration(-1,true)
        self.blot = true
    end
end



function lua_modifier_kalligromancer_heavy_blot:GetModifierPreAttack_CriticalStrike(event)

    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end

    if self:GetParent():PassivesDisabled() then return end

    if self.blot == false then return end

    local crit = self:GetAbility():GetSpecialValueFor("crit_damage")
    local add_crit = 0

    local talent = self:GetCaster():FindAbilityByName("special_bonus_kalligromancer_heavy_blot_aoe_plus_crit")
    if not talent == false then
        if talent:GetLevel() > 0 then
            add_crit = talent:GetSpecialValueFor("value")
        end
    end

    return crit+add_crit
end



function lua_modifier_kalligromancer_heavy_blot:OnAttackStart(event)
    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end

    if self:GetParent():PassivesDisabled() then return end

    if self.blot == false then return end

    self:GetParent():StartGesture(ACT_DOTA_GS_INK_CREATURE)

end



function lua_modifier_kalligromancer_heavy_blot:OnAttack(event)
    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end

    if self:GetParent():PassivesDisabled() then return end

    local stacks = self:GetAbility():GetSpecialValueFor("stacks")
    local helper_count = self:GetAbility():GetSpecialValueFor("helper_count")

    table.insert(self.attack_record,self.blot)

    if self.blot == false then
        if self:GetStackCount() > 0 then
            self:StartIntervalThink(helper_count)
            self:SetDuration(helper_count,true)
            self:DecrementStackCount()
            self.blot = false
        end

        if self:GetStackCount() == 0 then
            self:StartIntervalThink(-1)
            self:SetDuration(-1,true)
            self.blot = true
        end
    else
        --self:GetParent():StartGesture(ACT_DOTA_GS_INK_CREATURE)
        self:SetStackCount(stacks)
        self:StartIntervalThink(helper_count)
        self:SetDuration(helper_count,true)
        self.blot = false
        table.insert(self.attack_record,event.record)
    end

end



function lua_modifier_kalligromancer_heavy_blot:OnAttackLanded(event)
    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end

    if #self.attack_record <= 0 then return end

    local do_aoe_damage = -1
    for i=1,#self.attack_record,1 do
        if event.record == self.attack_record[i] then
            do_aoe_damage = i
            break
        end
    end

    if do_aoe_damage == -1 then return end

    table.remove(self.attack_record,do_aoe_damage)


    local talent = self:GetCaster():FindAbilityByName("special_bonus_kalligromancer_heavy_blot_aoe_range")
    local aoe_radius = self:GetAbility():GetSpecialValueFor("aoe_radius")

    if not talent == false then
        if talent:GetLevel() > 0 then
            aoe_radius = aoe_radius + talent:GetSpecialValueFor("value")
        end
    end

    if event.target:IsBaseNPC() == false then return end

    local enemies = FindUnitsInRadius(
        event.attacker:GetTeam(),
        event.target:GetAbsOrigin(),
        nil,
        aoe_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    local aoe_damage = event.damage * (self:GetAbility():GetSpecialValueFor("aoe_damage")*0.01)

    for _,enemy in pairs(enemies) do
		if enemy ~= event.target then

            dtable = {
                victim = enemy,
                attacker = event.attacker,
                damage = aoe_damage,
                damage_type = event.damage_type,
                damage_flags = event.damage_flags,
                ability = self:GetAbility()
            }

            ApplyDamage(dtable)

            SendOverheadEventMessage(enemy,OVERHEAD_ALERT_CRITICAL,enemy,aoe_damage,event.attacker)

        end
	end

    local splat = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf",
        PATTACH_ABSORIGIN,
        event.target
    )
    ParticleManager:SetParticleControl(splat,2,Vector(aoe_radius,0,0))
    ParticleManager:SetParticleControl(splat,4,event.target:GetAbsOrigin())
    event.target:EmitSound("Hero_Grimstroke.InkSwell.Stun")
    --createhero npc_dota_hero_terrorblade enemy
end





function lua_modifier_kalligromancer_heavy_blot:GetModifierProjectileName()
    if not IsServer() then return end

    if self.blot == false then return end

    if self:GetParent():PassivesDisabled() then return end

    return "particles/units/heroes/kalligromancer/ability_3/blot_projectile.vpcf"
end
