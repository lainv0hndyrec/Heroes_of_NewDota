LinkLuaModifier( "lua_modifier_great_sage_ruyi_jingu_bang_slow", "heroes/great_sage/ability_2/lua_modifier_great_sage_ruyi_jingu_bang", LUA_MODIFIER_MOTION_NONE)




lua_modifier_great_sage_ruyi_jingu_bang_timer = class({})

function lua_modifier_great_sage_ruyi_jingu_bang_timer:IsHidden() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_timer:IsDebuff() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_timer:IsPurgable() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_timer:IsPurgeException() return false end



function lua_modifier_great_sage_ruyi_jingu_bang_timer:OnDestroy()
    if not IsServer() then return end
    local ability = self:GetAbility()
    local cd = ability:GetEffectiveCooldown(ability:GetLevel()-1)
    ability:StartCooldown(cd)
end



























lua_modifier_great_sage_ruyi_jingu_bang_vault = class({})

function lua_modifier_great_sage_ruyi_jingu_bang_vault:IsHidden() return true end
function lua_modifier_great_sage_ruyi_jingu_bang_vault:IsDebuff() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_vault:IsPurgable() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_vault:IsPurgeException() return false end


function lua_modifier_great_sage_ruyi_jingu_bang_vault:CheckState()
    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_STUNNED] = true
    }
    return cstate
end




function lua_modifier_great_sage_ruyi_jingu_bang_vault:OnCreated(kv)



    self.aoe_radius = self:GetAbility():GetSpecialValueFor("aoe_radius")

    self.ability_damage = self:GetAbility():GetSpecialValueFor("ability_damage")



    if not IsServer() then return end

    if not kv.vault_distance then self:Destroy() return end
    if not kv.face_x then self:Destroy() return end
    if not kv.face_y then self:Destroy() return end
    if not kv.face_z then self:Destroy() return end
    if not kv.duration then self:Destroy() return end

    ProjectileManager:ProjectileDodge(self:GetParent())

    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_MK_SPRING_SOAR,1.0)
    self:GetParent():EmitSound("Hero_MonkeyKing.TreeJump.Cast")

    self.vault_distance = kv.vault_distance
    self.direction = Vector(kv.face_x,kv.face_y,kv.face_z)
    self.direction.z = 0
    self.duration = kv.duration
    self.parent_starting_pos = self:GetParent():GetAbsOrigin()
    self.total_vault = 0.0

    if self:ApplyHorizontalMotionController() == false then
	    self:Destroy()
    end

    if self:ApplyVerticalMotionController() == false then
	    self:Destroy()
    end

end


function lua_modifier_great_sage_ruyi_jingu_bang_vault:OnRefresh(kv)
    self:OnCreated(kv)
end




function lua_modifier_great_sage_ruyi_jingu_bang_vault:UpdateVerticalMotion( me, dt )
    local step = 1-(self:GetRemainingTime()/self.duration)
    local height_step = math.sqrt(step-(step^2))
    local new_height = 500*height_step

    local current_pos = self:GetParent():GetAbsOrigin()
    local ground_pos = GetGroundPosition(current_pos,self:GetParent())
    ground_pos.z = ground_pos.z+new_height
    ground_pos.z = math.min(ground_pos.z,550)
    self:GetParent():SetAbsOrigin(ground_pos)

    -- y = 2x-x^2


end





function lua_modifier_great_sage_ruyi_jingu_bang_vault:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local speed = (dt/self.duration) * self.vault_distance

    self.total_vault = math.min(self.total_vault+speed,self.vault_distance)


    local new_pos = self.parent_starting_pos + (self.total_vault*self.direction)

    local ground_pos = GetGroundPosition(new_pos,self:GetParent())

    if ground_pos.z > -16 and ground_pos.z <= 550 then
        self:GetParent():SetAbsOrigin(new_pos)
    end

end




function lua_modifier_great_sage_ruyi_jingu_bang_vault:OnHorizontalMotionInterrupted()
    self:Destroy()
end


function lua_modifier_great_sage_ruyi_jingu_bang_vault:OnVerticalMotionInterrupted()
    self:Destroy()
end



function lua_modifier_great_sage_ruyi_jingu_bang_vault:OnDestroy()
    if not IsServer() then return end

    local slow_dur = self:GetAbility():GetSpecialValueFor("slow_duration")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_great_sage_ruyi_jingu_bang_slow_duration")
    if not talent == false then
        if talent:GetLevel() > 0 then
            slow_dur = slow_dur + talent:GetSpecialValueFor("value")
        end
    end


    self:GetParent():RemoveGesture(ACT_DOTA_MK_SPRING_SOAR)
    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,1.0)

    self:GetParent():RemoveHorizontalMotionController(self)
    self:GetParent():RemoveVerticalMotionController(self)

    local pos = self:GetParent():GetAbsOrigin()
    pos = GetGroundPosition(pos, self:GetParent())
    self:GetParent():SetAbsOrigin(pos)

    local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		self.aoe_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do
        local dtable = {
            victim = enemy,
            attacker = self:GetParent(),
            damage = self.ability_damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self:GetAbility()
        }

        ApplyDamage(dtable)

        if enemy:IsMagicImmune() == false then
            enemy:AddNewModifier(
                self:GetCaster(),self:GetAbility(),
                "lua_modifier_great_sage_ruyi_jingu_bang_slow",
                {duration = slow_dur}
            )
        end
	end


    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(),self.aoe_radius,false)

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_monkey_king/monkey_king_spring.vpcf",
        PATTACH_ABSORIGIN,
        self:GetParent()
    )

    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,1,Vector(self.aoe_radius,0,0))
    ParticleManager:SetParticleControl(particle,2,Vector(self.aoe_radius,0,0))
    ParticleManager:SetParticleControl(particle,3,Vector(self.aoe_radius,0,0))

    self:GetParent():EmitSound("Hero_MonkeyKing.Spring.Impact")

