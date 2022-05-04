
lua_modifier_boogeyman_lunge_dash = class({})



function lua_modifier_boogeyman_lunge_dash:IsHidden() return true end
function lua_modifier_boogeyman_lunge_dash:IsDebuff() return false end
function lua_modifier_boogeyman_lunge_dash:IsPurgable() return false end
function lua_modifier_boogeyman_lunge_dash:IsPurgeException() return false end


function lua_modifier_boogeyman_lunge_dash:CheckState()
    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_STUNNED] = true
    }
    return cstate
end


function lua_modifier_boogeyman_lunge_dash:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_MODIFIER_ADDED
    }
    return dfunc
end


function lua_modifier_boogeyman_lunge_dash:GetActivityTranslationModifiers()
    return "haste"
end


function lua_modifier_boogeyman_lunge_dash:GetModifierModelChange()
    return "models/heroes/nightstalker/nightstalker_night.vmdl"
end


function lua_modifier_boogeyman_lunge_dash:OnCreated(kv)

    if not IsServer() then return end

    if not kv.target then self:Destroy() return end

    self.target = EntIndexToHScript(kv.target)

    self:GetParent():StartGesture(ACT_DOTA_RUN)

    self.hit_enemies = {}

    local d_dmg = self:GetAbility():GetSpecialValueFor("devour_damage_stack")
    self.damage = self:GetAbility():GetSpecialValueFor("ability_damage")

    local s_heal = self:GetAbility():GetSpecialValueFor("devour_heal_stack")
    self.heal = self:GetAbility():GetSpecialValueFor("flight_heal")

    local d_stacks = self:GetParent():FindModifierByName("lua_modifier_boogeyman_devour_stacks")
    if not d_stacks == false then
        self.damage = self.damage+(d_dmg*d_stacks:GetStackCount())
        self.heal = self.heal+(s_heal*d_stacks:GetStackCount())
    end


    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf",
            PATTACH_POINT_FOLLOW,self:GetParent()
        )
        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    end


    if self:ApplyHorizontalMotionController() == false then
	    self:Destroy()
    end
end


function lua_modifier_boogeyman_lunge_dash:OnModifierAdded(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end
    if event.added_buff == self then return end

    if self:GetParent():IsStunned() then
        self:Destroy()
        return
    end

    if self:GetParent():IsRooted() then
        self:Destroy()
        return
    end

end


function lua_modifier_boogeyman_lunge_dash:UpdateHorizontalMotion(me,dt)
    if not IsServer() then return end

    if self.target:IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetParent():IsAlive() == false then
        self:Destroy()
        return
    end

    local speed = self:GetAbility():GetSpecialValueFor("speed")*dt
    local target_pos = self.target:GetAbsOrigin()
    local my_pos = self:GetParent():GetAbsOrigin()
    local diff = target_pos-my_pos
    local diff_norm = diff:Normalized()
    local diff_length = diff:Length2D()
    local velocity = my_pos+(speed*diff_norm)
    velocity = GetGroundPosition(velocity,self:GetParent())

    self:GetParent():FaceTowards(target_pos)

    local cast_range = self:GetAbility():GetCastRange(target_pos,self.target)
    if diff_length > cast_range*1.5 then
        self:Destroy()
        return
    end


    if diff_length <= 150 then
        self:GetParent():SetAbsOrigin(target_pos-(diff_norm*150))
        self:AbilityHit()
        self:Destroy()
        return
    end

    self:GetParent():SetAbsOrigin(velocity)
    self:AbilityHit()
end


function lua_modifier_boogeyman_lunge_dash:OnHorizontalMotionInterrupted()
    self:Destroy()
end


function lua_modifier_boogeyman_lunge_dash:AbilityHit()
    if not IsServer() then return end

    -- DebugDrawCircle(
    --     self:GetParent():GetAbsOrigin(),
    --     Vector(255,0,0),1.0,
    --     self:GetAbility():GetAOERadius(),
    --     false,1.0
    -- )

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self:GetAbility():GetAOERadius(),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for i=1, #enemies do

        local exist = false

        for j=1, #self.hit_enemies do
            if self.hit_enemies[j] == enemies[i] then
                exist = true
                break
            end
        end


        if exist == false then

            table.insert(self.hit_enemies,enemies[i])

            local dtable = {
                victim = enemies[i],
                attacker = self:GetParent(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                ability = self:GetAbility()
            }
            ApplyDamage(dtable)

            self:GetParent():Heal(self.heal,self:GetAbility())

        end
    end
end


function lua_modifier_boogeyman_lunge_dash:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveGesture(ACT_DOTA_RUN)
    self:GetParent():RemoveHorizontalMotionController(self)

    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
end
