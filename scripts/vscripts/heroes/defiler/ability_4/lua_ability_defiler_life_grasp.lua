LinkLuaModifier( "lua_modifier_defiler_life_grasp_anim", "heroes/defiler/ability_4/lua_modifier_defiler_life_grasp", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_defiler_life_grasp_hook", "heroes/defiler/ability_4/lua_modifier_defiler_life_grasp", LUA_MODIFIER_MOTION_NONE )

lua_ability_defiler_life_grasp = class({})


function lua_ability_defiler_life_grasp:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_defiler_life_grasp:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_defiler_life_grasp:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end




function lua_ability_defiler_life_grasp:OnSpellStart()

    self:GetCaster():EmitSound("Hero_LifeStealer.Consume")

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end


    local hook_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/defiler/ability_4/life_grasp.vpcf",
        PATTACH_POINT_FOLLOW,self:GetCaster()
    )

    ParticleManager:SetParticleControlEnt(
        hook_particle,0,self:GetCaster(),PATTACH_POINT_FOLLOW,
        "attach_jaw",Vector(0,0,0),false
    )



    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_defiler_life_grasp_anim",
        {duration = self:GetSpecialValueFor("anim_duration")}
    )

    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_defiler_life_grasp_hook",
        {
            duration = self:GetSpecialValueFor("anim_duration"),
            target = self:GetCursorTarget():GetEntityIndex(),
            particle = hook_particle
        },
        self:GetCaster():GetAbsOrigin(),self:GetCaster():GetTeam(),false
    )


end
