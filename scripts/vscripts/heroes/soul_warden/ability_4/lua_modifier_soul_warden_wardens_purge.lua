LinkLuaModifier( "lua_modifier_soul_warden_wardens_purge_ally", "heroes/soul_warden/ability_4/lua_modifier_soul_warden_wardens_purge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_soul_warden_wardens_purge_enemy", "heroes/soul_warden/ability_4/lua_modifier_soul_warden_wardens_purge", LUA_MODIFIER_MOTION_NONE)

lua_modifier_soul_warden_wardens_purge_ally = class({})

function lua_modifier_soul_warden_wardens_purge_ally:IsHidden() return false end
function lua_modifier_soul_warden_wardens_purge_ally:IsDebuff() return false end
function lua_modifier_soul_warden_wardens_purge_ally:IsPurgable() return true end
function lua_modifier_soul_warden_wardens_purge_ally:IsPurgeException() return true end


function lua_modifier_soul_warden_wardens_purge_ally:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return dfunc
end




function lua_modifier_soul_warden_wardens_purge_ally:OnCreated(kv)
    if not IsServer() then return end

    if not kv.chain_order then self:Destroy() return end


    self:GetParent():Purge(false,true,false,false,false)

    self:GetParent():EmitSound("DOTA_Item.DiffusalBlade.Activate")

    --particle
    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/soul_warden/ability_4/wardens_purge.vpcf",
            PATTACH_POINT_FOLLOW,
            self:GetParent()
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,0,self:GetParent(),PATTACH_POINT_FOLLOW,
            "attach_hitlock",Vector(0,0,0),false
        )
    end


    --check if need to chain
    local add_max = 0
    if self:GetCaster():HasScepter() then
        add_max = self:GetAbility():GetSpecialValueFor("scepter_max_chain")
    end
    local max_chain = self:GetAbility():GetSpecialValueFor("max_chain")+add_max
    local chain_order = kv.chain_order
    if chain_order >= max_chain then return end

    local new_target = nil

    --find another hero
    local chain_range = self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(),self:GetParent())
    local allies = FindUnitsInRadius(
        self:GetParent():GetTeam(),
        self:GetParent():GetAbsOrigin(),
        nil,chain_range,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,false
    )

    for _,ally in pairs(allies) do
        if ally:IsMagicImmune() == false then
            if ally:HasModifier("lua_modifier_soul_warden_wardens_purge_ally") == false then
                new_target = ally
                break
            end
        end
    end

    --find another basic ally
    if not new_target then
        local allies = FindUnitsInRadius(
            self:GetParent():GetTeam(),
            self:GetParent():GetAbsOrigin(),
            nil,chain_range,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,false
        )

        for _,ally in pairs(allies) do
            if ally:IsMagicImmune() == false then
                if ally:HasModifier("lua_modifier_soul_warden_wardens_purge_ally") == false then
                    new_target = ally
                    break
                end
            end
        end
    end

    --still nil then end the chain
    if not new_target then return end

    --the new target
    new_target:AddNewModifier(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_soul_warden_wardens_purge_ally",
        {
            duration = self:GetAbility():GetSpecialValueFor("ms_duration"),
            chain_order = chain_order+1
        }
    )


    --apply particle effect
    local arc_effect = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf",
        PATTACH_POINT_FOLLOW,
        self:GetParent()
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,0,self:GetParent(),PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,1,new_target,PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,2,self:GetParent(),PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )


end


function lua_modifier_soul_warden_wardens_purge_ally:OnRefresh(kv)
    self:OnCreated(kv)
end



function lua_modifier_soul_warden_wardens_purge_ally:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("ally_ms")
end

function lua_modifier_soul_warden_wardens_purge_ally:GetModifierAttackSpeedBonus_Constant()
    if self:GetCaster():HasScepter() == false then return end
    return self:GetAbility():GetSpecialValueFor("ally_ms")
end


function lua_modifier_soul_warden_wardens_purge_ally:OnDestroy()

    if not IsServer() then return end

    if not self.particle then return end

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil

end



























lua_modifier_soul_warden_wardens_purge_enemy = class({})

