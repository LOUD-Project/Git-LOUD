-- Helper Functions by PhoenixMT
PhxLib ={
    _VERSION = '2.0',
    _DESCRIPTION = 'General Helper Functions',
    -- Threat Balance Constants are defined here
    -- see: https://docs.google.com/document/d/1oMpHiHDKjTID0szO1mvNSH_dAJfg0-DuZkZAYVdr-Ms/edit
    SpeedT2_KNIFE = 3.1058,
    RangeT2_KNIFE = 25,
    RangeAvgEngage = 50,
    tEnd = 13.0,
}

PhxLib.canTargetHighAir = function(weapon)
    local completeTargetLayerList = ''
--    for curLayerID,curLayerList in ipairs(weapon.FireTargetLayerCapsTable) do
--        completeTargetLayerList = completeTargetLayerList .. curLayerList
--    end
    if(weapon.FireTargetLayerCapsTable) then
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(string.find(completeTargetLayerList,"Air") and
            not string.find((weapon.TargetRestrictDisallow or "None"),
                           "HIGHALTAIR") and
            not string.find((weapon.TargetRestrictOnlyAllow or "None"),
                           "TACTICAL") and
            not string.find((weapon.TargetRestrictOnlyAllow or "None"),
                           "MISSILE")
        ) then
            return true
        end
    end

    return false
end

PhxLib.canTargetLand = function(weapon)
    local completeTargetLayerList = ''
--    for curLayerID,curLayerList in ipairs(weapon.FireTargetLayerCapsTable) do
--        completeTargetLayerList = completeTargetLayerList .. curLayerList
--    end
    if(weapon.FireTargetLayerCapsTable) then
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(string.find(completeTargetLayerList,"Land") or
           string.find(completeTargetLayerList,"Water")
        ) then
            return true
        end
    end

    return false
end

PhxLib.canTargetSubs = function(weapon)
    if(weapon.AboveWaterTargetsOnly) then return false end
    if(weapon.FireTargetLayerCapsTable) then
        local completeTargetLayerList = ''
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(
            string.find(completeTargetLayerList,"Sub") 
            --or string.find(completeTargetLayerList,"Seabed") 
        ) then
            return true
        end
    end

    return false
end

PhxLib.cleanUnitName = function(bp)
    --<LOC ual0402_name>Overlord
    local UnitBaseName = "None"
    -- General.UnitName is usually better, but doesn't always exist.
    if(bp.General and bp.General.UnitName) then
        UnitBaseName = bp.General.UnitName
        local strStrt = string.find(UnitBaseName,">")
        local strStop = string.len(UnitBaseName)
        if (strStrt and strStop) then
            UnitBaseName = string.sub(UnitBaseName,strStrt+1,strStop)
        end
    -- Fall back to Description if needed
    elseif(bp.Description) then
        UnitBaseName = bp.Description
        local strStrt = string.find(UnitBaseName,">")
        local strStop = string.len(UnitBaseName)
        if (strStrt and strStop) then
            UnitBaseName = string.sub(UnitBaseName,strStrt+1,strStop)
        end
    else
        --UnitBaseName = "None"
    end

    return UnitBaseName
end

PhxLib.getTechLevel = function(bp)
    if(bp.Categories) then
        local completeCategoriesList = ''
        for curKey,curCategory in pairs(bp.Categories) do
            completeCategoriesList = completeCategoriesList .. curCategory
        end
        if string.find(completeCategoriesList,"EXPERIMENTAL")
            then return 4
        elseif string.find(completeCategoriesList,"TECH3")
            then return 3
        elseif string.find(completeCategoriesList,"TECH2")
            then return 2
        elseif string.find(completeCategoriesList,"TECH1")
            then return 1
        else 
            return 0
        end
    else
        if bp.General and 
            bp.General.TechLevel == 'RULEUTL_Basic'
        then Tier = 1
        elseif bp.General and 
            bp.General.TechLevel == 'RULEUTL_Advanced'
        then Tier = 2
        elseif bp.General and 
            bp.General.TechLevel == 'RULEUTL_Secret'
        then Tier = 3
        elseif bp.General and 
            bp.General.TechLevel == 'RULEUTL_Experimental'
        then Tier = 4
        end

        return 0
    end
end

PhxLib.getHealth = function(curBP)
    local Health = 0
    if  curBP.Defense and 
        curBP.Defense.MaxHealth
    then 
        Health = curBP.Defense.MaxHealth or 0
    else
        Health = 0
    end

    return Health
end

PhxLib.getShield = function(curBP)
    local Shield = 0
    if  curBP.Defense and 
        curBP.Defense.Shield and 
        curBP.Defense.ShieldMaxHealth
    then
        Shield = curBP.Defense.Shield.SheildMaxHealth or 0
    else 
        Shield = 0
    end
    
    return Shield
