#
# Blueprint loading
#
#   During preloading of the map, we run loadBlueprints() from this file. It scans
#   the game directories and runs all .bp files it finds.
#
#   The .bp files call UnitBlueprint(), PropBlueprint(), etc. to define a blueprint.
#   All those functions do is fill in a couple of default fields and store off the
#   table in 'original_blueprints'.
#
#   Once that scan is complete, ModBlueprints() is called. It can arbitrarily mess
#   with the data in original_blueprints.
#
#   Finally, the engine registers all blueprints in original_blueprints to define the
#   "real" blueprints used by the game. A separate copy of these blueprints is made
#   available to the sim-side and user-side scripts.
#
# How mods can affect blueprints
#
#   First, a mod can simply add a new blueprint file that defines a new blueprint.
#
#   Second, a mod can contain a blueprint with the same ID as an existing blueprint.
#   In this case it will completely override the original blueprint. Note that in
#   order to replace an original non-unit blueprint, the mod must set the "BlueprintId"
#   field to name the blueprint to be replaced. Otherwise the BlueprintId is defaulted
#   off the source file name. (Units don't have this problem because the BlueprintId is
#   shortened and doesn't include the original path).
#
#   Third, a mod can can contain a blueprint with the same ID as an existing blueprint,
#   and with the special field "Merge = true". This causes the mod to be merged with,
#   rather than replace, the original blueprint.
#
#   Finally, a mod can hook the ModBlueprints() function which manipulates the
#   blueprints table in arbitrary ways.
#      1. create a file /mod/s.../hook/system/Blueprints.lua
#      2. override ModBlueprints(all_bps) in that file to manipulate the blueprints
#
# Reloading of changed blueprints
#
#   When the disk watcher notices that a .bp file has changed, it calls
#   ReloadBlueprint() on it. ReloadBlueprint() repeats the above steps, but with
#   original_blueprints containing just the one blueprint.
#
#   Changing an existing blueprint is not 100% reliable; some changes will be picked
#   up by existing units, some not until a new unit of that type is created, and some
#   not at all. Also, if you remove a field from a blueprint and then reload, it will
#   default to its old value, not to 0 or its normal default.
#

local sub = string.sub
local gsub = string.gsub
local lower = string.lower
local getinfo = debug.getinfo
local here = getinfo(1).source

local original_blueprints

local function InitOriginalBlueprints()
    original_blueprints = {
        Mesh = {},
        Unit = {},
        Prop = {},
        Projectile = {},
        TrailEmitter = {},
        Emitter = {},
        Beam = {},
    }
end

local function GetSource()

    -- Find the first calling function not in this source file
    local n = 2
    local there
	
    while true do
        there = getinfo(n).source
		
        if there != here then
			break
		end
		
        n = n+1
    end
	
    if sub(there,1,1)=="@" then
        there = sub(there,2)
    end
    return DiskToLocal(there)
end


local function StoreBlueprint(group, bp)

    local id = bp.BlueprintId
    local t = original_blueprints[group]

    if t[id] and bp.Merge then
		--LOG("*AI DEBUG Doing merge for "..repr(id))
        bp.Merge = nil
        bp.Source = nil
        t[id] = table.merged(t[id], bp)
    else
		--LOG("*AI DEBUG Adding Blueprint for "..repr(id))
        t[id] = bp
    end
end


#
# Figure out what to name this blueprint based on the name of the file it came from.
# Returns the entire filename. Either this or SetLongId() should really be got rid of.
#
local function SetBackwardsCompatId(bp)
    bp.Source = bp.Source or GetSource()
    bp.BlueprintId = lower(bp.Source)
end


#
# Figure out what to name this blueprint based on the name of the file it came from.
# Returns the full resource name except with ".bp" stripped off
#
local function SetLongId(bp)
    bp.Source = bp.Source or GetSource()
    if not bp.BlueprintId then
        local id = lower(bp.Source)
        id = gsub(id, "%.bp$", "")                          # strip trailing .bp
        --id = gsub(id, "/([^/]+)/%1_([a-z]+)$", "/%1_%2")    # strip redundant directory name
        bp.BlueprintId = id
    end
end


#
# Figure out what to name this blueprint based on the name of the file it came from.
# Returns just the base filename, without any blueprint type info or extension. Used
# for units only.
#
local function SetShortId(bp)
    bp.Source = bp.Source or GetSource()
    bp.BlueprintId = bp.BlueprintId or
        gsub(lower(bp.Source), "^.*/([^/]+)_[a-z]+%.bp$", "%1")
end


