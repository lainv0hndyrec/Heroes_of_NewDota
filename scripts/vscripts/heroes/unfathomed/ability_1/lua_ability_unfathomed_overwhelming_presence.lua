LinkLuaModifier( "lua_modifier_unfathomed_overwhelming_presence", "heroes/unfathomed/ability_1/lua_modifier_unfathomed_overwhelming_presence", LUA_MODIFIER_MOTION_NONE )

lua_ability_unfathomed_overwhelming_presence = class({})


function lua_ability_unfathomed_overwhelming_presence:GetAOERadius()

    local range = self:GetLevelSpecialValueFor("aoe_range",0)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unfathomed_overwhelming_presence_range")
    if not talent == false then
        if talent:GetLevel() > 0 then
            range = range+talent:GetSpecialValueFor("value")
        end
    end
    return range
end



function lua_ability_unfathomed_overwhelming_presence:GetCastRange(location,target)

    local range = 0

    local caster = self:GetCaster()

    if not caster then return range end

    range = self:GetAOERadius()

    return range

end


function lua_ability_unfathomed_overwhelming_presence:OnSpellStart()

    local aoe_range = self:GetAOERadius()
    local aoe_damage = self:GetSpecialValueFor("aoe_damage")
    local effect_duration = self:GetSpecialValueFor("effect_duration")

    local is_push = false --pull if false
    local eorder_ability = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_ethereal_order")

    if not eorder_ability == false then
        is_push = eorder_ability:GetToggleState()
    end


    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        aoe_range,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )



    for _,enemy in pairs(enemies) do
        if enemy:IsMagicImmune() == false then
            --apply Damage
            local dtable = {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = aoe_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                self
            }

            ApplyDamage(dtable)

            --apply modifier
            enemy:AddNewModifier(
                self:GetCaster(),
                self,
                "lua_modifier_unfathomed_overwhelming_presence",
                {duration = effect_duration}
            )
        end
	end



    --DebugDrawCircle(self:GetCaster():GetAbsOrigin(),Vector(255,0,0),1,aoe_range,false,1.0)
    local pulse_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/unfathomed/ability_1/ovherwhelming_presence_wraper.vpcf",
        PATTACH_ABSORIGIN,
        self:GetCaster()
    )
    ParticleManager:SetParticleControl(pulse_particle,0,self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(pulse_particle,1,Vector(aoe_range,0,0))
    if is_push == true then
        ParticleManager:SetParticleControl(pulse_particle,60,Vector(255,0,255))
    else
        ParticleManager:SetParticleControl(pulse_particle,60,Vector(0,255,255))
    end
    ParticleManager:ReleaseParticleIndex(pulse_particle)



    self:GetCaster():EmitSound("Hero_Enigma.Malefice")


end
