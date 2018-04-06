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
        #id = gsub(id, "/([^/]+)/%1_([a-z]+)$", "/%1_%2")    # strip redundant directory name
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
		ExtractPhaseMeshBlueprint(bp)
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


-- Hook for mods to manipulate the entire blueprint table
function ModBlueprints(all_blueprints)

	-- Used for loading loose files in the Development build, as part of the GitHub Repo.
	for bptype, array in all_blueprints do
		if (bptype != "Unit" and bptype != "Mesh") then
			for id, bp in array do
				if string.find(bp.BlueprintId, "/") and string.find(bp.BlueprintId, "/gamedata/") then
					local slash = string.find(bp.BlueprintId, "/", 2)
					slash = string.find(bp.BlueprintId, "/", slash + 1)
					LOG(bp.BlueprintId)
					bp.BlueprintId = string.sub(bp.BlueprintId, slash)
					LOG(bp.BlueprintId)
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

            for ik, wep in bp.Weapon do
				
				if wep.RateOfFire then
					wep.RateOfFire = wep.RateOfFire * ROFadjust
				end

				if not (wep.BeamLifetime or wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or wep.WeaponCategory == 'Air Crash') and not wep.ProjectileLifetime and not wep.ProjectileLifetimeUsesMultiplier then
					LOG("*AI DEBUG "..id.." "..bp.Description.." has no projectile lifetime for "..repr(wep.DisplayName).." Label "..repr(wep.Label))
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
	
	local capreturnradius = 50
	
    local econScale = 0
	local speedScale = 0
	local viewScale = 0

    for id,bp in all_blueprints.Unit do

		if bp.AI.GuardReturnRadius then
			
			if bp.AI.GuardReturnRadius > capreturnradius then
				bp.AI.GuardReturnRadius = capreturnradius
			end

			if bp.AI.GuardReturnRadius > 150 then
				bp.AI.GuardReturnRadius = 150
			end
		end
		
		if bp.Economy.MaxBuildDistance and bp.Economy.MaxBuildDistance < 3 then
		
			LOG("*AI DEBUG MaxBuildDistance now 3")
			bp.Economy.MaxBuildDistance = 3
		
		end
	
		if bp.Categories then
		
			for i, cat in bp.Categories do
		
				if cat == 'NAVAL' then
			
					econScale = 0.05    # -- cost more
					speedScale = -0.1  # -- move slower
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
							
							if bp.Intel.WaterVisionRadius then
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
						
							if bp.Intel.WaterVisionRadius then
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
			
					econScale = 0.20	# -- cost more
					speedScale = -0.05   # -- move slower
					viewScale = -0.05    # -- see less
		
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

							if bp.Physics.MaxBrake then
								bp.Physics.MaxBrake = bp.Physics.MaxBrake + (bp.Physics.MaxBrake * speedScale)
							end
							
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
						end
					end
				end
			
				if cat == 'LAND' then
			
					econScale = 0
					speedScale = -0.1	# -- move slower
					viewScale = 0.00
		
					for j, catj in bp.Categories do
				
						if catj == 'MOBILE' then
					
							if bp.Economy.BuildTime and econScale > 0 then
								bp.Economy.BuildTime = bp.Economy.BuildTime + (bp.Economy.BuildTime * econScale)
								bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy + (bp.Economy.BuildCostEnergy * econScale)
								bp.Economy.BuildCostMass = bp.Economy.BuildCostMass + (bp.Economy.BuildCostMass * econScale)
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
							
							-- this series of adjustments is designed to give the lower tech mobile land units a little more 'oomph' with
							-- regards to their T3 counterparts both in the form of Health and Speed
							local T1_Adjustment = 1.275
							local T2_Adjustment = 1.105
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
										bp.Display.UniformScale = bp.Display.UniformScale * .9
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
								
									LOG("*AI DEBUG Modifying Weapon Range on EXPERIMENTAL "..bp.Description)
									
									for ik, wep in bp.Weapon do
										if wep.MaxRadius and wep.MaxRadius > 60 then
											LOG("*AI DEBUG MaxRadius goes from "..wep.MaxRadius.." to "..math.floor(wep.MaxRadius * 0.91))
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
						LifeTime = 600,	-- give naval wreckage a lifetime value of 10 minutes
						MassMult = 0.9,
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
					bp.Wreckage.LifeTime = 600
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