#
# If the bp contains a 'Mesh' section, move that over to a separate Mesh blueprint, and
# point bp.MeshBlueprint at it.
#
# Also fill in a default value for bp.MeshBlueprint if one was not given at all.
#
function ExtractMeshBlueprint(bp)
    local disp = bp.Display or {}
    bp.Display = disp

    if disp.MeshBlueprint=='' then
        LOG('Warning: ',bp.Source,': MeshBlueprint should not be an empty string')
        disp.MeshBlueprint = nil
    end

    if type(disp.MeshBlueprint)=='string' then
        if disp.MeshBlueprint!=lower(disp.MeshBlueprint) then
            #Should we allow mixed-case blueprint names?
            #LOG('Warning: ',bp.Source,' (MeshBlueprint): ','Blueprint IDs must be all lowercase')
            disp.MeshBlueprint = lower(disp.MeshBlueprint)
        end

        # strip trailing .bp
        disp.MeshBlueprint = gsub(disp.MeshBlueprint, "%.bp$", "")

        if disp.Mesh then
            LOG('Warning: ',bp.Source,' has mesh defined both inline and by reference')
        end
    end

    if disp.MeshBlueprint==nil then
        # For a blueprint file "/units/uel0001/uel0001_unit.bp", the default
        # mesh blueprint is "/units/uel0001/uel0001_mesh"
        local meshname,subcount = gsub(bp.Source, "_[a-z]+%.bp$", "_mesh")
        if subcount==1 then
            disp.MeshBlueprint = meshname
        end

        if type(disp.Mesh)=='table' then
            local meshbp = disp.Mesh
            meshbp.Source = meshbp.Source or bp.Source
            meshbp.BlueprintId = disp.MeshBlueprint
            # roates:  Commented out so the info would stay in the unit BP and I could use it to precache by unit.
            # disp.Mesh = nil
            MeshBlueprint(meshbp)
        end
    end
end


function ExtractWreckageBlueprint(bp)

    local meshid = bp.Display.MeshBlueprint
    if not meshid then return end

    local meshbp = original_blueprints.Mesh[meshid]
    if not meshbp then return end

    local wreckbp = table.deepcopy(meshbp)
	
    if wreckbp.LODs then
        for i,lod in wreckbp.LODs do
            if lod.ShaderName == 'TMeshAlpha' or lod.ShaderName == 'NormalMappedAlpha' or lod.ShaderName == 'UndulatingNormalMappedAlpha' then
                lod.ShaderName = 'BlackenedNormalMappedAlpha'
            else
                lod.ShaderName = 'Wreckage'
                lod.SpecularName = '/env/common/props/wreckage_noise.dds'
            end
        end
    end
	
    wreckbp.BlueprintId = meshid .. '_wreck'
    bp.Display.MeshBlueprintWrecked = wreckbp.BlueprintId
    MeshBlueprint(wreckbp)
end

function ExtractBuildMeshBlueprint(bp)

	local FactionName = bp.General.FactionName

	if FactionName == 'Aeon' or FactionName == 'UEF' or FactionName == 'Cybran' or FactionName == 'Seraphim' then 
	
		local meshid = bp.Display.MeshBlueprint
		if not meshid then return end

		local meshbp = original_blueprints.Mesh[meshid]
		if not meshbp then return end

		local shadername = FactionName .. 'Build'
		local secondaryname = '/textures/effects/' .. FactionName .. 'BuildSpecular.dds'

		local buildmeshbp = table.deepcopy(meshbp)
		
		if buildmeshbp.LODs then
			for i,lod in buildmeshbp.LODs do
				lod.ShaderName = shadername
				lod.SecondaryName = secondaryname
				if FactionName == 'Seraphim' then
				    lod.LookupName = '/textures/environment/Falloff_seraphim_lookup.dds'
				end
			end
		end
		
		buildmeshbp.BlueprintId = meshid .. '_build'
		bp.Display.BuildMeshBlueprint = buildmeshbp.BlueprintId
		MeshBlueprint(buildmeshbp)
	end
end

function ExtractCloakMeshBlueprint(bp)

	local meshid = bp.Display.MeshBlueprint
	
	if not meshid then return end

	local meshbp = original_blueprints.Mesh[meshid]
	
	if not meshbp then return end

	local shadernameE = 'ShieldCybran'
	local shadernameA = 'ShieldAeon'
	local shadernameC = 'ShieldCybran'
	local shadernameS = 'ShieldAeon'

	local cloakmeshbp = table.deepcopy(meshbp)

	if cloakmeshbp.LODs then
	
		for i,cat in bp.Categories do

			if cat == 'UEF' then
				for i,lod in cloakmeshbp.LODs do
					lod.ShaderName = shadernameE
				end
			elseif cat == 'AEON' then
				for i,lod in cloakmeshbp.LODs do
					lod.ShaderName = shadernameA
				end
			elseif cat == 'CYBRAN' then
				for i,lod in cloakmeshbp.LODs do
					lod.ShaderName = shadernameA
				end
			elseif cat == 'SERAPHIM' then
				for i,lod in cloakmeshbp.LODs do
					lod.ShaderName = shadernameS
				end
			end
		end
	end

	cloakmeshbp.BlueprintId = meshid .. '_cloak'
	bp.Display.CloakMeshBlueprint = cloakmeshbp.BlueprintId
	MeshBlueprint(cloakmeshbp)
	
