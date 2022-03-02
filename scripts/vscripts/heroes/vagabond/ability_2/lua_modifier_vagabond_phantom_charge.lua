LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_bonus_as", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_phantom_charge_vision", "heroes/vagabond/ability_2/lua_modifier_vagabond_phantom_charge", LUA_MODIFIER_MOTION_NONE )


lua_modifier_vagabond_phantom_charge = class({})

function lua_modifier_vagabond_phantom_charge:IsDebuff() return false end
function lua_modifier_vagabond_phantom_charge:IsPurgable() return false end
function lua_modifier_vagabond_phantom_charge:IsPurgeException() return false end
function lua_modifier_vagabond_phantom_charge:IsHidden() return true end





function lua_modifier_vagabond_phantom_charge:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end


function lua_modifier_vagabond_phantom_charge:DeclareFunctions()
    local dfuncs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return dfuncs
end



function lua_modifier_vagabond_phantom_charge:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true
	}
	return state
end



function lua_modifier_vagabond_phantom_charge:OnCreated(kv)

    self.ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")


    if not IsServer() then return end

    if not self.ability then
        self:Destroy()
        return
    end

    self.target = self:GetAbility():GetCursorTarget()

    self.duration = self.ability:GetSpecialValueFor("charge_duration")

    self:StartIntervalThink(FrameTime())

    self.mod_vision = self.target:AddNewModifier(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_vagabond_phantom_charge_vision",
        {duration = self.ability:GetSpecialValueFor("charge_duration")}
    )


    self.particle = ParticleManager:CreateParticle("particles/econ/events/new_bloom/dragon_death_sparkle.vpcf",PATTACH_WORLDORIGIN,self:GetParent())
    ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(self.particle)

    self:GetParent():EmitSound("Hero_PhantomLancer.PhantomEdge")
end



function lua_modifier_vagabond_phantom_charge:OnRefresh(kv)

    self.ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")

    if not IsServer() then return end

    if not self.ability then
        self:Destroy()
        return
    end

    self.target = self:GetAbility():GetCursorTarget()

    self.duration = self.ability:GetSpecialValueFor("charge_duration")

    self:StartIntervalThink(FrameTime())

    self.mod_vision = self.target:AddNewModifier(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_vagabond_phantom_charge_vision",
        {duration = self.ability:GetSpecialValueFor("charge_duration")}
    )

    self.particle = ParticleManager:CreateParticle("particles/econ/events/new_bloom/dragon_death_sparkle.vpcf",PATTACH_WORLDORIGIN,self:GetParent())
    ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(self.particle)

    self:GetParent():EmitSound("Hero_PhantomLancer.PhantomEdge")
end



function lua_modifier_vagabond_phantom_charge:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():IsRooted() then
        self:Destroy()
        return
    end

    if self:GetParent():IsStunned() then
        self:Destroy()
        return
    end

    if self.target:IsAlive() == false then
        self:Destroy()
    end

    self:GetParent():MoveToTargetToAttack(self.target)
    self.duration = self.duration - FrameTime()

    if self.duration <= 0.0 then
        self:StartIntervalThink(-1)
        self:Destroy()
    end
end



function lua_modifier_vagabond_phantom_charge:GetModifierMoveSpeed_Absolute()
    return self.ability:GetSpecialValueFor("charge_ms")
end



function lua_modifier_vagabond_phantom_charge:GetModifierAttackSpeedBonus_Constant()
    return self.ability:GetSpecialValueFor("bonus_as")
end



function lua_modifier_vagabond_phantom_charge:OnOrder(event)

    if not IsServer() then return end

    if event.unit ~= self:GetParent() then return end

    local wont_stop = {
        DOTA_UNIT_ORDER_ATTACK_MOVE,
        DOTA_UNIT_ORDER_ATTACK_TARGET,
        DOTA_UNIT_ORDER_PURCHASE_ITEM,
        DOTA_UNIT_ORDER_SELL_ITEM,
        DOTA_UNIT_ORDER_DISASSEMBLE_ITEM,
        DOTA_UNIT_ORDER_MOVE_ITEM,
        DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO,
        DOTA_UNIT_ORDER_GLYPH,
        DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH,
        DOTA_UNIT_ORDER_CAST_RUNE,
        DOTA_UNIT_ORDER_PING_ABILITY,
        DOTA_UNIT_ORDER_RADAR,
        DOTA_UNIT_ORDER_SET_ITEM_COMBINE_LOCK,
        DOTA_UNIT_ORDER_CAST_RIVER_PAINT
    }

    local stop = true
    for i = 1,#wont_stop,1 do
        if wont_stop[i] == event.order_type then
            stop = false
            break
        end
    end

    if stop == true then
        self:Destroy()
        return
    end
