LinkLuaModifier( "lua_modifier_soul_warden_static_barrier_dot", "heroes/soul_warden/ability_2/lua_modifier_soul_warden_static_barrier", LUA_MODIFIER_MOTION_NONE )

lua_modifier_soul_warden_static_barrier = class({})

function lua_modifier_soul_warden_static_barrier:IsHidden() return false end
function lua_modifier_soul_warden_static_barrier:IsDebuff() return false end
function lua_modifier_soul_warden_static_barrier:IsPurgable() return false end
function lua_modifier_soul_warden_static_barrier:IsPurgeException() return false end

function lua_modifier_soul_warden_static_barrier:IsAura() return true end
function lua_modifier_soul_warden_static_barrier:GetAuraEntityReject(target) return false end
function lua_modifier_soul_warden_static_barrier:GetAuraDuration() return 1.0 end
function lua_modifier_soul_warden_static_barrier:IsAuraActiveOnDeath() return false end

function lua_modifier_soul_warden_static_barrier:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function lua_modifier_soul_warden_static_barrier:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function lua_modifier_soul_warden_static_barrier:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function lua_modifier_soul_warden_static_barrier:GetModifierAura()
	return "lua_modifier_soul_warden_static_barrier_dot"
end

function lua_modifier_soul_warden_static_barrier:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("spark_aoe")
end


function lua_modifier_soul_warden_static_barrier:DeclareFunctions()
    return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end


function lua_modifier_soul_warden_static_barrier:OnCreated(kv)
    if not IsServer() then return end

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/soul_warden/ability_2/static_barrier.vpcf",
            PATTACH_ABSORIGIN_FOLLOW ,
            self:GetParent()
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,0,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,
            "follow_origin",Vector(0,0,0),false
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,1,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,
            "follow_origin",Vector(0,0,0),false
        )
    end

    local barrier_value = self:GetAbility().barrier_value
    self:SetStackCount(barrier_value)

    self:GetCaster():EmitSound("Hero_Razor.UnstableCurrent.Target")
    self:GetCaster():EmitSound("Hero_Razor.IdleLoop")


end



function lua_modifier_soul_warden_static_barrier:OnRefresh(kv)
    self:OnCreated(kv)
end



function lua_modifier_soul_warden_static_barrier:GetModifierTotal_ConstantBlock(event)
    if not IsServer() then return end

    if event.target ~= self:GetParent() then return end

    local damage_prevented = event.original_damage*0.5
    local remaining_barrier = self:GetStackCount()
    local diff = remaining_barrier-damage_prevented

    if diff > 0 then
        self:SetStackCount(diff)
        return damage_prevented
    else
        self:SetStackCount(0)
        self:Destroy()
        return remaining_barrier
    end
end




function lua_modifier_soul_warden_static_barrier:OnDestroy()
    if not IsServer() then return end
    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end

    self:GetCaster():StopSound("Hero_Razor.IdleLoop")
end







lua_modifier_soul_warden_static_barrier_dot = class({})
function lua_modifier_soul_warden_static_barrier_dot:IsHidden() return true end
function lua_modifier_soul_warden_static_barrier_dot:IsDebuff() return true end
function lua_modifier_soul_warden_static_barrier_dot:IsPurgable() return false end
function lua_modifier_soul_warden_static_barrier_dot:IsPurgeException() return false end






function lua_modifier_soul_warden_static_barrier_dot:OnCreated(kv)
    self:OnIntervalThink()
    self:StartIntervalThink(1.0)
end


function lua_modifier_soul_warden_static_barrier_dot:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():IsMagicImmune() then return end

    local spark_aoe = self:GetAbility():GetSpecialValueFor("spark_aoe")
    local pass = false

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        self:GetCaster():GetAbsOrigin(),
        nil, spark_aoe,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,
        false
    )

    for _,enemy in pairs(enemies) do
        if enemy == self:GetParent() then
            pass = true
            break
        end
    end

    if pass == false then return end

    local spark_damage = self:GetAbility():GetSpecialValueFor("spark_damage")
	local talent = self:GetCaster():FindAbilityByName("special_bonus_soul_warden_static_barrier_damage")
	if not talent == false then
		if talent:GetLevel() > 0 then
			spark_damage = spark_damage+talent:GetSpecialValueFor("value")
		end
	end

    local dtable ={
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = spark_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)

    ParticleManager:CreateParticle(
        "particles/econ/items/disruptor/disruptor_ti8_immortal_weapon/disruptor_ti8_immortal_thunder_strike_aoe_electric.vpcf",
        PATTACH_POINT_FOLLOW,
        self:GetParent()
    )

    self:GetParent():EmitSound("Hero_razor.Attack")

end