end













































lua_modifier_great_sage_ruyi_jingu_bang_pull = class({})

function lua_modifier_great_sage_ruyi_jingu_bang_pull:IsHidden() return true end
function lua_modifier_great_sage_ruyi_jingu_bang_pull:IsDebuff() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_pull:IsPurgable() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_pull:IsPurgeException() return false end




function lua_modifier_great_sage_ruyi_jingu_bang_pull:CheckState()
    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true
    }
    return cstate
end




function lua_modifier_great_sage_ruyi_jingu_bang_pull:OnCreated(kv)

    self.ability_damage = self:GetAbility():GetSpecialValueFor("ability_damage")


    if not IsServer() then return end

    if not kv.unit_pull_distance then self:Destroy() return end
    if not kv.face_x then self:Destroy() return end
    if not kv.face_y then self:Destroy() return end
    if not kv.face_z then self:Destroy() return end
    if not kv.duration then self:Destroy() return end


    local slow_dur = self:GetAbility():GetSpecialValueFor("slow_duration")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_great_sage_ruyi_jingu_bang_slow_duration")
    if not talent == false then
        if talent:GetLevel() > 0 then
            slow_dur = slow_dur + talent:GetSpecialValueFor("value")
        end
    end

    self.parent_starting_pos = self:GetParent():GetAbsOrigin()
    self.unit_pull_distance = kv.unit_pull_distance
    self.direction = Vector(kv.face_x,kv.face_y,kv.face_z)
    self.duration = kv.duration
    self.total_pull = 0.0


    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.ability_damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)

    if self:GetParent():IsMagicImmune() == false then
        self:GetParent():AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "lua_modifier_great_sage_ruyi_jingu_bang_slow",
            {duration = slow_dur}
        )
    end


    if self:ApplyHorizontalMotionController() == false then
	    self:Destroy()
    end

end





function lua_modifier_great_sage_ruyi_jingu_bang_pull:OnRefresh(kv)
    self:OnCreated(kv)
end







function lua_modifier_great_sage_ruyi_jingu_bang_pull:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local speed = (dt/self.duration) * self.unit_pull_distance

    self.total_pull = math.min(self.total_pull+speed,self.unit_pull_distance)

    local new_pos = self.parent_starting_pos + (self.total_pull*self.direction)

    local ground_pos = GetGroundPosition(new_pos,self:GetParent())

    GridNav:DestroyTreesAroundPoint(ground_pos,150,false)

    if GridNav:IsTraversable(ground_pos) then
        self:GetParent():SetAbsOrigin(ground_pos)
    end

    -- local particle = ParticleManager:CreateParticle("particles/units/heroes/great_sage/ability_1/image_trail.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    -- ParticleManager:SetParticleControl(particle, 0, current_pos)
    -- ParticleManager:SetParticleControl(particle, 1, ground_pos)
    -- ParticleManager:SetParticleControlEnt(particle, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,RandomInt(0,360),0), true)
    -- ParticleManager:DestroyParticle(particle,false)


    -- ParticleManager:SetParticleControlEnt(particle,0,self:GetParent(),PATTACH_ABSORIGIN,attach_origin,self:GetParent():GetAbsOrigin(),false)
    -- ParticleManager:SetParticleControlEnt(particle,1,self:GetParent(),PATTACH_ABSORIGIN,attach_origin,self:GetParent():GetAbsOrigin(),false)

    --set the position
    -- if ground_pos.z > -16 and ground_pos.z <= 550 then
    --     self:GetParent():SetAbsOrigin(ground_pos)
    -- end

    --remove trees
    -- local hull = self:GetParent():GetHullRadius()*4
    -- GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(),hull,false)
end




function lua_modifier_great_sage_ruyi_jingu_bang_pull:OnHorizontalMotionInterrupted()
    self:Destroy()
end




function lua_modifier_great_sage_ruyi_jingu_bang_pull:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController(self)
end




































lua_modifier_great_sage_ruyi_jingu_bang_slow = class({})

function lua_modifier_great_sage_ruyi_jingu_bang_slow:IsHidden() return false end
function lua_modifier_great_sage_ruyi_jingu_bang_slow:IsDebuff() return true end
function lua_modifier_great_sage_ruyi_jingu_bang_slow:IsPurgable() return true end
function lua_modifier_great_sage_ruyi_jingu_bang_slow:IsPurgeException() return true end


function lua_modifier_great_sage_ruyi_jingu_bang_slow:OnCreated(kv)
    if not IsServer() then return end
    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf",PATTACH_OVERHEAD_FOLLOW,self:GetParent()
        )

        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    end

end



function lua_modifier_great_sage_ruyi_jingu_bang_slow:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end



function lua_modifier_great_sage_ruyi_jingu_bang_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow_percent")
end



function lua_modifier_great_sage_ruyi_jingu_bang_slow:OnDestroy()
    --remove particle here
    if not IsServer() then return end

    ParticleManager:DestroyParticle(self.particle ,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil
end