end

function ExtractPhaseMeshBlueprint(bp)
	local meshid = bp.Display.MeshBlueprint
	if not meshid then return end

	local meshbp = original_blueprints.Mesh[meshid]
	
	if not meshbp then return end

	local shadernameP1 = 'ShieldUEF'
	local shadernameP2 = 'AlphaFade'
	local shadernameP12 = 'PhalanxEffect'
	local shadernameP22 = 'AlphaFade'

	local phase1meshbp = table.deepcopy(meshbp)

	if phase1meshbp.LODs then
		
		for i,cat in bp.Categories do
			if cat == 'UEF' then
				for i,lod in phase1meshbp.LODs do
					lod.ShaderName = shadernameP1
				end
			elseif cat == 'AEON' then
				for i,lod in phase1meshbp.LODs do
					lod.ShaderName = shadernameP1
				end
			elseif cat == 'CYBRAN' then
				for i,lod in phase1meshbp.LODs do
					lod.ShaderName = shadernameP12
				end
			elseif cat == 'SERAPHIM' then
				for i,lod in phase1meshbp.LODs do
					lod.ShaderName = shadernameP12
				end
			end
		end
	end

	local phase2meshbp = table.deepcopy(meshbp)

	if phase2meshbp.LODs then
		
		for i,cat in bp.Categories do
			if cat == 'UEF' then
				for i,lod in phase2meshbp.LODs do
					lod.ShaderName = shadernameP2
				end
			elseif cat == 'AEON' then
				for i,lod in phase2meshbp.LODs do
					lod.ShaderName = shadernameP2
				end
			elseif cat == 'CYBRAN' then
				for i,lod in phase2meshbp.LODs do
					lod.ShaderName = shadernameP22
				end
			elseif cat == 'SERAPHIM' then
				for i,lod in phase2meshbp.LODs do
					lod.ShaderName = shadernameP22
				end
			end
		end
	end

	phase1meshbp.BlueprintId = meshid .. '_phase1'
	phase2meshbp.BlueprintId = meshid .. '_phase2'
	
	bp.Display.Phase1MeshBlueprint = phase1meshbp.BlueprintId
	bp.Display.Phase2MeshBlueprint = phase2meshbp.BlueprintId

	MeshBlueprint(phase1meshbp)
	MeshBlueprint(phase2meshbp)
end


function MeshBlueprint(bp)
    # fill in default values
    SetLongId(bp)
    StoreBlueprint('Mesh', bp)
end


function UnitBlueprint(bp)
    SetShortId(bp)
    StoreBlueprint('Unit', bp)
end


function PropBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Prop', bp)
end


function ProjectileBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Projectile', bp)
end


function TrailEmitterBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('TrailEmitter', bp)
end


function EmitterBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Emitter', bp)
end


function BeamBlueprint(bp)
    SetBackwardsCompatId(bp)
    StoreBlueprint('Beam', bp)
end


function ExtractAllMeshBlueprints()

    for id,bp in original_blueprints.Unit do
	
        ExtractMeshBlueprint(bp)
        ExtractWreckageBlueprint(bp)
        ExtractBuildMeshBlueprint(bp)
		ExtractCloakMeshBlueprint(bp)
		
		-- this is really a Black Ops thing with little function
		-- disabling saves about 8MB of RAM
		--ExtractPhaseMeshBlueprint(bp)
    end

    for id,bp in original_blueprints.Prop do
	
        ExtractMeshBlueprint(bp)
        ExtractWreckageBlueprint(bp)
		
    end

    for id,bp in original_blueprints.Projectile do
	
        ExtractMeshBlueprint(bp)
		
    end
end


function RegisterAllBlueprints(blueprints)

    local function RegisterGroup(g, fun)
        for id,bp in sortedpairs(g) do
            fun(g[id])
        end
    end

    RegisterGroup(blueprints.Mesh, RegisterMeshBlueprint)
    RegisterGroup(blueprints.Unit, RegisterUnitBlueprint)
    RegisterGroup(blueprints.Prop, RegisterPropBlueprint)
    RegisterGroup(blueprints.Projectile, RegisterProjectileBlueprint)
    RegisterGroup(blueprints.TrailEmitter, RegisterTrailEmitterBlueprint)
    RegisterGroup(blueprints.Emitter, RegisterEmitterBlueprint)
    RegisterGroup(blueprints.Beam, RegisterBeamBlueprint)
