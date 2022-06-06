LinkLuaModifier( "lua_modifier_banshee_possess_ride", "heroes/banshee/ability_4/lua_modifier_banshee_possess", LUA_MODIFIER_MOTION_NONE )



lua_ability_banshee_possess = class({})


function lua_ability_banshee_possess:CastFilterResultTarget(target)
    if not IsServer() then return end

    if target:GetTeam() ~= self:GetCaster():GetTeam() then return UF_FAIL_ENEMY end
    if target:IsCreep() then return UF_FAIL_CREEP end
    if target:IsBuilding() then return UF_FAIL_BUILDING end
    if target:IsCourier() then return UF_FAIL_COURIER end
    if target:IsOther() then return UF_FAIL_OTHER end
    if target:IsSummoned() then return UF_FAIL_SUMMONED end
    if target:IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():IsAlive() == false then return UF_FAIL_DEAD end
    if target == self:GetCaster() then return UF_FAIL_CUSTOM end

    return UF_SUCCESS
end


function lua_ability_banshee_possess:GetCustomCastErrorTarget(target)
    if target == self:GetCaster() then
        return "Invalid Target"
    end
end


function lua_ability_banshee_possess:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_banshee_possess:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    if self:GetCaster():HasScepter() then
        ability_cd = ability_cd - self:GetLevelSpecialValueFor("scepter_cd",0)
    end
    return ability_cd
end


function lua_ability_banshee_possess:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_banshee_possess:OnSpellStart()
    self:GetCaster():Purge(true,true,false,true,false)

    local position = self:GetCaster():GetAbsOrigin()

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_undying/undying_soul_rip_heal_rope.vpcf",
        PATTACH_WORLDORIGIN,self:GetCaster()
    )

    ParticleManager:SetParticleControl(particle,1,position)
    ParticleManager:SetParticleControl(particle,0,self:GetCursorTarget():GetAbsOrigin())
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)


    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_banshee_possess_ride",
        {
            duration = self:GetSpecialValueFor("effect_duration"),
            target = self:GetCursorTarget():GetEntityIndex()
        }
    )

    self:SetHidden(true)
end



function lua_ability_banshee_possess:GetAssociatedSecondaryAbilities()
    return "lua_ability_banshee_possess_release"
end













----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
LinkLuaModifier( "lua_modifier_banshee_possess_rush", "heroes/banshee/ability_4/lua_modifier_banshee_possess", LUA_MODIFIER_MOTION_NONE )


lua_ability_banshee_possess_death_rush = class({})



function lua_ability_banshee_possess_death_rush:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_banshee_possess_death_rush:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_banshee_possess_death_rush:OnSpellStart()
    local possess = self:GetCaster():FindModifierByName("lua_modifier_banshee_possess_ride")

    if not possess then return end

    local speed_time = self:GetSpecialValueFor("ms_duration")
    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")

    if shard == true then
        speed_time = speed_time + self:GetSpecialValueFor("shard_ms_duration")
    end


    possess.target:AddNewModifier(
        self:GetCaster(),self ,
        "lua_modifier_banshee_possess_rush",
        {duration = speed_time}
    )


end










----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

lua_ability_banshee_possess_release = class({})


function lua_ability_banshee_possess_release:OnSpellStart()
    local possess = self:GetCaster():FindModifierByName("lua_modifier_banshee_possess_ride")

    if not possess == false then
        possess:Destroy()
    end

end



function lua_ability_banshee_possess_release:GetAssociatedPrimaryAbilities()
    return "lua_ability_banshee_possess"
end
