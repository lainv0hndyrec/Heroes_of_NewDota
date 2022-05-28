LinkLuaModifier( "lua_modifier_pope_of_pestilence_banish_pooled", "heroes/pope_of_pestilence/ability_3/lua_modifier_pope_of_pestilence_banish", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_pope_of_pestilence_banish_pickable", "heroes/pope_of_pestilence/ability_3/lua_modifier_pope_of_pestilence_banish", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_pope_of_pestilence_banish_buff", "heroes/pope_of_pestilence/ability_3/lua_modifier_pope_of_pestilence_banish", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_pope_of_pestilence_banish_slow", "heroes/pope_of_pestilence/ability_3/lua_modifier_pope_of_pestilence_banish", LUA_MODIFIER_MOTION_NONE )


lua_modifier_pope_of_pestilence_banish_skull = class({})


function lua_modifier_pope_of_pestilence_banish_skull:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_banish_skull:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_banish_skull:IsPurgeException() return false end
function lua_modifier_pope_of_pestilence_banish_skull:IsHidden() return true end
function lua_modifier_pope_of_pestilence_banish_skull:RemoveOnDeath() return false end
function lua_modifier_pope_of_pestilence_banish_skull:AllowIllusionDuplicate() return true end


function lua_modifier_pope_of_pestilence_banish_skull:OnCreated(kv)
    if not IsServer() then return end
    self.skull_pool = {}
    self:StartIntervalThink(0.1)
end


function lua_modifier_pope_of_pestilence_banish_skull:DeclareFunctions()
    local dfuncs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return dfuncs
end


function lua_modifier_pope_of_pestilence_banish_skull:OnDeath(event)
    if not IsServer() then return end

    if self:GetParent():IsIllusion() then return end

    local pos = event.unit:GetAbsOrigin()
    self:CreateASkull(pos)
end


function lua_modifier_pope_of_pestilence_banish_skull:CreateASkull(pos)

    if not IsServer() then return end

    if self:GetParent():IsIllusion() then
        self:CreateASkullFromIllusion(pos)
        return
    end

    local death_pos = pos
    death_pos.z = death_pos.z + 40

    -- local range = self:GetAbility():GetSpecialValueFor("tethered_soul_range")
    -- local length = (self:GetParent():GetAbsOrigin() - death_pos):Length2D()
    --
    -- if length > range then return end

    local add_skull_in_list = true


    --check if there is a skull in the pool
    for i = 1, #self.skull_pool do

        local pool_mod = self.skull_pool[i]:FindModifierByName("lua_modifier_pope_of_pestilence_banish_pooled")

        if not pool_mod == false then

            pool_mod:Destroy()

            FindClearSpaceForUnit(self.skull_pool[i],death_pos,true)
            self.skull_pool[i]:SetAbsOrigin(death_pos)

            self.skull_pool[i]:AddNewModifier(
                self:GetParent(),self:GetAbility(),
                "lua_modifier_pope_of_pestilence_banish_pickable",
                {duration = self:GetAbility():GetSpecialValueFor("soul_decay")}
            )

            add_skull_in_list = false
            break
        end

    end

    --if none then create one
    if add_skull_in_list == true then

        local skull = CreateUnitByName(
            "npc_custom_unit_pope_of_pestilence_soul_skull",
            death_pos,false,
            self:GetParent(),self:GetParent(),
            self:GetParent():GetTeam()
        )

        skull:SetAbsOrigin(death_pos)


        skull:AddNewModifier(
            self:GetParent(),self:GetAbility(),
            "lua_modifier_pope_of_pestilence_banish_pickable",
            {duration = self:GetAbility():GetSpecialValueFor("soul_decay")}
        )

        table.insert(self.skull_pool,skull)
    end
end



function lua_modifier_pope_of_pestilence_banish_skull:CreateASkullFromIllusion(pos)

    if not IsServer() then return end

    local death_pos = pos
    death_pos.z = death_pos.z + 40

    local add_skull_in_list = true

    local original_hero = self:GetParent():GetReplicatingOtherHero()
    if not original_hero then return end

    local original_ability = original_hero:FindAbilityByName("lua_ability_pope_of_pestilence_banish")
    if not original_ability then return end

    local original_modifier = original_hero:FindModifierByName("lua_modifier_pope_of_pestilence_banish_skull")
    if not original_modifier then return end


    --check if there is a skull in the pool
    for i = 1, #original_modifier.skull_pool do

        local pool_mod = original_modifier.skull_pool[i]:FindModifierByName("lua_modifier_pope_of_pestilence_banish_pooled")

        if not pool_mod == false then

            pool_mod:Destroy()

            FindClearSpaceForUnit(original_modifier.skull_pool[i],death_pos,true)
            original_modifier.skull_pool[i]:SetAbsOrigin(death_pos)

            original_modifier.skull_pool[i]:AddNewModifier(
                original_hero,original_ability,
                "lua_modifier_pope_of_pestilence_banish_pickable",
                {duration = original_ability:GetSpecialValueFor("soul_decay")}
            )

            add_skull_in_list = false
            break
        end

    end

    --if none then create one
    if add_skull_in_list == true then

        local skull = CreateUnitByName(
            "npc_custom_unit_pope_of_pestilence_soul_skull",
            death_pos,false,
            original_hero,original_hero,
            original_hero:GetTeam()
        )

        skull:SetAbsOrigin(death_pos)


        skull:AddNewModifier(
            original_hero,original_ability,
            "lua_modifier_pope_of_pestilence_banish_pickable",
            {duration = original_ability:GetSpecialValueFor("soul_decay")}
        )

        table.insert(original_modifier.skull_pool,skull)
    end
end












function lua_modifier_pope_of_pestilence_banish_skull:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():HasModifier("lua_modifier_pope_of_pestilence_banish_buff") then return end

    local pick_range = self:GetAbility():GetSpecialValueFor("pick_range")
    local skulls = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),
        nil,pick_range,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_CLOSEST,false
    )

    local the_skull = nil

    for i=1, #skulls do

        if skulls[i]:GetUnitName() == "npc_custom_unit_pope_of_pestilence_soul_skull" then

            local mod_pick = skulls[i]:FindModifierByName("lua_modifier_pope_of_pestilence_banish_pickable")
            if not mod_pick == false then
                mod_pick:Destroy()

                self:GetParent():AddNewModifier(
                    self:GetParent(),self:GetAbility(),
                    "lua_modifier_pope_of_pestilence_banish_buff",
                    {}
                )

                break

            end

        end

    end