end

-- Helper Functions by PhoenixMT
local PhxLib ={
    _VERSION = '0.3',
    _DESCRIPTION = 'General Helper Functions',
}

local SpeedT2_KNIFE = 3.1058
local RangeT2_KNIFE = 25
local RangeAvgEngage = 50
local tEnd = 13.0

function PhxLib.canTargetHighAir(weapon)
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

function PhxLib.canTargetLand(weapon)
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

function PhxLib.canTargetSubs(weapon)
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

function PhxLib.cleanUnitName(bp)
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

function PhxLib.getTechLevel(bp)
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

function PhxLib.getHealth(curBP)
    if  curBP.Defense and 
        curBP.Defense.MaxHealth
    then 
        Health = curBP.Defense.MaxHealth or 0
    else
        Health = 0
    end

    return Health
end

function PhxLib.getShield(curBP)
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

function PhxLib.getSpeed(curBP)
    -- Get Speed Value if it exists
    if  curBP.Physics and 
        curBP.Physics.MaxSpeed
    then
        Speed = curBP.Physics.MaxSpeed or 0
    else 
        Speed = 0
    end

    return Speed
end

function PhxLib.getVision(curBP)
    if curBP.Intel and curBP.Intel.VisionRadius then
        Vision = curBP.Intel.VisionRadius
    end

    return Vision
end

function PhxLib.PhxWeapDPS(weapon)
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

    local debug = false

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
    DPS.threatRange = (DPS.Range - RangeT2_KNIFE)
                      / SpeedT2_KNIFE 
                      * DPS.srfDPS/tEnd / 10
    DPS.threatRange = math.max(0,DPS.threatRange)
    DPS.threatSurf = DPS.srfDPS/20
    DPS.threatAir = DPS.airDPS/20
    DPS.threatSub = DPS.subDPS/20

    DPS.Warn = Warn

    return DPS
end

function PhxLib.calcUnitDPS(curBP,curShortID)
    local debug = false

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

    unitDPS.Threat.HP = (unitDPS.Health+unitDPS.Shield)/tEnd/20

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

        unitDPS.Threat.Speed = (RangeAvgEngage/SpeedT2_KNIFE - RangeAvgEngage/unitDPS.Speed)
                    * unitDPS.srfDPS/tEnd / 10
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

function PhxLib.myFunc()
    return 13
end

