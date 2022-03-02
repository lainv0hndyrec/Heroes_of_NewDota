LinkLuaModifier( "lua_modifier_corruptedlord_throw_glaive_thinker", "heroes/corruptedlord/ability_1/lua_modifier_corruptedlord_throw_glaive", LUA_MODIFIER_MOTION_NONE )

lua_ability_corruptedlord_throw_glaive = class({})


function lua_ability_corruptedlord_throw_glaive:Init()
    self.caster = self:GetCaster()
end


function lua_ability_corruptedlord_throw_glaive:OnUpgrade()
    self.caster = self:GetCaster()
    self.blink_name = "lua_ability_corruptedlord_throw_glaive_blink"
    self.blink_q = self.caster:FindAbilityByName(self.blink_name)
    if self.blink_q:GetLevel() <= 0 then
        self.blink_q:SetLevel(1)
        self.blink_q:SetActivated(false)
    end
end



function lua_ability_corruptedlord_throw_glaive:OnSpellStart()

    --set the other skill active
    self.blink_q:SetActivated(true)

    self.caster = self:GetCaster()
    self.cursorPt = self:GetCursorPosition()
    self.casterPt = self.caster:GetAbsOrigin()
    self.teamNum = self.caster:GetTeamNumber()


    if not IsServer() then return end

    self.caster:EmitSound("Hero_Terrorblade.ConjureImage")

    local thinker_table = CreateModifierThinker(
        self.caster,
        self,
        "lua_modifier_corruptedlord_throw_glaive_thinker",
        {
            target_x = self.cursorPt.x,
			target_y = self.cursorPt.y,
			target_z = self.cursorPt.z
        },
        self.casterPt,
        self.teamNum,
        false
    )

    self.modifier = thinker_table:FindModifierByName( "lua_modifier_corruptedlord_throw_glaive_thinker" )
    self.blink_q.modifier = self.modifier
end





function lua_ability_corruptedlord_throw_glaive:GetCooldown(level)
    local talent = self.caster:FindAbilityByName("special_bonus_corruptedlord_throw_glaive_reduce_cd")
    self.ability_cd = self:GetSpecialValueFor("ability_cd")
    if not talent == false then
        if talent:GetLevel() > 0 then
            return self.ability_cd - talent:GetSpecialValueFor("value")
        end
    end
    return self.ability_cd
end


function lua_ability_corruptedlord_throw_glaive:GetAssociatedSecondaryAbilities()
    return "lua_ability_corruptedlord_throw_glaive_blink"
end



----------------------------[[BLINK]]-----------------------------
----------------------------[[BLINK]]-----------------------------
----------------------------[[BLINK]]-----------------------------
----------------------------[[BLINK]]-----------------------------
lua_ability_corruptedlord_throw_glaive_blink = class({})



function lua_ability_corruptedlord_throw_glaive_blink:IsStealable()
    return false
end



function lua_ability_corruptedlord_throw_glaive_blink:talent_picked()
    local caster = self:GetCaster()
    local talent = caster:FindAbilityByName("special_bonus_corruptedlord_throw_glaive_blink_fear")

    if not talent then return end

    if talent:GetLevel() <= 0 then return end



    local wave_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_scepter.vpcf", PATTACH_ABSORIGIN , caster)
    ParticleManager:SetParticleControl(wave_particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(wave_particle, 1, Vector(200, 0, 0))
    ParticleManager:ReleaseParticleIndex(wave_particle)


    --find enemies near and fear them
    local fear_enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        400,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    --the fear modifier
    for _,enemy in pairs(fear_enemies) do
        if (enemy:IsNull() == false) and (enemy:IsAlive() == true) and (IsValidEntity(enemy) == true) then
            enemy:AddNewModifier(
        		caster,
        		self, -- ability source
        		"modifier_terrorblade_fear", -- modifier name
        		{duration = talent:GetSpecialValueFor("value")}
        	)
        end
	end
end




function lua_ability_corruptedlord_throw_glaive_blink:OnSpellStart()

    if not IsServer() then return end

    if self:IsActivated() == false then return end

    self:deactivation()
end



function lua_ability_corruptedlord_throw_glaive_blink:deactivation()
    local blink_pos = self.modifier.parent:GetAbsOrigin()
    local caster = self:GetCaster()

    local blink_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(blink_pfx,0,caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(blink_pfx)

    caster:EmitSound("Hero_Terrorblade_Morphed.projectileImpact")
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_3_END)

    local difference = blink_pos - caster:GetAbsOrigin()
    local distance = difference:Length2D()
    local normal = difference:Normalized()
    local increment = 100
    local loop = math.ceil(distance/increment)
    local final_pos = self:GetCaster():GetAbsOrigin()

    for i=0,loop,1 do
        local new_pos = blink_pos - (normal*i*increment)
        local good_pos = GridNav:IsTraversable(new_pos)
        if good_pos == true then
            final_pos = new_pos
            break
        end
    end

    FindClearSpaceForUnit(caster,final_pos,true)
    ProjectileManager:ProjectileDodge(caster)
    self:talent_picked()
    self:SetActivated(false)
    self.modifier:OnDestroy()
end
