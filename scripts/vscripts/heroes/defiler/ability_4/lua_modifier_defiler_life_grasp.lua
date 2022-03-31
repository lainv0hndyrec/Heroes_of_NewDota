LinkLuaModifier( "lua_modifier_defiler_life_grasp_leap", "heroes/defiler/ability_4/lua_modifier_defiler_life_grasp", LUA_MODIFIER_MOTION_HORIZONTAL)


lua_modifier_defiler_life_grasp_anim = class({})

function lua_modifier_defiler_life_grasp_anim:IsHidden() return true end
function lua_modifier_defiler_life_grasp_anim:IsDebuff() return false end
function lua_modifier_defiler_life_grasp_anim:IsPurgable() return false end
function lua_modifier_defiler_life_grasp_anim:IsPurgeException() return false end

function lua_modifier_defiler_life_grasp_anim:CheckState()
    local cstate = {
        --[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FROZEN] = true
    }
    return cstate
end











--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
lua_modifier_defiler_life_grasp_hook = class({})

function lua_modifier_defiler_life_grasp_hook:IsHidden() return true end
function lua_modifier_defiler_life_grasp_hook:IsDebuff() return false end
function lua_modifier_defiler_life_grasp_hook:IsPurgable() return false end
function lua_modifier_defiler_life_grasp_hook:IsPurgeException() return false end


function lua_modifier_defiler_life_grasp_hook:OnCreated(kv)
    if not IsServer() then return end

    self.hooked = false

    if not kv.target then self:Destroy() return end
    if not kv.particle then self:Destroy() return end

    self.delta = FrameTime()
    self.target = EntIndexToHScript(kv.target)
    self.particle = kv.particle

    ParticleManager:SetParticleControlEnt(
        self.particle,1,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,
        "follow_origin",Vector(0,0,0),false
    )

    self:StartIntervalThink(self.delta)
end


function lua_modifier_defiler_life_grasp_hook:OnIntervalThink()
    if not IsServer() then return end

    if self.target:IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetCaster():IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetCaster():IsStunned()  then
        self:Destroy()
        return
    end


    local speed = self:GetAbility():GetSpecialValueFor("hook_speed")*self.delta
    local target_pos = self.target:GetAbsOrigin()
    local mod_pos = self:GetParent():GetAbsOrigin()
    local diff = target_pos-mod_pos
    local diff_norm = diff:Normalized()
    local diff_length = diff:Length2D()
    local velocity = mod_pos+(speed*diff_norm)
    velocity = GetGroundPosition(velocity,self:GetCaster())
    velocity.z = velocity.z + 80


    if diff_length <= 150 then
        self.hooked = true
        self:GetParent():SetAbsOrigin(target_pos)
        self:LeapAtTarget()
        return
    end


    self:GetParent():SetAbsOrigin(velocity)

end


function lua_modifier_defiler_life_grasp_hook:LeapAtTarget()
    if not IsServer() then return end

    if self:GetCaster():IsRooted() then
        self:Destroy()
        return
    end

    if self.particle then
        ParticleManager:SetParticleControlEnt(
            self.particle,1,self.target,PATTACH_POINT_FOLLOW,
            "attach_hitloc",Vector(0,0,0),false
        )
    end

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self:GetAbility(),
        "lua_modifier_defiler_life_grasp_leap",
        {
            duration = self:GetAbility():GetSpecialValueFor("anim_duration"),
            target = self.target:GetEntityIndex(),
            particle = self.particle
        }
    )

    self:Destroy()
end


function lua_modifier_defiler_life_grasp_hook:OnDestroy()
    if not IsServer() then return end

    self:StartIntervalThink(-1)

    UTIL_Remove(self:GetParent())

    if self:GetCaster():IsAlive() then
        local mod_anim = self:GetCaster():FindModifierByName("lua_modifier_defiler_life_grasp_anim")
        if mod_anim then
            mod_anim:Destroy()
        end
    end

    if self.hooked == false then
        if self.particle then
            ParticleManager:DestroyParticle(self.particle,false)
            ParticleManager:ReleaseParticleIndex(self.particle)
            self.particle = nil
        end
    end
end
















--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
lua_modifier_defiler_life_grasp_leap = class({})

