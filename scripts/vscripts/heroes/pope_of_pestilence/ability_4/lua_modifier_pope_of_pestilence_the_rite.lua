LinkLuaModifier( "lua_modifier_pope_of_pestilence_the_rite_bomber", "heroes/pope_of_pestilence/ability_4/lua_modifier_pope_of_pestilence_the_rite", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_pope_of_pestilence_the_rite_attacker", "heroes/pope_of_pestilence/ability_4/lua_modifier_pope_of_pestilence_the_rite", LUA_MODIFIER_MOTION_NONE )


lua_modifier_pope_of_pestilence_the_rite_thinker = class({})


function lua_modifier_pope_of_pestilence_the_rite_thinker:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_the_rite_thinker:IsHidden() return true end
function lua_modifier_pope_of_pestilence_the_rite_thinker:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_the_rite_thinker:IsPurgeException() return false end


function lua_modifier_pope_of_pestilence_the_rite_thinker:OnCreated(kv)
    if not IsServer() then return end
    self.ghost_count = self:GetAbility():GetSpecialValueFor("ghost_count")
    if self:GetCaster():HasScepter() then
        self.ghost_count = self.ghost_count + self:GetAbility():GetSpecialValueFor("scepter_bomb_ghost_damage")
    end
    self:OnIntervalThink()
    self:StartIntervalThink(0.1)
    self:GetParent():EmitSound("Hero_Necrolyte.SpiritForm.Cast")
end


function lua_modifier_pope_of_pestilence_the_rite_thinker:OnIntervalThink()
    if not IsServer() then return end

    local center = self:GetParent():GetAbsOrigin()
    local radius = RandomInt(0,self:GetAbility():GetAOERadius())
    local normal = Vector(1,0,0)
    local angle = RandomFloat(0,360)
    local rotation = RotatePosition(Vector(0,0,0),QAngle(0,angle,0),normal)

    --randomize the summon position
    local summon_position = center + (rotation*radius)

    --summon ghost
    local ghost = CreateUnitByName(
        "npc_custom_unit_pope_of_pestilence_rite_ghost",
        summon_position,true,self:GetCaster(),
        self:GetCaster(),self:GetCaster():GetTeam()
    )

    --add ghost type/modifier
    ghost:AddNewModifier(
        self:GetCaster(),self:GetAbility(),
        "lua_modifier_pope_of_pestilence_the_rite_attacker",
        {duration = self:GetAbility():GetSpecialValueFor("ghost_duration")}
    )

    if self.ghost_count%2 > 0 then

        ghost:AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "lua_modifier_pope_of_pestilence_the_rite_bomber",
            {duration = self:GetAbility():GetSpecialValueFor("ghost_duration")}
        )

    end

    --particle shit
    local poof = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile_explosion_flash_c.vpcf",
        PATTACH_ABSORIGIN,ghost
    )
    ParticleManager:SetParticleControl(poof,3,ghost:GetAbsOrigin())

    --countdown
    self.ghost_count = self.ghost_count - 1

    if self.ghost_count <= 0 then
        self:StartIntervalThink(-1)
        self:Destroy()
    end
end


function lua_modifier_pope_of_pestilence_the_rite_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end




















------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

lua_modifier_pope_of_pestilence_the_rite_attacker = class({})


function lua_modifier_pope_of_pestilence_the_rite_attacker:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_the_rite_attacker:IsHidden() return true end
function lua_modifier_pope_of_pestilence_the_rite_attacker:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_the_rite_attacker:IsPurgeException() return false end
function lua_modifier_pope_of_pestilence_the_rite_attacker:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end


function lua_modifier_pope_of_pestilence_the_rite_attacker:CheckState()
    local cs = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return cs
end


function lua_modifier_pope_of_pestilence_the_rite_attacker:DeclareFunctions()
    local df = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
    }
    return df
end


function lua_modifier_pope_of_pestilence_the_rite_attacker:GetModifierExtraHealthBonus()
    local hp = self:GetAbility():GetSpecialValueFor("ghost_hp")
    if self:GetCaster():HasScepter() then
        hp = hp + self:GetAbility():GetSpecialValueFor("scepter_ghost_hp")
    end
    return hp
end




function lua_modifier_pope_of_pestilence_the_rite_attacker:OnCreated(kv)
    if not IsServer() then return end

    local atk_dmg = self:GetAbility():GetSpecialValueFor("ghost_atk_dmg")
    if self:GetCaster():HasScepter() then
        atk_dmg = atk_dmg + self:GetAbility():GetSpecialValueFor("scepter_ghost_atk_dmg")
    end

    self:GetParent():SetBaseDamageMax(atk_dmg)
    self:GetParent():SetBaseDamageMin(atk_dmg)

    self:OnIntervalThink()
    self:StartIntervalThink(1.0)
end


function lua_modifier_pope_of_pestilence_the_rite_attacker:OnIntervalThink()
    if not IsServer() then return end

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetParent():GetAbsOrigin(),
        nil,800,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false
    )

    if not enemies[1] then return end

    self:GetParent():MoveToTargetToAttack(enemies[1])
    self:GetParent():SetAggroTarget(enemies[1])
    self:GetParent():MoveToPositionAggressive(enemies[1]:GetAbsOrigin())
end



function lua_modifier_pope_of_pestilence_the_rite_attacker:OnDestroy()
    if not IsServer() then return end
    if self:GetParent():IsAlive() == false then return end
    self:GetParent():ForceKill(false)
end





























------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

lua_modifier_pope_of_pestilence_the_rite_bomber = class({})


function lua_modifier_pope_of_pestilence_the_rite_bomber:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_the_rite_bomber:IsHidden() return true end
function lua_modifier_pope_of_pestilence_the_rite_bomber:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_the_rite_bomber:IsPurgeException() return false end


function lua_modifier_pope_of_pestilence_the_rite_bomber:DeclareFunctions()
    local df = {
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
    return df
end

function lua_modifier_pope_of_pestilence_the_rite_bomber:OnCreated(kv)

end


function lua_modifier_pope_of_pestilence_the_rite_bomber:OnAttackStart(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    self:Destroy()
end


function lua_modifier_pope_of_pestilence_the_rite_bomber:GetModifierModelChange()
    return "models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_red.vmdl"
end


function lua_modifier_pope_of_pestilence_the_rite_bomber:OnDestroy()
    if not IsServer() then return end

    local dmg = self:GetAbility():GetSpecialValueFor("bomb_ghost_damage")

    if self:GetCaster():HasScepter() then
        dmg = dmg + self:GetAbility():GetSpecialValueFor("scepter_bomb_ghost_damage")
    end

    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        dmg = dmg + self:GetAbility():GetSpecialValueFor("shard_bomb_ghost_damage")
    end

    local aoe = self:GetAbility():GetSpecialValueFor("bomb_ghost_aoe")

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetParent():GetAbsOrigin(),
        nil,aoe,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )


    for i=1, #enemies do

        if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
            enemies[i]:AddNewModifier(
                self:GetParent(),self:GetAbility(),
                "modifier_silence",
                {duration = self:GetAbility():GetSpecialValueFor("shard_bomb_ghost_silence")}
            )
        end

        local dt = {
            victim = enemies[i],
            attacker = self:GetParent(),
            damage = dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self:GetAbility()
        }

        ApplyDamage(dt)
    end


    local boom = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf",
        PATTACH_POINT_FOLLOW,self:GetParent()
    )
    ParticleManager:SetParticleControl(boom,0,Vector(0,0,0))

    if self:GetParent():IsAlive() == false then return end

    self:GetParent():ForceKill(false)

end
