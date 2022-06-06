LinkLuaModifier( "lua_modifier_atniw_druid_bear_rush_debuff", "heroes/atniw_druid/ability_3/lua_modifier_atniw_druid_bear_rush", LUA_MODIFIER_MOTION_NONE )

lua_modifier_atniw_druid_bear_rush = class({})

function lua_modifier_atniw_druid_bear_rush:IsDebuff() return false end
function lua_modifier_atniw_druid_bear_rush:IsHidden() return true end
function lua_modifier_atniw_druid_bear_rush:IsPurgable() return false end
function lua_modifier_atniw_druid_bear_rush:IsPurgeException() return false end
function lua_modifier_atniw_druid_bear_rush:GetModifierIgnoreMovespeedLimit() return 1 end


function lua_modifier_atniw_druid_bear_rush:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_UNSLOWABLE] = true
    }
end


function lua_modifier_atniw_druid_bear_rush:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_MODIFIER_ADDED,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
end


function lua_modifier_atniw_druid_bear_rush:GetModifierMoveSpeed_Limit()
    return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
end


function lua_modifier_atniw_druid_bear_rush:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
end


function lua_modifier_atniw_druid_bear_rush:OnModifierAdded(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end

    if self:GetParent():IsStunned() then
        print(event.added_buff:GetName())
        self:Destroy()
        return
    end

    if self:GetParent():IsRooted() then
        self:Destroy()
        return
    end
end


function lua_modifier_atniw_druid_bear_rush:GetModifierModelChange()
    return "models/heroes/lone_druid/spirit_bear.vmdl"
end


function lua_modifier_atniw_druid_bear_rush:GetActivityTranslationModifiers()
    return "haste"
end

function lua_modifier_atniw_druid_bear_rush:OnCreated(kv)
    if not IsServer() then return end

    if not kv.pos_x then return end

    self.target_pos = Vector(kv.pos_x,kv.pos_y,kv.pos_z)
    self.original_pos = self:GetParent():GetAbsOrigin()
    self.total_move_length = 0

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end


function lua_modifier_atniw_druid_bear_rush:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():IsAlive() == false then
        self:Destroy()
        return
    end

    --particle
    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_lone_druid/lone_druid_rabid_buff_speed.vpcf",
        PATTACH_ABSORIGIN, self:GetParent()
    )
    ParticleManager:SetParticleControlEnt(
        particle,2,self:GetParent(),PATTACH_ABSORIGIN,
        "attach_origin",self:GetParent():GetAbsOrigin(),true
    )

    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)



    local particle_wave = ParticleManager:CreateParticle(
        "particles/units/heroes/atniw_druid/ability_3/atniw_bear_rush_waves.vpcf",
        PATTACH_ABSORIGIN, self:GetParent()
    )
    ParticleManager:SetParticleControl(particle_wave,0,self:GetParent():GetAbsOrigin())
    ParticleManager:DestroyParticle(particle_wave,false)
    ParticleManager:ReleaseParticleIndex(particle_wave)




    --debuff
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),self:GetParent():GetAbsOrigin(),
        nil,self:GetAbility():GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER, false
    )

    for i=1, #enemies do
        enemies[i]:AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "lua_modifier_atniw_druid_bear_rush_debuff",
            {duration = self:GetAbility():GetSpecialValueFor("trample_duration")}
        )
    end



    --runnin
    local mypos = self:GetParent():GetAbsOrigin()
    local length = (self.target_pos - mypos):Length2D()

    local cast_range = self:GetAbility():GetCastRange(mypos,self:GetParent())
    local move_length = (self.original_pos - mypos):Length2D()
    self.original_pos  = mypos
    self.total_move_length = self.total_move_length + move_length

    if self.total_move_length >= cast_range then
        self:Destroy()
        return
    end

    if GridNav:CanFindPath(mypos,self.target_pos) == false then
        self:Destroy()
        return
    end

    if length <= 150 then
        self:Destroy()
        return
    end

    self:GetParent():MoveToPosition(self.target_pos)
end















----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

lua_modifier_atniw_druid_bear_rush_debuff = class({})
function lua_modifier_atniw_druid_bear_rush_debuff:IsDebuff() return true end
function lua_modifier_atniw_druid_bear_rush_debuff:IsHidden() return false end
function lua_modifier_atniw_druid_bear_rush_debuff:IsPurgable() return true end
function lua_modifier_atniw_druid_bear_rush_debuff:IsPurgeException() return true end


function lua_modifier_atniw_druid_bear_rush_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end


function lua_modifier_atniw_druid_bear_rush_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("trample_slow_percent")
end


function lua_modifier_atniw_druid_bear_rush_debuff:GetModifierMagicalResistanceBonus(event)
    return -self:GetAbility():GetSpecialValueFor("trample_mr_minus_percent")
end


function lua_modifier_atniw_druid_bear_rush_debuff:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end