end

PhxLib.getSpeed = function(curBP)
    -- Get Speed Value if it exists
    local Speed = 0
    if  curBP.Physics and 
        curBP.Physics.MaxSpeed
    then
        Speed = curBP.Physics.MaxSpeed or 0
    else 
        Speed = 0
    end

    return Speed
end

PhxLib.getVision = function(curBP)
    local Vision = 0
    if curBP.Intel and curBP.Intel.VisionRadius then
        Vision = curBP.Intel.VisionRadius
    end

    return Vision
end

PhxLib.PhxWeapDPS = function(weapon)
    -- Inputs: weapon blueprint
    -- Outputs: DPS table with:
    --            Ttime - total time for all racks+muzzles+recharges etc.
    --            RateOfFire - 1/(Ttime)
    --              NOTE: Not blueprint weapon RoF!
    --            Damage - Alpha Strike or Impulse Damage
    --            Range
    --            WeaponName
    --            Warn - A comma-delimited list of special warnings
    --            subDPS - DPS to submarine vessels (not seafloor)
    --            airDPS - DPS to High Altitude Air 
    --            srfDPS - DPS to surface targets (land and sea)
    --            DPS - Total DPS to any one target (not the sum of above!)

    local DPS = {}
    local Ttime = 0
    local Tdamage = 0
    DPS.Range = weapon.MaxRadius or 0
    DPS.WeaponName = (weapon.Label or "None") .. 
                     "/" .. (weapon.DisplayName or "None")
    local Warn = ''

    local debug = true

    local numRackBones = 0
    local numMuzzleBones = 0
    if weapon.RackBones then
        numRackBones = table.getn(weapon.RackBones) or 0

        if(weapon.RackBones[1].MuzzleBones) then
            numMuzzleBones = table.getn(weapon.RackBones[1].MuzzleBones)
        end
        
        if(debug) then print("Racks: " .. numRackBones .. ", Rack 1 Muzzles: " .. numMuzzleBones) end
    end


    -- enable debug text
    local BeamLifetime = (weapon.BeamLifetime or 0)

    if weapon.DPSOverRide then
        -- Override of script-based weapons (like drones)
        Tdamage = weapon.DPSOverRide
        Ttime = 1

    elseif weapon.DummyWeapon == true or weapon.Label == 'DummyWeapon' then
        --skip dummy weapons
        Tdamage = 0
        Ttime = 1

    elseif weapon.WeaponCategory  == 'Kamikaze' then
        --Suicide Weapons have no RateOfFire
        Ttime = 1
        Tdamage = weapon.Damage

    -- Check for Continous Beams
    --   NOTE: This will throw out lots of logic as beam turns on only
    --         once and then do damage continuously. That's ok for now.
    elseif (weapon.ContinuousBeam and BeamLifetime==0) then
        if(debug) then print("Continuous Beam") end
        local timeToTriggerDam = math.max(weapon.BeamCollisionDelay,0.1)

        Ttime = math.ceil(timeToTriggerDam*10)/10
        Tdamage = weapon.Damage

    elseif (numRackBones > 0) then
        -- TODO: Need a better methodology to identify single-shot and
        --       multi-muzzle/rack weapons
        if(debug) then print("Multiple Rack/Muzzles") end

        -- This is extrapolated from coversations with people, not actual code
        --  It is supposed to be time between onFire() events
        local onFireTime = math.max(0.1,math.floor(10/weapon.RateOfFire+0.5)/10)

        -- Each Muzzle Cycle Time
        local MuzzleSalvoDelay = (weapon.MuzzleSalvoDelay or 0)
        local muzzleTime =  MuzzleSalvoDelay +
                            (weapon.MuzzleChargeDelay or 0)

        if not(MuzzleSalvoDelay == 0) then  
            -- These are the standard calculations
            -- Each Muzzle spawns a projectile and takes muzzleTime to do so
            Tdamage = weapon.Damage * (weapon.MuzzleSalvoSize or 1)
            muzzleTime = muzzleTime * (weapon.MuzzleSalvoSize or 1)
        else  
            -- These are special catch for a dumb if() statement
            --    || Issue in deafaultweapons.lua Line 850
            
            -- Warn if the number of MuzzleBones doesn't equal the MuzzleSalvoSize
            if (numMuzzleBones ~= (weapon.MuzzleSalvoSize or 1)) then 
                Warn = Warn.."MuzzleSalvoSize_Overridden,"
            end

            -- either way report the actual DPS (but likely unintended)
            Tdamage = weapon.Damage * numMuzzleBones
            muzzleTime = muzzleTime * numMuzzleBones

        end

        -- If RackFireTogether is set, then each rack also fires all muzzles
        --  all in RackSalvoFiringState without exiting to another state
        if(weapon.RackFireTogether) then 
            Tdamage = Tdamage * numRackBones
            muzzleTime = muzzleTime * numRackBones
        elseif (numRackBones > 1) then
            --  However, racks go back to RackSalvoFireReadyState and wait
            --   for OnFire() event
            muzzleTime = math.max(muzzleTime, onFireTime) * numRackBones
            Tdamage = Tdamage * numRackBones
        end

        -- Check for Beams that trigger multiple times
        if(BeamLifetime > 0) then
            if(debug) then print("Pulse Beam") end
            
            -- Beam damage events can only trigger on ticks, therefore round
            --  both BeamLifetime and BeamTriggerTime
            BeamLifetime = math.ceil(BeamLifetime*10)/10
            local BeamTriggerTime = weapon.BeamCollisionDelay + 0.01
            BeamTriggerTime = math.ceil(BeamTriggerTime*10)/10

            Ttime = math.max(BeamLifetime,0.1,Ttime)
            Tdamage = Tdamage * BeamLifetime / BeamTriggerTime
        end

        local rechargeTime = 0
        local energyRequired = (weapon.EnergyRequired or 0)
        if energyRequired > 0 -- and 
           --not weapon.RackSalvoFiresAfterCharge 
           then
            rechargeTime = energyRequired / 
                           weapon.EnergyDrainPerSecond
            rechargeTime = math.ceil(rechargeTime*10)/10
            rechargeTime = math.max(0.1,rechargeTime)
        end

        local RackTime = (weapon.RackSalvoReloadTime or 0) + 
                         (weapon.RackSalvoChargeTime or 0)

        -- RackTime is in parallel with energy-based recharge time
        local rackNchargeTime = math.max(RackTime,rechargeTime)
        rackNchargeTime = math.ceil(rackNchargeTime*10)/10
        
        -- RateofFire is always in parallel
        -- MuzzleTime is added to rackTime and energy-based recharge time
        --print("Quick Debug: ",muzzleTime,',',rackNchargeTime,',',math.ceil(10/weapon.RateOfFire)/10)
        Ttime = math.max(   
                                muzzleTime + rackNchargeTime, 
                                onFireTime
                            )

        --   This is correct method for DoT, which happen DoTPulses 
        --   times and stack infinately
        if(weapon.DoTPulses) then 
            Tdamage = Tdamage * weapon.DoTPulses
        end

        -- This is a rare weapon catch that skips OnFire() and
        --   EconDrain entirely, its kinda scary.
        if(weapon.RackSalvoFiresAfterCharge and 
           weapon.RackSalvoReloadTime>0 and
           weapon.RackSalvoChargeTime>0
          ) then
            Ttime = muzzleTime + RackTime
            Warn = Warn .. "RackSalvoFiresAfterCharge_ComboWarn,"
        end
        -- Units Affected: 
        -- UAB2204 (T2 Aeon? Flak), 
        -- XSB3304 (T3 Sera Flak), 
        -- XSS0202 (T2 Sera Cruiser),
        -- WRA0401, 

        -- TODO: Add additional time if( WeaponUnpacks && WeaponRepackTimeout > 0 && RackSalvoChargeTime <= 0) 
        -- {add_time WeaponRepackTimeout}
        -- This only matters if SkipReadState is true and we enter Unpack more than once.
        if(weapon.SkipReadyState and weapon.WeaponUnpacks) then
            Warn = Warn .. "SkipReadyState_addsUnpackDelay,"
        end

        -- TODO: Another oddball case, if SkipReadyState and not 
        --   RackSalvoChargeTime>0 and not WeaponUnpacks then Econ 
        --   drain doesn't get checked.  Otherwise behaves normally(?).
        -- Only three units /w : BRPAT2BOMBER, DEA0202, XSA0202

    else
        if(debug) then print("Unknown") end
        print("ERROR: Weapon Type Undetermined")
        Warn = Warn .. 'Unknown Type,'
        Tdamage = 0
        Ttime = 1
    end

    -- TODO: Add warning code to check if RateOfFire has rounding error problem (ie., RoF = 3 --> TimeToFire = 0.333 --> 0.4)
    -- TODO: Add warning code to check if(RackReloadTimeout>0 and numRackBones > 1)
    
    DPS.RateOfFire = 1/Ttime
    DPS.DPS = Tdamage/Ttime
    DPS.Damage = Tdamage
    DPS.Ttime = Ttime

    -- Categorize DPS
    DPS.subDPS = 0
    DPS.airDPS = 0
    DPS.srfDPS = 0
    --Weapons that can target air also are allowed to be counted as 
    --  surf/sub damge
    if(PhxLib.canTargetHighAir(weapon)) then
        DPS.airDPS = Tdamage/Ttime
        if(debug) then print("air") end
    end

    --Since "Surface" and "Sub" both include water sub damage must 
    --  override surface damage.
    if(PhxLib.canTargetSubs(weapon)) then
        DPS.subDPS = Tdamage/Ttime
        if(debug) then print("sub") end
    elseif (PhxLib.canTargetLand(weapon)) then
        DPS.srfDPS = Tdamage/Ttime
        if(debug) then print("surface") end
    end

    -- Calculate Threat Values for this Weapon
    DPS.threatRange = (DPS.Range - PhxLib.RangeT2_KNIFE)
                      / PhxLib.SpeedT2_KNIFE 
                      * DPS.srfDPS/PhxLib.tEnd / 10
    DPS.threatRange = math.max(0,DPS.threatRange)
    DPS.threatSurf = DPS.srfDPS/20
    DPS.threatAir = DPS.airDPS/20
    DPS.threatSub = DPS.subDPS/20

    DPS.Warn = Warn

    return DPS
