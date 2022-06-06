LinkLuaModifier( "lua_modifier_defiler_mimicry_hero", "heroes/defiler/ability_2/lua_modifier_defiler_mimicry", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_defiler_mimicry_host", "heroes/defiler/ability_2/lua_modifier_defiler_mimicry", LUA_MODIFIER_MOTION_NONE )
--3rd ability mod
LinkLuaModifier( "lua_modifier_defiler_defiling_touch_source", "heroes/defiler/ability_3/lua_modifier_defiler_defiling_touch", LUA_MODIFIER_MOTION_NONE )


lua_ability_defiler_mimicry = class({})


function lua_ability_defiler_mimicry:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_defiler_mimicry:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_defiler_mimicry:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



-- function lua_ability_defiler_mimicry:OnAbilityPhaseStart()
--     if self:GetCursorTarget():GetName() == "npc_dota_roshan" then return false end
--
--     if self:GetCursorTarget():IsAncient() then return false end
--
--     return true
-- end



function lua_ability_defiler_mimicry:CastFilterResultTarget(target)
    if not IsServer() then return end
    if target:IsHero() then return UF_FAIL_HERO end
    if target:IsConsideredHero() then return UF_FAIL_CONSIDERED_HERO end
    if target:IsBuilding() then return UF_FAIL_BUILDING end
    if target:IsCourier() then return UF_FAIL_COURIER end
    if target:IsOther() then return UF_FAIL_OTHER end

    if target:GetName() == "npc_dota_roshan" then return UF_FAIL_CUSTOM end

    if target:IsAncient() then
        if self:GetCaster():HasScepter() == false then
            return UF_FAIL_ANCIENT
        end
    end

    if target:IsIllusion() then return UF_FAIL_ILLUSION end
    if target:IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():IsAlive() == false then return UF_FAIL_DEAD end
    if target:IsMagicImmune() then return UF_FAIL_CUSTOM end
    if target:IsInvulnerable() then return UF_FAIL_INVULNERABLE end
    if self:GetCaster():CanEntityBeSeenByMyTeam(target) == false then return UF_FAIL_IN_FOW end
    if target:IsInvisible() then return UF_FAIL_INVISIBLE end
    if target:IsOutOfGame() then return UF_FAIL_OUT_OF_WORLD end



    return UF_SUCCESS
end



function lua_ability_defiler_mimicry:GetCustomCastErrorTarget(target)
    if target:IsMagicImmune() then
        return "Target is Magic Immune"
    end

    if target:GetName() == "npc_dota_roshan"  then
        return "Ability Can't Target Roshan"
    end
end





function lua_ability_defiler_mimicry:OnSpellStart()

    self:GetCaster():EmitSound("Hero_LifeStealer.Infest")

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    if self:GetCursorTarget():IsAlive() == false then return end

    if self:GetCursorTarget():IsNull() then return end


    local target_name = self:GetCursorTarget():GetUnitName()
    local player = self:GetCaster():GetPlayerOwnerID()
    local target_max_hp = self:GetCursorTarget():GetMaxHealth()
    local target_hp = self:GetCursorTarget():GetHealth()
    local target_max_mp = self:GetCursorTarget():GetMaxMana()
    local target_mp = self:GetCursorTarget():GetMana()
    local bounty_min = self:GetCursorTarget():GetMinimumGoldBounty()
    local bounty_max = self:GetCursorTarget():GetMaximumGoldBounty()
    local pos = self:GetCursorTarget():GetAbsOrigin()

    self:GetCursorTarget():AddNoDraw()
    self:GetCursorTarget():Kill(self,self:GetCaster())

    --create the target
    local new_target = CreateUnitByName(
        target_name,pos,false,self:GetCaster(),
        self:GetCaster(),self:GetCaster():GetTeam()
    )

    --control
    new_target:SetControllableByPlayer(player,false)

    --copy the stats
    new_target:SetMaxHealth(target_max_hp)
    new_target:SetHealth(target_hp)
    new_target:SetMaxMana(target_max_mp)
    new_target:SetMana(target_mp)
    new_target:SetMinimumGoldBounty(bounty_min)
    new_target:SetMaximumGoldBounty(bounty_max)

    --add the end ability
    for i=0,3 do
        local ability = new_target:GetAbilityByIndex(i)
        if not ability then
            new_target:AddAbility("generic_hidden")
        end
    end
    local end_mimic = new_target:AddAbility("lua_ability_defiler_mimicry_end")
    end_mimic:SetLevel(1)

    --purge self and add the new modifier
    self:GetCaster():Purge(true,true,false,true,false)
    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_defiler_mimicry_hero",
        {host = new_target:GetEntityIndex()}
    )

    --add the new modifier
    new_target:AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_defiler_mimicry_host",
        {}
    )

    --if you have the defiling touch source then add it to this neutral
    if self:GetCaster():HasModifier("lua_modifier_defiler_defiling_touch_source") then
        local find_ability = self:GetCaster():FindAbilityByName("lua_ability_defiler_defiling_touch")
        new_target:AddNewModifier(
            self:GetCaster(),find_ability,
            "lua_modifier_defiler_defiling_touch_source",
            {}
        )
    end



    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_life_stealer/life_stealer_loadout.vpcf",
        PATTACH_POINT_FOLLOW,self:GetCaster()
    )

    ParticleManager:SetParticleControlEnt(
        particle,0,self:GetCaster(),PATTACH_POINT_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        particle,1,new_target,PATTACH_POINT_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:ReleaseParticleIndex(particle)

end




























lua_ability_defiler_mimicry_end = class({})



function lua_ability_defiler_mimicry_end:OnSpellStart()


    self:GetCaster():ForceKill(false)


end
