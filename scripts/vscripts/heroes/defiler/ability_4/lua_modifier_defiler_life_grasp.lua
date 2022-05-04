LinkLuaModifier( "lua_modifier_defiler_life_grasp_leap", "heroes/defiler/ability_4/lua_modifier_defiler_life_grasp", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier( "lua_modifier_defiler_life_grasp_switch", "heroes/defiler/ability_4/lua_modifier_defiler_life_grasp", LUA_MODIFIER_MOTION_NONE)


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

    if self:GetCaster():IsRooted()  then
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
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return cstate
end



function lua_modifier_defiler_life_grasp_leap:DeclareFunctions()
    return {MODIFIER_EVENT_ON_MODIFIER_ADDED}
end



function lua_modifier_defiler_life_grasp_leap:OnModifierAdded(event)
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

    local speed = self:GetAbility():GetSpecialValueFor("leap_speed")*dt
    local target_pos = self.target:GetAbsOrigin()
    local my_pos = self:GetParent():GetAbsOrigin()
    local diff = target_pos-my_pos
    local diff_norm = diff:Normalized()
    local diff_length = diff:Length2D()
    local velocity = my_pos+(speed*diff_norm)
    velocity = GetGroundPosition(velocity,self:GetParent())

    self:GetCaster():FaceTowards(target_pos)

    local cast_range = self:GetAbility():GetCastRange(target_pos,self.target)
    if diff_length > cast_range*1.5 then
        self:Destroy()
        return
    end


    if diff_length <= 150 then
        self:GetParent():SetAbsOrigin(target_pos-(diff_norm*150))
        self:UltimateHit()
        return
    end

    self:GetParent():SetAbsOrigin(velocity)
end


function lua_modifier_defiler_life_grasp_leap:UltimateHit()
    if not IsServer() then return end

    self.target:AddNewModifier(
        self:GetParent(),self:GetAbility(),
        "lua_modifier_defiler_life_grasp_switch",
        {}
    )

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



















----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
lua_modifier_defiler_life_grasp_switch = class({})

function lua_modifier_defiler_life_grasp_switch:IsDebuff() return false end
function lua_modifier_defiler_life_grasp_switch:IsHidden() return true end
function lua_modifier_defiler_life_grasp_switch:IsPurgable() return false end
function lua_modifier_defiler_life_grasp_switch:IsPurgeException() return false end


function lua_modifier_defiler_life_grasp_switch:OnCreated(kv)
    if not IsServer() then return end

    self.target_mod_pair = {}
    self.caster_mod_pair = {}

    if self:GetParent():IsMagicImmune() == false then

        --GET BUFFS FROM TARGET
        local target_mods = self:GetParent():FindAllModifiers()
        for i=1, #target_mods do
            if target_mods[i]:IsDebuff() == false then
                if target_mods[i]:GetRemainingTime()-FrameTime() > 0 then
                    self.target_mod_pair[target_mods[i]:GetName()] = {target_mods[i]:GetRemainingTime()-FrameTime(),target_mods[i]:GetAbility()}
                end
            end
        end
        --PURGE THE BUFFS FROM THE TARGET
        self:GetParent():Purge(true,false,false,false,false)

        --GIVE DEBUFFS TO THE TARGET
        local caster_mods = self:GetCaster():FindAllModifiers()
        for i=1, #caster_mods do
            if caster_mods[i]:IsDebuff() then
                if caster_mods[i]:GetRemainingTime()-FrameTime() > 0 then
                    self.caster_mod_pair[caster_mods[i]:GetName()] = {caster_mods[i]:GetRemainingTime()-FrameTime(),caster_mods[i]:GetAbility()}
                end
            end
        end

    end

    --PURGE THE DEBUFFS FROM YOU
    self:GetCaster():Purge(false,true,false,false,false)


    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("pure_damage"),
        damage_type = DAMAGE_TYPE_PURE ,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)

    self:StartIntervalThink(FrameTime())
end



function lua_modifier_defiler_life_grasp_switch:OnIntervalThink()
    if not IsServer() then return end

    --Recieve Buffs
    if self:GetParent():IsAlive() then

        for mod_name,array in pairs(self.target_mod_pair) do

            if self:GetParent():HasModifier(mod_name) == false then
                if self:GetCaster():IsAlive() then
                    self:GetCaster():AddNewModifier(
                        self:GetCaster(),array[2],
                        mod_name, {duration = array[1]}
                    )
                end
            end
        end

        if self:GetParent():IsMagicImmune() == false then
            self:GetParent():AddNewModifier(
                self:GetCaster(),self:GetAbility(),
                "modifier_silence",
                {duration = self:GetAbility():GetSpecialValueFor("silence_duration")}
            )
        end
    end

    --Give Debuffs
    if self:GetCaster():IsAlive() then

        local caster_mods = self:GetCaster():FindAllModifiers()

        for mod_name,array in pairs(self.caster_mod_pair) do

            if self:GetCaster():HasModifier(mod_name) == false then
                if self:GetParent():IsAlive() then
                    self:GetParent():AddNewModifier(
                        self:GetCaster(),array[2],
                        mod_name, {duration = array[1]}
                    )
                end
            end

        end

    end




    self:StartIntervalThink(-1)
    self:Destroy()
end