end




























-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------


lua_modifier_pope_of_pestilence_banish_pooled = class({})

function lua_modifier_pope_of_pestilence_banish_pooled:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_banish_pooled:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_banish_pooled:IsPurgeException() return false end
function lua_modifier_pope_of_pestilence_banish_pooled:IsHidden() return true end

function lua_modifier_pope_of_pestilence_banish_pooled:CheckState()
    local cstate = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR_FOR_ENEMIES] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true
    }
    return cstate
end


function lua_modifier_pope_of_pestilence_banish_pooled:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():AddNoDraw()
end

























-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------


lua_modifier_pope_of_pestilence_banish_pickable = class({})

function lua_modifier_pope_of_pestilence_banish_pickable:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_banish_pickable:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_banish_pickable:IsPurgeException() return false end
function lua_modifier_pope_of_pestilence_banish_pickable:IsHidden() return true end

function lua_modifier_pope_of_pestilence_banish_pickable:CheckState()
    local cstate = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        --[MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR_FOR_ENEMIES] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true
    }
    return cstate
end


function lua_modifier_pope_of_pestilence_banish_pickable:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():RemoveNoDraw()

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            --"particles/units/heroes/hero_witchdoctor/witchdoctor_ward_flame_a_rubick.vpcf",
            "particles/units/heroes/hero_visage/visage_base_attack_fire.vpcf",
            PATTACH_ABSORIGIN,self:GetParent()
        )
        --ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
        --ParticleManager:SetParticleControl(self.particle,1,self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle,3,self:GetParent():GetAbsOrigin())
    end
end


