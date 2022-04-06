LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_bonus_as", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_truesight", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )



lua_modifier_vagabond_phantom_charge_particle = class({})

function lua_modifier_vagabond_phantom_charge_particle:IsHidden() return true end
function lua_modifier_vagabond_phantom_charge_particle:IsDebuff() return false end
function lua_modifier_vagabond_phantom_charge_particle:IsPurgable() return false end
function lua_modifier_vagabond_phantom_charge_particle:IsPurgeException() return false end

function lua_modifier_vagabond_phantom_charge_particle:OnCreated(kv)
    local particle = ParticleManager:CreateParticle(
        "particles/econ/events/new_bloom/dragon_death_sparkle.vpcf",PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
end


function lua_modifier_vagabond_phantom_charge_particle:OnDestroy()
    UTIL_Remove(self:GetParent())
end













---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
lua_modifier_vagabond_phantom_charge_invi = class({})

function lua_modifier_vagabond_phantom_charge_invi:IsHidden() return true end
function lua_modifier_vagabond_phantom_charge_invi:IsDebuff() return false end
function lua_modifier_vagabond_phantom_charge_invi:IsPurgable() return false end
function lua_modifier_vagabond_phantom_charge_invi:IsPurgeException() return false end
function lua_modifier_vagabond_phantom_charge_invi:AllowIllusionDuplicate() return true end


function lua_modifier_vagabond_phantom_charge_invi:CheckState()
    local cstate = {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return cstate
end


function lua_modifier_vagabond_phantom_charge_invi:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
    }
    return dfunc
end


function lua_modifier_vagabond_phantom_charge_invi:GetModifierInvisibilityLevel()
    return 1
end



function lua_modifier_vagabond_phantom_charge_invi:OnAttack(event)
    if event.attacker ~= self:GetParent() then return end
    self:Destroy()
end


function lua_modifier_vagabond_phantom_charge_invi:OnAbilityFullyCast(event)
    if event.unit ~= self:GetParent() then return end
    if event.ability == self:GetAbility() then return end
    self:Destroy()
end













---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

lua_modifier_vagabond_phantom_charge_movement = class({})

function lua_modifier_vagabond_phantom_charge_movement:IsHidden() return true end
function lua_modifier_vagabond_phantom_charge_movement:IsDebuff() return false end
function lua_modifier_vagabond_phantom_charge_movement:IsPurgable() return false end
function lua_modifier_vagabond_phantom_charge_movement:IsPurgeException() return false end
function lua_modifier_vagabond_phantom_charge_movement:AllowIllusionDuplicate() return true end


function lua_modifier_vagabond_phantom_charge_movement:CheckState()
    local cstate = {
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return cstate
end


function lua_modifier_vagabond_phantom_charge_movement:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_ORDER
    }
    return dfunc
end


function lua_modifier_vagabond_phantom_charge_movement:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end


function lua_modifier_vagabond_phantom_charge_movement:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end


function lua_modifier_vagabond_phantom_charge_movement:OnRefresh(kv)
    self:OnCreated(kv)
end



function lua_modifier_vagabond_phantom_charge_movement:OnCreated(kv)
    if not IsServer() then return end

    if not kv.target then self:Destroy() return end

    self.target = EntIndexToHScript(kv.target)

    if not self.truesight then
        self.truesight = self.target:AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "lua_modifier_vagabond_phantom_charge_truesight",
            {duration = self:GetRemainingTime()}
        )
    end

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end


function lua_modifier_vagabond_phantom_charge_movement:OnIntervalThink()
    if not IsServer() then return end

    if self.target:IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetParent():IsRooted() then
        self:Destroy()
        return
    end

    if self:GetParent():IsStunned() then
        self:Destroy()
        return
    end

    if self.target:IsAttackImmune() then return end

    if self:GetParent():IsDisarmed() then return end

    self:GetParent():MoveToTargetToAttack(self.target)
end


function lua_modifier_vagabond_phantom_charge_movement:GetModifierAttackSpeedBonus_Constant()
    return 200
end


function lua_modifier_vagabond_phantom_charge_movement:GetModifierBaseAttackTimeConstant()
    return 0.1
