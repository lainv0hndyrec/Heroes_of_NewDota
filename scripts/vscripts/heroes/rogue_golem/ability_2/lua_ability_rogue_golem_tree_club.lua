LinkLuaModifier( "lua_modifier_rogue_golem_tree_club_buff", "heroes/rogue_golem/ability_2/lua_modifier_rogue_golem_tree_club", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_rogue_golem_tree_chuck_slow", "heroes/rogue_golem/ability_2/lua_modifier_rogue_golem_tree_club", LUA_MODIFIER_MOTION_NONE )


lua_ability_rogue_golem_tree_club = class({})


function lua_ability_rogue_golem_tree_club:OnUpgrade()
    local chuck = self:GetCaster():FindAbilityByName("lua_ability_rogue_golem_tree_chuck")

    if not chuck then return end
    chuck:SetLevel(1)
end




function lua_ability_rogue_golem_tree_club:CastFilterResultLocation(pos)
    if not IsServer() then return end
    local tree = GridNav:IsNearbyTree(pos,100,false)

    if tree == true then
        return UF_SUCCESS
    end

    return UF_FAIL_CUSTOM
end



function lua_ability_rogue_golem_tree_club:GetCustomCastErrorLocation(pos)
    return "Invalid Target"
end



function lua_ability_rogue_golem_tree_club:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_rogue_golem_tree_club:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_rogue_golem_tree_club:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_rogue_golem_tree_club:OnSpellStart()

    local trees = GridNav:GetAllTreesAroundPoint(self:GetCursorPosition(),100,false)
    if not trees[1] == false then
        trees[1]:CutDown(self:GetCaster():GetTeam())
    end

    self:GetCaster():EmitSound("Hero_Tiny.Tree.Grab")

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_rogue_golem_tree_club_buff",
        {got_tree = true}
    )

    local chuck = self:GetCaster():FindAbilityByName("lua_ability_rogue_golem_tree_chuck")
    if not chuck then return end
    if chuck:IsHidden() == true then
        chuck:SetHidden(false)
    end

end



function lua_ability_rogue_golem_tree_club:GetAssociatedSecondaryAbilities()
    return "lua_ability_rogue_golem_tree_chuck"
end























--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------



lua_ability_rogue_golem_tree_chuck = class({})


function lua_ability_rogue_golem_tree_chuck:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end



function lua_ability_rogue_golem_tree_chuck:OnSpellStart()
    local mod = self:GetCaster():FindModifierByName("lua_modifier_rogue_golem_tree_club_buff")
    if not mod == false then
        mod:Destroy()
    end

    local proj = {
        vSourceLoc = self:GetCaster():GetAbsOrigin(),
        Target = self:GetCursorTarget(),
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        flExpireTime = GameRules:GetGameTime() + 10.0,
        bDodgeable = true,
        bReplaceExisting = false,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true,
        EffectName = "particles/units/heroes/hero_tiny/tiny_tree_proj.vpcf",
        Ability = self,
        Source = self:GetCaster()
    }

    ProjectileManager:CreateTrackingProjectile(proj)

end



function lua_ability_rogue_golem_tree_chuck:OnProjectileHit(target,pos)
    if not target then return true end

    if target:TriggerSpellAbsorb(self) then return true end

    if target:IsAlive() == false then return true end

    local skill = self
    local club = self:GetCaster():FindAbilityByName("lua_ability_rogue_golem_tree_club")
    if not club == false then
        skill = club
    end


    local mod = self:GetCaster():AddNewModifier(
        self:GetCaster(),skill,
        "lua_modifier_rogue_golem_tree_club_buff",
        {}
    )

    self:GetCaster():PerformAttack(
        target,true,true,true,
        false,false,false,true
	)

    mod:Destroy()
end


function lua_ability_rogue_golem_tree_chuck:GetAssociatedPrimaryAbilities()
    return "lua_ability_rogue_golem_tree_club"
end
