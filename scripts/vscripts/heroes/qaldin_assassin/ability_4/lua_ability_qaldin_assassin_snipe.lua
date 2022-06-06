LinkLuaModifier( "lua_modifier_qaldin_assassin_snipe_marker", "heroes/qaldin_assassin/ability_4/lua_modifier_qaldin_assassin_snipe", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_qaldin_assassin_snipe_slow", "heroes/qaldin_assassin/ability_4/lua_modifier_qaldin_assassin_snipe", LUA_MODIFIER_MOTION_NONE )



lua_ability_qaldin_assassin_snipe = class({})







function lua_ability_qaldin_assassin_snipe:GetCastRange(pos,target)
    local lvl = self:GetLevel()-1
    local cast_range = self:GetLevelSpecialValueFor("cast_range",math.max(lvl,0))
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        cast_range = cast_range+self:GetLevelSpecialValueFor("shard_range",0)
    end
    return cast_range
end


function lua_ability_qaldin_assassin_snipe:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_qaldin_assassin_snipe:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end




function lua_ability_qaldin_assassin_snipe:OnAbilityPhaseStart()
    if not IsServer() then return end

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,0.1)

    local marker = self:GetCursorTarget():FindModifierByName("lua_modifier_qaldin_assassin_snipe_marker")

    if not marker then
        self:GetCursorTarget():AddNewModifier(
            self:GetCaster(),self,"lua_modifier_qaldin_assassin_snipe_marker",
            {duration = self:GetCastPoint()}
        )
    end

    return true
end





function lua_ability_qaldin_assassin_snipe:OnAbilityPhaseInterrupted()
    if not IsServer() then return end

    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    local marker = self:GetCursorTarget():FindModifierByName("lua_modifier_qaldin_assassin_snipe_marker")

    if not marker then return end

    marker:Destroy()
end





function lua_ability_qaldin_assassin_snipe:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

    self:GetCaster():EmitSound("Hero_BountyHunter.Shuriken")

    local projectile ={
        vSourceLoc = self:GetCaster():GetAbsOrigin(),
        Target = self:GetCursorTarget(),
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        flExpireTime = GameRules:GetGameTime() + 10.0,
        bDodgeable = true,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true,
        EffectName = "particles/econ/items/bounty_hunter/bounty_hunter_shuriken_hidden/bounty_hunter_suriken_toss_hidden_hunter.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = self:GetCaster():GetTeam()
    }

    ProjectileManager:CreateTrackingProjectile(projectile)

end



function lua_ability_qaldin_assassin_snipe:OnProjectileHit(target,pos)

    if not target then return true end

    if target:TriggerSpellAbsorb(self) then return true end

    local scepter = self:GetCaster():HasScepter()

    if scepter == false then
        if target:IsMagicImmune() then return true end
    end


    target:AddNewModifier(
        self:GetCaster(),self,
        "modifier_stunned",
        {duration = self:GetSpecialValueFor("mini_stun")}
    )


    target:AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_qaldin_assassin_snipe_slow",
        {duration = self:GetSpecialValueFor("ms_slow_time")}
    )



    local base_dmg = self:GetSpecialValueFor("base_damage")
    local dmg_type = DAMAGE_TYPE_MAGICAL
    if scepter then
        base_dmg = base_dmg + self:GetSpecialValueFor("scepter_base_damage")
        dmg_type = DAMAGE_TYPE_PURE
    end

    local hp_dmg = self:GetSpecialValueFor("hp_percent_damage")*0.01
    local total_dmg = base_dmg + (hp_dmg*target:GetMaxHealth())



    local dtable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = total_dmg,
        damage_type = dmg_type,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self
    }

    ApplyDamage(dtable)

    target:EmitSound("Hero_BountyHunter.Jinada")
    target:EmitSound("Hero_BountyHunter.Target")

    return true
end










-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
lua_ability_qaldin_assassin_snipe_blink = class({})


function lua_ability_qaldin_assassin_snipe_blink:OnInventoryContentsChanged()
    if not IsServer() then return end

    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") == false then return end

    if self:IsHidden() == false then return end

    self:SetHidden(false)
    self:SetLevel(1)
end



function lua_ability_qaldin_assassin_snipe_blink:OnSpellStart()
    if not IsServer() then return end

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),
        nil,99999,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false
    )

    for i=1, #enemies do
        if enemies[i]:HasModifier("lua_modifier_qaldin_assassin_snipe_slow") then

            local particle1 = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_bounty_hunter/bounty_loadout.vpcf",
                PATTACH_ABSORIGIN,self:GetCaster()
            )
            ParticleManager:SetParticleControl(particle1,0,self:GetCaster():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle1)

            self:GetCaster():EmitSound("Hero_BountyHunter.WindWalk")

            local back_vector = -enemies[i]:GetForwardVector()
            local radius = enemies[i]:GetPaddedCollisionRadius()
            local pos = (back_vector*radius) + enemies[i]:GetAbsOrigin()

            FindClearSpaceForUnit(self:GetCaster(),pos,true)

            self:GetCaster():MoveToTargetToAttack(enemies[i])

            local particle2 = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_bounty_hunter/bounty_loadout.vpcf",
                PATTACH_ABSORIGIN,self:GetCaster()
            )
            ParticleManager:SetParticleControl(particle2,0,pos)
            ParticleManager:ReleaseParticleIndex(particle2)
            
            enemies[i]:EmitSound("Hero_BountyHunter.WindWalk")
            return
        end
    end

    self:EndCooldown()
end



function lua_ability_qaldin_assassin_snipe_blink:ProcsMagicStick()
    return false
end