end



function lua_modifier_vagabond_phantom_charge_movement:GetModifierMoveSpeed_Absolute()
    return self:GetAbility():GetSpecialValueFor("charge_ms")
end


function lua_modifier_vagabond_phantom_charge_movement:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


function lua_modifier_vagabond_phantom_charge_movement:OnAttack(event)
    if event.attacker ~= self:GetParent() then return end

    if self:GetParent():IsRangedAttacker() == false then return end

    self:GetParent():AddNewModifier(
        self:GetCaster(),self:GetAbility(),
        "lua_modifier_vagabond_phantom_charge_bonus_as",
        {duration = self:GetAbility():GetSpecialValueFor("duration_as")}
    )

    self:Destroy()
end


function lua_modifier_vagabond_phantom_charge_movement:OnAttackLanded(event)
    if event.attacker ~= self:GetParent() then return end
    if event.ranged_attack then return end


    self:GetParent():AddNewModifier(
        self:GetCaster(),self:GetAbility(),
        "lua_modifier_vagabond_phantom_charge_bonus_as",
        {duration = self:GetAbility():GetSpecialValueFor("duration_as")}
    )

    if self:GetParent():IsIllusion() then
        local dtable = {
            victim = self.target,
            attacker = self:GetParent(),
            damage = self:GetParent():GetAverageTrueAttackDamage(nil),
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self:GetAbility()
        }
        ApplyDamage(dtable)
    end

    self:Destroy()
end


function lua_modifier_vagabond_phantom_charge_movement:OnAbilityFullyCast(event)
    if event.unit ~= self:GetParent() then return end
    if event.ability == self:GetAbility() then return end
    self:Destroy()
end


function lua_modifier_vagabond_phantom_charge_movement:OnOrder(event)
    if event.unit ~= self:GetParent() then return end

    if event.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
        self:Destroy()
    end

    if event.order_type == DOTA_UNIT_ORDER_STOP then
        self:Destroy()
    end
end



function lua_modifier_vagabond_phantom_charge_movement:OnDestroy()
    if not IsServer() then return end

    if not self.truesight == false then
        if self.truesight:IsNull() == false then
            self.truesight:Destroy()
            self.truesight = nil
        end
    end

    self:StartIntervalThink(-1)
    if self:GetParent():IsIllusion() == false then return end
    self:GetParent():ForceKill(false)
end














---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

lua_modifier_vagabond_phantom_charge_bonus_as = class({})

function lua_modifier_vagabond_phantom_charge_bonus_as:IsHidden() return false end
function lua_modifier_vagabond_phantom_charge_bonus_as:IsDebuff() return false end
function lua_modifier_vagabond_phantom_charge_bonus_as:IsPurgable() return true end
function lua_modifier_vagabond_phantom_charge_bonus_as:IsPurgeException() return true end


function lua_modifier_vagabond_phantom_charge_bonus_as:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end


function lua_modifier_vagabond_phantom_charge_bonus_as:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end



function lua_modifier_vagabond_phantom_charge_bonus_as:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return dfunc
end


function lua_modifier_vagabond_phantom_charge_bonus_as:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_as")
end
























---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

lua_modifier_vagabond_phantom_charge_truesight = class({})

function lua_modifier_vagabond_phantom_charge_truesight:IsHidden() return true end
function lua_modifier_vagabond_phantom_charge_truesight:IsDebuff() return true end
function lua_modifier_vagabond_phantom_charge_truesight:IsPurgable() return false end
function lua_modifier_vagabond_phantom_charge_truesight:IsPurgeException() return false end
function lua_modifier_vagabond_phantom_charge_truesight:GetPriority() return MODIFIER_PRIORITY_ULTRA end
function lua_modifier_vagabond_phantom_charge_truesight:GetModifierProvidesFOWVision() return 1 end

function lua_modifier_vagabond_phantom_charge_truesight:CheckState()
    return {[MODIFIER_STATE_INVISIBLE] = false}
end

function lua_modifier_vagabond_phantom_charge_truesight:DeclareFunctions()
    return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end