-- Hook for mods to manipulate the entire blueprint table
function ModBlueprints(all_blueprints)

	--Example: local SetPrimaryLandAttackBase = import('/lua/loudutilities.lua').SetPrimaryLandAttackBase
	--local calcUnitDPS = import('lua/PhxLib.lua').calcUnitDPS
	--local cleanUnitName = import('lua/PhxLib.lua').cleanUnitName


	-- Used for loading loose files in the Development build, as part of the GitHub Repo.
	for bptype, array in all_blueprints do
		if (bptype != "Unit" and bptype != "Mesh") then
			for id, bp in array do
				if string.find(bp.BlueprintId, "/") and string.find(bp.BlueprintId, "/gamedata/") then
					local slash = string.find(bp.BlueprintId, "/", 2)
					slash = string.find(bp.BlueprintId, "/", slash + 1)
					--LOG(bp.BlueprintId)
					bp.BlueprintId = string.sub(bp.BlueprintId, slash)
					--LOG(bp.BlueprintId)
				end
			end
		end
	end

	--LOG("*AI DEBUG ScenarioInfo data is "..repr( _G ) )

	LOG("*AI DEBUG Adding SATELLITE restriction to ANTIAIR Weapons - unit must have the UWRC-AntiAir range category in the weapon")
	LOG("*AI DEBUG Adjusting ROF,TargetCheckInterval and Energy Drain requirements")

	local ROFadjust = 0.85

    for id, bp in all_blueprints.Unit do

        if bp.Weapon then

			-- Insert here, code to overwrite threat values in units
			-- note: edits to arguments change values in operand
			--LOG("DJO Test: ")
			--LOG("DJO Test2: "..PhxLib.myFunc())
			local unitDPS = PhxLib.calcUnitDPS(bp,1)
			local bob = PhxLib.PhxWeapDPS(bp.Weapon[1])
			
			if bp and
			   bp.Defense and
			   bp.Defense.SurfaceThreatLevel
			then
				LOG("Threat Overriden: "..id..", "
				 .. PhxLib.cleanUnitName(bp)..", "
				 .. "PrevThreat = " .. bp.Defense.SurfaceThreatLevel..","
				 .. "NewThreat = " .. unitDPS.Threat.Total
				)
				bp.Defense.SurfaceThreatLevel = unitDPS.Threat.Total
				
			end

            for ik, wep in bp.Weapon do
				
				if wep.RateOfFire then
					wep.RateOfFire = wep.RateOfFire * ROFadjust
					
					if wep.MuzzleSalvoDelay == nil then
						--LOG("*AI DEBUG "..id.." has nil for "..repr(wep.Label).." MuzzleSalvoDelay")
						wep.MuzzleSalvoDelay = 0
					end
                end

				if not (wep.BeamLifetime or wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or wep.WeaponCategory == 'Air Crash') and not wep.ProjectileLifetime and not wep.ProjectileLifetimeUsesMultiplier then
					--LOG("*AI DEBUG "..id.." "..repr(bp.Description).." "..repr(wep.Label).." has no projectile lifetime for "..repr(wep.DisplayName).." Label "..repr(wep.Label))
				end
				
				if wep.ProjectileLifetime == 0 then
				
					if wep.MuzzleVelocity and wep.MuzzleVelocity > 0 then
					
						wep.ProjectileLifetime = (wep.MaxRadius / wep.MuzzleVelocity) * 1.15
					end
				end

				if wep.TargetCheckInterval then
				
					if wep.TargetCheckInterval < .1 then 
						wep.TargetCheckInterval = .1
					end
					
					if wep.TargetCheckInterval > 6 then
						wep.TargetCheckInterval = 6
					end
				end

				if wep.DisplayName then
					wep.DisplayName = nil
				end

				if wep.RangeCategory == 'UWRC_AntiAir' then
				
					if not wep.AntiSat == true then
						wep.TargetRestrictDisallow = wep.TargetRestrictDisallow .. ', SATELLITE'
					end
				end
            end
        end
    end 

	LOG("*AI DEBUG Capping GuardReturnRadius")
	LOG("*AI DEBUG Adjusting View Radius")
	
	local capreturnradius = 80
	
    local econScale = 0
	local speedScale = 0
	local viewScale = 0

    for id,bp in all_blueprints.Unit do

		if bp.AI.GuardReturnRadius then
			
			if bp.AI.GuardReturnRadius > capreturnradius then
				bp.AI.GuardReturnRadius = capreturnradius
			end

			if bp.AI.GuardReturnRadius > 80 then
				bp.AI.GuardReturnRadius = 80
			end
		else
			if not bp.AI then
				bp.AI = {}
			end
		
			bp.AI.GuardReturnRadius = 20
		end
		
		if bp.AI.GuardScanRadius then
		
			if bp.AI.GuardScanRadius > 40 then
			
				bp.AI.GuardScanRadius = 40
			end
		else
			bp.AI.GuardScanRadius = 15
		end
		
		if bp.Economy.MaxBuildDistance and bp.Economy.MaxBuildDistance < 3 then
		
			LOG("*AI DEBUG MaxBuildDistance now 3")
			bp.Economy.MaxBuildDistance = 3
		
		end
	
		if bp.Categories then
		
			for i, cat in bp.Categories do
		
				if cat == 'NAVAL' then
			
					econScale = 0.0    # -- cost more
					speedScale = -0.05  # -- move slower
					viewScale = 0.0   
			
					for j, catj in bp.Categories do
				
						if catj == 'MOBILE' then
			
							if bp.Economy.BuildTime then
							
								bp.Economy.BuildTime = bp.Economy.BuildTime + (bp.Economy.BuildTime * econScale)
								bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy + (bp.Economy.BuildCostEnergy * econScale)
								bp.Economy.BuildCostMass = bp.Economy.BuildCostMass + (bp.Economy.BuildCostMass * econScale)
								
							end
						
							if bp.Physics.Maxspeed then
							
								bp.Physics.MaxSpeed = bp.Physics.MaxSpeed + (bp.Physics.MaxSpeed * speedScale)
								
							end	
							
							if bp.Intel.VisionRadius then
							
								bp.Intel.VisionRadius = math.floor(bp.Intel.VisionRadius + (bp.Intel.VisionRadius * viewScale))
								
							end
							
							if bp.Intel.WaterVisionRadius and bp.Intel.WaterVisionRadius > 0 then
							
								bp.Intel.WaterVisionRadius = math.floor(bp.Intel.WaterVisionRadius + (bp.Intel.WaterVisionRadius * viewScale))
								
							else
							
								if bp.Intel then
									bp.Intel.WaterVisionRadius = 6
								end
								
							end
					
						end
						
						-- naval structures get a little extra adjustment seperate from all other structures
						if catj == 'STRUCTURE' then
				
							if bp.Intel.VisionRadius then
							
								bp.Intel.VisionRadius = math.floor(bp.Intel.VisionRadius + (bp.Intel.VisionRadius * viewScale))
								
							end
						
							if bp.Intel.WaterVisionRadius and bp.Intel.WaterVisionRadius > 0 then
							
								bp.Intel.WaterVisionRadius = math.floor(bp.Intel.WaterVisionRadius + (bp.Intel.WaterVisionRadius * viewScale))
								
							else
							
								if bp.Intel then
									bp.Intel.WaterVisionRadius = 6
								end
								
							end
						end						
					end
				end
			
				if cat == 'AIR' then
			
					econScale = 0.075	# -- cost more
					speedScale = -0.0
					viewScale = -0.05    # -- see less
		
					for j, catj in bp.Categories do
				
						if catj == 'MOBILE' then

							if bp.Economy.BuildTime then
								bp.Economy.BuildTime = bp.Economy.BuildTime + (bp.Economy.BuildTime * econScale)
								bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy + (bp.Economy.BuildCostEnergy * econScale)
								bp.Economy.BuildCostMass = bp.Economy.BuildCostMass + (bp.Economy.BuildCostMass * econScale)
							end

							-- although air units speed is not controlled by this I do it anyways for visual reference in-game.
							if bp.Physics.Maxspeed then
								bp.Physics.MaxSpeed = bp.Physics.MaxSpeed + (bp.Physics.MaxSpeed * speedScale)
							end
							
							if bp.Air.MaxAirspeed then
								bp.Air.MaxAirspeed = bp.Air.MaxAirspeed + (bp.Air.MaxAirspeed * speedScale)
							end
						
							-- if the unit uses a SizeSphere for collisions, make sure it's big enough as related to it's max speed
							-- if the value is set too low, the unit becomes nearly unhittable except by tracking SAMs
							-- this steep dropoff starts to occur around .9 but is tolerable at that setting with a decent amount of
							-- hits but a few misses at the top end (of particular note are the AA lasers)
							if bp.SizeSphere and bp.Air.MaxAirspeed then
								bp.SizeSphere = math.max( 0.9, bp.Air.MaxAirspeed * 0.095 )
							end

							if bp.Physics.MaxBrake then
								bp.Physics.MaxBrake = bp.Physics.MaxBrake + (bp.Physics.MaxBrake * speedScale)
							end
							
							if bp.Intel.VisionRadius then
								bp.Intel.VisionRadius = math.floor(bp.Intel.VisionRadius + (bp.Intel.VisionRadius * viewScale))
							end
							
							if bp.Intel.WaterVisionRadius and bp.Intel.WaterVisionRadius > 0 then
								bp.Intel.WaterVisionRadius = math.floor(bp.Intel.WaterVisionRadius + (bp.Intel.WaterVisionRadius * viewScale))
							else
								if bp.Intel then
									bp.Intel.WaterVisionRadius = 0
								end
							end
						end
					end
				end
			
				if cat == 'LAND' then
			
					econScale = 0
					speedScale = 0
					viewScale = 0
		
					for j, catj in bp.Categories do
				
						if catj == 'MOBILE' then
					
							if bp.Economy.BuildTime and econScale != 0 then
								bp.Economy.BuildTime = bp.Economy.BuildTime + (bp.Economy.BuildTime * econScale)
								bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy + (bp.Economy.BuildCostEnergy * econScale)
								bp.Economy.BuildCostMass = bp.Economy.BuildCostMass + (bp.Economy.BuildCostMass * econScale)
							end
							
							if bp.SizeY and not bp.Physics.LayerChangeOffsetHeight then
								bp.Physics.LayerChangeOffsetHeight = bp.SizeY/2 * -1
							end
			
							if bp.Physics.MaxSpeed then
								bp.Physics.MaxSpeed = bp.Physics.MaxSpeed + (bp.Physics.MaxSpeed * speedScale)
							end
							
							if bp.Physics.MaxBrake then
								bp.Physics.MaxBrake = bp.Physics.MaxBrake + (bp.Physics.MaxBrake * speedScale)
							end
							
							if bp.Physics.MaxSpeedReverse then
								bp.Physics.MaxSpeedReverse = bp.Physics.MaxSpeedReverse + (bp.Physics.MaxSpeedReverse * speedScale)
							end
							
							if bp.Physics.RotateOnSpot then
								bp.Physics.RotateOnSpot = false
							end
							
							if bp.Intel.VisionRadius then
								bp.Intel.VisionRadius = math.floor(bp.Intel.VisionRadius + (bp.Intel.VisionRadius * viewScale))
							end	

							if bp.Intel.WaterVisionRadius and bp.Intel.WaterVisionRadius > 0 then
								bp.Intel.WaterVisionRadius = math.floor(bp.Intel.WaterVisionRadius + (bp.Intel.WaterVisionRadius * viewScale))
							else
								if bp.Intel then
									bp.Intel.WaterVisionRadius = 3
								end
							end
							
							-- this series of adjustments is designed to give the lower tech mobile land units a little more 'oomph' with
							-- regards to their T3 counterparts both in the form of Health and Speed
							local T1_Adjustment = 1.275
							local T2_Adjustment = 1.120
							local T3_Adjustment = 1.000
						
							for _, cat_mobile in bp.Categories do
							
								if cat_mobile == 'TECH1' then
								
									bp.Defense.MaxHealth = bp.Defense.MaxHealth * T1_Adjustment
									
									bp.Defense.Health = bp.Defense.MaxHealth
									
									if bp.Physics.MaxSpeed then
										bp.Physics.MaxSpeed = bp.Physics.MaxSpeed * T1_Adjustment
									end
								
								elseif cat_mobile == 'TECH2' then
								
									bp.Defense.MaxHealth = bp.Defense.MaxHealth * T2_Adjustment
									
									bp.Defense.Health = bp.Defense.MaxHealth
									
									if bp.Physics.MaxSpeed then
										bp.Physics.MaxSpeed = bp.Physics.MaxSpeed * T2_Adjustment
									end
									
									-- make them appear a little smaller
									if bp.Display.UniformScale then
										bp.Display.UniformScale = bp.Display.UniformScale * .95
									end
								
								elseif cat_mobile == 'TECH3' then
								
									bp.Defense.MaxHealth = bp.Defense.MaxHealth * T3_Adjustment
									
									bp.Defense.Health = bp.Defense.MaxHealth
									
									-- make them appear a little smaller
									if bp.Display.UniformScale then
										bp.Display.UniformScale = bp.Display.UniformScale * .95
									end
								end
							end
						end
					end
				end
				
				-- all structures
				if cat == 'STRUCTURE' then
			
					viewScale = 0.15    # -- see further				
				
					if bp.Intel.VisionRadius then
					
						bp.Intel.VisionRadius = math.floor(bp.Intel.VisionRadius + (bp.Intel.VisionRadius * viewScale))
						
					end

					if bp.Intel.WaterVisionRadius then
					
						bp.Intel.WaterVisionRadius = math.floor(bp.Intel.WaterVisionRadius + (bp.Intel.WaterVisionRadius * viewScale))
						
					else
					
						if bp.Intel then
							bp.Intel.WaterVisionRadius = 0
						end
						
					end
				
					local buildtimemod = 1	# -- take longer to build (but costs remain same)
				
					if bp.Economy.BuildTime then
						bp.Economy.BuildTime = bp.Economy.BuildTime * buildtimemod
					end
					
					-- the purpose of this alteration is to address the parity of T2 and T3 static defenses with respect to mobile units
					-- I felt, and the numbers clearly show, that a tremendous range difference crept into the game as many 3rd party
					-- point defenses were added - blame the UEF Ravager for setting a bad precedent with a range of 65 - others that 
					-- followed often went beyond that, which made even mobile artillery effectively pointless, and greatly encouraged
					-- 'turtling' instead of mobile warfare
				
					-- This mod addresses that by bringing any DIRECTFIRE structures back into some kind of normalacy and giving the 
					-- mobile units some chance of getting within firing range before being completely shellacked.
					for _, cat_structure in bp.Categories do
					
						if cat_structure == 'DIRECTFIRE' then
							
							for _, cat_tech in bp.Categories do

								if cat_tech == 'EXPERIMENTAL' then
								
									--LOG("*AI DEBUG Modifying Weapon Range on EXPERIMENTAL "..bp.Description)
									
									for ik, wep in bp.Weapon do
										if wep.MaxRadius and wep.MaxRadius > 60 then
											--LOG("*AI DEBUG MaxRadius goes from "..wep.MaxRadius.." to "..math.floor(wep.MaxRadius * 0.91))
											wep.MaxRadius = math.floor(wep.MaxRadius * 0.91)
										end
									end										
								end									
							end
						end
					end					
				end
			end
		end
    end

    LOG("*AI DEBUG Adding NAVAL Wreckage information and setting wreckage lifetime")
	
    for id,bp in pairs(all_blueprints.Unit) do				
	
        local cats = {}

		if bp.Categories then
			
			for k,cat in pairs(bp.Categories) do
				cats[cat] = true
			end
		
			if cats.NAVAL then
			
				if not bp.Wreckage then
				
					bp.Wreckage = {
						Blueprint = '/props/DefaultWreckage/DefaultWreckage_prop.bp',
						EnergyMult = 0.3,
						HealthMult = 0.9,
						LifeTime = 720,	-- give naval wreckage a lifetime value of 12 minutes
						MassMult = 0.8,
						ReclaimTimeMultiplier = 1,
						
						WreckageLayers = {
							Air = false,
							Land = false,
							Seabed = true,
							Sub = true,
							Water = true,
						};
					}
				else
					local wl = bp.Wreckage.WreckageLayers
					wl.Seabed = true
					wl.Sub = true
					wl.Water = true
					bp.Wreckage.LifeTime = 720
				end
				
			else
			
				if bp.Wreckage then
				
					if not bp.Wreckage.Lifetime then

						bp.Wreckage.Liftime = 900
						
					end
				end
			end
		end
    end

	LOG("*AI DEBUG Adding Audio Cues for COMMANDERS - NUKES - FERRY ROUTES - EXTRACTORS")

	local factions = {'UEF', 'Aeon', 'Cybran', 'Aeon'}

	for i,bp in pairs(all_blueprints.Unit) do
		
		if bp.Categories then
		
			local categories = {}
			
			for j,category in pairs(bp.Categories) do
				categories[category] = true
			end

			for j,faction in pairs(factions) do
			
				if categories['COMMAND'] == true then
				
					--DETECTED
					local Detected = Sound { Bank = 'XGG', Cue = 'XGG_Computer_CV01_04724',}

					bp.Audio['EnemyUnitDetected'..faction] = Detected
				end
				
				if categories['STRATEGIC'] == true and categories['NUKE'] == true and categories['SILO'] == true then
					
					--DETECTED
					local Detected = Sound { Bank = 'XGG', Cue = 'XGG_Rhiza_MP1_04588',}

					bp.Audio['EnemyUnitDetected'..faction] = Detected
                end

				if categories['TRANSPORTATION'] == true then
				
					local FerrySet = Sound { Bank = 'XGG', Cue = 'XGG_HQ_GD1_04193',}

					bp.Audio['FerryPointSetBy'..faction] = FerrySet
				end

				#UNDER ATTACK
				if categories['MASSEXTRACTION'] then
				
					local MexUnderAttack = Sound { Bank = 'XGG', Cue = 'XGG_Computer_CV01_04728',}
					
					bp.Audio['UnitUnderAttack'..faction] = MexUnderAttack
				end
			end
		end
	end

	-- adjust projectile values
