LinkLuaModifier( "lua_modifier_qaldin_assassin_qaldin_eye_ward", "heroes/qaldin_assassin/ability_2/lua_modifier_qaldin_assassin_qaldin_eye", LUA_MODIFIER_MOTION_NONE )


lua_ability_qaldin_assassin_qaldin_eye = class({})



function lua_ability_qaldin_assassin_qaldin_eye:OnUpgrade()
    local detonate =  self:GetCaster():FindAbilityByName("lua_ability_qaldin_assassin_qaldin_eye_detonate_hero")
    detonate:SetLevel(1)
end



function lua_ability_qaldin_assassin_qaldin_eye:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end



function lua_ability_qaldin_assassin_qaldin_eye:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_qaldin_assassin_qaldin_eye:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end



function lua_ability_qaldin_assassin_qaldin_eye:GetAOERadius()
    local radius = self:GetLevelSpecialValueFor("ward_collision",0)
    return radius
end



function lua_ability_qaldin_assassin_qaldin_eye:CastFilterResultLocation(pos)
    if not IsServer() then return end

    local check_units = FindUnitsInRadius(
    DOTA_TEAM_CUSTOM_4,pos,nil,self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_BOTH,
    DOTA_UNIT_TARGET_BUILDING,DOTA_UNIT_TARGET_FLAG_INVULNERABLE ,
    FIND_ANY_ORDER,false
    )

    if #check_units > 0 then
        if check_units[1]:IsBuilding() then return UF_FAIL_CUSTOM end
    end

    if GridNav:IsNearbyTree(pos,self:GetAOERadius(),false) then return UF_FAIL_CUSTOM end

    if GridNav:IsTraversable(pos) == false then return UF_FAIL_CUSTOM end


    return UF_SUCCESS
end



function lua_ability_qaldin_assassin_qaldin_eye:GetCustomCastErrorLocation(pos)
    if not IsServer() then return end

    local check_units = FindUnitsInRadius(
    DOTA_TEAM_CUSTOM_4,pos,nil,self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_BOTH,
    DOTA_UNIT_TARGET_BUILDING,DOTA_UNIT_TARGET_FLAG_INVULNERABLE ,
    FIND_ANY_ORDER,false
    )

    if #check_units > 0 then
        if check_units[1]:IsBuilding() then return "Blocked By A Building" end
    end

    if GridNav:IsNearbyTree(pos,self:GetAOERadius(),false) then return "Blocked By A Tree" end

    if GridNav:IsTraversable(pos) == false then return "Can Not Be Traversed" end

    return UF_SUCCESS
end



function lua_ability_qaldin_assassin_qaldin_eye:OnSpellStart()

    local find_all_wards = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),nil,
        999999,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_FARTHEST,false
    )


    local my_wards = {}
    for i=1,#find_all_wards do
        if find_all_wards[i]:GetUnitName() == "npc_custom_unit_qaldin_eye" then
            table.insert(my_wards,find_all_wards[i])
        end
    end

    local max_wards = self:GetSpecialValueFor("active_wards")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_qaldin_assassin_qaldin_eye_max")
    if not talent == false then
        if talent:GetLevel() > 0 then
            max_wards = max_wards + talent:GetSpecialValueFor("value")
        end
    end

    if max_wards <= #my_wards then
        my_wards[1]:ForceKill(false)
    end


    local ward = CreateUnitByName(
        "npc_custom_unit_qaldin_eye",
        self:GetCursorPosition(),true,self:GetCaster(),
        self:GetCaster(),self:GetCaster():GetTeam()
    )



    local playerid = self:GetCaster():GetPlayerID()
    ward:SetControllableByPlayer(playerid,true)

    ward:AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_qaldin_assassin_qaldin_eye_ward",{}
    )

    local detonate = ward:FindAbilityByName("lua_ability_qaldin_assassin_qaldin_eye_detonate_ward")
    detonate:SetLevel(self:GetLevel())

    self:GetCaster():EmitSound("DOTA_Item.ObserverWard.Activate")

end



function lua_ability_qaldin_assassin_qaldin_eye:GetAssociatedSecondaryAbilities()
    return "lua_ability_qaldin_assassin_qaldin_eye_detonate_hero"
end



















lua_ability_qaldin_assassin_qaldin_eye_detonate_hero = class({})



function lua_ability_qaldin_assassin_qaldin_eye_detonate_hero:OnSpellStart()

    local find_all_wards = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),nil,
        999999,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false
    )

    local my_wards = {}
    for i=1,#find_all_wards do
        if find_all_wards[i]:GetUnitName() == "npc_custom_unit_qaldin_eye" then
            table.insert(my_wards,find_all_wards[i])
        end
    end

    if #my_wards <= 0 then return end

    local playerID = self:GetCaster():GetPlayerID()
    local detonate = my_wards[1]:FindAbilityByName("lua_ability_qaldin_assassin_qaldin_eye_detonate_ward")
    my_wards[1]:CastAbilityNoTarget(detonate,playerID)

end



function lua_ability_qaldin_assassin_qaldin_eye_detonate_hero:GetAssociatedPrimaryAbilities()
    return "lua_ability_qaldin_assassin_qaldin_eye"
end




function lua_ability_qaldin_assassin_qaldin_eye_detonate_hero:ProcsMagicStick()
    return false
end



























lua_ability_qaldin_assassin_qaldin_eye_detonate_ward = class({})



function lua_ability_qaldin_assassin_qaldin_eye_detonate_ward:GetCastRange(pos,target)
    local ward_silence_range = self:GetLevelSpecialValueFor("ward_silence_range",0)
    return ward_silence_range
end



function lua_ability_qaldin_assassin_qaldin_eye_detonate_ward:GetAOERadius()
    local ward_silence_range = self:GetLevelSpecialValueFor("ward_silence_range",0)
    return ward_silence_range
end



function lua_ability_qaldin_assassin_qaldin_eye_detonate_ward:OnSpellStart()

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),nil,
        self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )

    for i=1, #enemies do
        enemies[i]:AddNewModifier(
            self:GetCaster(),self,"modifier_silence",
            {duration = self:GetSpecialValueFor("silence_duration")}
        )
    end


    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )

    ParticleManager:SetParticleControl(particle,0,self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,1,Vector(self:GetAOERadius(),0,0))

    self:GetCaster():EmitSound("Hero_BountyHunter.Target")

    self:GetCaster():ForceKill(false)


end



function lua_ability_qaldin_assassin_qaldin_eye_detonate_ward:ProcsMagicStick()
    return false
end