function lua_modifier_pope_of_pestilence_banish_pickable:OnDestroy()
    if not IsServer() then return end

    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end

    self:GetParent():AddNewModifier(
        self:GetCaster(),self:GetAbility(),
        "lua_modifier_pope_of_pestilence_banish_pooled",
        {}
    )
end





























-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------


lua_modifier_pope_of_pestilence_banish_buff = class({})

function lua_modifier_pope_of_pestilence_banish_buff:IsHidden() return false end
function lua_modifier_pope_of_pestilence_banish_buff:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_banish_buff:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_banish_buff:IsPurgeException() return false end
function lua_modifier_pope_of_pestilence_banish_buff:AllowIllusionDuplicate() return true end

function lua_modifier_pope_of_pestilence_banish_buff:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end


function lua_modifier_pope_of_pestilence_banish_buff:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
    return dfunc
end


function lua_modifier_pope_of_pestilence_banish_buff:OnCreated(kv)
    self.attack_record = -1
    self.attack_released = false
end




function lua_modifier_pope_of_pestilence_banish_buff:GetModifierPreAttack_CriticalStrike(event)
    if event.attacker ~= self:GetParent() then return end

    if self:GetAbility():GetToggleState() == false then return end

    if self:GetParent():PassivesDisabled() then return end

    if self.attack_released == true then return end

    self.attack_record = event.record

    return self:GetAbility():GetSpecialValueFor("crit_damage")
end


function lua_modifier_pope_of_pestilence_banish_buff:OnAttack(event)
    if event.attacker ~= self:GetParent() then return end

    if event.target:IsBaseNPC() == false then return end

    if event.target:IsBuilding() then
        self.attack_record = event.record
    end

    if self.attack_record ~= event.record then return end

    if self.attack_released == true then return end

    self.attack_released = true
end


function lua_modifier_pope_of_pestilence_banish_buff:OnAttackLanded(event)
    self:OnAttackFail(event)
end


function lua_modifier_pope_of_pestilence_banish_buff:OnAttackFail(event)

    if event.attacker ~= self:GetParent() then return end

    if self.attack_record ~= event.record then return end

    if self.attack_released == false then return end

    if event.target:IsBaseNPC() == false then return end

    if self:GetParent():IsAlive() then
        local skull_mod = self:GetParent():FindModifierByName("lua_modifier_pope_of_pestilence_banish_skull")
        if not skull_mod == false then
            local normal = self:GetParent():GetAbsOrigin() - event.target:GetAbsOrigin()
            local add_pos = normal:Normalized()*100
            add_pos.z = 0
            skull_mod:CreateASkull(event.target:GetAbsOrigin()+add_pos)
        end
    end

    if event.fail_type == DOTA_ATTACK_RECORD_FAIL_NO then
        if event.target:IsAlive() then
            event.target:AddNewModifier(
                self:GetParent(),self:GetAbility(),
                "lua_modifier_pope_of_pestilence_banish_slow",
                {duration = self:GetAbility():GetSpecialValueFor("slow_time")}
            )
        end
    end

    self:Destroy()
end


function lua_modifier_pope_of_pestilence_banish_buff:GetModifierProjectileName()
    if self.attack_released == true then return end
    return "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf"
end


















-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------


lua_modifier_pope_of_pestilence_banish_slow = class({})


function lua_modifier_pope_of_pestilence_banish_slow:IsHidden() return false end
function lua_modifier_pope_of_pestilence_banish_slow:IsDebuff() return true end
function lua_modifier_pope_of_pestilence_banish_slow:IsPurgable() return true end
function lua_modifier_pope_of_pestilence_banish_slow:IsPurgeException() return true end


function lua_modifier_pope_of_pestilence_banish_slow:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return dfunc
end


function lua_modifier_pope_of_pestilence_banish_slow:GetModifierMoveSpeedBonus_Percentage()
    local slow = self:GetAbility():GetSpecialValueFor("ms_slow_percent")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_pope_of_pestilence_banish_slow_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            slow = slow+talent:GetSpecialValueFor("value")
        end
    end

    return -slow
end


function lua_modifier_pope_of_pestilence_banish_slow:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end