--[[
    local initialMultFactor = 1.0
    local turnMultFactor = 1.0

    for id, bp in all_blueprints.Projectile do
	
        if bp.Physics.TurnRate then
            bp.Physics.TurnRate = bp.Physics.TurnRate * turnMultFactor
        end

        if bp.Physics.MaxSpeed then
            bp.Physics.MaxSpeed = bp.Physics.MaxSpeed * initialMultFactor
        end
		
        if bp.Physics.Acceleration then
            bp.Physics.Acceleration = bp.Physics.Acceleration * initialMultFactor
        end
		
    end
--]]

end


#-- Load all blueprints

function LoadBlueprints()

    LOG('Loading blueprints...')

    InitOriginalBlueprints()
	
	local count = 0
	local rcount = 0
	local mcount = 0
	
	for i,dir in {'/effects', '/env', '/meshes', '/projectiles', '/props', '/units'} do
	
		LOG("loading resources from "..dir)
		count = 0
		
        for k,file in DiskFindFiles(dir, '*.bp') do
		
            BlueprintLoaderUpdateProgress()
			
			--LOG("loading resource "..file..' '..repr(doscript))
			
            safecall("loading blueprint "..file, doscript, file)
			
			count = count + 1
			rcount = rcount + 1
			
        end
		
		LOG("loaded "..count.." resources from "..dir)
		
    end
	
	LOG("Loaded "..rcount.." std resources")	
	
    for i,m in __active_mods do
	
		LOG("loading resources from mod at "..m.location)
		count = 0
		
        for k,file in DiskFindFiles(m.location, '*.bp') do
		
            BlueprintLoaderUpdateProgress()
			
            --LOG("loading mod blueprint "..file)
			
            safecall("loading mod blueprint "..file, doscript, file)
			
			count = count + 1
			mcount = mcount + 1
			
        end
		
		LOG("loaded "..count.." resources from mod at "..m.location)
		
    end
	
	LOG("Loaded "..mcount.." mod resources")
 
	LOG("Loaded "..rcount+mcount.." blueprints in total")

    BlueprintLoaderUpdateProgress()
    LOG('Extracting mesh blueprints.')
    ExtractAllMeshBlueprints()

    BlueprintLoaderUpdateProgress()
    LOG('Modding blueprints.')
    ModBlueprints(original_blueprints)

    BlueprintLoaderUpdateProgress()
    LOG('Registering blueprints...')
    RegisterAllBlueprints(original_blueprints)
	
    original_blueprints = nil

    LOG('Blueprints loaded')

end


# Reload a single blueprint
function ReloadBlueprint(file)
    InitOriginalBlueprints()

    safecall("reloading blueprint "..file, doscript, file)

    ExtractAllMeshBlueprints()
    ModBlueprints(original_blueprints)
    RegisterAllBlueprints(original_blueprints)
    original_blueprints = nil
end
