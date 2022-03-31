LinkLuaModifier( "lua_modifier_great_sage_earth_driver_illu", "heroes/great_sage/ability_3/lua_modifier_great_sage_earth_driver", LUA_MODIFIER_MOTION_NONE)


lua_ability_great_sage_earth_driver = class({})

function lua_ability_great_sage_earth_driver:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Hero_MonkeyKing.Strike.Cast")
    return true
end


function lua_ability_great_sage_earth_driver:OnSpellStart()

    self:GetCaster():EmitSound("Hero_MonkeyKing.Spring.Channel")

    local range = self:GetSpecialValueFor("strike_range")
    local facing = self:GetCaster():GetForwardVector()*range
    local target_pos = self:GetCaster():GetAbsOrigin()+facing
    target_pos = GetGroundPosition(target_pos,self:GetCaster())

    local illu = CreateIllusions(
        self:GetCaster(),
        self:GetCaster(),
        {
            outgoing_damage = 0,
            incoming_damage = 0,
            bounty_base = 0,
            bounty_growth = 0,
            outgoing_damage_structure = 0,
            outgoing_damage_roshan = 0
        },1,self:GetCaster():GetHullRadius(),
        false, false
    )


    illu[1]:SetAbsOrigin(target_pos)
    illu[1]:SetModelScale(0.7)

    illu[1]:AddNewModifier(
        self:GetCaster(),
        self,"lua_modifier_great_sage_earth_driver_illu",
        {duration = self:GetSpecialValueFor("delay_duration")}
    )

    illu[1]:SetTeam(DOTA_TEAM_NOTEAM)

    if illu[1]:HasModifier("lua_modifier_great_sage_somersault_cloud") then
        local remove_mod = illu[1]:FindModifierByName("lua_modifier_great_sage_somersault_cloud")
        remove_mod:Destroy()
    end

end



function lua_ability_great_sage_earth_driver:GetCooldown(lvl)
    local cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return cd
end


function lua_ability_great_sage_earth_driver:GetManaCost(lvl)
    local mana = self:GetLevelSpecialValueFor("ability_mana",lvl)
    return mana
end