end



function lua_modifier_vagabond_phantom_charge:OnAttackLanded(event)

    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end

    local dtable = {
        victim = event.target,
        attacker = self:GetParent(),
        damage = self.ability:GetSpecialValueFor("bonus_damage"),
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)

    self:GetParent():AddNewModifier(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_vagabond_phantom_charge_bonus_as",
        {duration = self.ability:GetSpecialValueFor("duration_as")}
    )

    self:Destroy()
end



function lua_modifier_vagabond_phantom_charge:OnDestroy()
    if not IsServer() then return end

    self:StartIntervalThink(-1)

    if self:GetParent():IsIllusion() == true then
        self:GetParent():ForceKill(false)
        UTIL_Remove(self:GetParent())
    end
end









-----------------------------------------------
-- VISION ENEMY
----------------------------------------------


lua_modifier_vagabond_phantom_charge_vision = class({})
function lua_modifier_vagabond_phantom_charge_vision:IsDebuff() return false end

function lua_modifier_vagabond_phantom_charge_vision:IsPurgable() return false end

function lua_modifier_vagabond_phantom_charge_vision:IsPurgeException() return false end

function lua_modifier_vagabond_phantom_charge_vision:IsHidden() return true end

function lua_modifier_vagabond_phantom_charge_vision:DeclareFunctions() return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end

function lua_modifier_vagabond_phantom_charge_vision:GetModifierProvidesFOWVision() return 1 end










-----------------------------------------------
-- ATTACK SPEED BONUS
----------------------------------------------

lua_modifier_vagabond_phantom_charge_bonus_as = class({})

function lua_modifier_vagabond_phantom_charge_bonus_as:IsDebuff() return false end

function lua_modifier_vagabond_phantom_charge_bonus_as:IsPurgable() return true end

function lua_modifier_vagabond_phantom_charge_bonus_as:IsHidden() return false end

function lua_modifier_vagabond_phantom_charge_bonus_as:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end

function lua_modifier_vagabond_phantom_charge_bonus_as:OnCreated(kv)
    self.ability = self:GetCaster():FindAbilityByName("lua_ability_vagabond_phantom_charge")
    if not self.ability then
        self:Destroy()
        return
    end
end

function lua_modifier_vagabond_phantom_charge_bonus_as:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end

function lua_modifier_vagabond_phantom_charge_bonus_as:GetModifierAttackSpeedBonus_Constant()
    return self.ability:GetSpecialValueFor("bonus_as")
end











-----------------------------------------------------------
--Invi
----------------------------------------------------------
lua_modifier_vagabond_phantom_charge_invi = class({})

function lua_modifier_vagabond_phantom_charge_invi:IsDebuff() return false end

function lua_modifier_vagabond_phantom_charge_invi:IsPurgable() return true end

function lua_modifier_vagabond_phantom_charge_invi:IsHidden() return true end

function lua_modifier_vagabond_phantom_charge_invi:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end



function lua_modifier_vagabond_phantom_charge_invi:DeclareFunctions()
	local dfucs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return dfucs
end




function lua_modifier_vagabond_phantom_charge_invi:GetModifierInvisibilityLevel()
	return 1
end



function lua_modifier_vagabond_phantom_charge_invi:OnAbilityFullyCast(event)
	if event.unit ~= self:GetParent() then return end
    if event.ability == self:GetAbility() then return end
	self:Destroy()
end



function lua_modifier_vagabond_phantom_charge_invi:OnAttack(event)
	if event.attacker ~= self:GetParent() then return end
	self:Destroy()
end




















-----------------------------------------------------------
--Invi
----------------------------------------------------------
lua_modifier_vagabond_phantom_charge_invi_frame = class({})

function lua_modifier_vagabond_phantom_charge_invi_frame:IsDebuff() return false end

function lua_modifier_vagabond_phantom_charge_invi_frame:IsPurgable() return true end

function lua_modifier_vagabond_phantom_charge_invi_frame:IsHidden() return true end

function lua_modifier_vagabond_phantom_charge_invi_frame:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end



function lua_modifier_vagabond_phantom_charge_invi_frame:DeclareFunctions()
	local dfucs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return dfucs
end




function lua_modifier_vagabond_phantom_charge_invi_frame:GetModifierInvisibilityLevel()
	return 1
end



function lua_modifier_vagabond_phantom_charge_invi_frame:OnAbilityFullyCast(event)
	if event.unit ~= self:GetParent() then return end
    if event.ability == self:GetAbility() then return end
	self:Destroy()
end



function lua_modifier_vagabond_phantom_charge_invi_frame:OnAttack(event)
	if event.attacker ~= self:GetParent() then return end
	self:Destroy()
end