end

PhxLib.calcUnitDPS = function(curBP,curShortID)
    local debug = true

    local unitDPS = {}
    unitDPS.Threat = {}
    unitDPS.Threat.Range = 0
    unitDPS.Threat.HP = 0
    unitDPS.Threat.Speed = 0
    unitDPS.Threat.Dam = 0
    unitDPS.Threat.Total = 0
    unitDPS.srfDPS = 0
    unitDPS.subDPS = 0
    unitDPS.airDPS = 0
    unitDPS.totDPS = 0
    unitDPS.maxRange = 0
    unitDPS.Warn = ''

    unitDPS.Health = PhxLib.getHealth(curBP)
    unitDPS.Shield = PhxLib.getShield(curBP)
    unitDPS.Speed = PhxLib.getSpeed(curBP)

    unitDPS.Threat.HP = (unitDPS.Health+unitDPS.Shield)/PhxLib.tEnd/20

    -- Run PhxWeapDPS on each weapon, then calculate threat value 
    --  and accumulate into totals for the unit.
    if curBP.Weapon then
        local NumWeapons = table.getn(curBP.Weapon)
        if debug then print("**" .. curShortID .. "/" .. PhxLib.cleanUnitName(curBP) 
            .. " has " .. NumWeapons .. " weapons" 
            --.. " and is stored in " .. (allFullDirs[curBPid] or "None")
        ) end
        
        for curWepID,curWep in ipairs(curBP.Weapon) do
            local weapDPS = PhxLib.PhxWeapDPS(curWep)
            if debug then print(curShortID ..
                "/" .. weapDPS.WeaponName ..
                ': has Damage: ' .. weapDPS.Damage ..
                ' - Time: ' .. weapDPS.Ttime ..
                ' - new DPS: ' .. (weapDPS.Damage/weapDPS.Ttime)
            ) end

            if unitDPS.maxRange < weapDPS.Range then
                unitDPS.maxRange = weapDPS.Range
            end
            
            unitDPS.srfDPS = unitDPS.srfDPS + weapDPS.srfDPS
            unitDPS.subDPS = unitDPS.subDPS + weapDPS.subDPS
            unitDPS.airDPS = unitDPS.airDPS + weapDPS.airDPS
            unitDPS.totDPS = unitDPS.totDPS + weapDPS.DPS

            unitDPS.Warn = unitDPS.Warn .. weapDPS.Warn

            --print(" weapDPS.threatRange = " ..  weapDPS.threatRange)
            unitDPS.Threat.Range = unitDPS.Threat.Range + weapDPS.threatRange
            unitDPS.Threat.Dam = unitDPS.Threat.Dam + weapDPS.threatSurf
            if debug then print(" ") end -- End of Weapon Reporting
        end --Weapon For Loop

        unitDPS.Threat.Speed = (PhxLib.RangeAvgEngage/PhxLib.SpeedT2_KNIFE - PhxLib.RangeAvgEngage/unitDPS.Speed)
                    * unitDPS.srfDPS/PhxLib.tEnd / 10
        unitDPS.Threat.Speed = math.max(0,unitDPS.Threat.Speed)
        print(" unitDPS.Threat.Speed = " ..  unitDPS.Threat.Speed)

    else
        print(curShortID .. "/" .. (curBP.Description or "None") .. 
            " has NO weapons")
    end --End if(weapon)

    unitDPS.Threat.Total = unitDPS.Threat.Speed + unitDPS.Threat.Range 
                         + unitDPS.Threat.Dam + unitDPS.Threat.HP

    return unitDPS
end

PhxLib.myFunc = function() 
    return 13
end