LinkLuaModifier( "lua_modifier_defiler_fetid_slime_buff", "heroes/defiler/ability_1/lua_modifier_defiler_fetid_slime", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_defiler_fetid_slime_debuff", "heroes/defiler/ability_1/lua_modifier_defiler_fetid_slime", LUA_MODIFIER_MOTION_NONE )

lua_ability_defiler_fetid_slime = class({})



function lua_ability_defiler_fetid_slime:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_defiler_fetid_slime:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_defiler_fetid_slime:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_defiler_fetid_slime:OnSpellStart()

    self:GetCaster():EmitSound("Hero_LifeStealer.OpenWounds.Cast")

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end


    local proj ={
        vSourceLoc = self:GetCaster():GetAbsOrigin(),
        Target = self:GetCursorTarget(),
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        flExpireTime = GameRules:GetGameTime() + 10.0,
        bDodgeable = true,
        bIsAttack = false,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true,
        EffectName = "particles/units/heroes/defiler/ability_1/rend_wounds.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        bProvidesVision = false
    }

    self.projectile = ProjectileManager:CreateTrackingProjectile(proj)


end



function lua_ability_defiler_fetid_slime:OnProjectileHit(target,pos)

    if not target then return true end

    if target:TriggerSpellAbsorb(self) then return true end

    local ms_time = self:GetSpecialValueFor("ms_time")
    local talent_time = self:GetCaster():FindAbilityByName("special_bonus_defiler_fetid_slime_slow_time")
    if not talent_time == false then
        if talent_time:GetLevel() > 0 then
            ms_time = ms_time + talent_time:GetSpecialValueFor("value")
        end
    end



    local ability_damage = self:GetSpecialValueFor("ability_damage")
    local talent_dmg = self:GetCaster():FindAbilityByName("special_bonus_defiler_fetid_slime_damage")
    if not talent_dmg == false then
        if talent_dmg:GetLevel() > 0 then
            ability_damage = ability_damage + talent_dmg:GetSpecialValueFor("value")
        end
    end


    local stolen_ms = self:GetSpecialValueFor("stolen_ms")

    target:AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_defiler_fetid_slime_debuff",
        {duration = ms_time}
    )

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_defiler_fetid_slime_buff",
        {duration = ms_time}
    )

    local dtable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = ability_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self
    }

    ApplyDamage(dtable)

    target:EmitSound("Hero_LifeStealer.OpenWounds")

    return true
end
