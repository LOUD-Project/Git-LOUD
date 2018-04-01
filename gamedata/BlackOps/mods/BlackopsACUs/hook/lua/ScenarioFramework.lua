do
local TriggerFile = import('scenariotriggers.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local UnitUpgradeTemplates = import('/lua/upgradeTemplates.lua').UnitUpgradeTemplates
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local SimCamera = import('/lua/SimCamera.lua').SimCamera
local Cinematics = import('/lua/cinematics.lua')
local SimUIVars = import('/lua/sim/SimUIState.lua')
local Utilities = import('/lua/Utilities.lua') # enabled so we can hide strat icons during NISs

PingGroups = import('/lua/SimPingGroup.lua')
Objectives = import('/lua/SimObjectives.lua')

function FakeGateInUnit(unit, callbackFunction)
    local faction
    local bp = unit:GetBlueprint()

    if EntityCategoryContains( categories.COMMAND, unit ) then
        for k,v in bp.Categories do
            if v == 'UEF' then
                faction = 1
                break
            elseif v == 'AEON' then
                faction = 2
                break
            elseif v == 'CYBRAN' then
                faction = 3
                break
            end
        end

        unit:HideBone(0, true)
        unit:SetUnSelectable(true)
        unit:SetBusy(true)
        unit:PlayUnitSound('CommanderArrival')
        unit:CreateProjectile( '/effects/entities/UnitTeleport03/UnitTeleport03_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(0.75)

        LOG('Faction ',faction)
        if faction == 1 then
            unit:SetMesh('/mods/BlackopsACUs/units/eel0001/EEL0001_PhaseShield_mesh', true)
            unit:ShowBone(0, true)
            unit:HideBone('Engineering_Suite', true)
            unit:HideBone('Flamer', true)
            unit:HideBone('HAC', true)
            unit:HideBone('Gatling_Cannon', true)
            unit:HideBone('Back_MissilePack_B01', true)
            unit:HideBone('Back_SalvoLauncher', true)
            unit:HideBone('Back_ShieldPack', true)
            unit:HideBone('Left_Lance_Turret', true)
            unit:HideBone('Right_Lance_Turret', true)
            unit:HideBone('Zephyr_Amplifier', true)
            unit:HideBone('Back_IntelPack', true)
            unit:HideBone('Torpedo_Launcher', true)
        elseif faction == 2 then
            unit:SetMesh('/mods/BlackopsACUs/units/eal0001/EAL0001_PhaseShield_mesh', true)
            unit:ShowBone(0, true)
		    unit:HideBone('Engineering', true)
		    unit:HideBone('Combat_Engineering', true)
		    unit:HideBone('Left_Turret_Plates', true)
		    unit:HideBone('Basic_GunUp_Range', true)
		    unit:HideBone('Basic_GunUp_RoF', true)
		    unit:HideBone('Torpedo_Launcher', true)
		    unit:HideBone('Laser_Cannon', true)
		    unit:HideBone('IntelPack_Torso', true)
		    unit:HideBone('IntelPack_Head', true)
		    unit:HideBone('IntelPack_LShoulder', true)
		    unit:HideBone('IntelPack_RShoulder', true)
		    unit:HideBone('DamagePack_LArm', true)
		    unit:HideBone('DamagePack_RArm', true)
		    unit:HideBone('DamagePack_Torso', true)
		    unit:HideBone('DamagePack_RLeg_B01', true)
		    unit:HideBone('DamagePack_RLeg_B02', true)
		    unit:HideBone('DamagePack_LLeg_B01', true)
		    unit:HideBone('DamagePack_LLeg_B02', true)
		    unit:HideBone('ShieldPack_Normal', true)
		    unit:HideBone('Shoulder_Arty_L', true)
		    unit:HideBone('ShieldPack_Arty_LArm', true)
		    unit:HideBone('Shoulder_Arty_R', true)
		    unit:HideBone('ShieldPack_Arty_RArm', true)
		    unit:HideBone('Artillery_Torso', true)
		    unit:HideBone('ShieldPack_Artillery', true)
		    unit:HideBone('Artillery_Barrel_Left', true)
		    unit:HideBone('Artillery_Barrel_Right', true)
		    unit:HideBone('Artillery_Pitch', true)
        elseif faction == 3 then
            unit:SetMesh('/mods/BlackopsACUs/units/erl0001/ERL0001_PhaseShield_mesh', true)
            unit:ShowBone(0, true)
            unit:HideBone('Mobility_LLeg_B01', true)
            unit:HideBone('Mobility_LLeg_B02', true)
            unit:HideBone('Mobility_RLeg_B01', true)
            unit:HideBone('Mobility_RLeg_B02', true)
            unit:HideBone('Back_AA_B01', true)
            unit:HideBone('Back_AA_B02R', true)
            unit:HideBone('Back_AA_B02L', true)
            unit:HideBone('Engineering', true)
            unit:HideBone('Combat_Engineering', true)
            unit:HideBone('Right_Upgrade', true)
            unit:HideBone('EMP_Array', true)
            unit:HideBone('EMP_Array_Cable', true)
            unit:HideBone('Back_MobilityPack', true)
            unit:HideBone('Back_CounterIntelPack', true)
            unit:HideBone('Torpedo_Launcher', true)
            unit:HideBone('Combat_B03_Head', true)
            unit:HideBone('Combat_B01_LArm', true)
            unit:HideBone('Combat_B01_RArm', true)
            unit:HideBone('Combat_B02_LLeg', true)
            unit:HideBone('Combat_B02_RLeg', true)
            unit:HideBone('Back_CombatPack', true)
            unit:HideBone('Chest_Open', true)
        end

        unit:SetUnSelectable(false)
        unit:SetBusy(false)

        local totalBones = unit:GetBoneCount() - 1
        local army = unit:GetArmy()
        for k, v in import('/lua/EffectTemplates.lua').UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(unit,bone,army, v)
            end
        end

        WaitSeconds(2)
        unit:SetMesh(unit:GetBlueprint().Display.MeshBlueprint, true)
    else
        LOG ('debug:non commander')
        unit:PlayTeleportChargeEffects()
        unit:PlayUnitSound('GateCharge')
        WaitSeconds(2)
        unit:CleanupTeleportChargeEffects()
    end

    if callbackFunction then
        callbackFunction()
    end
end
end