function lua_modifier_defiler_life_grasp_leap:IsHidden() return true end
function lua_modifier_defiler_life_grasp_leap:IsDebuff() return false end
function lua_modifier_defiler_life_grasp_leap:IsPurgable() return false end
function lua_modifier_defiler_life_grasp_leap:IsPurgeException() return false end


function lua_modifier_defiler_life_grasp_leap:CheckState()
    local cstate = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return cstate
end


function lua_modifier_defiler_life_grasp_leap:OnCreated(kv)
    if not IsServer() then return end

    if not kv.target then self:Destroy() return end
    if not kv.particle then self:Destroy() return end

    self.target = EntIndexToHScript(kv.target)
    self.particle = kv.particle

    self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_6)

    if self:ApplyHorizontalMotionController() then return end
	self:Destroy()
end


function lua_modifier_defiler_life_grasp_leap:OnHorizontalMotionInterrupted()
    self:Destroy()
end


function lua_modifier_defiler_life_grasp_leap:UpdateHorizontalMotion(me,dt)
    if not IsServer() then return end

    if self.target:IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetParent():IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetParent():IsStunned() then
        self:Destroy()
        return
    end

    if self:GetParent():IsRooted() then
        self:Destroy()
        return
    end

    local speed = self:GetAbility():GetSpecialValueFor("leap_speed")*dt
    local target_pos = self.target:GetAbsOrigin()
    local my_pos = self:GetParent():GetAbsOrigin()
    local diff = target_pos-my_pos
    local diff_norm = diff:Normalized()
    local diff_length = diff:Length2D()
    local velocity = my_pos+(speed*diff_norm)
    velocity = GetGroundPosition(velocity,self:GetParent())

    self:GetCaster():FaceTowards(target_pos)

    if diff_length <= 150 then
        self:GetParent():SetAbsOrigin(target_pos-(diff_norm*150))
        self:UltimateHit()
        return
    end

    self:GetParent():SetAbsOrigin(velocity)
end


function lua_modifier_defiler_life_grasp_leap:UltimateHit()
    if not IsServer() then return end

    if self.target:TriggerSpellAbsorb(self) then
        self:Destroy()
        return
    end

    local dtable = {
        victim = self.target,
        attacker = self:GetParent(),
        damage = self:GetAbility():GetSpecialValueFor("pure_damage"),
        damage_type = DAMAGE_TYPE_PURE ,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)

    local target_mods = self.target:FindAllModifiers()
    local my_mods = self:GetParent():FindAllModifiers()

    if self.target:IsMagicImmune() == false then
        for i=1, #target_mods do
            if target_mods[i]:IsDebuff() == false then

                local mod_name = target_mods[i]:GetName()
                local mod_time = target_mods[i]:GetRemainingTime()
                local mod_caster = target_mods[i]:GetCaster()
                local mod_ability = target_mods[i]:GetAbility()
                local transfer_mod = self:GetParent():AddNewModifier(mod_caster,mod_ability,mod_name,{})
                transfer_mod:SetDuration(mod_time,true)
                self.target:RemoveModifierByName(mod_name)

            end
        end

        self.target:AddNewModifier(
            self:GetParent(),self:GetAbility(),"modifier_silence",
            {duration = self:GetAbility():GetSpecialValueFor("silence_duration") }
        )
    end


    for i=1, #my_mods do
        if my_mods[i]:IsDebuff() then

            local mod_name = my_mods[i]:GetName()
            local mod_time = my_mods[i]:GetRemainingTime()
            local mod_caster = my_mods[i]:GetCaster()
            local mod_ability = my_mods[i]:GetAbility()

            if self.target:IsMagicImmune() == false then
                local transfer_mod = self.target:AddNewModifier(mod_caster,mod_ability,mod_name,{})
                transfer_mod:SetDuration(mod_time,true)
            end

            self:GetParent():RemoveModifierByName(mod_name)

        end
    end


    local particle = ParticleManager:CreateParticle(
        "particles/items2_fx/soul_ring_blood.vpcf",
        PATTACH_ABSORIGIN,self.target
    )
    ParticleManager:SetParticleControl(particle,0,self.target:GetAbsOrigin())


    self:Destroy()
end


function lua_modifier_defiler_life_grasp_leap:OnDestroy()
    if not IsServer() then return end

    self:StartIntervalThink(-1)

    self:GetParent():RemoveHorizontalMotionController(self)

    if not self.particle then return end

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil
end
