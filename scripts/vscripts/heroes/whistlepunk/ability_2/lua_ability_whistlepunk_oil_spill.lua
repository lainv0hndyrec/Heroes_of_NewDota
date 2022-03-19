LinkLuaModifier( "lua_modifier_whistlepunk_oil_spill_thinker", "heroes/whistlepunk/ability_2/lua_modifier_whistlepunk_oil_spill", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_whistlepunk_oil_spill_slowburn", "heroes/whistlepunk/ability_2/lua_modifier_whistlepunk_oil_spill", LUA_MODIFIER_MOTION_NONE )


lua_ability_whistlepunk_oil_spill = class({})

function lua_ability_whistlepunk_oil_spill:GetAOERadius()
    self.ability_aoe = self:GetSpecialValueFor("ability_aoe")
    return self.ability_aoe
end

function lua_ability_whistlepunk_oil_spill:OnSpellStart()

    if not IsServer() then return end

    self.caster = self:GetCaster()
    self.cursor = self:GetCursorPosition()
    self.teamnumber = self.caster:GetTeamNumber()
    self.projectile_speed = self:GetSpecialValueFor("projectile_speed")
    self.ability_aoe = self:GetSpecialValueFor("ability_aoe")
    self.slow_duration = self:GetSpecialValueFor("slow_duration")

    self.thinker = CreateModifierThinker(
        self.caster,
        self,
        "lua_modifier_whistlepunk_oil_spill_thinker",
        {duration = 5.0},
        self.cursor,
        self.teamnumber,
        false
    )

    local projectile_table = {
        vSourceLoc = self.caster:GetAbsOrigin(),
        Target = self.thinker,
        iMoveSpeed = self.projectile_speed,
        flExpireTime = GameRules:GetGameTime()+5.0,
        bDodgeable = false,
        bIsAttack = false,
        bReplaceExisting = false,
        bIgnoreObstructions = true,
        bDrawsOnMinimap = false,
        --bVisibleToEnemies = false,
        EffectName = "particles/units/heroes/whisltepunk/ability_2/sludge_shot.vpcf",
        Ability = self,
        Source = self.caster,
        bProvidesVision = true,
        iVisionRadius = 100,
        iVisionTeamNumber = self.teamnumber
    }

    self.sludge_projectile = ProjectileManager:CreateTrackingProjectile(projectile_table)

    self.caster:EmitSound("Hero_Shredder.TimberChain.Impact")
end





function lua_ability_whistlepunk_oil_spill:OnProjectileHit(target,location)

    if not IsServer() then return end


    local splat = ParticleManager:CreateParticle(
        "particles/units/heroes/whisltepunk/ability_2/whistlepunk_sludge_splat_endcap.vpcf",
        PATTACH_ABSORIGIN,
        self.caster
    )

    local aboveground = GetGroundPosition(location,nil)
    ParticleManager:SetParticleControl(splat,0,aboveground)
    ParticleManager:ReleaseParticleIndex(splat)

    AddFOWViewer(self.teamnumber,location,self.ability_aoe,1.0,false)
    --DebugDrawCircle(location,Vector(255,0,0),1,self.ability_aoe,true,1.0)

    --oil near enemies
    local oiled_enemies = FindUnitsInRadius(
        self.teamnumber,
        location,
        nil,
        self.ability_aoe,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    local oil_spill_slow_duration = self.slow_duration
    local talent_slow_duration = self.caster:FindAbilityByName("special_bonus_whistlepunk_oil_spill_slow_duration")
    if not talent_slow_duration == false then
        if talent_slow_duration:GetLevel() > 0 then
            oil_spill_slow_duration = self.slow_duration+talent_slow_duration:GetSpecialValueFor("value")
        end
    end

    --loop enemies
    for _,enemy in pairs(oiled_enemies) do
        enemy:AddNewModifier(
    		self.caster,
    		self, -- ability source
    		"lua_modifier_whistlepunk_oil_spill_slowburn", -- modifier name
    		{duration = oil_spill_slow_duration}
    	)
	end

    self.caster:EmitSound("Hero_Alchemist.AcidSpray.Damage")
    target:Destroy()

    return true
end