function lua_modifier_soul_warden_wardens_purge_enemy:IsHidden() return false end
function lua_modifier_soul_warden_wardens_purge_enemy:IsDebuff() return true end
function lua_modifier_soul_warden_wardens_purge_enemy:IsPurgable() return true end
function lua_modifier_soul_warden_wardens_purge_enemy:IsPurgeException() return true end


function lua_modifier_soul_warden_wardens_purge_enemy:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return dfunc
end




function lua_modifier_soul_warden_wardens_purge_enemy:OnCreated(kv)
    if not IsServer() then return end

    self:GetParent():Purge(true,false,false,false,false)

    self:PureDamageSummonedIllusions()

    self:GetParent():EmitSound("DOTA_Item.DiffusalBlade.Activate")

    --particle
    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/soul_warden/ability_4/wardens_purge.vpcf",
            PATTACH_POINT_FOLLOW,
            self:GetParent()
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,0,self:GetParent(),PATTACH_POINT_FOLLOW,
            "attach_hitlock",Vector(0,0,0),false
        )
    end


    --check if need to chain
    local add_max = 0
    if self:GetCaster():HasScepter() then
        add_max = self:GetAbility():GetSpecialValueFor("scepter_max_chain")
    end
    local max_chain = self:GetAbility():GetSpecialValueFor("max_chain")+add_max
    local chain_order = kv.chain_order
    if chain_order >= max_chain then return end

    local new_target = nil

    --find another hero
    local chain_range = self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(),self:GetParent())
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),
        self:GetParent():GetAbsOrigin(),
        nil,chain_range,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,false
    )

    for _,enemy in pairs(enemies) do
        if enemy:IsMagicImmune() == false then
            if enemy:IsInvisible() == false then
                if self:GetCaster():CanEntityBeSeenByMyTeam(enemy) == true then
                    if enemy:HasModifier("lua_modifier_soul_warden_wardens_purge_enemy") == false then
                        new_target = enemy
                        break
                    end
                end
            end
        end
    end

    --find another basic ally
    if not new_target then
        local enemies = FindUnitsInRadius(
            self:GetParent():GetTeam(),
            self:GetParent():GetAbsOrigin(),
            nil,chain_range,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,false
        )

        for _,enemy in pairs(enemies) do
            if enemy:IsMagicImmune() == false then
                if enemy:IsInvisible() == false then
                    if self:GetCaster():CanEntityBeSeenByMyTeam(enemy) == true then
                        if enemy:HasModifier("lua_modifier_soul_warden_wardens_purge_enemy") == false then
                            new_target = enemy
                            break
                        end
                    end
                end
            end
        end
    end

    --still nil then end the chain
    if not new_target then return end

    --the new target
    new_target:AddNewModifier(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_soul_warden_wardens_purge_enemy",
        {
            duration = self:GetAbility():GetSpecialValueFor("ms_duration"),
            chain_order = chain_order+1
        }
    )


    --apply particle effect
    local arc_effect = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf",
        PATTACH_POINT_FOLLOW,
        self:GetParent()
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,0,self:GetParent(),PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,1,new_target,PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,2,self:GetParent(),PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )


end


function lua_modifier_soul_warden_wardens_purge_enemy:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_soul_warden_wardens_purge_enemy:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("enemy_ms")
end

function lua_modifier_soul_warden_wardens_purge_enemy:GetModifierAttackSpeedBonus_Constant()
    if self:GetCaster():HasScepter() == false then return end
    return -self:GetAbility():GetSpecialValueFor("enemy_ms")
end


function lua_modifier_soul_warden_wardens_purge_enemy:OnDestroy()

    if not IsServer() then return end

    if not self.particle then return end

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil
end






function lua_modifier_soul_warden_wardens_purge_enemy:PureDamageSummonedIllusions()
    local apply_damage = false

    if self:GetParent():IsIllusion() then
        apply_damage = true
    end

    if self:GetParent():IsSummoned() then
        apply_damage = true
    end

    if apply_damage == false then return end

    local summon_damage = self:GetAbility():GetSpecialValueFor("summon_damage")

    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = summon_damage,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)
end
