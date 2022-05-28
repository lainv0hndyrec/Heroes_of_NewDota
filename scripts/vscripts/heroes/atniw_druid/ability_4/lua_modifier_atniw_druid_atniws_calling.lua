LinkLuaModifier( "lua_modifier_atniw_druid_atniws_calling_slow", "heroes/atniw_druid/ability_4/lua_modifier_atniw_druid_atniws_calling", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_atniw_druid_tangling_roots_debuff", "heroes/atniw_druid/ability_1/lua_modifier_atniw_druid_tangling_roots", LUA_MODIFIER_MOTION_NONE )



lua_modifier_atniw_druid_atniws_calling = class({})

function lua_modifier_atniw_druid_atniws_calling:IsDebuff() return false end
function lua_modifier_atniw_druid_atniws_calling:IsHidden() return false end
function lua_modifier_atniw_druid_atniws_calling:IsPurgable() return false end
function lua_modifier_atniw_druid_atniws_calling:IsPurgeException() return true end
function lua_modifier_atniw_druid_atniws_calling:GetModifierAttackRangeOverride() return 150 end
function lua_modifier_atniw_druid_atniws_calling:GetOverrideAttackMagical() return 1 end
function lua_modifier_atniw_druid_atniws_calling:AllowIllusionDuplicate() return true end
function lua_modifier_atniw_druid_atniws_calling:GetPriority() return MODIFIER_PRIORITY_HIGH end


function lua_modifier_atniw_druid_atniws_calling:GetEffectName()
    return  "particles/units/heroes/atniw_druid/ability_4/atniw_bear_smokedebuff.vpcf"
end


function lua_modifier_atniw_druid_atniws_calling:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_OVERRIDE_ATTACK_MAGICAL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
    }
end


function lua_modifier_atniw_druid_atniws_calling:GetModifierModelChange()
    return "models/heroes/lone_druid/true_form.vmdl"
end


function lua_modifier_atniw_druid_atniws_calling:GetAttackSound()
    return "Hero_LoneDruid.TrueForm.Attack"
end


function lua_modifier_atniw_druid_atniws_calling:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_hp")
end


function lua_modifier_atniw_druid_atniws_calling:GetModifierMagicalResistanceBonus(event)
    return self:GetAbility():GetSpecialValueFor("bonus_mr_percent")
end


function lua_modifier_atniw_druid_atniws_calling:GetModifierProcAttack_BonusDamage_Physical(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    if event.target:IsBaseNPC() == false then return end
    if event.target:IsBuilding() then return end
    if event.target:IsMagicImmune() then return end



    local magic_dmg = self:GetAbility():GetSpecialValueFor("attack_magic_damage")
    local percent_dmg = self:GetAbility():GetSpecialValueFor("add_atk_percent_as_magic_dmg")*0.01
    local add_magic_dmg = event.damage*percent_dmg
    local total_dmg = magic_dmg+add_magic_dmg


    if self:GetParent():HasModifier("modifier_item_aghanims_shard") then

        local rand = RandomFloat(0.0,100.0)
        local treshold = self:GetAbility():GetSpecialValueFor("shard_root_chance")
        local ability_q = self:GetParent():FindAbilityByName("lua_ability_atniw_druid_tangling_roots")

        if ability_q:GetLevel() > 0 then
            if rand <= treshold then
                event.target:AddNewModifier(
                    self:GetCaster(),ability_q,
                    "lua_modifier_atniw_druid_tangling_roots_debuff",
                    {duration = ability_q:GetSpecialValueFor("stun_duration")}
                )
            end
        end
    end


    if self:GetParent():HasScepter() then
        total_dmg = total_dmg + self:GetAbility():GetSpecialValueFor("scepter_attack_magic_damage")
        local splash_radius = self:GetAbility():GetSpecialValueFor("scepter_attack_splash_radius")

        local particle = ParticleManager:CreateParticle(
            "particles/units/heroes/atniw_druid/ability_4/atniw_bear_scepter_splash_attack.vpcf",
            PATTACH_ABSORIGIN,event.target
        )
        ParticleManager:SetParticleControl(particle ,0,event.target:GetAbsOrigin())

        if event.attacker:IsIllusion() then
            total_dmg = total_dmg*0.33
        end

        local enemies = FindUnitsInRadius(
            self:GetParent():GetTeam(),event.target:GetAbsOrigin(),
            nil,splash_radius,DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
        )

        for i=1, #enemies do
            enemies[i]:AddNewModifier(
                self:GetParent(),self:GetAbility(),
                "lua_modifier_atniw_druid_atniws_calling_slow",
                {duration = self:GetAbility():GetSpecialValueFor("slow_time")}
            )

            local dtable = {
                victim = enemies[i],
                attacker = self:GetParent(),
                damage = total_dmg,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                ability = self:GetAbility()
            }
            ApplyDamage(dtable)

        end

        return -event.damage
    end


    event.target:AddNewModifier(
        self:GetParent(),self:GetAbility(),
        "lua_modifier_atniw_druid_atniws_calling_slow",
        {duration = self:GetAbility():GetSpecialValueFor("slow_time")}
    )


    if event.attacker:IsIllusion() then
        total_dmg = total_dmg*0.33
    end


    local dtable = {
        victim = event.target,
        attacker = self:GetParent(),
        damage = total_dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)

    return -event.damage
end


function lua_modifier_atniw_druid_atniws_calling:OnCreated(kv)
    if not IsServer() then return end
    self.original_atk_cap = self:GetParent():GetAttackCapability()
    self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

    local particle = ParticleManager:CreateParticle(
        "particles/econ/events/fall_major_2016/blink_dagger_start_sparkles_fm06.vpcf",
        PATTACH_POINT,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())

    local particle_smoke = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_treant/treant_naturesguise_mushroom.vpcf",
        PATTACH_POINT,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle_smoke,2,self:GetParent():GetAbsOrigin())
end


function lua_modifier_atniw_druid_atniws_calling:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_LoneDruid.BattleCry")
    self:GetParent():SetAttackCapability(self.original_atk_cap)
end
























---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------


lua_modifier_atniw_druid_atniws_calling_slow = class({})

function lua_modifier_atniw_druid_atniws_calling_slow:IsDebuff() return true end
function lua_modifier_atniw_druid_atniws_calling_slow:IsHidden() return false end
function lua_modifier_atniw_druid_atniws_calling_slow:IsPurgable() return true end
function lua_modifier_atniw_druid_atniws_calling_slow:IsPurgeException() return true end


function lua_modifier_atniw_druid_atniws_calling_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end


function lua_modifier_atniw_druid_atniws_calling_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("ms_slow")
end



function lua_modifier_atniw_druid_atniws_calling_slow:GetEffectName()
    return  "particles/units/heroes/atniw_druid/ability_4/atniw_bear_smokedebuff.vpcf"
end
