LinkLuaModifier( "lua_modifier_unfathomed_yield_damage", "heroes/unfathomed/ability_2/lua_modifier_unfathomed_yield", LUA_MODIFIER_MOTION_NONE )


lua_ability_unfathomed_yield = class({})





function lua_ability_unfathomed_yield:GetCastRange(location,target)

    local range = 0

    local caster = self:GetCaster()

    if not caster then return range end

    range = self:GetCaster():Script_GetAttackRange()

    return range

end



function lua_ability_unfathomed_yield:OnAbilityPhaseStart()
    if self:GetCursorTarget() == self:GetCaster() then return false end
    return true
end




function lua_ability_unfathomed_yield:OnSpellStart()

    -- damage
    if self:GetCaster():GetTeamNumber() ~= self:GetCursorTarget():GetTeamNumber() then

        local damage_mod = self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_unfathomed_yield_damage",
            {}
        )

        self:GetCaster():PerformAttack(
        	self:GetCursorTarget(),
        	true,
        	true,
        	true,
        	false,
        	false,
        	false,
        	true
        )

        damage_mod:Destroy()

    end


    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    if self:GetCursorTarget():IsMagicImmune() then return end

    -- push / pull computation
    local is_push = false --pull if false
    local eorder_ability = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_ethereal_order")
    if not eorder_ability == false then
        is_push = eorder_ability:GetToggleState()
    end

    local difference = self:GetCursorTarget():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    local normal = difference:Normalized()
    local distance = difference:Length2D()

    local effect_distance = self:GetSpecialValueFor("effect_distance")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unfathomed_yield_range")
    if not talent == false then
        effect_distance = effect_distance+talent:GetSpecialValueFor("value")
    end

    local new_pos = Vector(0,0,0)
    local final_distance = 0

    if is_push == true then
        normal = -1*normal
        new_pos = normal*effect_distance
        final_distance = effect_distance
    else
        if effect_distance < distance then
            new_pos = normal*effect_distance
            final_distance = effect_distance
        else
            new_pos = normal*distance
            final_distance = distance
        end
    end

    --particle
    local particle = ParticleManager:CreateParticle("particles/units/heroes/unfathomed/ability_2/yield_preimage.vpcf", PATTACH_ABSORIGIN, self:GetCursorTarget())
	ParticleManager:SetParticleControl(particle, 0, self:GetCursorTarget():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, self:GetCursorTarget():GetAbsOrigin()-new_pos)
	ParticleManager:SetParticleControlEnt(particle, 2, self:GetCursorTarget(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCursorTarget():GetForwardVector(), true)
    if is_push == true then
        ParticleManager:SetParticleControl(particle,60,Vector(255,0,255))
    else
        ParticleManager:SetParticleControl(particle,60,Vector(0,255,255))
    end
    ParticleManager:ReleaseParticleIndex(particle)

    --shard stun special
    local shard_mod = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard_mod then
        local wstun = self:GetCursorTarget():GetHullRadius()
        local estunned = FindUnitsInLine(
            self:GetCaster():GetTeamNumber(),
            self:GetCursorTarget():GetAbsOrigin(),
            self:GetCursorTarget():GetAbsOrigin()-new_pos,
            nil,
            wstun,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE
        )

        for _,victim in pairs(estunned) do
            if victim ~= self:GetCursorTarget() then
                if victim:IsMagicImmune() == false then
                    victim:AddNewModifier(
                        self:GetCaster(),
                        self,
                        "modifier_stunned",
                        {duration = self:GetSpecialValueFor("shard_stun")}
                    )
                end
            end
        end
    end



    --destroy trees
    local hull = self:GetCursorTarget():GetHullRadius()*3
    local loop = math.ceil(final_distance/hull)
    local valid_pos = self:GetCursorTarget():GetAbsOrigin()
    for i=0,loop,1 do
        local g_pos = self:GetCursorTarget():GetAbsOrigin() - (i*normal*hull)
        GridNav:DestroyTreesAroundPoint(
            g_pos,
            hull*2,
            false
        )

        if GridNav:IsTraversable(g_pos) then
            valid_pos = g_pos
        end
    end

    --teleport
    FindClearSpaceForUnit(
        self:GetCursorTarget(),
        valid_pos,
        false
    )

    self:GetCaster():EmitSound("Hero_Enigma.Black_Hole.Stop")

end




--createhero npc_dota_hero_axe enemy
