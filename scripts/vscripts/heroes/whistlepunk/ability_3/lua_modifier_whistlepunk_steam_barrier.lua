lua_modifier_whistlepunk_steam_barrier = class({})
function lua_modifier_whistlepunk_steam_barrier:IsHidden() return false end
function lua_modifier_whistlepunk_steam_barrier:IsDebuff() return false end
function lua_modifier_whistlepunk_steam_barrier:IsPurgable() return true end
function lua_modifier_whistlepunk_steam_barrier:IsPurgeException() return true end
function lua_modifier_whistlepunk_steam_barrier:AllowIllusionDuplicate() return true end


function lua_modifier_whistlepunk_steam_barrier:OnCreated(kv)
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.max_shield = self.ability:GetSpecialValueFor("barrier_amount")
    self.mana_convert = self.ability:GetSpecialValueFor("mana_convert")*0.01
    self.current_shield = self.max_shield

    if not IsServer() then return end

    self.parent:Purge(false, true, false, false, false)

    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/soul_warden/ability_2/static_barrier_outer.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self.parent
    )

    ParticleManager:SetParticleControlEnt(
        self.particle, 1, self.parent,
        PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
        self.parent:GetAbsOrigin(), false
    )

    self.parent:EmitSound("DOTA_Item.EssenceRing.Cast")
end



function lua_modifier_whistlepunk_steam_barrier:OnRefresh(kv)
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.max_shield = self.ability:GetSpecialValueFor("barrier_amount")
    self.current_shield = self.max_shield

    if not IsServer() then return end

    --self.parent:Purge(false, true, false, false, false)

    self.parent:EmitSound("DOTA_Item.EssenceRing.Cast")
end



function lua_modifier_whistlepunk_steam_barrier:DeclareFunctions()
    local dfuncs = {
        MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_TOOLTIP
    }
	return dfuncs
end



function lua_modifier_whistlepunk_steam_barrier:GetModifierMagical_ConstantBlock(event)
    if not IsServer() then return end

    if event.target:IsAlive() == false then return end
    if event.target ~= self.parent then return end

    if event.damage_type ~= DAMAGE_TYPE_MAGICAL  then return end

    local particle_splash = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_tinker/tinker_defense_matrix_ball_sphere_rings.vpcf",
        PATTACH_POINT_FOLLOW,
        self.parent
    )
    ParticleManager:ReleaseParticleIndex(particle_splash)

    self.parent:EmitSound("DOTA_Item.ArcaneRing.Cast")


    local talent = self.parent:FindAbilityByName("special_bonus_whistlepunk_steam_barrier_purge_heal")

    if self.current_shield > event.damage then
        self.current_shield = self.current_shield - event.damage
        self.parent:GiveMana(event.damage*self.mana_convert)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD , self.parent, event.damage*self.mana_convert, nil)

        if not talent == false then
            if talent:GetLevel() > 0 then
                self.parent:Heal(event.damage,self.parent)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.parent, event.damage, nil)
            end
        end

        return event.damage
    else
        self.parent:GiveMana(self.current_shield*self.mana_convert)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD , self.parent, self.current_shield*self.mana_convert, nil)

        if not talent == false then
            if talent:GetLevel() > 0 then
                self.parent:Heal(self.current_shield,self.parent)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.parent, self.current_shield, nil)
            end
        end

        self:Destroy()
        return self.current_shield
    end



end


function lua_modifier_whistlepunk_steam_barrier:OnTooltip()
    return self.max_shield
end




function lua_modifier_whistlepunk_steam_barrier:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end
