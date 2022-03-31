LinkLuaModifier( "lua_modifier_great_sage_earth_driver_knockup", "heroes/great_sage/ability_3/lua_modifier_great_sage_earth_driver", LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier( "lua_modifier_great_sage_earth_driver_thinker", "heroes/great_sage/ability_3/lua_modifier_great_sage_earth_driver", LUA_MODIFIER_MOTION_NONE)



lua_modifier_great_sage_earth_driver_illu = class({})

function lua_modifier_great_sage_earth_driver_illu:IsHidden() return true end
function lua_modifier_great_sage_earth_driver_illu:IsDebuff() return false end
function lua_modifier_great_sage_earth_driver_illu:IsPurgable() return false  end
function lua_modifier_great_sage_earth_driver_illu:IsPurgeException() return false end
function lua_modifier_great_sage_earth_driver_illu:AllowIllusionDuplicate() return true end


function lua_modifier_great_sage_earth_driver_illu:CheckState()
    local cstate = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FROZEN] = true
    }
    return cstate
end





function lua_modifier_great_sage_earth_driver_illu:GetStatusEffectName()
    return "particles/units/heroes/great_sage/ability_3/stone_statue.vpcf"
end



function lua_modifier_great_sage_earth_driver_illu:OnCreated(kv)

    if not IsServer() then return end

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/great_sage/ability_3/monkey_signcast.vpcf",
            PATTACH_ABSORIGIN,
            self:GetParent()
        )

        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    end

    CreateModifierThinker(
        self:GetCaster(), self:GetAbility(),
        "lua_modifier_great_sage_earth_driver_thinker",
        {duration = self:GetAbility():GetSpecialValueFor("delay_duration")},
        self:GetParent():GetAbsOrigin(),self:GetCaster():GetTeam(), false
    )

end






function lua_modifier_great_sage_earth_driver_illu:OnDestroy()
    if not IsServer() then return end

    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end


    CreateModifierThinker(
        self:GetCaster(), self:GetAbility(),
        "lua_modifier_great_sage_earth_driver_thinker",
        {duration = self:GetAbility():GetSpecialValueFor("delay_duration")},
        self:GetParent():GetAbsOrigin(),self:GetCaster():GetTeam(), false
    )

    self:GetParent():ForceKill(false)
end























lua_modifier_great_sage_earth_driver_thinker = class({})

function lua_modifier_great_sage_earth_driver_thinker:IsHidden() return true end
function lua_modifier_great_sage_earth_driver_thinker:IsDebuff() return false end
function lua_modifier_great_sage_earth_driver_thinker:IsPurgable() return false  end
function lua_modifier_great_sage_earth_driver_thinker:IsPurgeException() return false end


function lua_modifier_great_sage_earth_driver_thinker:OnCreated(kv)


    if not IsServer() then return end

    self:GetParent():EmitSound("Hero_MonkeyKing.Strike.Impact.EndPos")

    local aoe_radius = self:GetAbility():GetSpecialValueFor("strike_aoe_range")
    local aoe_damage = self:GetAbility():GetSpecialValueFor("ability_damage")
    local knockup = self:GetAbility():GetSpecialValueFor("knockup_duration")

    if self:GetCaster():HasScepter() then
        aoe_radius = aoe_radius + self:GetAbility():GetSpecialValueFor("scepter_aoe_range")
        local dmult = self:GetAbility():GetSpecialValueFor("scepter_ability_damage")*0.01
        aoe_damage = (aoe_damage*dmult) + aoe_damage
    end


    local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		aoe_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do
        if enemy:IsMagicImmune() == false then
            local dtable = {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = aoe_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                ability = self:GetAbility()
            }

            ApplyDamage(dtable)

            enemy:AddNewModifier(
                self:GetCaster(),self:GetAbility(),
                "lua_modifier_great_sage_earth_driver_knockup",
                {duration = knockup}
            )
        end
	end


    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/great_sage/ability_3/earth_drive_earth_b.vpcf",
            PATTACH_ABSORIGIN,
            self:GetParent()
        )

        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle,1,Vector(aoe_radius,0,0))
    end

end




function lua_modifier_great_sage_earth_driver_thinker:OnDestroy()

    if not IsServer() then return end

    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end

    UTIL_Remove(self:GetParent())
end

























lua_modifier_great_sage_earth_driver_knockup = class({})

function lua_modifier_great_sage_earth_driver_knockup:IsHidden() return true end
function lua_modifier_great_sage_earth_driver_knockup:IsDebuff() return true end
function lua_modifier_great_sage_earth_driver_knockup:IsPurgable() return false  end
function lua_modifier_great_sage_earth_driver_knockup:IsPurgeException() return true end



function lua_modifier_great_sage_earth_driver_knockup:CheckState()
    local cstate = {
        [MODIFIER_STATE_STUNNED] = true
    }
    return cstate
end


function lua_modifier_great_sage_earth_driver_knockup:OnCreated(kv)
    if not IsServer() then return end
    if self:ApplyVerticalMotionController() == false then
	    self:Destroy()
    end
end


function lua_modifier_great_sage_earth_driver_knockup:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_great_sage_earth_driver_knockup:UpdateVerticalMotion( me, dt )
    local step = 1-(self:GetRemainingTime()/self:GetDuration())
    local height_step = math.sqrt(step-(step^2))
    local new_height = 500*height_step

    local current_pos = self:GetParent():GetAbsOrigin()
    local ground_pos = GetGroundPosition(current_pos,self:GetParent())
    ground_pos.z = ground_pos.z+new_height
    ground_pos.z = math.min(ground_pos.z,550)
    self:GetParent():SetAbsOrigin(ground_pos)
end


function lua_modifier_great_sage_earth_driver_knockup:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveVerticalMotionController(self)
end
