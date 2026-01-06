--**  File     :  /lua/unit.lua

local Entity                        = import('/lua/sim/Entity.lua').Entity
local EntityOnCreate                = Entity.OnCreate

local CreateWreckageEffects         = import('/lua/defaultexplosions.lua').CreateWreckageEffects
local CreateScalableUnitExplosion   = import('/lua/defaultexplosions.lua').CreateScalableUnitExplosion

local EffectTemplate                = import('/lua/EffectTemplates.lua')

local EffectUtilities               = import('/lua/EffectUtilities.lua')

local CleanupEffectBag              = EffectUtilities.CleanupEffectBag
local CreateUnitDestructionDebris   = EffectUtilities.CreateUnitDestructionDebris

local Game                          = import('/lua/game.lua')
local GetConstructEconomyModel      = Game.GetConstructEconomyModel

local GetEnemyUnitsInSphere         = import('/lua/utilities.lua').GetEnemyUnitsInSphere

local Shield                        = import('/lua/shield.lua').Shield
local UnitShield                    = import('/lua/shield.lua').UnitShield
local AntiArtilleryShield           = import('/lua/shield.lua').AntiArtilleryShield
local DomeHunkerShield              = import('/lua/shield.lua').DomeHunkerShield
local PersonalHunkerShield          = import('/lua/shield.lua').PersonalHunkerShield
local ProjectedShield               = import('/lua/shield.lua').ProjectedShield

local ApplyBuff                     = import('/lua/sim/buff.lua').ApplyBuff
local HasBuff                       = import('/lua/sim/buff.lua').HasBuff
local RemoveBuff                    = import('/lua/sim/buff.lua').RemoveBuff			

local ApplyCheatBuffs               = import('/lua/ai/aiutilities.lua').ApplyCheatBuffs
local BuffFieldBlueprints           = import('/lua/sim/BuffField.lua').BuffFieldBlueprints

local RRBC                          = import('/lua/sim/RebuildBonusCallback.lua').RegisterRebuildBonusCheck


-- from Domino Mod Support
local __DMSI = false    --import('/mods/Domino_Mod_Support/lua/initialize.lua') or false
local AvailableToggles = {} --  __DMSI.Custom_Toggles() or {}

if __DMSI then
    AvailableToggles = __DMSI.Custom_Toggles()
end

local LOUDATTACHEMITTER     = CreateAttachedEmitter
local LOUDATTACHBEAMENTITY  = AttachBeamEntityToEntity
local LOUDCOS               = math.cos
local LOUDEMITATENTITY      = CreateEmitterAtEntity
local LOUDEMITATBONE        = CreateEmitterAtBone
local LOUDENTITY            = EntityCategoryContains
local LOUDGETN              = table.getn
local LOUDINSERT            = table.insert
local LOUDMAX               = math.max
local LOUDMIN               = math.min
local LOUDPARSE             = ParseEntityCategory
local LOUDSIN               = math.sin
local LOUDSTATE             = ChangeState

local unpack            = unpack
local setmetatable      = setmetatable
local WaitFor           = WaitFor
local WaitTicks         = coroutine.yield

local PlatoonExists = moho.aibrain_methods.PlatoonExists
local PlayAnim      = moho.AnimationManipulator.PlayAnim
	
local EntityMethods = moho.entity_methods

local AdjustHealth          = EntityMethods.AdjustHealth
local GetArmy               = EntityMethods.GetArmy
local GetBlueprint          = EntityMethods.GetBlueprint
local GetBoneCount          = EntityMethods.GetBoneCount
local GetEntityId           = EntityMethods.GetEntityId
local GetFractionComplete   = EntityMethods.GetFractionComplete
local GetHealth             = EntityMethods.GetHealth
local GetMaxHealth          = EntityMethods.GetMaxHealth
local IsValidBone           = EntityMethods.IsValidBone
local Kill                  = EntityMethods.Kill
local PlaySound             = EntityMethods.PlaySound
local RequestRefreshUI      = EntityMethods.RequestRefreshUI
local SetHealth             = EntityMethods.SetHealth
local SetIntelRadius        = EntityMethods.SetIntelRadius
local SetMesh               = EntityMethods.SetMesh

local UnitMethods = moho.unit_methods

local GetAIBrain                        = UnitMethods.GetAIBrain
local GetBuildRate                      = UnitMethods.GetBuildRate
local GetCurrentLayer                   = UnitMethods.GetCurrentLayer
local GetFocusUnit                      = UnitMethods.GetFocusUnit
local GetHeading                        = UnitMethods.GetHeading
local GetStat                           = UnitMethods.GetStat
local GetWeapon                         = UnitMethods.GetWeapon
local GetWeaponCount                    = UnitMethods.GetWeaponCount
local HideBone                          = UnitMethods.HideBone
local IsUnitState                       = UnitMethods.IsUnitState
local SetConsumptionActive              = UnitMethods.SetConsumptionActive
local SetConsumptionPerSecondEnergy     = UnitMethods.SetConsumptionPerSecondEnergy
local SetConsumptionPerSecondMass       = UnitMethods.SetConsumptionPerSecondMass
local SetProductionActive               = UnitMethods.SetProductionActive
local SetProductionPerSecondEnergy      = UnitMethods.SetProductionPerSecondEnergy
local SetProductionPerSecondMass        = UnitMethods.SetProductionPerSecondMass
local SetStat                           = UnitMethods.SetStat

local DamageArea            = DamageArea
local GetTerrainType        = GetTerrainType
local ForkThread            = ForkThread
local ForkTo                = ForkThread
local IsAllied              = IsAlly


local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

--LOG('entity_methods.__index = ',EntityMethods.__index,' ',repr(EntityMethods))
--LOG(' URGH ',repr(moho))
--LOG('scripttask_methods.__index = ',moho.ScriptTask_methods.__index,' ',repr(moho.ScriptTask_methods))
--LOG('blip_methods.__index = ',moho.blip_methods.__index,' ',repr(moho.blip_methods))
--LOG('manipulator_methods.__index = ',moho.manipulator_methods.__index,' ',repr(moho.manipulator_methods))
--LOG('navigator_methods.__index = ',moho.navigator_methods.__index,' ',repr(moho.navigator_methods))
--LOG('projectile_methods.__index = ',moho.projectile_methods.__index,' ',repr(moho.projectile_methods))
--LOG('prop_methods.__index = ',moho.prop_methods.__index,' ',repr(moho.prop_methods))
--LOG('shield_methods.__index = ',moho.shield_methods.__index,' ',repr(moho.shield_methods))
--LOG('unit_methods.__index = ',UnitMethods.__index,' ',repr(UnitMethods))
--LOG('weapon_methods.__index = ',moho.weapon_methods.__index,' ',repr(moho.weapon_methods))

SyncMeta = {
    __index = function(t,key)
	
        return UnitData[rawget(t,'id')].Data[key]
		
    end,

    __newindex = function(t,key,val)
	
        local id = rawget(t,'id')
		
        if not UnitData[id] then
		
            UnitData[id] = { OwnerArmy = rawget(t,'army'), Data = {} }
			
        end
		
        UnitData[id].Data[key] = val

        if UnitData[id].OwnerArmy == GetFocusArmy() then
		
            if not Sync.UnitData[id] then
			
                Sync.UnitData[id] = {}
				
            end
			
            Sync.UnitData[id][key] = val
        end
		
    end,
}

local ALLBPS = __blueprints

local BRAINS = ArmyBrains

local ALLUNITS      = categories.ALLUNITS
local FACTORY       = categories.FACTORY
local PROJECTILE    = categories.PROJECTILE
local STRUCTURE     = categories.STRUCTURE
local SUBCOMMANDER  = categories.SUBCOMMANDER
local WALL          = categories.WALL

Unit = Class(UnitMethods) {

    BuffTypes = {
        Regen               = { BuffType = 'VET_REGEN',         BuffValFunction = 'Add',    BuffDuration = -1, BuffStacks = 'REPLACE' },
        Health              = { BuffType = 'VET_HEALTH',        BuffValFunction = 'Mult',   BuffDuration = -1, BuffStacks = 'REPLACE' },
        EnergyWeapon        = { BuffType = 'VET_ENERGYWEAPON',  BuffValFunction = 'Mult',   BuffDuration = -1, BuffStacks = 'REPLACE' },
		VisionRadius        = { BuffType = 'VET_VISION',        BuffValFunction = 'Add',    BuffDuration = -1, BuffStacks = 'REPLACE' },
        WaterVisionRadius   = { BuffType = 'VET_WATER_VISION',  BuffValFunction = 'Add',    BuffDuration = -1, BuffStacks = 'REPLACE' },
    },

    FxDamageScale = 1,
	
    -- FX Damage tables. A random damage effect table of emitters is choosen out of this table
    FxDamage1 = { EffectTemplate.DamageSmoke01, EffectTemplate.DamageSparks01 },
    FxDamage2 = { EffectTemplate.DamageFireSmoke01, EffectTemplate.DamageSparks01 },
    FxDamage3 = { EffectTemplate.DamageFire01, EffectTemplate.DamageSparks01 },
	
    -- This will be true for all units being constructed as upgrades
    DisallowCollisions = false,

    -- Destruction params
    PlayDestructionEffects = true,

    GetSync = function(self)
	
        if not Sync.UnitData[GetEntityId(self)] then
		
            Sync.UnitData[GetEntityId(self)] = {}
			
        end
		
        return Sync.UnitData[GetEntityId(self)]
		
    end,

    OnPreCreate = function(self)

        self.Sync = { army = GetArmy(self), id = GetEntityId(self) }

        setmetatable( self.Sync, SyncMeta )
		
		local bp = GetBlueprint(self)

        self.Army = self.Sync.army
		self.BlueprintID = bp.BlueprintId
        self.Dead = false
        self.EntityID = self.Sync.id
        
        self.EventCallbacks = {
		
            --OnKilled = {},
			
            --OnUnitBuilt = {},
            --OnStartBuild = {},
			
            --OnReclaimed = {},
            --OnStartReclaim = {},
            --OnStopReclaim = {},
			
            --OnStopBeingBuilt = {},

            --OnCaptured = {},
            --OnCapturedNewUnit = {},
			
            --OnDamaged = {},

            --OnStartCapture = {},
            --OnStopCapture = {},
            --OnFailedCapture = {},
            --OnStartBeingCaptured = {},
            --OnStopBeingCaptured = {},
            --OnFailedBeingCaptured = {},
			
            --OnFailedToBuild = {},
			
            --OnVeteran = {},

            --SpecialToggleEnableFunction = false,
            --SpecialToggleDisableFunction = false,

            -- new eventcallbacks. returns only 'self' as argument unless otherwise noted
            --OnCreated = {},

            --OnTransportAttach = {},
            --OnTransportDetach = {},

            --OnShieldIsUp = {},
            --OnShieldIsDown = {},
            --OnShieldIsCharging = {},
			
            --OnPaused = {},				-- pause button
            --OnUnpaused = {},
			
            --OnProductionPaused = {},	-- production button for f.e. mass fab
            --OnProductionUnpaused = {},
			
            --OnHealthChanged = {},		-- returns self, newHP, oldHP
			
            --OnTMLAmmoIncrease = {},		-- use AddOnMLammoIncreaseCallback function. uses 6 sec interval polling so not accurate
            --OnTMLaunched = {},
			
            --OnSMLAmmoIncrease = {},		-- use AddOnMLammoIncreaseCallback function. uses 6 sec interval polling so not accurate
            --OnSMLaunched = {},

            --OnCmdrUpgradeFinished = {},	-- happens whenever a unit is enhanced (as opposed to upgrade)
            --OnCmdrUpgradeStart = {},	-- happens whenever a unit starts an enhancement --

            --OnTeleportCharging = {}, 	-- returns self, location
            --OnTeleported = {},			-- returns self, location

            --OnTimedEvent = {},			-- returns self, variable (can be antyhing, value is determined when adding event callback)

            --OnAttachedToTransport = {},	-- returns self, transport unit
            --OnDetachedToTransport = {},	-- returns self, transport unit

            --OnBeforeTransferingOwnership = {},
            --OnAfterTransferingOwnership = {},
			
        }

        -- should investigage this for usage, perhaps eliminating it's necessity 
        self.OnBeingBuiltEffectsBag = TrashBag()
		
        
		self.PlatoonHandle = false

        if not self.Trash then
            self.Trash = TrashBag()
        end

    end,

    OnCreate = function(self)

        EntityOnCreate(self)
        
        local aiBrain = GetAIBrain(self)

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..aiBrain.Nickname.." "..self.EntityID.." OnCreate for "..ALLBPS[self.BlueprintID].Description.." on tick "..GetGameTick() )
        end

        self.ArmyIndex = aiBrain.ArmyIndex

		local bp = ALLBPS[self.BlueprintID]

        self.Buffs = { BuffTable = {}, Affects = {}, }

        if self.BuffFields and bp.BuffFields then
            self:InitBuffFields( bp )
        end
  
		self.CacheLayer = GetCurrentLayer(self)

		self.CanBeKilled = true
		self.CanTakeDamage = true
        
        GetStat( self, 'REGEN', bp.Defense.RegenRate )
        
        self.CurrentRegenRate = bp.Defense.RegenRate
        
        SetStat( self, 'REGEN', self.CurrentRegenRate )
        
        GetStat( self, 'VISION', bp.Intel.VisionRadius or 4 )
        SetStat( self, 'VISION', bp.Intel.VisionRadius or 4 )
        
        GetStat( self, 'WATERVISION', bp.Intel.WaterVisionRadius or 4)
        SetStat( self, 'WATERVISION', bp.Intel.WaterVisionRadius or 4 )

        GetStat( self, 'FUELTIME', bp.Physics.FuelUseTime or -1 )
        SetStat( self, 'FUELTIME', bp.Physics.FuelUseTime or -1 )
     
        local damageamounts = 1
        local vol = bp.SizeX * bp.SizeY * bp.SizeZ
        
        self.FxDamageAmount = {0,0,0}

        if vol >= 30 then
            damageamounts = 4
            self.FxDamageScale = 1.2
			
        elseif vol >= 15 then
		
            damageamounts = 3
            self.FxDamageScale = 1.1
            
        elseif vol >= 1 then
		
            damageamounts = 2
        end

        self.FxDamageAmount[1] = self.FxDamage1Amount or damageamounts
        self.FxDamageAmount[2] = self.FxDamage2Amount or damageamounts
        self.FxDamageAmount[3] = self.FxDamage3Amount or damageamounts
   
        if self.LandBuiltHiddenBones then
		
			if self.CacheLayer == 'Land' then
			
				for _,v in self.LandBuiltHiddenBones do
				
					if IsValidBone(self,v) then
						HideBone(self,v, true)
					end
				end
			end
        end

		self.PlatoonHandle = false
		
        if bp.Display.AnimationDeath[1] then
			self.PlayDeathAnimation = true
        end

        -- all AI (except Civilian) are technically cheaters --
        if aiBrain.CheatingAI then
            self:ForkThread(ApplyCheatBuffs)
        end

        SetConsumptionPerSecondEnergy( self, bp.Economy.MaintenanceConsumptionPerSecondEnergy or 0 )
        SetConsumptionPerSecondMass( self, bp.Economy.MaintenanceConsumptionPerSecondMass or 0 )
		
        SetProductionPerSecondEnergy( self, bp.Economy.ProductionPerSecondEnergy or 0 )

        SetProductionPerSecondMass( self, bp.Economy.ProductionPerSecondMass or 0 )

        SetProductionActive( self, true )
   
        SetIntelRadius( self, 'Vision', bp.Intel.VisionRadius or 0)

		-- from CBFP
        if bp.Transport and bp.Transport.DontUseForcedAttachPoints then
            self:RemoveTransportForcedAttachPoints()
        end
     
        self:DisableRestrictedWeapons()
        
        -- from All Your Voice mod -- this routine gets launched on EVERY unit
		-- since it really only does anything if the blueprint has the correct audio section
        -- then this should only be launched if that is the case - instead of every unit        
        if ArmyIsCivilian( aiBrain.ArmyIndex ) == false then

            for _,faction in {'UEF', 'Aeon', 'Cybran', 'Seraphim'} do

                if bp.Audio['EnemyUnitDetected'..faction] then

                    self.SeenEver = {}
                    self.SeenEverDelay = {}

                    -- this puts an entry for every army into this unit
                    for _, brain in BRAINS do
                        self.SeenEver[brain.ArmyIndex] = false
                        self.SeenEverDelay[brain.ArmyIndex] = 0
                    end                    

                    self:ForkThread( self.WatchIntelFromOthers, bp, aiBrain )
                end
            end
        end
        
        self:OnCreated()  
		
    end,

    OnCreated = function(self)

        self:DoUnitCallbacks('OnCreated')
		
    end,

    ForkThread = function(self, fn, ...)

        local thread = ForkThread(fn, self, unpack(arg))
		
        TrashAdd( self.Trash,thread )
		
        return thread
		
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', __blueprints[self.BlueprintID].Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', __blueprints[self.BlueprintID].Economy.StorageMass)
    end,

	-- set the current layer whenever it changes
	OnLayerChange = function (self, new, old)

		self.CacheLayer = new		
		
	end,
	
	GetCurrentLayer = function(self)
	
		return self.CacheLayer
		
	end,
	
    InitBuffFields = function(self, bp)
		
        if self.BuffFields and bp.BuffFields then
		
            for scriptName, field in self.BuffFields do

                local BuffFieldBp = BuffFieldBlueprints[bp.BuffFields[scriptName]]

                if not self.MyBuffFields then
                    self.MyBuffFields = {}
                end
				
                self:CreateBuffField( scriptName, BuffFieldBp )
            end
		end
    end,

    CreateBuffField = function( self, name, buffFieldBP )

		local spec = { Name = buffFieldBP.Name, Owner = self,}
		
        return ( self.BuffFields[name](spec) )
		
    end,

    GetBuffFieldByName = function(self, name)
	
        if self.BuffFields and self.MyBuffFields then
			
            for k, field in self.MyBuffFields do
				
                local fieldBP = field:GetBlueprint()
				
                if fieldBP.Name == name then
				
                    return field
                end
            end
        end
    end,	

    -- disables some weapons as defined in the unit restriction list, if unit restrictions enabled of course. [119]
    -- why not do this using a blueprint mod? removing the weapon in the blueprint would break compatibility with other
    -- mods that might change nuke weapons.
    DisableRestrictedWeapons = function(self)
	
        local noNukes = Game.NukesRestricted()
        
        local noTacMsl = Game.TacticalMissilesRestricted()
		
        for i = 1, GetWeaponCount(self) do
		
            local wep = self:GetWeapon(i)
            local bp = wep.bp
			
            if bp.CountedProjectile then
			
                if noNukes and bp.NukeWeapon then
				
                    wep:SetWeaponEnabled(false)
                    self:RemoveCommandCap('RULEUCC_Nuke')
                    self:RemoveCommandCap('RULEUCC_SiloBuildNuke')
					
                elseif noTacMsl then
				
                    wep:SetWeaponEnabled(false)
					
                    -- todo: this may not be sufficient for all units, ACUs with a tactical missile enhancements may by-pass this
                    self:RemoveCommandCap('RULEUCC_Tactical')
                    self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
                end
            end
        end
		
    end,
	
	-- from All Your Voice mod
	-- this loop runs for units in order to play VOs to Human players
	-- in a nutshell, this loop runs every 6 seconds to see if the unit
	-- is visible to enemy players - and if so - it plays the audio cue
	-- if the unit becomes undetected, the audio cue will be reset but
    WatchIntelFromOthers = function(self, bp, mybrain)
		
		local GetBlip = UnitMethods.GetBlip
		local IsSeenEver = moho.blip_methods.IsSeenEver
		local WaitTicks = WaitTicks
		
		local audio = bp.Audio
        
        local enemy_index = {}
        local enemy_count = 1

        for _, brain in BRAINS do
        
            if brain.BrainType == 'Human' and IsEnemy( brain.ArmyIndex, mybrain.ArmyIndex) then
                enemy_index[enemy_count] = brain.ArmyIndex
                enemy_count = enemy_count + 1
            end
            
        end

		while enemy_count > 1 do
        
			for _, index in enemy_index do
                
				local blip = GetBlip(self, index )

				if blip != nil then

					-- if the unit has been visually identified play the audio cue
					if IsSeenEver( blip, index ) and self.SeenEver[index] == false and self.SeenEverDelay[index] == 0 then

						GetArmyBrain(index):EnemyUnitDetected(audio['EnemyUnitDetectedUEF'], self:GetPosition())

						self.SeenEverDelay[index] = 30 #-- DetectionDelay -- controls time between voiceovers if unit appears, disappears and then reappears
                        self.SeenEver[index] = true
					end
                    
				else
				
					self.SeenEver[index] = false
				end

				if self.SeenEverDelay[index] > 0 then
				
					self.SeenEverDelay[index] = self.SeenEverDelay[index] - 6.0
					
				else
				
                    self.SeenEverDelay[index] = 0
                end
				
                WaitTicks(6)
				
			end
			
			WaitTicks(61)
		end
    end,

    IsDead = function(self)
        return self.Dead
    end,

    GetCachePosition = function(self)
        return self:GetPosition()
    end,

    GetFootPrintSize = function(self)

        local bp = ALLBPS[self.BlueprintID]
        local fp = bp.Footprint
        
        -- return Footprint values - or if not present use Size 
        return LOUDMAX( fp.SizeX or bp.SizeX, fp.SizeY or bp.SizeZ )

    end,

    -- Returns 4 numbers: skirt x0, skirt z0, skirt.x1, skirt.z1
    GetSkirtRect = function(self, bp)

		local pos = self:GetPosition()

        local fx = pos[1] - bp.Footprint.SizeX*.5
        local fz = pos[3] - bp.Footprint.SizeZ*.5
		
        local sx = fx + bp.Physics.SkirtOffsetX
        local sz = fz + bp.Physics.SkirtOffsetZ
		
        return sx, sz, sx+bp.Physics.SkirtSizeX, sz+bp.Physics.SkirtSizeZ
		
    end,

    GetUnitSizes = function(self)

        local bp = ALLBPS[self.BlueprintID]
		
        return bp.SizeX or 0.5, bp.SizeY or 0.5, bp.SizeZ or 0.5
		
    end,

    GetRandomOffset = function(self, scalar)

        local bp = ALLBPS[self.BlueprintID]

        local sx = scalar * (bp.SizeX or 0.5)
        local sy = scalar * (bp.SizeY or 0.5)
        local sz = scalar * (bp.SizeZ or 0.5)
        
		local RD = Random()
		
        sx = RD * sx - (sx * 0.5)
        local y  = RD * sy + (bp.CollisionOffsetY or 0)
        sz = RD * sz - (sz * 0.5)
        
        local heading = GetHeading(self)
        
		local LC = LOUDCOS(heading)
		local LS = LOUDSIN(heading)
        
        return LC*sx - LS*sz, y, LS*sx - LC*sz

        --return x,y,z
		
    end,

    LifeTimeThread = function(self, lifetime)

		WaitTicks(lifetime*10)

		self:Destroy()
		
    end,

    SetTargetPriorities = function(self, priTable)

        for i = 1, GetWeaponCount(self) do
		
            local wep = GetWeapon(self,i)
            
            if wep.WeaponIsEnabled then
                wep:SetWeaponPriorities(priTable)
            end
			
        end
		
    end,
    
    SetLandTargetPriorities = function(self, priTable)

        for i = 1, GetWeaponCount(self) do
		
            local wep = GetWeapon(self,i)
            
            for onLayer, targetLayers in wep.bp.FireTargetLayerCapsTable do
			
                if string.find(targetLayers, 'Land') then
				
                    wep:SetWeaponPriorities(priTable)
					
                    break
                end
            end
        end
		
    end,
	
	############
    ## toggles
    ############
	
    EnableSpecialToggle = function(self)
	
        if self.EventCallbacks.SpecialToggleEnableFunction then
		
            self.EventCallbacks.SpecialToggleEnableFunction(self)
			
        end
		
    end,

    DisableSpecialToggle = function(self)
	
        if self.EventCallbacks.SpecialToggleDisableFunction then
		
            self.EventCallbacks.SpecialToggleDisableFunction(self)
			
        end
		
    end,

    AddSpecialToggleEnable = function(self, fn)
	
        if fn then
		
            self.EventCallbacks.SpecialToggleEnableFunction = fn
			
        end
		
    end,

    AddSpecialToggleDisable = function(self, fn)
	
        if fn then
		
            self.EventCallbacks.SpecialToggleDisableFunction = fn
			
        end
		
    end,

    EnableDefaultToggleCaps = function( self )
	
        if self.ToggleCaps then
		
            for k,v in self.ToggleCaps do
			
                self:AddToggleCap(v)
				
            end
			
        end
		
    end,

    DisableDefaultToggleCaps = function( self )
	
        self.ToggleCaps = {}
		
		local counter = 0
		
        local capsCheckTable = {'RULEUTC_WeaponToggle', 'RULEUTC_ProductionToggle', 'RULEUTC_GenericToggle', 'RULEUTC_SpecialToggle'}
		
        for k,v in capsCheckTable do
		
            if self:TestToggleCaps(v) == true then
			
				counter = counter + 1
                self.ToggleCaps[counter] = v

            end
			
            self:RemoveToggleCap(v)
			
        end
		
    end,
	
	-- all these Extra Caps functions come from Domino Mod Support
	AddExtraCap = function(self, Cap)
	
		if string.sub(Cap,1,8) == 'RULEETC_' and AvailableToggles[Cap] then 
			if not UnitData[self:GetEntityId()].Data[Cap] then
				self.Sync[Cap] = true
				self.Sync[Cap.. '_state'] = AvailableToggles[Cap].initialState
			end
		end
		
		RequestRefreshUI(self)
	end,
	
	RemoveExtraCap = function(self, Cap)
	
		if string.sub(Cap,1,8) == 'RULEETC_' and AvailableToggles[Cap] then 
			if UnitData[self:GetEntityId()].Data[Cap] then 
				self.Sync[Cap] = false
				self.Sync[Cap .. '_state'] = AvailableToggles[Cap].initialState
			end
		end
		
		RequestRefreshUI(self)
	end,
	
	GetExtraBit = function(self, Cap)
	
		if string.sub(Cap,1,8) == 'RULEETC_' and AvailableToggles[Cap] then 
			if not UnitData[self:GetEntityId()].Data[Cap] then
				LOG('DMOD --> No Toggle exists on the unit by the name of ' .. Cap)
			else
				local ToggleData = UnitData[self:GetEntityId()].Data[Cap.. '_state']
 
				if ToggleData then 
					return true
				else
					return false
				end
			end
		else
			return nil
		end
	end,
	
	SetExtraBit = function(self, Cap, Param)
	
		if string.sub(Cap,1,8) == 'RULEETC_' and AvailableToggles[Cap] then
			if not UnitData[self:GetEntityId()].Data[Cap] then
				LOG('DMOD --> No Toggle exists on the unit by the name of ' .. Cap)
			else
				if Param then 
					self.Sync[Cap .. '_state'] = Param
					self:OnExtraToggleSet(Cap)
				else
					self.Sync[Cap .. '_state'] = Param
					self:OnExtraToggleClear(Cap)
				end
				
				RequestRefreshUI(self)
			end
		else
			LOG('DMod --> Invalid Toggle Cap specified for SetExtraBit ' .. Cap)
		end
		
	end,

	OnExtraToggleClear = function(self, ToggleName)
	end,
	
	OnExtraToggleSet = function(self, ToggleName)
	end,
	
	-- standard script bits --
    OnScriptBitSet = function(self, bit)

        if bit == 0 then			-- shield toggle
		
		    self:EnableShield()
			
        elseif bit == 1 then 		-- weapon toggle

        elseif bit == 2 then 		-- jamming toggle
		
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Jammer')
			
        elseif bit == 3 then 		-- intel toggle
		
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('Omni')
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('CloakField')
            self:DisableUnitIntel('Spoof')
            self:DisableUnitIntel('Jammer')
            self:DisableUnitIntel('Radar')
			
        elseif bit == 4 then 		-- production toggle

            self:OnProductionPaused()
			
        elseif bit == 5 then 		-- stealth toggle
		
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')
			
        elseif bit == 6 then 		-- generic pause toggle

            self:SetPaused(true)
			
        elseif bit == 7 then 		-- special toggle
		
            self:EnableSpecialToggle()
			
        elseif bit == 8 then 		-- cloak toggle

            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
			self:DisableUnitIntel('CloakField')

            self.CloakEffectEnabled = false
        end
    end,

    OnScriptBitClear = function(self, bit)

        if bit == 0 then
		
            self:DisableShield()
			
        elseif bit == 1 then

        elseif bit == 2 then

            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Jammer')
			
        elseif bit == 3 then

            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('Omni')
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('CloakField')
            self:EnableUnitIntel('Spoof')
            self:EnableUnitIntel('Jammer')
			
        elseif bit == 4 then
		
            self:OnProductionUnpaused()
			
        elseif bit == 5 then

            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
			
        elseif bit == 6 then
		
            self:SetPaused(false)
			
        elseif bit == 7 then
		
            self:DisableSpecialToggle()
			
        elseif bit == 8 then

            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
			self:EnableUnitIntel('CloakField')
            
            self.CloakEffectEnabled = true
        end
		
    end,

    OnPaused = function(self)
	
        self:SetActiveConsumptionInactive()
        
        self:StopUnitAmbientSound( 'ConstructLoop' )
        
        self:DoUnitCallbacks('OnPaused')
    end,

    OnUnpaused = function(self)
		
        if IsUnitState( self, 'Building') or IsUnitState( self, 'Upgrading') or IsUnitState( self, 'Repairing') then
		
            self:SetActiveConsumptionActive()

            self:PlayUnitAmbientSound( 'ConstructLoop' )
			
        end
		
        self:DoUnitCallbacks('OnUnpaused')
    end,
	
    TimedEventThread = function(self, interval, passData)
	
        WaitTicks(interval*10)
		
        while not self.Dead do
		
            WaitTicks(interval*10)
			
            self:OnTimedEvent(interval, passData)
			
        end
		
    end,

    OnTimedEvent = function(self, interval, passData)
	
        self:DoOnTimedEventCallbacks(interval, passData)
		
    end,

    OnBeforeTransferingOwnership = function(self, ToArmy)
	
        self:DoUnitCallbacks('OnBeforeTransferingOwnership')
		
    end,

    OnAfterTransferingOwnership = function(self, FromArmy)
	
        self:DoUnitCallbacks('OnAfterTransferingOwnership')
		
    end,

    OnSpecialAction = function(self, location)
    end,

    OnProductionActive = function(self)
    end,

    OnActive = function(self)
    end,

    OnInactive = function(self)
    end,

	-- when you start being captured
    OnStartBeingCaptured = function(self, captor)
	
        self:DoUnitCallbacks('OnStartBeingCaptured', captor )
        self:PlayUnitSound('StartBeingCaptured')
    end,

	-- when you finish being captured by something else
    OnStopBeingCaptured = function(self, captor)
	
        self:DoUnitCallbacks('OnStopBeingCaptured', captor )
        self:PlayUnitSound('StopBeingCaptured')
    end,

	-- when you are captured
    OnCaptured = function(self, captor)
	
        if self and (not self.Dead) and captor and (not captor.Dead) and GetAIBrain(self) ~= GetAIBrain(captor) then
		
            if not self:IsCapturable() then
			
                Kill(self)
                return
				
            end
			
            -- kill non capturable things on a transport
            if LOUDENTITY( categories.TRANSPORTATION, self ) then
			
                local cargo = self:GetCargo()
				
                for _,v in cargo do
				
                    if not v.Dead and not v:IsCapturable() then
					
                        Kill(v)
						
                    end
					
                end
				
            end 
			
            self:DoUnitCallbacks('OnCaptured', captor)
			
            local newUnitCallbacks = {}
			
            if self.EventCallbacks.OnCapturedNewUnit then
                newUnitCallbacks = self.EventCallbacks.OnCapturedNewUnit
            end
			
            local entId = GetEntityId(self)
            local unitEnh = SimUnitEnhancements[entId]
            local captorArmyIndex = captor.Army
            local captorBrain = false
           
            -- bugfix when capturing an enemy it should retain its data
            local newUnits = import('/lua/SimUtils.lua').TransferUnitsOwnership( {self}, captorArmyIndex)
           
            if ScenarioInfo.CampaignMode and not captorBrain.IgnoreArmyCaps then
			
                SetIgnoreArmyUnitCap(captorArmyIndex, false)
				
            end

            -- the unit transfer function returns a table of units. since we transfered 1 unit the table contains 1
            -- unit (the new unit).
            if LOUDGETN(newUnits) != 1 then
			
                return
				
            end
			
            local newUnit
			
            for k, unit in newUnits do
			
                newUnit = unit
                break
				
            end

            -- Because the old unit is lost we cannot call a member function for newUnit callbacks
            for k,cb in newUnitCallbacks do
			
                if cb then
				
                    cb(newUnit, captor)
					
                end
				
            end
			
        end
		
    end,

	-- when you fail to get captured by something else
    OnFailedBeingCaptured = function(self, captor)
	
        self:DoUnitCallbacks('OnFailedBeingCaptured', captor )
        --self:PlayUnitSound('FailedBeingCaptured')
		
    end,

	-- when you are reclaimed
    OnReclaimed = function(self, entity)

        self:DoUnitCallbacks('OnReclaimed', entity)
        --self.CreateReclaimEndEffects( entity, self )
        self:Destroy()
		
    end,

	-- when something decays (ie. - tread, splat)
    OnDecayed = function(self)
	
        self:Destroy()
		
    end,

    SetMaintenanceConsumptionActive = function(self)

        self.MaintenanceConsumption = true
        self:UpdateConsumptionValues()
		
    end,

    SetMaintenanceConsumptionInactive = function(self)

        self.MaintenanceConsumption = nil
        self:UpdateConsumptionValues()
		
    end,

    SetActiveConsumptionActive = function(self)

        self.ActiveConsumption = true
        self:UpdateConsumptionValues()
		
    end,

    SetActiveConsumptionInactive = function(self)

        self.ActiveConsumption = nil
        self:UpdateConsumptionValues()
		
    end,

    OnProductionPaused = function(self)
	
        self:SetMaintenanceConsumptionInactive()

		-- check for -- and remove - any buffs we may have on adjacent units --
		if self.AdjacencyBeamsBag then

			for k,v in self.AdjacencyBeamsBag do
			
				local unit = GetEntityById(v.Unit)
			
				--LOG("*AI DEBUG Adjacency Unit is "..repr(unit:GetBlueprint().Description) )

				local adjBuffs = ALLBPS[self.BlueprintID].Adjacency

				if adjBuffs and import('/lua/sim/adjacencybuffs.lua')[adjBuffs] then
				
					for k,v in import('/lua/sim/adjacencybuffs.lua')[adjBuffs] do
					
						if HasBuff(unit, v) then
							RemoveBuff(unit, v, false, self)
						end
					end
				end
				
				RequestRefreshUI( self )
                
                if unit and not unit:BeenDestroyed() then
                    RequestRefreshUI( unit )
                end
			end
		end		
		
        SetProductionActive( self, false )
		
        self:DoUnitCallbacks('OnProductionPaused')
    end,

    OnProductionUnpaused = function(self)
	
        self:SetMaintenanceConsumptionActive()

		-- reapply buffs to adjacent units --
		if self.AdjacencyBeamsBag then
		
			for k,v in self.AdjacencyBeamsBag do
			
				local unit = GetEntityById(v.Unit)
			
				--LOG("*AI DEBUG Adjacency Unit is "..repr(unit:GetBlueprint().Description) )

				local adjBuffs = ALLBPS[self.BlueprintID].Adjacency

				if adjBuffs and import('/lua/sim/adjacencybuffs.lua')[adjBuffs] then
				
					for k,v in import('/lua/sim/adjacencybuffs.lua')[adjBuffs] do

						ApplyBuff( unit, v, self )

					end
				end

				RequestRefreshUI( self )
				RequestRefreshUI( unit )				
			end
		end		
		
        SetProductionActive( self, true )
		
        self:DoUnitCallbacks('OnProductionUnpaused')
    end,

    SetBuildTimeMultiplier = function(self, time_mult)
        self.BuildTimeMultiplier = time_mult
    end,

    GetMassBuildAdjMod = function(self)
        return (self.MassBuildAdjMod or 1)
    end,

    GetEnergyBuildAdjMod = function(self)
        return (self.EnergyBuildAdjMod or 1)
    end,

    GetEconomyBuildRate = function(self)
        return GetBuildRate(self) 
    end,

    -- Called when we start building a unit, turn on/off, get/lose bonuses, or on
    -- any other change that might affect our build rate or resource use.
    UpdateConsumptionValues = function(self)

        local energy_rate = 0
        local mass_rate = 0
		
		if not self.Dead then

            local LOUDMAX = LOUDMAX

			if self.ActiveConsumption then
            
       			local GetBuildRate = GetBuildRate

				local focus = GetFocusUnit(self)
                local rate = GetBuildRate(self) or 1
				
				if focus and self.WorkItem and self.WorkProgress < 1 and (IsUnitState(focus,'Enhancing') or IsUnitState(focus,'Building')) then
				
					self.WorkItem = focus.WorkItem    -- set our workitem to the focus unit work item, is specific for enhancing
					
				end
				
				local time = 1
				local mass = 0
				local energy = 0
			
				-- if the unit is enhancing (as opposed to upgrading ie. - commander, subcommander)
				if self.WorkItem then
				
					time, energy, mass = GetConstructEconomyModel(self, self.WorkItem, rate)
				
				-- if the unit is assisting something that is building ammo
				elseif focus and IsUnitState(focus,'SiloBuildingAmmo') then
					
					--GPG: If building silo ammo; create the energy and mass costs based on build rate
					--of the silo against the build rate of the assisting unit
					time, energy, mass = focus:GetBuildCosts(focus.SiloProjectile)

					local siloBuildRate = GetBuildRate(focus) or 1
					
					energy = (energy / siloBuildRate) * rate
					mass = (mass / siloBuildRate) * rate
				
				-- if the unit is building, upgrading or assisting an upgrade, or repairing something
				elseif focus then

					time, energy, mass = GetConstructEconomyModel( self, ALLBPS[focus.BlueprintID].Economy, rate )
					
				end
			
				energy = energy * (self.EnergyBuildAdjMod or 1)
				
				if energy < 1 then
					energy = 0
				end
			
				mass = mass * (self.MassBuildAdjMod or 1)
			
				if mass < .1 then
					mass = 0
				end

				energy_rate = energy / time
				mass_rate = mass / time
				
			end
		
			local myBlueprint = ALLBPS[self.BlueprintID].Economy
			
			-- LOUD -- add in the specific -- but possibly seperate -- active costs (ie. - for moving)
			if myBlueprint.ActiveConsumptionPerSecondEnergy or myBlueprint.ActiveConsumptionPerSecondMass then
				
				energy_rate = energy_rate + (myBlueprint.ActiveConsumptionPerSecondEnergy or 0)
				mass_rate = mass_rate + (myBlueprint.ActiveConsumptionPerSecondMass or 0)
				
			end		

			-- LOUD -- add in the maintenance costs -- for unit features (ie. - Shields, effects)
			if self.MaintenanceConsumption then
                
				-- apply bonuses
				energy_rate = energy_rate + ((self.EnergyMaintenanceConsumptionOverride or myBlueprint.MaintenanceConsumptionPerSecondEnergy) or 0) * (100 + (self.EnergyModifier or 0)) * (self.EnergyMaintAdjMod or 1) * 0.01
				mass_rate = mass_rate + (myBlueprint.MaintenanceConsumptionPerSecondMass or 0) * (100 + (self.MassModifier or 0)) * (self.MassMaintAdjMod or 1) * 0.01
				
			end
	
			-- enforce the minimum rates
			energy_rate = LOUDMAX(energy_rate, myBlueprint.MinConsumptionPerSecondEnergy or 0)
			mass_rate = LOUDMAX(mass_rate, myBlueprint.MinConsumptionPerSecondMass or 0)
			
		end

        SetConsumptionPerSecondEnergy( self, energy_rate )
        SetConsumptionPerSecondMass( self, mass_rate )

        if (energy_rate > 0) or (mass_rate > 0) then
		
            SetConsumptionActive( self, true)
		
        else
		
            SetConsumptionActive( self, false)
			
        end
		
    end,

    UpdateProductionValues = function(self)
	
		if ALLBPS[self.BlueprintID].Economy then
	
			local bpEcon = ALLBPS[self.BlueprintID].Economy
		
			SetProductionPerSecondEnergy( self, (bpEcon.ProductionPerSecondEnergy or 0) * (self.EnergyProdAdjMod or 1))
			SetProductionPerSecondMass( self, (bpEcon.ProductionPerSecondMass or 0) * (self.MassProdAdjMod or 1))
		end
		
    end,

    SetEnergyMaintenanceConsumptionOverride = function(self, override)
	
        self.EnergyMaintenanceConsumptionOverride = override or false
    end,

    SetBuildRateOverride = function(self, overRide)
	
        self.BuildRateOverride = overRide
    end,

    GetBuildRateOverride = function(self)
	
        return self.BuildRateOverride
    end,

    SetCanTakeDamage = function(self, val)
	
        self.CanTakeDamage = val
    end,

    CheckCanTakeDamage = function(self)
	
        return self.CanTakeDamage
    end,
    
    OnDamage = function(self, instigator, amount, vector, damageType)
    
        local platoon = self.PlatoonHandle

        -- if the unit is in a platoon that exists and that platoon has a CallForHelpAI
		-- I should probably do this thru a callback but it's much easier to find and work with it here until I have it right
		if platoon.CallForHelpAI or platoon.RetreatAI then
			
			if (not platoon.DistressCall) and (not platoon.UnderAttack) then

                local aiBrain = GetAIBrain(self)

                if PlatoonExists( aiBrain, platoon ) then
			
                    -- turn on the UnderAttack flag and process it
                    if not platoon.UnderAttack then
                        platoon:ForkThread( platoon.PlatoonUnderAttack, aiBrain)
                    end
                end
				
			end
        end
		
        if self.CanTakeDamage then
		
            self:DoOnDamagedCallbacks(instigator)
			
			-- from BrewLAN -- reduces bomb damage against bombers in the air
			if EntityCategoryContains(categories.BOMBER, self) and self:GetCurrentLayer() == 'Air' and damageType == 'NormalBomb' then
				amount = amount * 0.05
			end
--[[
            if ScenarioInfo.UnitDialog then
                if instigator.BlueprintID then
                    LOG("*AI DEBUG UNIT Instigator "..repr(instigator.BlueprintID).." OnDamage to "..self.EntityID.." "..self.BlueprintID.." for "..amount.." on tick "..GetGameTick())
                else
                    LOG("*AI DEBUG UNIT Instigator "..repr(instigator).." OnDamage to "..self.BlueprintID.." for "..amount.." on tick "..GetGameTick())                
                end
            end
--]]			
            self:DoTakeDamage(instigator, amount, vector, damageType)
			
        end
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)

		local GetHealth = GetHealth
	
        local preAdjHealth = GetHealth(self)

        if preAdjHealth > 0 then

            if ScenarioInfo.UnitDialog then
                LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." with "..preAdjHealth.." takes "..amount.." damage on tick "..GetGameTick())
            end

            AdjustHealth( self, instigator, -amount)
        
        end
		
        if GetHealth(self) < 1 then
        
            self.CanTakeDamage = false
		
            if damageType == 'Reclaimed' then
			
                self:Destroy()
				
            else
			
                local excessDamageRatio = 0.0
				
                -- Calculate the excess damage amount
                local excess = preAdjHealth - amount
                local maxHealth = EntityMethods.GetMaxHealth(self)
				
                if (excess < 0 and maxHealth > 0) then
				
                    excessDamageRatio = -excess / maxHealth
					
                end
				
                Kill( self, instigator, damageType, excessDamageRatio)
				
            end
			
        end
		
		
        if not self.Dead and LOUDENTITY(categories.COMMAND, self) then
		
			GetAIBrain(self):OnPlayCommanderUnderAttackVO()
			
        end
		
    end,

    OnHealthChanged = function(self, new, old)
	
        self:ManageDamageEffects( new, old )

        self:DoOnHealthChangedCallbacks( new, old )

        --LOG("*AI DEBUG DamageEffectsBag after HealthChange is "..repr(self.DamageEffectsBag) )
		
    end,

    ManageDamageEffects = function(self, newHealth, oldHealth)

		if not self.Dead then
        
            --LOG("*AI DEBUG ManageDamageEffects from "..oldHealth.." to "..newHealth )
		
			-- Health values come in at fixed 25% intervals
			if newHealth < oldHealth then
			
				-- if we have any damage effects in the blueprint
				if self.FxDamageAmount[1] then
			
					if oldHealth == 0.75 then
				
						for i = 1, self.FxDamageAmount[1] do
							self:PlayDamageEffect(self.FxDamage1, 1 )
						end
					
					elseif oldHealth == 0.5 then
				
						for i = 1, self.FxDamageAmount[2] do
							self:PlayDamageEffect(self.FxDamage2, 2 )
						end
					
					elseif oldHealth == 0.25 then
				
						for i = 1, self.FxDamageAmount[3] do
							self:PlayDamageEffect(self.FxDamage3, 3 )
						end
					
					end
					
				end
				
			else

				-- if there are any ongoing damage effects --
				if self.DamageEffectsBag[1] or self.DamageEffectsBag[2] or self.DamageEffectsBag[3] then
				
					if newHealth <= 0.25 and newHealth > 0 and self.DamageEffectsBag[3] then
				
						for k, v in self.DamageEffectsBag[3] do
							v:Destroy()
                            self.DamageEffectsBag[3][k] = nil
						end
					
					elseif newHealth <= 0.5 and newHealth > 0.25 and self.DamageEffectsBag[2] then
				
						for k, v in self.DamageEffectsBag[2] do
							v:Destroy()
                            self.DamageEffectsBag[2][k] = nil
						end
					
					elseif newHealth <= 0.75 and newHealth > 0.5 and self.DamageEffectsBag[1] then
				
						for k, v in self.DamageEffectsBag[1] do
							v:Destroy()
                            self.DamageEffectsBag[1][k] = nil
						end
					
					elseif newHealth > 0.75 then
				
						self:DestroyAllDamageEffects()
					
					end
					
				end
			
			end
			
		end
		
    end,

    PlayDamageEffect = function(self, fxTable, fxBag)
	
        local effects = fxTable[Random(1,LOUDGETN(fxTable))]
        
        --LOG("*AI DEBUG PlayDamageEffect fxTable is "..repr(fxTable).." bag is "..repr(fxBag))
		
        if not effects then
			return
		end
        
        if not self.DamageEffectsBag then
            self.DamageEffectsBag = { {},{},{} }
        end
		
        local army = self.Army
		
		local Random = Random

		local LOUDINSERT = LOUDINSERT
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		
        local totalBones = GetBoneCount(self)
        local bone = Random(1, totalBones) - 1
		
        local bpDE = ALLBPS[self.BlueprintID].Display.DamageEffects
		
		local fx, bpFx
		
        for k, v in effects do
			
            if bpDE then
			
                bpFx = bpDE[ Random(1, table.getsize(bpDE)) ]
				
                fx = LOUDATTACHEMITTER(self, bpFx.Bone or 0,army, v):ScaleEmitter(self.FxDamageScale):OffsetEmitter(bpFx.OffsetX or 0, bpFx.OffsetY or 0, bpFx.OffsetZ or 0)
				
            else
			
                fx = LOUDATTACHEMITTER(self, bone, army, v):ScaleEmitter(self.FxDamageScale)
            end
			
            LOUDINSERT(self.DamageEffectsBag[fxBag], fx)
        end
		
    end,

    DestroyAllDamageEffects = function(self)
	
		if self.DamageEffectsBag then
			
			for kb, vb in self.DamageEffectsBag do
			
				for ke, ve in vb do
					ve:Destroy()
                    self.DamageEffectsBag[kb][ke] = nil
				end
			end
            
            self.DamageEffectsBag = nil
		end

    end,

    CheckCanBeKilled = function(self,other)
	
        return self.CanBeKilled
    end,
	
    --Sets if the unit can be killed.  val = true means it can be killed.
    SetCanBeKilled = function(self, val)
	
        self.CanBeKilled = val
    end,

    SetDead = function(self)
    
        if not self.Killed then
    
            --if not self:BeenDestroyed() and ScenarioInfo.UnitDialog then
              --  LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." tried to SET DEAD for "..self.BlueprintID.." which was NOT killed on tick "..GetGameTick() )
            --end
        
            return
        end
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." SET DEAD for "..self.BlueprintID.." on tick "..GetGameTick() )
        end

		self.Dead = true
        
        self.Killed = true
	
		self.DisallowCollisions = nil

		self.EconomyProductionInitiallyActive = nil

		self.FxDamageAmount = nil

		self.HasFuel = nil
		self.Buffs = nil
        
		self.MaintenanceConsumption = nil
		self.ActiveConsumption = nil
		self.ProductionEnabled = nil
		self.EnergyModifier = nil
		self.MassModifier = nil
		
		self.VeteranLevel = nil
		
    end,

    -- On killed: this function plays when the unit takes a mortal hit.  It plays all the default death effect
    OnKilled = function(self, instigator, deathtype, overkillRatio)

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." OnKilled "..self.BlueprintID.." on tick "..GetGameTick())
        end

        if self.UnitBeingBuilt and LOUDENTITY(FACTORY, self) then
		
            if  not self.UnitBeingBuilt.Dead and GetFractionComplete(self.UnitBeingBuilt) < 1 then
                Kill( self.UnitBeingBuilt)
            end
        end

        -- satellites
        if categories.SATELLITEUPLINK then
        
            if EntityCategoryContains(categories.SATELLITEUPLINK + categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
                self:OnSatelliteCapacityChange(true)
            end
            
        end

        if not self:IsBeingBuilt() then

            if self.DeathWeaponEnabled != false then
                self:DoDeathWeapon()
            end

            if self.PlayDeathAnimation then 
                self:ForkThread(self.PlayAnimationThread, 'AnimationDeath')
                self:SetCollisionShape('None')
            end
        end
    		
        for i = 1, GetWeaponCount(self) do
			
            local wep = GetWeapon(self,i) or false

            if wep and (not wep.Dead and not wep.bp.FireOnDeath) then

                if wep.SetWeaponEnabled then
                    wep:SetWeaponEnabled(false)
                end
			end
        end
    
		self.PlayUnitSound( self, 'Killed')
		
		self:DoUnitCallbacks('OnKilled')
		
		if self.TopSpeedEffectsBag then
			self:DestroyTopSpeedEffects()
		end
		
		if self.BeamExhaustEffectsBag then
		    self:DestroyBeamExhaust()
		end
		
		if self.BuildEffectsBag then
			TrashDestroy(self.BuildEffectsBag)
			self.BuildEffectsBag = nil
		end

        if self.UnitBeingTeleported and not self.UnitBeingTeleported.Dead then
            self.UnitBeingTeleported:Destroy()
            self.UnitBeingTeleported = nil
        end

        -- Notify instigator that you killed me - do not grant kills for walls
		if instigator then

            if not LOUDENTITY(WALL, self) then
                if IsUnit(instigator) then
                    instigator:ForkThread( instigator.OnKilledUnit, self )
                end
            end
		end
		
        self:DisableShield()
        self:DisableUnitIntel()
        
        if not self.Impact then
            self:ForkThread(self.DeathThread, overkillRatio, instigator)
        end

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." OnKilled "..self.BlueprintID.." completed on tick "..GetGameTick())
        end
        
        self.Killed = true
        
        self:SetDead()

    end,

    DoDeathWeapon = function(self)

        local weapons       = ALLBPS[self.BlueprintID].Weapon or {}
        local UnitDialog    = ScenarioInfo.UnitDialog
		
        for _, v in weapons do
		
            if (v.Label == 'DeathWeapon') then

                if UnitDialog then
                    LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." DoDeathWeapon on tick "..GetGameTick())
                end
  
                if v.FireOnDeath == true then
			
                    local wep = self:GetWeaponByLabel('DeathWeapon')
                
                    if UnitDialog then
                        LOG("*AI DEBUG UNIT DeathWeapon FireOnDeath wep is "..repr(wep.bp) )
                    end
                    
                    wep:SetWeaponEnabled(true)
                    
                    wep:OnWeaponFired()
                    
                    wep:Fire()

                else
                
                    if UnitDialog then
                        LOG("*AI DEBUG UNIT DeathWeapon Damage Thread for "..v.Damage.." radius "..v.DamageRadius)
                    end

                    if v.Damage > 0 and v.DamageRadius > 0 then
                        self:ForkThread(self.DeathWeaponDamageThread, v.DamageRadius, v.Damage, v.DamageType, v.DamageFriendly)
                    end
                end
                
                if v.Buffs then
                
                    local Buff = v.Buffs
                    
                    if type(Buff.TargetAllow) == 'string' then
                        Buff.TargetAllow = LOUDPARSE(Buff.TargetAllow)
                        Buff.TargetDisallow = LOUDPARSE(Buff.TargetDisallow)
                    end
                    
					self:AddBuff( Buff, self:GetCachePosition() )
                end
            end
        end
		
    end,

    DeathWeaponDamageThread = function( self , damageRadius, damage, damageType, damageFriendly)
	
        WaitTicks(1)

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." DeathWeaponDamage of "..damage.." in radius "..damageRadius.." on tick "..GetGameTick())
        end
 		
        DamageArea(self, self:GetPosition(), damageRadius or 1, damage, damageType or 'Normal', damageFriendly or false)
    end,
	
    PlayAnimationThread = function(self, anim, rate)

        local bp = ALLBPS[self.BlueprintID]
		
        if bp.Display[anim] then
        
            local animBlock = self:ChooseAnimBlock( bp.Display[anim] )
			
            if animBlock.Mesh then
                SetMesh(self,animBlock.Mesh)
            end
			
            if animBlock.Animation then

                local rate = rate or 2
				
                if animBlock.AnimationRateMax and animBlock.AnimationRateMin then
				
                    rate = Random(animBlock.AnimationRateMin * 10, animBlock.AnimationRateMax * 10) / 10
                end
				
                self.DeathAnimManip = CreateAnimator(self)

                PlayAnim( self.DeathAnimManip, animBlock.Animation):SetRate(rate)

                TrashAdd( self.Trash, self.DeathAnimManip)

                WaitFor( self.DeathAnimManip )

				self.DeathAnimManip = nil

            end

        end
		
    end,

    DeathThread = function( self, overkillRatio, instigator)
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." DeathThread for "..ALLBPS[self.BlueprintID].Description.." on tick "..GetGameTick() )
        end
        
        if self.DeathAnimManip then
			WaitFor(self.DeathAnimManip)
		end

		self.PlayUnitSound(self,'Destroyed')		
		
		WaitTicks(2)
		
		if self.DamageEffectsBag then
			self:DestroyAllDamageEffects()
		end

		-- if simspeed too low suppress destruction effects --
		if Sync.SimData.SimSpeed > -1 then
		
			if self.PlayDestructionEffects then
				self:CreateDestructionEffects( overkillRatio )
			end
        
			if ( self.ShowUnitDestructionDebris and overkillRatio ) then
		
				if overkillRatio <= 0.10 then
					self:CreateUnitDestructionDebris( true, true, false )
				else
					self:CreateUnitDestructionDebris( false, true, true )
				end
			end
		end
		
		if overkillRatio <= 0.10 then
			self:CreateWreckage( overkillRatio )
		end

        WaitTicks( (self.DeathThreadDestructionWaitTime or 0.1) * 10 )

        self:Destroy()

    end,
	
	CreateUnitDestructionDebris = function( self, high, low, chassis )

		self:ForkThread( CreateUnitDestructionDebris, self, high, low, chassis )
		
	end,
    

	-- this call can be made in two ways - one with a PosEntity value and one without
	-- and self can either be a target unit or the origin unit of the buff
	-- this makes it very flexible but tricky to read and you need to know where the call
	-- was made from before you can follow the flow

	-- the allow and disallow parsing has turned out to be problematic as well needing to be seperated by commas
	-- and not seeming to recognize the '-' (minus) operator -- Nov 2023 - I parse the buff allow and disallow categories
    -- when the weapon is created - so it doesn't need to be evaluated on the fly - repeatedly
    -- NOTE: DeathWeapons are usually 'dummy' weapons and don't get created like other weapons, I'll have to parse them elsewhere
    AddBuff = function(self, buffTable, PosEntity)
    
        local GetHealth = GetHealth
	
        local bt = buffTable.BuffType

        if bt == 'STUN' then

            local allow = ALLUNITS

            if buffTable.TargetAllow then
                allow = buffTable.TargetAllow
            end
		
            local disallow = false
		
            if buffTable.TargetDisallow then
                disallow = buffTable.TargetDisallow
            end

			if buffTable.Radius and buffTable.Radius > 0 then
                --if the radius is bigger than 0 then we will either use the provided position as the center of the stun blast
				--or if not provided, the self unit's position -- note -- self must be a friendly entity if you want to 
                --collect all enemy targets from that point -- we'd never want to STUN friendly units
                local targets = false
				
                if PosEntity then
				
                    targets = GetEnemyUnitsInSphere(self, PosEntity, buffTable.Radius)
					
                else

                    targets = GetEnemyUnitsInSphere(self, self:GetPosition(), buffTable.Radius)
					
                end
				
				if not targets then return end
				
                for k, v in EntityCategoryFilterDown( allow, targets ) do
			
                    if (not disallow) or (not LOUDENTITY( disallow, v)) then

                        v:SetStunned(buffTable.Duration or 1)
                    end
                end
				
            else
			
                --The buff will be applied to the unit
                if LOUDENTITY( allow, self) and (not disallow or not LOUDENTITY( disallow, self)) then
				
					self:SetStunned(buffTable.Duration or 1)
                end
            end
			
        elseif bt == 'MAXHEALTH' then
		
            self:SetMaxHealth(self:GetMaxHealth() + (buffTable.Value or 0))
			
        elseif bt == 'HEALTH' then
		
            SetHealth( self, self, GetHealth(self) + (buffTable.Value or 0))
			
        elseif bt == 'SPEEDMULT' then
		
            self:SetSpeedMult(buffTable.Value or 0)
			
        elseif bt == 'MAXFUEL' then
		
            self:SetFuelUseTime(buffTable.Value or 0)
			
        elseif bt == 'FUELRATIO' then

            local allow = ALLUNITS

            if buffTable.TargetAllow then
                allow = buffTable.TargetAllow
            end
		
            local disallow = false
		
            if buffTable.TargetDisallow then
                disallow = buffTable.TargetDisallow
            end

			if buffTable.Radius and buffTable.Radius > 0 then
                --if the radius is bigger than 0 then we will either use the provided position as the center of the stun blast
				--or if not provided, the self unit's position -- note -- self must be an entity if you want to 
                --collect all enemy targets from that point -- we'd never want to STUN friendly units
                local targets = false
				
                if PosEntity then
				
                    targets = GetEnemyUnitsInSphere(self, PosEntity, buffTable.Radius)
					
                else

                    targets = GetEnemyUnitsInSphere(self, self:GetPosition(), buffTable.Radius)
					
                end
				
				if not targets then return end
				
                for k, v in EntityCategoryFilterDown( allow, targets ) do
			
                    if (not disallow) or (not LOUDENTITY( disallow, v)) then
                    
                        local now = v:GetFuelRatio()
                        
                        if now > .01 then
                            v:SetFuelRatio( now * ((100 - buffTable.BuffValue)/100) )
                        end

                    end
                end
				
            else
			
                --The buff will be applied to the unit
                if LOUDENTITY( allow, self) and (not disallow or not LOUDENTITY( disallow, self)) then
                    
                    local now = self:GetFuelRatio()

                    if now > 0.01 then
                        self:SetFuelRatio( now * ((100 - buffTable.BuffValue)/100) )
                    end

                end
            end
			
        elseif bt == 'HEALTHREGENRATE' then
		
            self:SetRegenRate(buffTable.Value or 0)
            
            self.CurrentRegenRate = val
			
        end

    end,

    AddWeaponBuff = function(self, buffTable, weapon)
	
        local bt = buffTable.BuffType
		
        if not bt then
		
            error('*ERROR: Tried to add a weapon buff in unit.lua but got no buff table.  Wierd.', 1)
            return
        end
		
        if bt == 'RATEOFFIRE' then
		
            weapon:ChangeRateOfFire(buffTable.Value or 1)
			
        elseif bt == 'TURRETYAWSPEED' then
		
            weapon:SetTurretYawSpeed(buffTable.Value or 0)
			
        elseif bt == 'TURRETPITCHSPEED' then
		
            weapon:SetTurretPitchSpeed(buffTable.Value or 0)
			
        elseif bt == 'DAMAGE' then
		
            weapon:AddDamageMod(buffTable.Value or 0)
			
        elseif bt == 'MAXRADIUS' then
		
            weapon:ChangeMaxRadius(buffTable.Value or weapon.bp.MaxRadius)
			
        elseif bt == 'FIRINGRANDOMNESS' then
		
            weapon:SetFiringRandomness(buffTable.Value or 0)
			
        else
		
            self:AddBuff(buffTable)
			
        end
		
    end,

    CreateWreckage = function( self, overkillRatio )

        if ALLBPS[self.BlueprintID].Wreckage.WreckageLayers[self.CacheLayer] then

			self:CreateWreckageProp(overkillRatio)
        end
    end,

    CreateWreckageProp = function( self, overkillRatio, overridetime, bypasswreckageeffects )

		local bp        = ALLBPS[self.BlueprintID]
        local Wreckage  = bp.Wreckage
		local wreck     = Wreckage.Blueprint

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." CreateWreckageProp for "..self.BlueprintID)
        end

		if wreck then
		
			local function LifetimeThread(prop,lifetime)
			
				WaitTicks(lifetime * 10)
				
				prop:Destroy()
			end
			
			local pos = table.copy(self:GetPosition())
			
			local mass      = bp.Economy.BuildCostMass * (Wreckage.MassMult or 0)
			local energy    = bp.Economy.BuildCostEnergy * (Wreckage.EnergyMult or 0)
			local time      = (Wreckage.ReclaimTimeMultiplier or 1)
            
			local prop = CreateProp( pos, wreck )

			prop:AddBoundedProp(mass)

			prop:SetScale(bp.Display.UniformScale)
			prop:SetOrientation(self:GetOrientation(), true)
			prop:SetPropCollision('Box', bp.CollisionOffsetX, bp.CollisionOffsetY, bp.CollisionOffsetZ, bp.SizeX* 0.5, bp.SizeY* 0.5, bp.SizeZ * 0.5)
			
			prop:SetMaxReclaimValues(time, time, mass, energy)
			
			mass    = (mass - (mass * (overkillRatio or 1))) * GetFractionComplete(self)
			energy  = (energy - (energy * (overkillRatio or 1))) * GetFractionComplete(self)
			time    = time - (time * (overkillRatio or 1))
			
			prop:SetReclaimValues(time, time, mass, energy)
			
			prop:SetMaxHealth( bp.Defense.Health * (Wreckage.HealthMult or .1) )
            
			SetHealth( prop, self, bp.Defense.Health * (Wreckage.HealthMult or .1))

            if not Wreckage.UseCustomMesh then
    	        SetMesh( prop, bp.Display.MeshBlueprintWrecked )
            end

			-- all wreckage now has a lifetime max of 900 seconds --
            -- except starting props or those with an override value
			prop:ForkThread( LifetimeThread, overridetime or Wreckage.LifeTime or 900 )

            if not bypasswreckageeffects then
                TryCopyPose(self,prop,false)
            end
            
            pos[2] = GetTerrainHeight(pos[1],pos[3])

            Warp( prop, pos )

            prop.AssociatedBP = self.BlueprintID
			prop.IsWreckage = true
			
            -- this plays a final surface explosion with debris
            if not bypasswreckageeffects then

                -- when simspeed drops too low turn off visual effects			
                if Sync.SimData.SimSpeed > -1 then
                    CreateWreckageEffects(self,prop)
                end
            end
			
			return prop
			
		end
		
    end,

	-- when you kill a unit
    OnKilledUnit = function(self, unitKilled)

		if not self.Dead then
		
			self:CheckVeteranLevel()
		end
    end,
	
    OnCollisionCheck = function(self, other, firingWeapon)

        if self.DisallowCollisions then
		
            return false
        end
		
		-- for rail guns from 4DC credit Resin_Smoker
		if other.LastImpact then
		
			-- if hit same unit twice
			if other.LastImpact == self.EntityID then

				return false
				
			end
			
		end
		
		local LOUDENTITY = LOUDENTITY
		local LOUDPARSE = LOUDPARSE

		local GetArmy = GetArmy
		
        if LOUDENTITY(PROJECTILE, other) then

			local IsAllied = IsAlly
			local army1 = GetArmy(self)
			local army2 = GetArmy(other)
			
            if army1 == army2 or IsAllied( army1, army2 ) then
			
				-- if allied and not collide with friendly
				-- then dont process collision otherwise
				-- continue on to other checks
				if not other.DamageData.CollideFriendly then
				
					return false
				end
            end
			
        end
		
		local DNCList = ALLBPS[other.BlueprintID].DoNotCollideList or false
		
		if DNCList then
		
			for _,v in DNCList do
			
				if LOUDENTITY(LOUDPARSE(v), self) then
					return false
				end
			end
			
		end

		local DNCList = ALLBPS[self.BlueprintID].DoNotCollideList or false	
		
		if DNCList then
		
			for _,v in DNCList do
			
				if LOUDENTITY(LOUDPARSE(v), other) then
					return false
				end
			end
			
		end
		
		-- for rail guns from 4DC credit Resin_Smoker
		if other.LastImpact then
			-- if hit same unit twice
			if other.LastImpact == self.EntityID then
				return false
			end
		end

        if (not self.Dead) and self.EXPhaseEnabled then
		
            if LOUDENTITY(PROJECTILE, other) then 
			
                local random = Random(1,100)
				
                -- Allows % of projectiles to pass
                if random <= self.EXPhaseShieldPercentage then
				
                    -- Returning false allows the projectile to pass thru
                    return false
                end
            end
			
        end
		
		-- taken from BrewLAN
		-- essentially the railgun never registers a hit
		-- the projectile just carries thru to hit additional targets
		if other.DamageData.DamageType == 'Railgun' then
			other.LastImpact = self.EntityID
        end

        return true
		
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)

        if self.DisallowCollisions then
		
			return false
			
        end		
		

		local bp = firingWeapon.bp  --:GetBlueprint()
        local collidefriendly = bp.CollideFriendly

		-- check for allied passthrough if same army or allied army
		if not collidefriendly then
		
			local GetArmy = GetArmy
		
			local army1 = self.Army
			local army2 = GetArmy(firingWeapon.unit)
			
			if army1 == army2 or IsAllied(army1,army2) then
			
				return false
				
			end
			
		end

		local DNCList = bp.DoNotCollideList
		
		if DNCList then
		
			for _,v in DNCList do
			
				if LOUDENTITY(LOUDPARSE(v), self) then
				
					return false
					
				end
				
			end
			
		end
		
        return true
		
    end,
	
	-- this function from BO:U - all credit to Black Ops team
	GetShouldCollide = function(self, collidefriendly, army1, army2)
	
		if not collidefriendly then
		
			if army1 == army2 or IsAllied(army1, army2) then
			
				return false
				
			end
			
		end
		
		return true
		
	end,

    ChooseAnimBlock = function(self, bp)
    
        local totWeight = 0
        
        for _, v in bp do
		
            if v.Weight then
			
                totWeight = totWeight + v.Weight
				
            end
			
        end
        
        local val = 1
        local num = Random(0, totWeight)
        
        for _, v in bp do
        
            if v.Weight then
			
                val = val + v.Weight
				
            end
            
            if num < val then
			
                return v
				
            end
			
        end
		
    end,

    OnCountedMissileLaunch = function(self, missileType)
	
        -- is called in defaultweapons.lua when a counted missile (tactical, nuke) is launched
        if missileType == 'nuke' then
		
            self:OnSMLaunched()
        else
		
            self:OnTMLaunched()
        end
		
    end,

    OnTMLaunched = function(self)
        self:DoUnitCallbacks('OnTMLaunched')
    end,

    OnSMLaunched = function(self)
        self:DoUnitCallbacks('OnSMLaunched')
    end,

    -- Checks for satellite allowances
    OnSatelliteCapacityChange = function(self, deathcheck)
        -- Gather data
        local AIBrain = self:GetAIBrain()  -- (entityCategory, needToBeIdle, requireBuilt)
        local uplinks = AIBrain:GetListOfUnits(categories.SATELLITEUPLINK, false, true)
        local satellites = AIBrain:GetListOfUnits(categories.SATELLITEWITHNOPARENTALSUPERVISION, false, false) --requireBuilt true here makes it easy to exceed the cap

        -- Remove self from list if death check
        if deathcheck then
			
            if EntityCategoryContains(categories.SATELLITEUPLINK, self) then
                table.removeByValue(uplinks, self)
            end

            if EntityCategoryContains(categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
                table.removeByValue(satellites, self)
            end

        end

        -- If this is being called by something dying, check we are allowed satellites
        if deathcheck and table.getn(uplinks) == 0 and table.getn(satellites) > 0 then

            for i, v in satellites do

                LOG(v.StartUnguidedOrbitalDecay)

                if v.StartUnguidedOrbitalDecay then
                    v:StartUnguidedOrbitalDecay(v)
                else
                    v:Kill()
                end

            end

        else
            -- calculate if we should allow more construction

            local usedcap, maxcap = 0, 0

            -- Calculate max capacity
            for i, v in uplinks do
                maxcap = maxcap + (v:GetBlueprint().General.SatelliteCapacity or 1)
            end

            -- calculate used capacity
            for i, v in satellites do
                usedcap = usedcap + 1   --(v:GetBlueprint().General.CapCost or 1)
                -- Prevent preventable satellite explosions
                if v.UnguidedOrbitalDecay then
                    v:StopUnguidedOrbitalDecay(v)
                end
            end

            -- All satellites count as 1 even if CapCost is greater than 1
            if (maxcap - usedcap) < 1 then

                --This is done per-unit to prevent any conflicts with R&D unlock satellites, and potential game restrictions.
                --Is it more costly to check it can actually build, and or build satellites first, or do it and not care?
                for i, v in uplinks do

                    v:AddBuildRestriction(categories.SATELLITEWITHNOPARENTALSUPERVISION)
                end

            else

                for i, v in uplinks do
                    v:RemoveBuildRestriction(categories.SATELLITEWITHNOPARENTALSUPERVISION)
                end

            end
				
            self:RequestRefreshUI() -- worth checking if it actually needs a refresh?
        end

    end,

    CheckCountedMissileAmmo = function(self)
	
        -- polls the ammo count every 6 secs 
        local nukeCount = self:GetNukeSiloAmmoCount() or 0
        local lastTimeNukeCount = nukeCount
        local tacticalCount = self:GetTacticalSiloAmmoCount() or 0
        local lastTimeTacticalCount = tacticalCount
		
        while not self.Dead do
		
            nukeCount = self:GetNukeSiloAmmoCount() or 0
            tacticalCount = self:GetTacticalSiloAmmoCount() or 0

            if nukeCount > lastTimeNukeCount then
			
                self:OnSMLAmmoIncrease()
				
            elseif nukeCount < lastTimeNukeCount then
            
                self:OnSMLAmmoDecrease()
                
            end
			
            if tacticalCount > lastTimeTacticalCount then
			
                self:OnTMLAmmoIncrease()
				
            elseif tacticalCount < lastTimeTacticalCount then
            
                self:OnTMLAmmoDecrease()
                
            end

            lastTimeNukeCount = nukeCount 
            lastTimeTacticalCount = tacticalCount
			
            WaitTicks(61)
        end
		
    end,

    OnTMLAmmoIncrease = function(self)
        self:DoUnitCallbacks('OnTMLAmmoIncrease')
    end,
    
    OnTMLAmmoDecrease = function(self)
        self:DoUnitCallbacks('OnTMLAmmoDecrease')
    end,

    OnSMLAmmoIncrease = function(self)
        self:DoUnitCallbacks('OnSMLAmmoIncrease')
    end,
    
    OnSMLAmmoDecrease = function(self)
        self:DoUnitCallbacks('OnSMLAmmoDecrease')
    end,

    CreateDestructionEffects = function( self, overKillRatio )

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." CreateDestructionEffects on overkill "..repr(overKillRatio).." on tick "..GetGameTick())
        end
   
        CreateScalableUnitExplosion( self, overKillRatio )
    end,

    DoDestroyCallbacks = function(self)
	
        if self.EventCallbacks.OnDestroyed then
		
            for k, cb in self.EventCallbacks.OnDestroyed do
			
                if cb then
                    cb( GetAIBrain(self), self )
                end
            end
        end
    end,

    OnDestroy = function(self)

        -- satellites --
        if categories.SATELLITEUPLINK then

            if EntityCategoryContains(categories.SATELLITEUPLINK + categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
                self:OnSatelliteCapacityChange(true)
            end

        end

		self.PlatoonHandle = nil

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." OnDestroy for "..repr(ALLBPS[self.BlueprintID].Description).." on tick "..GetGameTick() )
        end

		Sync.ReleaseIds[self.EntityID] = true

		-- Don't allow anyone to stuff anything else in the table
		self.Sync = false

		-- If factory, destroy what I'm building if I die
		if LOUDENTITY(FACTORY, self) then
		
			if self.UnitBeingBuilt and (not self.UnitBeingBuilt.Dead) and GetFractionComplete(self.UnitBeingBuilt) < 1 then
				self.UnitBeingBuilt:Destroy()
			end
		end

		if self.IntelThread then
		
			KillThread(self.IntelThread)
			
			self.IntelThread = nil
		end

		if self.BuildArmManipulator then
			self.BuildArmManipulator = nil
		end
        
		if self.BuildEffectsBag then
		
			TrashDestroy(self.BuildEffectsBag)
			self.BuildEffectsBag = nil
		end
		
		if self.CaptureEffectsBag then
		
			TrashDestroy(self.CaptureEffectsBag)
			self.CaptureEffectsBag = nil
		end
		
		if self.ReclaimEffectsBag then
		
			TrashDestroy(self.ReclaimEffectsBag)
			self.ReclaimEffectsBag = nil
			
		end
		
		if self.OnBeingBuiltEffectsBag then
		
			TrashDestroy(self.OnBeingBuiltEffectsBag)
			self.OnBeingBuiltEffectsBag = nil
			
		end
		
		if self.UpgradeEffectsBag then
		
			TrashDestroy(self.UpgradeEffectsBag)
			self.UpgradeEffectsBag = nil
			
		end 
		
		if self.TeleportDrain then
		
			RemoveEconomyEvent( self, self.TeleportDrain)
			
		end
        
		RemoveAllUnitEnhancements(self)
        
		TrashDestroy(self.Trash)
        
        self.Killed = true
        
        if not self.Dead then
            self:SetDead()
        end
		
		LOUDSTATE(self, self.DeadState)
		
    end,

    HideLandBones = function(self)

        if self.LandBuiltHiddenBones and self.CacheLayer == 'Land' then
		
            for _, v in self.LandBuiltHiddenBones do
			
                if IsValidBone(self,v) then
				
                    HideBone(self,v, true)
					
                end
				
            end
			
        end
		
    end,

    ShowBones = function(self, table, children)

        for k, v in table do
		
            if IsValidBone(self,v) then
			
                self:ShowBone(v, children)
				
            end
			
        end
		
    end,

    OnFerryPointSet = function(self)
	
        local bp = GetBlueprint(self).Audio
		
        if bp then
		
            local aiBrain = GetAIBrain(self)
            local factionIndex = aiBrain.FactionIndex
			
            if factionIndex == 1 then
			
                if bp['FerryPointSetByUEF'] then
				
                    aiBrain:FerryPointSet(bp['FerryPointSetByUEF'])
					
                end
				
            elseif factionIndex == 2 then
			
                if bp['FerryPointSetByAeon'] then
				
                    aiBrain:FerryPointSet(bp['FerryPointSetByAeon'])
					
                end
				
            elseif factionIndex == 3 then
			
                if bp['FerryPointSetByCybran'] then
				
                    aiBrain:FerryPointSet(bp['FerryPointSetByCybran'])
					
                end
				
            end
			
        end
		
    end,

    OnDamageBy = function(self,index)
	
        local bp = ALLBPS[self.BlueprintID].Audio

        if bp then
			
			local mybrain = GetAIBrain(self)
			
			for _, brain in BRAINS do
        
				if brain.BrainType == 'Human' then
                
					if brain == mybrain then
                
						if bp['UnitUnderAttackUEF'] then
						
							brain:UnitUnderAttack(bp['UnitUnderAttackUEF'], self:GetPosition())
							
						end
                    
					elseif IsAllied(mybrain.ArmyIndex, brain.ArmyIndex) then
                
						if bp['AllyUnitUnderAttackUEF'] then
						
							brain:AllyUnitUnderAttack(bp['AllyUnitUnderAttackUEF'], self:GetPosition())
							
						end
						
					end
					
				end
				
			end
			
        end
		
    end,

    OnNukeArmed = function(self)
    end,

    OnNukeLaunched = function(self)
    end,

	-- this is where the Nuke Launched Audio is triggered 
    NukeCreatedAtUnit = function(self)
	
        local mybrain = GetAIBrain(self)
		
        for _, brain in BRAINS do
		
			if brain.BrainType == "Human" then
				
                if brain != mybrain then
				
                    brain:NuclearLaunchDetected()
					
                end
				
			end
			
        end
		
    end,

    SetAllWeaponsEnabled = function(self, enable)
	
        for i = 1, GetWeaponCount(self) do
		
            local wep = GetWeapon(self,i)
            
            wep:SetWeaponEnabled(enable)

            wep:AimManipulatorSetEnabled(enable)
        end
    end,

    SetWeaponEnabledByLabel = function(self, label, enable)
	
        local wep = self:GetWeaponByLabel(label)
		
        if not wep then return nil end

        if ScenarioInfo.WeaponStateDialog then
            LOG("*AI DEBUG Unit SetWeaponEnabledByLabel for "..repr(label).." enable is "..repr(enable).." on tick "..GetGameTick() )		
        end
		
        if not enable then
            wep:OnLostTarget()
        end

        if self.Dead then return wep end
        
        wep:SetWeaponEnabled(enable)

        wep:AimManipulatorSetEnabled(enable)
        
        return wep
    end,

    GetWeaponManipulatorByLabel = function(self, label)
	
        local wep = self:GetWeaponByLabel(label)
		
		return wep.AimControl
    end,

    GetWeaponByLabel = function(self, label)
	
        local wep
		
        for i = 1, GetWeaponCount(self) do
		
            wep = GetWeapon(self,i)
			
            if (wep.bp.Label == label) then 

                return wep
				
            end
        end
		
        return nil
    end,

    ResetWeaponByLabel = function(self, label)
        local wep = self:GetWeaponByLabel(label)
        wep:ResetTarget()
    end,

    SetDeathWeaponEnabled = function(self, enable)
        self.DeathWeaponEnabled = enable
    end,

	-- interesting event - triggered every 25% of something being built
    OnBeingBuiltProgress = function(self, unit, oldProg, newProg)
    end,

	-- is this issued by the unit being built ? or the builder of the unit ?
    OnStartBeingBuilt = function(self, builder, layer)
		
        local aiBrain = GetAIBrain(self)
        
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..aiBrain.Nickname.." "..self.EntityID.." OnStartBeingBuilt for "..ALLBPS[self.BlueprintID].Description.." on tick "..GetGameTick() )
        end

		self:CheckUnitRestrictions()
	
        self:StartBeingBuiltEffects(builder, layer)

		local LOUDENTITY = LOUDENTITY

		
        if aiBrain.UnitBuiltTriggerList[1] then
		
            for k,v in aiBrain.UnitBuiltTriggerList do
			
                if LOUDENTITY(v.Category, self) then
				
                    self:ForkThread(self.UnitBuiltPercentageCallbackThread, v.Percent, v.Callback)
					
                end
				
            end
			
        end
		
        local builderUpgradesTo = ALLBPS[builder.BlueprintID].General.UpgradesTo or false
		
        if not builderUpgradesTo or self.BlueprintID != builderUpgradesTo then

            if EntityCategoryContains( STRUCTURE, self ) then
			
                builder:ForkThread( builder.CheckFractionComplete, self ) 
				
            end

            -- this section is rebuild bonus check 2, it also requires the above IF statement to work OK [159]
            if builder.VerifyRebuildBonus then
			
                builder.VerifyRebuildBonus = nil
				
                self:ForkThread( self.CheckRebuildBonus )  # [159]
				
            end
			
        end	
		
    end,

    GetRebuildBonus = function(self, rebuildUnitBP)

        -- here 'self' is the engineer building the structure
        self.InitialFractionComplete = CBFP_oldUnit.GetRebuildBonus(self, rebuildUnitBP)
        self.VerifyRebuildBonus = true
		
        return self.InitialFractionComplete
		
    end,

    CheckFractionComplete = function(self, unitBeingBuilt, threadCount)
	
        -- rebuild bonus check 1 [159]
        -- This code checks if the unit is allowed to be accelerate-built. If not the unit is destroyed (for lack 
        -- of a SetFractionComplete() function). Added by brute51
        local fraction = GetFractionComplete(unitBeingBuilt)
		
        if fraction > (self.InitialFractionComplete or 0) then
		
            unitBeingBuilt:OnRebuildBonusIsIllegal()
			
        end
		
        self.InitialFractionComplete = nil
		
    end,

    CheckRebuildBonus = function(self)
	
        -- this section is rebuild bonus check 2 [159]
        -- This code checks if the unit is allowed to be accelerate-built. If not the unit is destroyed (for lack 
        -- of a SetFractionComplete() function). Added by brute51
        if GetFractionComplete(self) > 0 then
		
            local cb = function(bpUnitId)
			
                if self.BlueprintID == bpUnitId then 
				
                    self:OnRebuildBonusIsLegal()
					
                end
				
            end
			
            RRBC( self:GetPosition(), cb)
			
            self.RebuildBonusIllegalThread = self:ForkThread( function(self) WaitTicks(1) self:OnRebuildBonusIsIllegal() end )
			
        end
		
    end,

    OnRebuildBonusIsLegal = function(self)
	
        -- rebuild bonus check 2 [159]
        -- this doesn't always run. In fact, in most of the time it doesn't.
        if self.RebuildBonusIllegalThread then
		
            KillThread(self.RebuildBonusIllegalThread)
			
        end
		
    end,

    OnRebuildBonusIsIllegal = function(self)
        
        -- rebuild bonus check 1 and 2 [159]
        -- this doesn't always run. In fact, in most of the time it doesn't.
		-- self:Destroy()
    end,

    CheckUnitRestrictions = function(self)
        -- added by brute51 - to make sure stuff that shouldn't be available (unit restriction) can't be built [157]
        -- in this statement GetFractionComplete() is used to filter nukes building a missile or ACU upgrading (and
        -- probably more). Those situations bug out otherwise.
        if Game.UnitRestricted(self) and IsUnit(self) and GetFractionComplete(self) != 1 then
		
                -- I need a way to cancel a build command. Ordering the unit to stop works but it's a mickey mouse 
                -- workaround, not a real fix. Fortunately only AI players and cheating players (those using an UI 
                -- mod that shows restricted unit icons) are affected by this. And the AI doesn't have build 
                -- queues anyway so it's ok cancelling the orders (I hope!)
                -- If someone from GPG reads this: a better fix is to call CheckBuildRestriction() in the unit class
                -- each time a new build/upgrade command is given internally, to any unit. Right now that function
                -- is only used for command units (ACU or SCU) and only when they build, not when they assist
                -- an upgrade of a unit.
            self:Destroy()
			
        end
		
    end,
	
    UnitBuiltPercentageCallbackThread = function(self, percent, callback)
	
		local WaitTicks = WaitTicks
        local GetHealthPercent = self.GetHealthPercent

        while not self.Dead and GetHealthPercent(self) < percent do
		
            WaitTicks(12)
			
        end
		
        local aiBrain = GetAIBrain(self)
		
        for k,v in aiBrain.UnitBuiltTriggerList do
		
            if v.Callback == callback then
			
                callback(self)
                aiBrain.UnitBuiltTriggerList[k] = nil
				
            end
			
        end
		
    end,

	-- just a note - this function always reports the builder that originally began construction
	-- of the unit - even if that unit is not involved at the completion of the build
	-- if the original builder is dead - then no builder is reported
    OnStopBeingBuilt = function(self, builder, layer)
        
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." OnStopBeingBuilt for "..ALLBPS[self.BlueprintID].Description.." on tick "..GetGameTick() )
        end
		
		local bp = ALLBPS[self.BlueprintID]

		self:SetupIntel(bp)
	
		-- This is here to catch those units EXCEPT Factories and SubCommanders that might have enhancements
		-- by specifying the Sequence of enhancements we can invoke them on individual units
		if bp.Enhancements then
			
			if bp.Enhancements.Sequence then

                local aiBrain = GetAIBrain(self)
			
				if aiBrain.BrainType != 'Human' and not ( EntityCategoryContains( FACTORY, self ) or EntityCategoryContains( SUBCOMMANDER, self )) then
					
					if not self.EnhancementsComplete then
					
						if not self.EnhanceThread then
						
							self.EnhanceThread = self:ForkThread( import('/lua/ai/aibehaviors.lua').FactorySelfEnhanceThread, aiBrain.FactionIndex, aiBrain)
							
						end
						
					end	
					
				end
				
			end
			
		end
		
		-- this confused me for a bit because I couldn't understand how something could NOT have a builder
		-- but then I realized that some units 'create' others, rather than build them, and when a unit is
		-- spawned, rather than built, it has no builder (ie. - a unit created with the console)
		if builder then
		
			self:ForkThread( self.StopBeingBuiltEffects, builder, layer )
			
			-- buildings upgrading set this so we want the upgraded building to have the same health % as the builder
			-- this doesn't apply to mobile builders or factories since they are constructing new units
			-- upgrades are NOT new units
			if self.DisallowCollisions then
        
                local GetHealthPercent = builder.GetHealthPercent
			
				SetHealth( self, self, (GetHealthPercent(builder) or 1) * bp.Defense.MaxHealth )
                
				self.DisallowCollisions = false
			end
            
		end

        if not self.OnBeingBuiltEffectsBag[1] then
            self.OnBeingBuiltEffectsBag = nil
        end        
		
		if bp.Defense.LifeTime then
			self:ForkThread( self.LifeTimeThread, bp.Defense.Lifetime )
		end
		
        if bp.SizeSphere then
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere )
        end
        
        if bp.Audio.DoneBeingBuilt then
            PlaySound( self, bp.Audio.DoneBeingBuilt )
        end

        -- Checks for satellite allowances
        if categories.SATELLITEUPLINK then

            if EntityCategoryContains(categories.SATELLITEUPLINK + categories.SATELLITEWITHNOPARENTALSUPERVISION, self) then
                self:ForkThread( function() WaitTicks(1) self:OnSatelliteCapacityChange() end )
            end

        end
	
		--self:PlayUnitAmbientSound( 'ActiveLoop' )

		self:HideLandBones()
		
		self:DoUnitCallbacks('OnStopBeingBuilt')

		if bp.Defense.Shield.ShieldSize > 0 then

			if bp.Defense.Shield.StartOn != false then
			
				if bp.Defense.Shield.PersonalShield == true then
				
					self:CreatePersonalShield()
					
				elseif bp.Defense.Shield.AntiArtilleryShield then
				
					self:CreateAntiArtilleryShield()
					
				else
				
					self:CreateShield()
				end
			end
		end

		if bp.Display.AnimationPermOpen then
		
			self.PermOpenAnimManipulator = CreateAnimator(self)
            
            PlayAnim( self.PermOpenAnimManipulator, bp.Display.AnimationPermOpen )
            
			TrashAdd( self.Trash,self.PermOpenAnimManipulator)
		end

		-- Initialize movement effects subsystems, idle effects, beam exhaust, and footfall manipulators
		if bp.Display.MovementEffects then
		
			local bpTable = bp.Display.MovementEffects
        
			if bpTable.Land or bpTable.Seabed or bpTable.Air or bpTable.Water or bpTable.Sub or bpTable.BeamExhaust then

				self.MovementEffectsExist = true
			
				if bpTable.BeamExhaust and (bpTable.BeamExhaust.Idle != false) then
				
					self:UpdateBeamExhaust( 'Idle' )
				end
			
				if not self.Footfalls and bpTable[layer].Footfall then
				
					self.Footfalls = self:CreateFootFallManipulators( bpTable[layer].Footfall )
                end
			end
		end
		
		if ScenarioInfo.BOU_Installed then
			-- support BO:U Phased units 
			self.EXPhaseShieldPercentage = nil
			self.EXPhaseEnabled = nil
			self.EXTeleportCooldownCharge = nil
			self.EXPhaseCharge = nil
        end
		
		self:ForkThread(self.CloakEffectControlThread, bp)

		return bp	-- so we can reply with the blueprint --
		
    end,

    StartBeingBuiltEffects = function(self, builder, layer)
	
		local BuildMeshBp = ALLBPS[self.BlueprintID].Display.BuildMeshBlueprint
		
		if BuildMeshBp then
		
			SetMesh( self, BuildMeshBp, true)
		end
    end,

    -- this caught me by surprise as it is delayed 18 ticks for Aeon units
    StopBeingBuiltEffects = function(self, builder, layer)
	
        local bp = ALLBPS[self.BlueprintID].Display
		
        local useTerrainType = false
		
        if bp then
		
            if bp.TerrainMeshes then
			
                local bpTM = bp.TerrainMeshes
                local pos = self:GetPosition()
                local terrainType = GetTerrainType( pos[1], pos[3] )
				
                if bpTM[terrainType.Style] then
				
                    SetMesh( self, bpTM[terrainType.Style], true)
                    useTerrainType = true
                end
            end
			
            if not useTerrainType then
			
                SetMesh( self, bp.MeshBlueprint, true)
                self.CloakEffectEnabled = nil
            end
			
			-- added so that cloak effects are re-applied if unit was already cloaked
			if self.InCloakField or self:IsIntelEnabled('Cloak') then
			
				self.CloakEffectEnabled = nil
				self:UpdateCloakEffect(bp)
			end
        end
		
		if self.OnBeingBuiltEffectsBag then
		
			TrashDestroy(self.OnBeingBuiltEffectsBag)
			self.OnBeingBuiltEffectsBag = nil
		end
		
    end,

    OnFailedToBeBuilt = function(self)
	
        self:Destroy()
		
    end,
    
    OnSiloBuildStart = function(self, weapon)
	
        self.SiloWeapon = weapon
        self.SiloProjectile = weapon:GetProjectileBlueprint()
		
    end,
    
    OnSiloBuildEnd = function(self, weapon)
	
        self.SiloWeapon = nil
        self.SiloProjectile = nil
		
    end,

    SetupBuildBones = function(self)
	
        local bp = ALLBPS[self.BlueprintID]
		
        if not bp.General.BuildBones or
           not bp.General.BuildBones.YawBone or
           not bp.General.BuildBones.PitchBone or
           not bp.General.BuildBones.AimBone then
		   
           return
		   
        end
		
        -- Syntactical reference:
        -- CreateBuilderArmController(unit,turretBone, [barrelBone], [aimBone])
        -- BuilderArmManipulator:SetAimingArc(minHeading, maxHeading, headingMaxSlew, minPitch, maxPitch, pitchMaxSlew)
        self.BuildArmManipulator = CreateBuilderArmController(self, bp.General.BuildBones.YawBone or 0 , bp.General.BuildBones.PitchBone or 0, bp.General.BuildBones.AimBone or 0)
		
        self.BuildArmManipulator:SetAimingArc(-180, 180, 360, -90, 90, 360)
        self.BuildArmManipulator:SetPrecedence(5)
		
        if self.BuildingOpenAnimManip and self.BuildArmManipulator then
		
            self.BuildArmManipulator:Disable()
        end
		
        TrashAdd( self.Trash,self.BuildArmManipulator)
		
    end,

    BuildManipulatorSetEnabled = function(self, enable)
	
        if self.Dead or not self.BuildArmManipulator then return end
		
        if enable then
		
            self.BuildArmManipulator:Enable()
			
        else
		
            self.BuildArmManipulator:Disable()
			
        end
		
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." OnStartBuild for "..repr(order).." building "..repr(unitBeingBuilt.BlueprintID).." on tick "..GetGameTick() )
        end

        self:UpdateConsumptionValues()

		if order == 'Repair' and unitBeingBuilt.WorkItem != self.WorkItem then
			self:InheritWork(unitBeingBuilt)
		end
		
        local bp = ALLBPS[self.BlueprintID]
        
        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
            self:StartBuildingEffects(unitBeingBuilt, order)
        end

        if self.EventCallbacks.OnStartBuild then    
            self:DoOnStartBuildCallbacks(unitBeingBuilt)
        end
		
        self:SetActiveConsumptionActive()
        
        if bp.Audio['Construct'] then
            self:PlayUnitSound('Construct')
        end
		
        if order == 'Upgrade' and unitBeingBuilt.BlueprintID == bp.General.UpgradesTo then
            unitBeingBuilt.DisallowCollisions = true
        end
        
        if ALLBPS[unitBeingBuilt.BlueprintID].Physics.FlattenSkirt and unitBeingBuilt.CreateTarmac and not unitBeingBuilt.TarmacBag then
          
            if order != 'Repair' then
                unitBeingBuilt:CreateTarmac(true, true, true, false, false)
            end
        end
		
        self.CurrentBuildOrder = order
        
    end,

    OnStopBuild = function(self, unitBeingBuilt)
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." OnStopBuild for "..repr(unitBeingBuilt.BlueprintID).." on tick "..GetGameTick() )
        end

        self:DoOnUnitBuiltCallbacks(unitBeingBuilt)
    
        if self.BuildEffectsBag then
            TrashDestroy(self.BuildEffectsBag)
        end

        self:SetActiveConsumptionInactive()
	
        self:StopUnitAmbientSound('ConstructLoop')
        
        self:PlayUnitSound('ConstructStop')
        
        self.CurrentBuildOrder = false
    end,

    GetUnitBeingBuilt = function(self)
	
        return self.UnitBeingBuilt
		
    end,

    OnFailedToBuild = function(self)
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." OnFailedToBuild on tick "..GetGameTick() )
        end
 
        self:DoOnFailedToBuildCallbacks()
        self:SetActiveConsumptionInactive()
 		
    end,

    OnPrepareArmToBuild = function(self)
    end,

    StartBuildingEffects = function(self, unitBeingBuilt, order)
    
        if not self.BuildEffectsBag then
            self.BuildEffectsBag = TrashBag()
        end
	
        TrashAdd( self.BuildEffectsBag, self:ForkThread( self.CreateBuildEffects, unitBeingBuilt, order ) )
		
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
    end,

    StopBuildingEffects = function(self, unitBeingBuilt)
    
        if self.BuildEffectsBag then
            TrashDestroy(self.BuildEffectsBag)
        end
		
    end,

    -- Setup the initial intel of the unit.  Return true if it can, false if it can't.
	-- this will set all intel types to OFF except for vision
    SetupIntel = function(self,bp)

        local bp = bp.Intel or ALLBPS[self.BlueprintID].Intel
		
        if bp then
		
			self:EnableIntel('Vision')
			
            self.IntelDisables = {
                Radar = 1,
                Sonar = 1,
                Omni = 1,
                RadarStealth = 1,
                SonarStealth = 1,
                RadarStealthField = 1,
                SonarStealthField = 1,
                Cloak = 1,
                CloakField = 1,
                Spoof = 1,
                Jammer = 1,
            }
			
            self:EnableUnitIntel(nil)

        end
    end,

    DisableUnitIntel = function(self, intel)
		
        if self.Dead or not self.IntelDisables then return end

		local DisableIntel = EntityMethods.DisableIntel
		
		-- just some notes in here - the conditions for the intel flags are simple
		-- 0 means the intel is ON
		-- 1 means the intel is OFF
		
        if intel then

            if self.IntelDisables[intel] == 0 then

				self.IntelDisables[intel] = 1

				self:DisableIntel(intel)

                self:OnIntelDisabled(intel)
			end
			
        else
		
            for k, v in self.IntelDisables do

                self.IntelDisables[k] =  1

                if self.IntelDisables[k] == 0 then

					self.IntelDisables[k] = 1

                    self:DisableIntel(k)

                    self:OnIntelDisabled(k)
                end
				
            end
			
        end
		
    end,

    EnableUnitIntel = function(self, intel)

		if not self.Dead then
		
			local EnableIntel   = EntityMethods.EnableIntel
            local CacheLayer    = self.CacheLayer
			
			if CacheLayer == 'Seabed' or CacheLayer == 'Sub' or CacheLayer == 'Water' then
			
				EnableIntel(self,'WaterVision')
				
				if CacheLayer == 'Seabed' then
				
					self:DisableIntel('Vision')
					
				end
				
			end
			
			-- if an intel type and the intel table is ready
			-- since this will fire before intel table is setup
			if self.IntelDisables then
			
				-- used to enable a specific intel
				if intel then
			
					if self.IntelDisables[intel] == 1 then

						EnableIntel(self,intel)

						self.IntelDisables[intel] = 0						

                        self:OnIntelEnabled(intel)
					end

				else
				
					-- loop thru all intel types and try to turn them on
					for k, v in self.IntelDisables do
				
						if v == 1 then
		
							EnableIntel(self,k)

							if self:IsIntelEnabled(k) then

								self.IntelDisables[k] = 0
                                
                                self:OnIntelEnabled(k)
							end
							
						end
						
					end
					
				end
				
			end
			
			if not ALLBPS[self.BlueprintID].Intel.FreeIntel then
			
				if self.IntelThread then
				
					KillThread(self.IntelThread)
					
					self.IntelThread = nil
				end
				
				if not self.IntelThread then
				
					self.IntelThread = self:ForkThread(self.IntelWatchThread)
					
				end
				
			end  
			
		end
		
    end,

	-- modified for BO:U cloaking credit to Black Ops team
    OnIntelEnabled = function(self,intel)
	
		if not self.Dead and intel == 'Cloak' then
			self:UpdateCloakEffect()
		end
		
    end,

    OnIntelDisabled = function(self,intel)
	
		if not self.Dead and intel == 'Cloak' then
			self:UpdateCloakEffect()
		end
		
    end,

    IntelWatchThread = function(self)
	
		local aiBrain = GetAIBrain(self)
		
        local bp = ALLBPS[self.BlueprintID]
	
		local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetScriptBit = UnitMethods.GetScriptBit
		local IsIntelEnabled = EntityMethods.IsIntelEnabled
		local TestToggleCaps = UnitMethods.TestToggleCaps
        
		local WaitTicks = WaitTicks
        
        WaitTicks(2)
		
		local bpVal = self:GetConsumptionPerSecondEnergy()
        
		local intelTypeTbl = {'Radar','Sonar','Omni','RadarStealthField','SonarStealthField','CloakField','Jammer','Cloak','Spoof','RadarStealth','SonarStealth'}

		-- incorporated this function for speed
		local function ShouldWatchIntel(self, consumption)
		
			if not self.Dead then
			
				-- do we actually have any intel features turned on
				if consumption > 0 then

					for k,v in intelTypeTbl do
					
						if IsIntelEnabled(self,v) then

							return true
						end
					end
				end
			end
			
			return false
		end

        local recharge = bp.Intel.ReactivateTime or 20
		
		recharge = 1 + (recharge * 10)	-- convert to ticks from seconds

        while ShouldWatchIntel(self, bpVal) and not self.Dead do
		
            WaitTicks(21)
			
            if GetEconomyStored( aiBrain, 'ENERGY' ) < bpVal and not self.Dead then
				
				local a,b,c

				if TestToggleCaps(self,'RULEUTC_StealthToggle') then
				
					if not GetScriptBit(self,'RULEUTC_StealthToggle') then
					
						a = true
						
						self:SetScriptBit('RULEUTC_StealthToggle', true)
					end
				end
				
				if TestToggleCaps(self,'RULEUTC_CloakToggle') then
				
					-- if cloak bit is false (=On) remember that and turn off cloak
					if not GetScriptBit(self,'RULEUTC_CloakToggle') then
					
						b = true
						
						self:SetScriptBit('RULEUTC_CloakToggle', true)
					end
				end
				
				if TestToggleCaps(self,'RULEUTC_IntelToggle') then

					if not GetScriptBit(self,'RULEUTC_IntelToggle') then
					
						c = true
						
						self:SetScriptBit('RULEUTC_IntelToggle', true)
                    end
				end

				-- we wait here until there is enough power to turn back on
				-- checking every recharge period
				while GetEconomyStored( aiBrain, 'ENERGY' ) < bpVal and not self.Dead do

					WaitTicks(recharge + 1)
				end
				
				-- if stealth was On - turn it back on
				if a then
				
					self:SetScriptBit('RULEUTC_StealthToggle', false)
				end
				
				-- if cloak was On - turn it back on
				if b then
				
					self:SetScriptBit('RULEUTC_CloakToggle', false)
				end
				
				-- if intel (Everything) was on - turn it back on
				if c then
				
					self:SetScriptBit('RULEUTC_IntelToggle', false)
				end
				
            end 

			bpVal = self:GetConsumptionPerSecondEnergy()
        end
    end,

    InheritWork = function(self, target)
	
        self.WorkItem = target.WorkItem
		
    end,

    ClearWork = function(self)
	
        self.WorkItem = nil
        self.WorkItemBuildCostEnergy = nil
        self.WorkItemBuildCostMass = nil
        self.WorkItemBuildTime = nil
		
    end,

    OnWorkBegin = function(self, work)
	
        local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(self.EntityID)
        local tempEnhanceBp = ALLBPS[self.BlueprintID].Enhancements[work]

        if tempEnhanceBp.Prerequisite then
		
            if unitEnhancements[tempEnhanceBp.Slot] != tempEnhanceBp.Prerequisite then
			
                LOG("*AI DEBUG "..GetAIBrain(self).Nickname.." enhancement "..repr(work).." does not have the proper prereq "..repr(tempEnhanceBp.Prerequisite) )
                return false	-- should we be forking to OnWorkFail at this point ?
				
            end
			
        elseif unitEnhancements[tempEnhanceBp.Slot] then
		
			LOG("*AI DEBUG "..GetAIBrain(self).Nickname.." "..ALLBPS[self.BlueprintID].Description.." "..repr(work).." Slot required is " .. tempEnhanceBp.Slot )
			
            --error('*ERROR: "..self.Brain.Nickname.." enhancement '..repr(work)..' does not have the proper slot available!', 2)
            return false	-- as above, to OnWorkFail ?
			
        end
        
        if ScenarioInfo.ACUEnhanceDialog then
            LOG("*AI DEBUG "..GetAIBrain(self).Nickname.." doing enhancement "..repr(tempEnhanceBp.Name))
        end

        -- seems to support the UI and progress bar
        self.WorkItem = tempEnhanceBp
        self.WorkItemBuildCostEnergy = tempEnhanceBp.BuildCostEnergy
        self.WorkItemBuildCostMass = tempEnhanceBp.BuildCostMass
        self.WorkItemBuildTime = tempEnhanceBp.BuildTime
        self.WorkProgress = 0
		
        self:SetActiveConsumptionActive()
		
        self:UpdateConsumptionValues()
		
        self:CreateEnhancementEffects(work)

        self:PlayUnitSound('EnhanceStart')
		
        self:PlayUnitAmbientSound('EnhanceLoop')
		
        LOUDSTATE(self,self.WorkingState)
		
    end,

    OnWorkEnd = function(self, work)
	
        self:SetActiveConsumptionInactive()
      
        self:PlayUnitSound('EnhanceEnd')
		
        self:StopUnitAmbientSound('EnhanceLoop')
        
        self:ClearWork()
  		
        self:CleanupEnhancementEffects()
		
    end,

    OnWorkFail = function(self, work)
	
        self:SetActiveConsumptionInactive()
		
        self:PlayUnitSound('EnhanceFail')
		
        self:StopUnitAmbientSound('EnhanceLoop')
		
        self:ClearWork()
		
        self:CleanupEnhancementEffects()
		
    end,

    CreateEnhancement = function(self, enh)

        local bp = ALLBPS[self.BlueprintID].Enhancements[enh]
		
        if not bp then
		
            error('*ERROR: Got CreateEnhancement call with an enhancement that doesnt exist in the blueprint.', 2)
            return false
			
        end
		
        if bp.ShowBones then
		
            for k, v in bp.ShowBones do
			
                if IsValidBone(self,v) then
				
                    self:ShowBone(v, true)
					
                end
				
            end
			
        end
		
        if bp.HideBones then
		
            for k, v in bp.HideBones do
			
                if IsValidBone(self,v) then
				
                    HideBone(self,v, true)
					
                end
				
            end
			
        end
		
        AddUnitEnhancement(self, enh, bp.Slot or '')
		
        if bp.RemoveEnhancements then
		
            for k, v in bp.RemoveEnhancements do
			
                RemoveUnitEnhancement(self, v)
				
            end
			
        end
		
        RequestRefreshUI(self)
		
    end,

    CreateEnhancementEffects = function( self, enhancement )
    
        local bp = ALLBPS[self.BlueprintID].Enhancements[enhancement]
        
        if bp.UpgradeEffectBones then
        
            for k, v in bp.UpgradeEffectBones do
            
                if IsValidBone(self,v) then
                
                    if not self.UpgradeEffectsBag then
					
                        self.UpgradeEffectsBag = TrashBag()
						
                    end
                    
                    EffectUtilities.CreateEnhancementEffectAtBone(self, v, self.UpgradeEffectsBag )
					
                end
				
            end
			
        end
        
        if bp.UpgradeUnitAmbientBones then
        
            for k, v in bp.UpgradeUnitAmbientBones do
            
                if IsValidBone(self,v) then
                
                    if not self.UpgradeEffectsBag then
					
                        self.UpgradeEffectsBag = TrashBag()
						
                    end
                
                    EffectUtilities.CreateEnhancementUnitAmbient(self, v, self.UpgradeEffectsBag )
					
                end
				
            end
			
        end
		
    end,

    CleanupEnhancementEffects = function( self )
	
		if self.UpgradeEffectsBag then
		
			TrashDestroy(self.UpgradeEffectsBag)
			self.UpgradeEffectsBag = nil
			
		end
		
    end,

    HasEnhancement = function(self, enh)
	
        local unitEnh = SimUnitEnhancements[self.EntityID]
		
        if unitEnh then
		
            for k,v in unitEnh do
			
                if v == enh then
				
                    return true
					
                end
				
            end
			
        end
		
        return false
		
    end,

    GetTerrainTypeEffects = function( FxType, layer, pos, type, typesuffix )
	
        local TerrainType

        -- Get terrain type mapped to local position and if none defined use default
        if type then
		
            TerrainType = GetTerrainType( pos[1], pos[3] )
			
        else
		
            TerrainType = GetTerrainType( -1, -1 )
            type = 'Default'
			
        end

        -- Add in type suffix to type mask name
        if typesuffix then
		
            type = type .. typesuffix
			
        end

        -- If our current masking is empty try and get the default layer effect
        if TerrainType[FxType][layer][type] == nil then
		
			TerrainType = GetTerrainType( -1, -1 )
			
		end
		
        return TerrainType[FxType][layer][type] or false
		
    end,

    CreateTerrainTypeEffects = function( self, effectTypeGroups, FxBlockType, FxBlockKey, TypeSuffix, EffectBag, TerrainType )
	
		-- if simspeed drops too low suspend terrain effects --
		if Sync.SimData.SimSpeed < 0 then return end

        local GetTerrainTypeEffects = self.GetTerrainTypeEffects
        local LOUDINSERT = LOUDINSERT
        
        local Army      = self.Army
        local Position  = self:GetPosition()

        for _, vTypeGroup in effectTypeGroups do
		
	        local effects = {}
		
            if TerrainType then
			
                effects = TerrainType[FxBlockType][FxBlockKey][vTypeGroup.Type] or false
				
            else
			
                effects = GetTerrainTypeEffects( FxBlockType, FxBlockKey, Position, vTypeGroup.Type, TypeSuffix )
            end
            
            --LOG("*AI DEBUG CreateTerrainEffects for "..repr(FxBlockType).." "..repr(FxBlockKey).." "..repr(vTypeGroup).." in bag "..repr(EffectBag).." Effects are "..repr(effects) )

			if effects then
            
                local emit
                
                if EffectBag and not self[EffectBag] then
                    self[EffectBag] = {}
                end
			
				for _, vBone in vTypeGroup.Bones do
				
					for _, vEffect in effects do

						emit = LOUDATTACHEMITTER( self, vBone, Army, vEffect ):ScaleEmitter(vTypeGroup.Scale or 1)

						if vTypeGroup.Offset then
							emit:OffsetEmitter(vTypeGroup.Offset[1] or 0, vTypeGroup.Offset[2] or 0,vTypeGroup.Offset[3] or 0)
						end
                        
                        if EffectBag then
							LOUDINSERT( self[EffectBag], emit )
						end
					end
				end
                
                --LOG("*AI DEBUG EffectBag "..repr(EffectBag).." after create terrain effect is "..repr(self[EffectBag]))
			end
        end
		
    end,

    CreateIdleEffects = function( self )
	
		-- if simspeed drops too low suspend idle effects --
		if Sync.SimData.SimSpeed < 0 then return end
		
        local bpTable = ALLBPS[self.BlueprintID].Display.IdleEffects
		
		-- if there are idle effects -- many dont have them
		if bpTable then

			if bpTable[self.CacheLayer].Effects then
    
                --LOG("*AI DEBUG Create Idle Effect for "..repr(self.CacheLayer) )
			
				if not self.IdleEffectsBag then
					self.IdleEffectsBag = {}
				end
			
				self:CreateTerrainTypeEffects( bpTable[self.CacheLayer].Effects, 'FXIdle', self.CacheLayer, nil, 'IdleEffectsBag' )
			end
		end
		
    end,

    DestroyIdleEffects = function( self )
		CleanupEffectBag(self,'IdleEffectsBag')
    end,

    UpdateBeamExhaust = function( self, motionState )
	
		-- if simspeed drops too low suspend beamexhaust effects --
		if Sync.SimData.SimSpeed < 0 then return end

        local bpTable = ALLBPS[self.BlueprintID].Display.MovementEffects.BeamExhaust
		
        if not bpTable then
		
            return false
			
        end

        if motionState == 'Idle' then
		
            if self.BeamExhaustCruise  then
			
                self:DestroyBeamExhaust()
				
            end
			
            if self.BeamExhaustIdle and (bpTable.Idle != false) then
			
                self:CreateBeamExhaust( bpTable, self.BeamExhaustIdle )
				
            end
			
        elseif motionState == 'Cruise' then
		
            if self.BeamExhaustIdle and self.BeamExhaustCruise then
			
                self:DestroyBeamExhaust()
				
            end
			
            if self.BeamExhaustCruise and (bpTable.Cruise != false) then
			
                self:CreateBeamExhaust( bpTable, self.BeamExhaustCruise )
				
            end
			
        elseif motionState == 'Landed' then
		
            if not bpTable.Landed then
			
                self:DestroyBeamExhaust()
				
            end
        end
    end,

    CreateBeamExhaust = function( self, bpTable, beamBP )
	
        local army = self.Army
        local EffectBones = bpTable.Bones
        local LOUDINSERT = LOUDINSERT

		if not self.BeamExhaustEffectsBag then
			self.BeamExhaustEffectsBag = {}
		end
		
        for _, vb in EffectBones do
            LOUDINSERT( self.BeamExhaustEffectsBag, CreateBeamEmitterOnEntity(self, vb, army, beamBP ))
        end
		
    end,

    DestroyBeamExhaust = function( self )
        CleanupEffectBag(self,'BeamExhaustEffectsBag')
    end,

    MovementCameraShakeThread = function( self, camShake )
	
        local radius = camShake.Radius or 5.0
        local maxShakeEpicenter = camShake.MaxShakeEpicenter or 1.0
        local minShakeAtRadius = camShake.MinShakeAtRadius or 0.0
        local interval = camShake.Interval or 10.0
		
        if interval != 0.0 then
		
            while true do
			
                self:ShakeCamera( radius, maxShakeEpicenter, minShakeAtRadius, interval )
				
                WaitTicks(interval*10)
				
            end
			
        end
		
    end,

    GetWeaponClass = function(self, label)
	
        return self.Weapons[label] or import('/lua/sim/Weapon.lua').Weapon
		
    end,

    -- Return the total time in seconds, cost in energy, and cost in mass to build the given target type.
    GetBuildCosts = function(self, target_bp)

        return GetConstructEconomyModel(self, target_bp.Economy)
		
    end,

    -- Return the total time in seconds, cost in energy, and cost in mass to reclaim the given target from 100%.
    -- The energy and mass costs will normally be negative, to indicate that you gain mass/energy back.
    GetReclaimCosts = function(self, target_entity)

        local buildrate = GetBuildRate(self)
        local time, energy, mass
		
        if IsUnit(target_entity) then

            local target_bp = target_entity:GetBlueprint()
            
            energy = target_bp.Economy.BuildCostEnergy
            mass = target_bp.Economy.BuildCostMass

            local etime = (energy / buildrate) * .1
            local mtime = mass / buildrate

            time = LOUDMAX( mtime, etime, .1 ) * (self.ReclaimTimeMultiplier or 1)

            --if not self.Reclaiming then
              --  LOG("*AI DEBUG Unit reclaim values are -- Time "..time.." -- E "..energy.." -- M "..mass.." -- buildpower "..buildrate.." -- ReclaimTimeMultiplier is "..(self.ReclaimTimeMultiplier or 1) )			
            --end
            
            -- convert to per-tick cost -- and reflect that it's negative
            energy = (energy/time) * .1
            mass = (mass/time) * .1
        
            --self.Reclaiming = true

            return time, energy, mass
			
        elseif IsProp(target_entity) then
		
            -- this will report full time (in seconds) of the reclaim --
            time, energy, mass =  target_entity:GetReclaimCosts(self, buildrate)
            
            --LOG("*AI DEBUG Prop reclaim values are -- Time "..time.." -- E "..energy.." -- M "..mass.." -- buildpower "..buildrate )
            
            return time, energy, mass
			
        end
		
    end,

    -- Return the Bonus Build Multiplier for the target we are re-building if we are trying to rebuild the same
    -- structure that was destroyed earlier.
    GetRebuildBonus = function(self, rebuildUnitBP)
	
        -- for now everything is re-built is 50% complete to begin with
        return 0.5
		
    end,

    SetCaptureTimeMultiplier = function(self, time_mult)
	
        self.CaptureTimeMultiplier = time_mult
		
    end,

    GetHealthPercent = function(self)
	
        return GetHealth(self) / ALLBPS[self.BlueprintID].Defense.MaxHealth
		
    end,

    ValidateBone = function(self, bone)
	
        if IsValidBone(self,bone) then
            return true
        end
		
        error('*ERROR: Trying to use the bone, ' .. bone .. ' on unit ' .. self.BlueprintID .. ' and it does not exist in the model.', 2)
		
        return false
    end,

    CheckBuildRestriction = function(self, target_bp)

        if self:CanBuild(target_bp.BlueprintId) then
		
            return true
		end
		
        return false
    end,

    PlayUnitSound = function(self, sound)
		
        local bp = ALLBPS[self.BlueprintID].Audio[sound] or false

        if bp then
            PlaySound( self, bp )
        end

    end,

    PlayUnitAmbientSound = function(self, sound)
--[[	
        local bp = GetBlueprint(self)
        local id = bp.BlueprintId
		
        if not bp.Audio[sound] then return end
		
        if not self.AmbientSounds then
            self.AmbientSounds = {}
        end
		
        if not self.AmbientSounds[sound] then
            local sndEnt = Entity {}
            self.AmbientSounds[sound] = sndEnt
            TrashAdd( self.Trash,sndEnt)
            sndEnt:AttachTo(self,-1)
        end
        self.AmbientSounds[sound]:SetAmbientSound( bp.Audio[sound], nil )
--]]
    end,

    StopUnitAmbientSound = function(self, sound)
--[[
        if not self.AmbientSounds then
			return
		end
        if not self.AmbientSounds[sound] then
			return
		end
		
        self.AmbientSounds[sound]:SetAmbientSound(nil, nil)
        self.AmbientSounds[sound]:Destroy()
        self.AmbientSounds[sound] = nil
--]]		
    end,

    AddUnitCallback = function(self, fn, cbtype)
	
		if not self.EventCallbacks[cbtype] then
		
			self.EventCallbacks[cbtype] = {}
		end
	
        LOUDINSERT( self.EventCallbacks[cbtype], fn )
    end,
    
    DoUnitCallbacks = function(self, cbtype, param)
	
		if self.EventCallbacks[cbtype] then

			for num,cb in self.EventCallbacks[cbtype] do
		
				if cb then
			
					cb( self, param )
				end
			end
		end
		
    end,

    AddProjectileDamagedCallback = function( self, fn )
	
        LOUDINSERT( self.EventCallbacks.ProjectileDamaged, fn )
		
    end,

    AddOnCapturedCallback = function(self, cbOldUnit, cbNewUnit)
	
        if cbOldUnit then
		
            self:AddUnitCallback( cbOldUnit, 'OnCaptured' )
        end
		
        if cbNewUnit then
		
            self:AddUnitCallback( cbNewUnit, 'OnCapturedNewUnit' )
        end
		
    end,
    
    AddOnStartBuildCallback = function(self, fn, category)
	
		if not self.EventCallbacks.OnStartBuild then
        
			self.EventCallbacks.OnStartBuild = {}
		end
		
        LOUDINSERT(self.EventCallbacks.OnStartBuild, { CallbackFunction = fn, Category = category } )
    end,
    
    DoOnStartBuildCallbacks = function(self, unit)
	
		if self.EventCallbacks.OnStartBuild then
	
			for k,v in self.EventCallbacks.OnStartBuild do
		
				if v and unit and (not unit.Dead) and LOUDENTITY(v.Category, unit) then
			
					v.CallbackFunction(self, unit)
				end
			end
		end
		
    end,

    DoOnFailedToBuildCallbacks = function(self)
	
        if self.EventCallbacks.OnFailedToBuild then
		
            for k, cb in self.EventCallbacks.OnFailedToBuild do
			
                if cb then
				
                    cb(self)
                end
            end
        end
		
    end,

    AddOnUnitBuiltCallback = function(self, fn, category)
	
		if not self.EventCallbacks.OnUnitBuilt then
		
			self.EventCallbacks.OnUnitBuilt = {}
		end
	
        LOUDINSERT(self.EventCallbacks.OnUnitBuilt, { CallBackFunction = fn, Category = category } )
    end,

    DoOnUnitBuiltCallbacks = function(self, unit)

        if self.EventCallbacks.OnUnitBuilt then
		
            for k, v in self.EventCallbacks.OnUnitBuilt do
			
                if v and unit and (not unit.Dead) and LOUDENTITY(v.Category, unit) then
				
                    --Function will call back with both the unit's and the unit being built's handle
                    v.CallBackFunction(self, unit)
                end
            end
        end
		
    end,

    RemoveCallback = function(self, fn)
	
        --EventCallbacks has "SpecialToggle(Enable/Disable)Function" booleans in it so skip over those.
        for k, v in self.EventCallbacks do
		
            if type(v) == "table" then
			
                for kcb, vcb in v do
				
                    if vcb == fn then
                        LOG("*AI DEBUG Removing Callback "..repr(vcb))
                        v[kcb] = nil
                    end
                end
            end
        end
        
    end,

    AddOnDamagedCallback = function(self, fn, amount, repeatNum)
 
        local num = amount or -1
		
        repeatNum = repeatNum or 1
		
		if not self.EventCallbacks.OnDamaged then
		
			self.EventCallbacks.OnDamaged =  {}
		end
		
        LOUDINSERT(self.EventCallbacks.OnDamaged, {Func=fn, Amount=num, Called=0, Repeat=repeatNum})
    end,

    DoOnDamagedCallbacks = function(self, instigator)
	
        if self.EventCallbacks.OnDamaged then
		
            for num, callback in self.EventCallbacks.OnDamaged do
			
                if (callback.Called < callback.Repeat or callback.Repeat == -1) and ( callback.Amount == -1 or (1 - self:GetHealthPercent() > callback.Amount) ) then
				
                    callback.Called = callback.Called + 1
                    callback.Func(self, instigator)
                end
            end
        end
		
    end,

    DoOnHealthChangedCallbacks = function(self, newHP, oldHP) 	-- use normal add callback function

        local type = 'OnHealthChanged'
		
        if ( self.EventCallbacks[type] ) then
		
            for num,cb in self.EventCallbacks[type] do
			
                if cb then
				
                    cb( self, newHP, oldHP )
                end
            end
        end
		
    end,

    AddOnMLammoIncreaseCallback = function(self, fn) 	-- specialized cause this starts the ammo check thread
	
        if not fn then
            error('*ERROR: Tried to add a callback type - OnTMLAmmoIncrease with a nil function')
        else
            LOUDINSERT( self.EventCallbacks.OnTMLAmmoIncrease, fn )
            LOUDINSERT( self.EventCallbacks.OnTMLAmmoDecrease, fn )
        end
		
        if not self.MLAmmoCheckThread then
            self.MLAmmoCheckThread = self:ForkThread(self.CheckCountedMissileAmmo)
        end
		
    end,

    AddOnTimedEventCallback = function(self, fn, interval, passData) 
	
        -- specialized because this starts a timed even thread (interval = secs between events, passData can be
        -- anything, is passed to callback when event is fired)
        if not fn then
		
            error('*ERROR: Tried to add a callback type - OnTimedEvent with a nil function')
            return
        end
		
		if not self.EventCallbacks.OnTimedEvent then
		
			self.EventCallbacks.OnTimedEvent = {}
		end
		
        LOUDINSERT( self.EventCallbacks.OnTimedEvent, {fn = fn, interval = interval} )
		
        self:ForkThread(self.TimedEventThread, interval, passData)
    end,

    DoOnTimedEventCallbacks = function(self, interval, passData)
	
        local type = 'OnTimedEvent'
		
        if ( self.EventCallbacks[type] ) then
		
            for num,cb in self.EventCallbacks[type] do
			
                if cb and cb['fn'] and cb['interval'] == interval then
				
                    cb['fn']( self, passData )
                end
            end
        end
		
    end,

    IdleState = State {
	
        Main = function(self)
        end,
		
    },

    DeadState = State {
	
        Main = function(self)
			self = nil
        end,
		
    },

    WorkingState = State {
	
        Main = function(self)
		
			self:OnCmdrUpgradeStart()
			
            while self.WorkProgress < 1 and not self.Dead do
                WaitTicks(2)
            end
			
        end,

        OnWorkEnd = function(self, work)
		
            self:SetActiveConsumptionInactive()
			
            AddUnitEnhancement(self, work)
			
            self:CleanupEnhancementEffects(work)
            self:CreateEnhancement(work)
            
            self.WorkItem = nil
            self.WorkProgress = nil
            
            self:PlayUnitSound('EnhanceEnd')

            self:EnableDefaultToggleCaps()
			
			self:OnCmdrUpgradeFinished()
			
            LOUDSTATE(self, self.IdleState)
        end,
		
    },
    
    -- This function should be used for kills made through the script, since kills through the engine (projectiles etc...) are already counted.
    AddKills = function(self, numKills)
	
        -- Add the kills, then check veterancy junk.
        local unitKills = GetStat( self, 'KILLS', 0).Value + numKills
		
        SetStat( self, 'KILLS', unitKills)
        
        local vet = ALLBPS[self.BlueprintID].Veteran or Game.VeteranDefault
        
        local vetLevels = table.getsize(vet)
		
        if self.VeteranLevel == vetLevels then
		
            return
        end

        local nextLvl = (self.VeteranLevel or 0) + 1
        local nextKills = vet[('Level' .. nextLvl)]
        
        -- check if we gained more than one level
        while unitKills >= nextKills and (self.VeteranLevel or 0) < vetLevels do
		
            self:SetVeteranLevel(nextLvl)
            
            nextLvl = (self.VeteranLevel or 0) + 1
            nextKills = vet[('Level' .. nextLvl)]

        end 
		
    end,

    -- use this to go through the AddKills function rather than directly setting veterancy
    SetVeterancy = function(self, veteranLevel)
	
        veteranLevel = veteranLevel or 5
		
        if veteranLevel == 0 or veteranLevel > 5 then
		
            return
        end
		
        local bp = ALLBPS[self.BlueprintID]
		
        if bp.Veteran['Level'..veteranLevel] then
		
            self:AddKills(bp.Veteran['Level'..veteranLevel])
			
        elseif import('/lua/game.lua').VeteranDefault['Level'..veteranLevel] then
		
            self:AddKills(import('/lua/game.lua').VeteranDefault['Level'..veteranLevel])
			
        else
		
            error('Invalid veteran level - ' .. veteranLevel)
			
        end 
		
    end, 

    -- Return the current vet level
    GetVeteranLevel = function(self)
	
        return (self.VeteranLevel or 0)
		
    end,

    -- Check if we should veteran up.
    CheckVeteranLevel = function(self)
	
        local bp = ALLBPS[self.BlueprintID].Veteran or Game.VeteranDefault or false
		
        if (not bp) or not bp[('Level'..(self.VeteranLevel or 0) + 1)] then
            return
        end
		
		local brain = GetAIBrain(self)
		
        if GetStat( self, 'KILLS', 0).Value >= bp[('Level' .. (self.VeteranLevel or 0) + 1)] * ( 1.0 / (brain.VeterancyMult or 1.0) ) then

            self:SetVeteranLevel((self.VeteranLevel or 0) + 1)
			
			-- unit cap is increased by the veteran level * veterancy multiplier (derived from AI cheat)
			SetArmyUnitCap( brain.ArmyIndex, GetArmyUnitCap(brain.ArmyIndex) + ( (self.VeteranLevel or 0) * (brain.VeterancyMult or 1.0) ))
        end
		
    end,

    -- Set the veteran level to the level specified
    SetVeteranLevel = function(self, level)
		
        self.VeteranLevel = level
		
        -- Get the units override buffs if they exist
        local bp = ALLBPS[self.BlueprintID].Buffs
		
        -- the default veterancy buffs
        local buffTypes = { 'Regen', 'Health', 'VisionRadius' }
		
        for k,bType in buffTypes do
		
			-- if the unit doesn't have an override buff use the defaults
			if not bp[bType] then
			
				ApplyBuff( self, 'Veterancy' .. bType .. level )
			end
        end
		
        -- Check for unit buffs
        if bp then
		
            for bType,bData in bp do
			
                for lName,lValue in bData do
				
                    if lName == 'Level'..level then
					
                        -- Generate a buffname based on the data
                        local buffName = self:CreateVeterancyBuff( lName, lValue, bType, level )
						
                        if buffName then
						
							ApplyBuff( self, buffName )
                        end
                    end
                end
            end
        end
		
        self:DoUnitCallbacks('OnVeteran')
		
    end,
    

	CreateVeterancyBuff = function(self, levelName, levelValue, buffType)
	
        if buffType == 'MaxHealthAffectHealth' then
		
            return false
			
        end

		if buffType == 'Damage' then
		
            return false
			
        end
    
        -- Make sure there is an appropriate buff type for this unit
        if not self.BuffTypes[buffType] then
		
            WARN('*WARNING: Tried to generate a buff of unknown type to units: ' .. buffType .. ' - UnitId: ' .. self.BlueprintID )
			
            return nil
			
        end
        
        -- Generate a buffname based on the unitId
        local buffName = self.BlueprintID .. levelName .. buffType
        
        -- Figure out what we want the Add and Mult values to be based on the BuffTypes table
        local addVal = 0
        local multVal = 1
		
        if self.BuffTypes[buffType].BuffValFunction == 'Add' then 
		
            addVal = levelValue
			
        else
		
            multVal = levelValue
			
        end
        
        -- Create the buff if needed
        if not Buffs[buffName] then
		
			
            BuffBlueprint {
			
                Name = buffName,
				
                DisplayName = buffName,
				
                BuffType = self.BuffTypes[buffType].BuffType,
				
                Stacks = self.BuffTypes[buffType].BuffStacks,
				
                Duration = self.BuffTypes[buffType].BuffDuration,
				
                Affects = { [buffType] = { Add = addVal, Mult = multVal } },
				
            }
        end
        
        -- Return the buffname so the buff can be applied to the unit
        return buffName
		
    end,	

    PlayVeteranFx = function(self, newLvl)
	
        LOUDATTACHEMITTER(self, 0, self.Army, 'destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(1)
		
    end,

    CreateShield = function(self, shieldSpec)
	
        local bp = ALLBPS[self.BlueprintID]
		
        local bpShield = shieldSpec or bp.Defense.Shield
		
        if bpShield then
		
            self:DestroyShield()
			
            self.MyShield = Shield {
                Owner                               = self,
				Mesh                                = bpShield.Mesh or '',
				MeshZ                               = bpShield.MeshZ or '',
				ImpactMesh                          = bpShield.ImpactMesh or '',
				ImpactEffects                       = bpShield.ImpactEffects or '',    
                Size                                = bpShield.ShieldSize or 10,
                ShieldMaxHealth                     = bpShield.ShieldMaxHealth or 250,
                ShieldRechargeTime                  = bpShield.ShieldRechargeTime or 10,
                ShieldEnergyDrainRechargeTime       = bpShield.ShieldEnergyDrainRechargeTime or 10,
                ShieldVerticalOffset                = bpShield.ShieldVerticalOffset or -1,
                ShieldRegenRate                     = bpShield.ShieldRegenRate or 1,
                ShieldRegenStartTime                = bpShield.ShieldRegenStartTime or 5,
                PassOverkillDamage                  = bpShield.PassOverkillDamage or false,
            }
			
			self.MyShieldType = 'Shield'
			
            self:SetFocusEntity( self.MyShield )
			
            self:EnableShield()
			
            TrashAdd( self.Trash, self.MyShield )

        end
		
    end,

    CreatePersonalShield = function(self, shieldSpec)
	
        local bp = ALLBPS[self.BlueprintID]
		
        local bpShield = shieldSpec or bp.Defense.Shield
		
        if bpShield then
		
            self:DestroyShield()
			
            if bpShield.OwnerShieldMesh then
			
                self.MyShield = UnitShield {
                    Owner = self,
					ImpactEffects                   = bpShield.ImpactEffects or '',                     
                    CollisionSizeX                  = bp.SizeX * 0.55 or 1,
                    CollisionSizeY                  = bp.SizeY * 0.55 or 1,
                    CollisionSizeZ                  = bp.SizeZ * 0.55 or 1,
                    CollisionCenterX                = bp.CollisionOffsetX or 0,
                    CollisionCenterY                = bp.CollisionOffsetY or 0,
                    CollisionCenterZ                = bp.CollisionOffsetZ or 0,
                    OwnerShieldMesh                 = bpShield.OwnerShieldMesh,
                    ShieldMaxHealth                 = bpShield.ShieldMaxHealth or 250,
                    ShieldRechargeTime              = bpShield.ShieldRechargeTime or 10,
                    ShieldEnergyDrainRechargeTime   = bpShield.ShieldEnergyDrainRechargeTime or 10,
                    ShieldRegenRate                 = bpShield.ShieldRegenRate or 1,
                    ShieldRegenStartTime            = bpShield.ShieldRegenStartTime or 5,
                    PassOverkillDamage              = bpShield.PassOverkillDamage != false, -- force to true
                }
				
				self.MyShieldType = 'Personal'
				
                self:SetFocusEntity(self.MyShield)
				
                self:EnableShield()
				
                TrashAdd( self.Trash,self.MyShield)
				
            else
			
                LOG('*WARNING: TRYING TO CREATE PERSONAL SHIELD ON UNIT ',repr(self.BlueprintID),', but it does not have an OwnerShieldMesh=<meshBpName> defined in the Blueprint.')
				
            end
			
        end
		
    end,

    CreateAntiArtilleryShield = function(self, shieldSpec)
	
        local bp = ALLBPS[self.BlueprintID]
		
        local bpShield = shieldSpec or bp.Defense.Shield
	
        if bpShield then
		
            self:DestroyShield()
			
            self.MyShield = AntiArtilleryShield {
                Owner                               = self,
				Mesh                                = bpShield.Mesh or '',
				MeshZ                               = bpShield.MeshZ or '',
				ImpactMesh                          = bpShield.ImpactMesh or '',
				ImpactEffects                       = bpShield.ImpactEffects or '',                
                Size                                = bpShield.ShieldSize or 10,
                ShieldMaxHealth                     = bpShield.ShieldMaxHealth or 250,
                ShieldRechargeTime                  = bpShield.ShieldRechargeTime or 10,
                ShieldEnergyDrainRechargeTime       = bpShield.ShieldEnergyDrainRechargeTime or 10,
                ShieldVerticalOffset                = bpShield.ShieldVerticalOffset or -1,
                ShieldRegenRate                     = bpShield.ShieldRegenRate or 1,
                ShieldRegenStartTime                = bpShield.ShieldRegenStartTime or 5,
                PassOverkillDamage                  = bpShield.PassOverkillDamage or false,
            }
			
			self.MyShieldType = 'AntiArtilleryShield'
			
            self:SetFocusEntity(self.MyShield)
			
            self:EnableShield()
			
            TrashAdd( self.Trash,self.MyShield)
			
        end
		
    end,

	CreateDomeHunkerShield = function(self, shieldSpec)
	
        local bp = ALLBPS[self.BlueprintID]
		
        local bpShield = shieldSpec or bp.Defense.Shield

        if bpShield then
		
            self:DestroyHunkerShield()
			
            self.MyHunkerShield = DomeHunkerShield {
                Owner                               = self,
				Mesh                                = bpShield.Mesh,
				MeshZ                               = bpShield.MeshZ,
				ImpactMesh                          = bpShield.ImpactMesh,
				ImpactEffects                       = bpShield.ImpactEffects,				
                Size                                = bpShield.ShieldSize or 10,
                ShieldMaxHealth                     = bpShield.ShieldMaxHealth or 250,
                ShieldRechargeTime                  = bpShield.ShieldRechargeTime or 10,
                ShieldEnergyDrainRechargeTime       = bpShield.ShieldEnergyDrainRechargeTime or 20,
                ShieldVerticalOffset                = bpShield.ShieldVerticalOffset or -1,
                ShieldRegenRate                     = bpShield.ShieldRegenRate or 1,
                ShieldRegenStartTime                = bpShield.ShieldRegenStartTime or 5,
				PassOverkillDamage                  = bpShield.PassOverkillDamage or false,
            }
			
			self.MyShieldType = 'HunkerShield'
			
            self:SetFocusEntity(self.MyHunkerShield)
			
            self:EnableShield()
			
            TrashAdd( self.Trash,self.MyHunkerShield)

        end
		
    end,

	CreatePersonalHunkerShield = function(self, shieldSpec)
	
        local bp = ALLBPS[self.BlueprintID]
		
        local bpShield = shieldSpec or bp.Defense.Shield
		
        if bpShield then
		
            self:DestroyHunkerShield()
			
            if bpShield.OwnerShieldMesh then
			
                self.MyHunkerShield = PersonalHunkerShield {
                    Owner                           = self,
                    CollisionSizeX                  = bp.SizeX * 0.75 or 1,
                    CollisionSizeY                  = bp.SizeY * 0.75 or 1,
                    CollisionSizeZ                  = bp.SizeZ * 0.75 or 1,
                    CollisionCenterX                = bp.CollisionOffsetX or 0,
                    CollisionCenterY                = bp.CollisionOffsetY or 0,
                    CollisionCenterZ                = bp.CollisionOffsetZ or 0,
                    OwnerShieldMesh                 = bpShield.OwnerShieldMesh,
					ImpactEffects                   = 'UEFShieldHit01',
                    ShieldMaxHealth                 = bpShield.ShieldMaxHealth or 250,
                    ShieldRechargeTime              = bpShield.ShieldRechargeTime or 10,
                    ShieldEnergyDrainRechargeTime   = bpShield.ShieldEnergyDrainRechargeTime or 20,
                    ShieldRegenRate                 = bpShield.ShieldRegenRate or 1,
                    ShieldRegenStartTime            = bpShield.ShieldRegenStartTime or 5,
					PassOverkillDamage              = bpShield.PassOverkillDamage != false,     --- force to true
                }
				
				self.MyShieldType = 'HunkerPersonal'				
				
				self:SetFocusEntity(self.MyHunkerShield)
				
                self:EnableShield()
				
                TrashAdd( self.Trash,self.MyHunkerShield)
        
                GetStat( self,'SHIELDHP', 0 )
                GetStat( self,'SHIELDREGEN', 0 )
  
                SetStat(self,'SHIELDHP', bpShield.ShieldMaxHealth )
                SetStat(self,'SHIELDREGEN', bpShield.ShieldRegenRate)

            else
                LOG('*WARNING: TRYING TO CREATE HUNKER SHIELD ON UNIT ',repr(self.BlueprintID),', but it does not have an OwnerShieldMesh=<meshBpName> defined in the Blueprint.')
            end
			
        end
		
    end,

	-- all credit to BrewLAN
    CreateProjectedShield = function(self, shieldSpec)
    
        shieldSpec = shieldSpec or ALLBPS.sab4401.Defense.TargetShield

        if shieldSpec then

            local bp = ALLBPS[self.BpId] or self:GetBlueprint()
            
            local size = LOUDMAX(bp.Footprint.SizeX or 0, bp.Footprint.SizeZ or 0, bp.SizeX or 0, bp.SizeX or 0, bp.SizeY or 0, bp.SizeZ or 0, bp.Physics.MeshExtentsX or 0, bp.Physics.MeshExtentsY or 0, bp.Physics.MeshExtentsZ or 0) * 1.414

            --LOG("*AI DEBUG Creating Projected Shield on "..bp.Description)
            
            self:DestroyShield()
            
            self.MyShield = ProjectedShield ({
                Owner                           = self,
                Mesh                            = shieldSpec.Mesh or '',
                MeshZ                           = shieldSpec.MeshZ or '',
                ImpactMesh                      = shieldSpec.ImpactMesh or '',
                ImpactEffects                   = shieldSpec.ImpactEffects or '',
                Size                            = size,
                ShieldSize                      = size,
                ShieldMaxHealth                 = shieldSpec.ShieldMaxHealth or 250,
                ShieldRechargeTime              = shieldSpec.ShieldRechargeTime or 10,
                ShieldEnergyDrainRechargeTime   = shieldSpec.ShieldEnergyDrainRechargeTime or 10,
                ShieldVerticalOffset            = bp.CollisionOffsetY or 0,
                ShieldRegenRate                 = shieldSpec.ShieldRegenRate or 1,
                ShieldRegenStartTime            = shieldSpec.ShieldRegenStartTime or 5,
                PassOverkillDamage              = shieldSpec.PassOverkillDamage != false,   --- force to true
            }, self)
            
            if not EntityCategoryContains( categories.FACTORY, self ) then
            
                self:SetFocusEntity(self.MyShield)
            
                self:EnableShield()
                
            end
            
            TrashAdd( self.Trash, self.MyShield)
        end
    end,

    OnShieldEnabled = function(self)

        if self.ShieldEffects then
            
            if not self.ShieldEffectsBag then
                self.ShieldEffectsBag = {}
            end
            
            for k,v in self.ShieldEffects do
                LOUDINSERT(self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, self:GetArmy(), v ))
            end
        end
	
        self:SetMaintenanceConsumptionActive()
		
    end,

    OnShieldDisabled = function(self)
    
        if self.ShieldEffectsBag then
            
            for k,v in self.ShieldEffectsBag do
                v:Destroy()
            end
            
            self.ShieldEffectsBag = {}
        end

        self:SetMaintenanceConsumptionInactive()
		
    end,

    EnableShield = function(self)
	
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
		
        if self.MyShield then
		
            self.MyShield:TurnOn()
			
        end
		
    end,

    DisableShield = function(self)
	
        self:SetScriptBit('RULEUTC_ShieldToggle', false)
		
        if self.MyShield then
		
            self.MyShield:TurnOff()
			
        end
		
    end,

    DestroyShield = function(self)
	
        if self.MyShield then

            self.MyShield:Destroy()
            self.MyShield = nil
			self.MyShieldType = nil
			
        end
		
    end,
	
	DestroyHunkerShield = function(self)
	
        if self.MyHunkerShield then
		
            self:ClearFocusEntity()
            self.MyHunkerShield:Destroy()
            self.MyHunkerShield = nil
			self.MyShieldType = nil
			
        end
    end,


    ShieldIsOn = function(self)
	
        if self.MyShield then
		
            return self.MyShield:IsOn()
			
        end
		
        return false
		
    end,
	
	GetShieldRegenRate = function(self)
	
		if self.MyShield then
		
			return self.MyShield.RegenRate
			
		end
		
		return 0
		
	end,

    OnShieldIsUp = function(self)

        if ScenarioInfo.ShieldDialog then
            LOG("*AI DEBUG OnShieldIsUp")
        end

        self:DoUnitCallbacks('OnShieldIsUp')
		
    end,

	OnShieldIsDown = function(self)

        if ScenarioInfo.ShieldDialog then
            LOG("*AI DEBUG OnShieldIsDown")
        end
	
        self:DoUnitCallbacks('OnShieldIsDown')
		
	end,

    OnShieldIsCharging = function(self)

        if ScenarioInfo.ShieldDialog then
            LOG("*AI DEBUG OnShieldIsCharging")
        end
	
        self:DoUnitCallbacks('OnShieldIsCharging')
		
    end,

    MarkWeaponsOnTransport = function(self, unit, transport)
	
        -- Mark the weapons on a transport
        if unit then
		
            for i = 1, GetWeaponCount(unit) do
			
                local wep = GetWeapon(unit,i) or false

				if wep then
					wep.SetOnTransport( wep, transport )
				end
            end
        end
		
    end,
    
	-- issued by the Transport as a unit loads on
    OnTransportAttach = function(self, attachBone, unit)

        --LOG("*AI DEBUG UNIT "..self.Sync.id.." attaches unit "..unit.Sync.id.." "..repr(unit.PlatoonHandle.BuilderName).." on tick "..GetGameTick() )

        self:MarkWeaponsOnTransport(unit, true)
		
        if unit.MyShield and unit.MyShield:IsOn() then

            unit:DisableShield()
            unit:DisableDefaultToggleCaps()
        end
		
		unit:SetDoNotTarget(true)
        unit:SetCanTakeDamage(false)
		
        if not LOUDENTITY(categories.PODSTAGINGPLATFORM, self) then
            self:RequestRefreshUI()
        end

        unit:DoUnitCallbacks( 'OnAttachedToTransport', self )
		
        self:DoUnitCallbacks('OnTransportAttach', unit )
		
    end,

	-- issued by the Transport as units are detached
    OnTransportDetach = function(self, attachBone, unit)

        --LOG("*AI DEBUG UNIT "..self.Sync.id.." detaches unit "..unit.Sync.id.." "..repr(unit.PlatoonHandle.BuilderName).." on tick "..GetGameTick() )
		
        unit:TransportAnimation(-1)
		
		unit:SetDoNotTarget(false)
        unit:SetCanTakeDamage(true)
		
		if (not unit.Dead) and unit.MyShield and not unit.MyShield:IsOn() then
        
            --LOG("*AI DEBUG Unit "..unit.EntityID.." "..unit.BlueprintID.." says shield is "..repr( unit.MyShield:IsOn() ) )

            unit:EnableShield()
            unit:EnableDefaultToggleCaps()

		end

        if not LOUDENTITY(categories.PODSTAGINGPLATFORM, self) then
            self:RequestRefreshUI()
        end

        self:MarkWeaponsOnTransport(unit, false)

        unit:DoUnitCallbacks( 'OnDetachedToTransport', self)
		
        self:DoUnitCallbacks('OnTransportDetach', unit )
		
    end,

    OnAddToStorage = function(self, unit)
		
        if LOUDENTITY(categories.CARRIER, unit) then

            if LOUDENTITY(categories.TRANSPORTFOCUS, self) then

                -- detach any attached units
                -- transport units cannot carry loaded units into storage
                self:TransportDetachAllUnits(true)
            end   

            self:MarkWeaponsOnTransport(self, true)
			
            HideBone(self,0, true)
			
            self:SetCanTakeDamage(false)
            self:SetReclaimable(false)
            self:SetCapturable(false)

        end
		
    end,

    OnRemoveFromStorage = function(self, unit)

        if LOUDENTITY(categories.CARRIER, unit) then
		
            self:SetCapturable(true)
            self:SetReclaimable(true)
            self:SetCanTakeDamage(true)

            self:ShowBone(0, true)

            self:MarkWeaponsOnTransport(self, false)
			
        end
		
    end,
	
	-- issued when a unit tries to start a teleport
    OnTeleportUnit = function(self, teleporter, location, orientation)
	
        local mybrain = GetAIBrain(self)

        self.teleported = false
	
        if not self.teleporting then
            LOG("*AI DEBUG "..mybrain.Nickname.." OnTeleportUnit "..repr(self.BlueprintID).." to location "..repr(location).." on tick "..GetGameTick() )
            self.teleporting = true
        else 
            LOG("*AI DEBUG "..mybrain.Nickname.." OnTelportUnit FAILS for "..repr(self.BlueprintID).." to location "..repr(location).." - teleport already in progress")
            return
        end

		local bp = ALLBPS[self.BlueprintID]
        
		-- Range Check to location
        -- in this respect maxrange is the optimal range - you can go any distance
        -- but as you will see, the costs explode if you do.
		local teleRange = bp.Defense.MaxTeleRange or 375
        
		local myposition = self:GetPosition()
		local destRange = VDist2(location[1], location[3], myposition[1], myposition[3])
		
        -- Economy Check and Initial Charge
		local telecost = bp.Economy.TeleportBurstEnergyCost or 4000
	
        local storedenergy = mybrain:GetEconomyStored('ENERGY')
		
		if telecost > 0 and not self.TeleportCostPaid then
		
			if storedenergy >= telecost then
			
				mybrain:TakeResource('ENERGY', telecost)
                
                -- this initial charge is only used if a teleport is successful
                -- so that if it fails you don't pay twice
                self.TeleportCostPaid = true
				
			else
			
				FloatingEntityText(self.EntityID,'Insufficient Energy Storage ('..telecost..')' )

                --LOG("*AI DEBUG OnTeleportUnit "..repr(self.BlueprintID).." to location "..repr(location).." - failed - Insufficient energy - "..repr(telecost).." required to initialize a teleport - storage "..repr(storedenergy) )
                
                self.teleporting = nil
                
				return
				
			end
			
		end
		
		-- stop any existing teleportation
        if self.TeleportDrain then
		
            RemoveEconomyEvent( self, self.TeleportDrain)
            self.TeleportDrain = nil
			
        end
		
        if self.TeleportThread then
		
            KillThread(self.TeleportThread)
            self.TeleportThread = nil
			
        end
		
        EffectUtilities.CleanupTeleportChargeEffects(self)
        
        --LOG("*AI DEBUG OnTeleportUnit "..repr(self.BlueprintID).." Teleport process begins")
        
		-- start teleportation sequence --
        self.TeleportThread = self:ForkThread(self.InitiateTeleportThread, teleporter, bp, location, destRange, teleRange, orientation, telecost)
		
    end,
	
	-- Like PlayTeleportChargeEffects, but scaled based on the size of the unit
	-- After calling this, you should still call CleanupTeleportChargeEffects
	PlayScaledTeleportChargeEffects = function(self)
	
		local army = self.Army
		local bp = ALLBPS[self.BlueprintID]

		local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
		local yOffset = (bp.Physics.MeshExtentsY or bp.SizeY or 1) / 2
		
		self.TeleportChargeBag = { }
		
		for k, v in EffectTemplate.GenericTeleportCharge01 do
		
			local fx = CreateEmitterAtEntity(self, army, v):OffsetEmitter(0, yOffset, 0):ScaleEmitter(scaleFactor)
			
			TrashAdd( self.Trash,fx)
			
			LOUDINSERT(self.TeleportChargeBag, fx)
		end
		
	end,
	
	-- Like PlayTeleportOutEffects, but scaled based on the size of the unit 
	PlayScaledTeleportOutEffects = function(self)
	
		local army = self.Army
		local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
		
		for k, v in EffectTemplate.GenericTeleportOut01 do
		
			CreateEmitterAtEntity(self, army, v):ScaleEmitter(scaleFactor)
		end
		
	end,
	
	-- Like PlayTeleportInEffects, but scaled based on the size of the unit
	PlayScaledTeleportInEffects = function(self, scaleoverride)
	
		local army = self.Army
		local bp = ALLBPS[self.BlueprintID]
		local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
		
		local yOffset = (bp.Physics.MeshExtentsY or bp.SizeY or 1) / 2
		
		for k, v in EffectTemplate.GenericTeleportIn01 do
		
			CreateEmitterAtEntity(self, army, v):OffsetEmitter(0, yOffset, 0):ScaleEmitter(scaleoverride or scaleFactor)
		end
		
	end,	
	
	CleanupTeleportChargeEffects = function(self)
	
		EffectUtilities.CleanupTeleportChargeEffects(self)
	end,

    OnFailedTeleport = function(self)

        LOG("*AI DEBUG OnFailedTeleport "..repr(self.BlueprintID))
        
        if not self.Dead and self.TeleportDrain then
		
            RemoveEconomyEvent( self, self.TeleportDrain)
			
            self.TeleportDrain = nil
        end
		
        if self.TeleportThread then
		
            KillThread(self.TeleportThread)
            self.TeleportThread = nil
        end
		
        --self:StopUnitAmbientSound('TeleportLoop')
		
        EffectUtilities.CleanupTeleportChargeEffects(self)
		
        self:SetWorkProgress(0.0)
        self:SetImmobile(false)
        
        -- clear the teleport in process flag
        self.UnitBeingTeleported = nil
        -- clear the teleport requested flag
        self.teleporting = nil
        -- set teleported flag
        self.teleported = false
		
		-- from BO:U
		if not self.Dead and self.EXPhaseEnabled then   
		
			self.EXPhaseEnabled = nil
			self.EXPhaseCharge = 0
			self.EXPhaseShieldPercentage = 0
			
			local bp = ALLBPS[self.BlueprintID]
			local bpDisplay = bp.Display
			
			if self.EXPhaseCharge == 0 then
			
				SetMesh( self, bpDisplay.MeshBlueprint, true )
			end
        end
		
    end,

    UpdateTeleportProgress = function(self, progress)
	
        self:SetWorkProgress(progress)
    end,

    InitiateTeleportThread = function(self, teleporter, bp, location, teledistance, teleRange, orientation, telecostpaid)
    
        local TeleportDialog = false

        if TeleportDialog then
            LOG("*AI DEBUG Initiate Teleport Thread begins on tick "..GetGameTick() )
        end	

        self:OnTeleportCharging(location)
	
        local tbp = ALLBPS[teleporter.BlueprintID]
		
        self.UnitBeingTeleported = self
        
        self:SetImmobile(true)
        
        self:PlayUnitSound('GateCharge')

        local rangemod = 1
        local teleportenergy = 0
        local teleporttime = 0
		
        if bp.Economy then
		
			-- calc a resource cost value based on both mass and energy
            local mass = bp.Economy.BuildCostMass * LOUDMIN(.15, bp.Economy.TeleportMassMod or 0.15)		-- ie. 18000 mass becomes 2700

            local energy = bp.Economy.BuildCostEnergy * LOUDMIN(.08, bp.Economy.TeleportEnergyMod or 0.08)	-- ei. 5m Energy becomes 400,000

            -- remove the initial E charge already paid
            energy = LOUDMAX( 0, energy - telecostpaid)
            
            teleportenergy = mass + energy

            if teledistance <= teleRange then
                rangemod = ( math.max( .33, teledistance/teleRange ) * math.max( .33, teledistance/teleRange ) )
                teleportenergy = teleportenergy * rangemod
            else
                rangemod = 1.1 + (3.14 * ((teledistance - teleRange)/teleRange))
                teleportenergy = teleportenergy * rangemod
            end
            
            local buildrate = teleporter:GetBuildRate()
            
            if TeleportDialog then
                LOG("*AI DEBUG Teleport dist "..teledistance.." -- optimal range is "..teleRange.." range adjust is "..rangemod.." E required is "..teleportenergy )
            end
            -- time is now based on how much energy this unit can channel per second -- channeled flow = buildrate * 10
            -- this tapers nicely with the mass of the unit, since although lesser builders can flow as much energy - the energy required of smaller units is much less.
            -- powerful builders (SACU) can teleport very quickly
            -- minimum teleport time of 12 and the recovery time is 24 + the teleport time 

            teleporttime = math.max( 12, ( teleportenergy / (buildrate * 10) ))

            if TeleportDialog then
                LOG('*AI DEBUG Teleport charge time = '..repr(teleporttime).."  will be using "..repr(teleportenergy/teleporttime).."E per second" )
                LOG('*AI DEBUG Teleport cooldown time is '..(24 + math.floor(teleporttime)).." ticks")
			end
        end
        
        self:SetMaintenanceConsumptionInactive()

        if TeleportDialog then
            LOG("*AI DEBUG Initiate Teleport Thread creating "..repr(teleporttime).." second drain on tick "..GetGameTick() )
        end	

        self.TeleportDrain = CreateEconomyEvent(self, teleportenergy or 10000, 0, teleporttime or 15, self.UpdateTeleportProgress)

        -- teleport charge effect
        EffectUtilities.PlayTeleportChargeEffects(self)

        WaitFor( self.TeleportDrain  ) 		-- Perform fancy Teleportation FX here

        self:SetMaintenanceConsumptionActive()        
        
        if self.TeleportDrain then
		
            RemoveEconomyEvent(self, self.TeleportDrain )
			
            self.TeleportDrain = nil
        end

		FloatingEntityText(self.EntityID,'Starting Cooldown..')

        EffectUtilities.PlayTeleportOutEffects(self)

        EffectUtilities.CleanupTeleportChargeEffects(self)

        WaitTicks(1)

        self:SetWorkProgress(0.0)
    
        local TeleportLocationBlocked   = import('/lua/loudutilities.lua').TeleportLocationBlocked
    
        if TeleportLocationBlocked( self, location ) then

            FloatingEntityText(self.EntityID,'Teleport Destination Scrambled')

            LOG("*AI DEBUG OnTeleportUnit "..repr(self.BlueprintID).." to location "..repr(location).." - failed - blocked ")

		else
	        
            Warp(self, location, orientation)

            self:OnTeleported(location)        
        end
		
        EffectUtilities.PlayTeleportInEffects(self)

        WaitTicks( 24 + math.floor(teleporttime) ) 	-- Perform cooldown Teleportation FX here

		FloatingEntityText(self.EntityID,'Cooldown complete..')        

        self:PlayUnitSound('TeleportEnd')
        
        self:SetImmobile(false)

        self.UnitBeingTeleported = nil
        
        self.TeleportThread = nil
        
        self.teleporting = nil
        
        self.teleported = true
        
        self.TeleportCostPaid = nil

    end,
	
    OnTeleportCharging = function(self, location)
        self:DoUnitCallbacks('OnTeleportCharging', location)
    end,

    OnTeleported = function(self, location)
        self:DoUnitCallbacks('OnTeleported', self, location)
    end,
	
	--  Summary  :  SHIELD Scripts required for drone spawned bubble shields.
	--  Copyright � 2010 4DC  All rights reserved.
    SpawnDomeShield = function(self) 
	
		LOG("*AI DEBUG SpawnDomeShield")
	
        if not self.Dead then    
		
            -- Get units bp 
            local bp = ALLBPS[self.BlueprintID]
            
            -- Initialize variables 
            local sldArea, offSet, sldHealth            
            local x, y, z = self:GetUnitSizes()   
            
            self.XzySize = {}      
            
            LOUDINSERT(self.XzySize, x)
            LOUDINSERT(self.XzySize, y)   
            LOUDINSERT(self.XzySize, z)                                       
            table.sort(self.XzySize)
			
            --LOG('Table: ', self.XzySize[3])
			
            -- Get the surface area of a Rectangle 2(L*W+L*H+W*H)       
           --# sldArea = ((bp.SizeX * bp.SizeZ) + (bp.SizeX * bp.SizeY) + (bp.SizeZ * bp.SizeY )) * 1.8     
           --# sldArea = ((bp.SizeX * bp.SizeZ) + (bp.SizeX * bp.SizeY) + (bp.SizeZ * bp.SizeY )) * 1.412                 
           
            sldArea = 1.25 * (self.XzySize[3] * 1.4142) -- diagonal of a square
            
            offSet = bp.SizeY * 0.5 -- need to figure the distance the units main bone is above the ground and apply this as the offset, plus 1/2 the Y axis.        
            
            --LOG('BP Sizes X Y Z: ', bp.SizeX, bp.SizeY, bp.SizeZ)
            --LOG('Unit Sizes X Y Z: ', x, y, z)

            --LOG('SLD AREA1: ', sldArea)           
            -- Rescale the shield if sizes get ridiculous
            --if sldArea <= 5 then
            --    offSet = bp.SizeY or 1            
            --#elseif sldArea > 5 and sldArea < 10 then
            --#    sldArea = sldArea * 0.75
            --#    offSet = bp.SizeY or 0.75 
            --#elseif sldArea > 10 and sldArea < 20 then
            --#    sldArea = sldArea * 0.5
            --#    offSet = bp.SizeY or 0.5                 
            --#elseif sldArea > 20 then
            --#    sldArea = sldArea * 0.25
            --#    offSet = bp.SizeY or 0.25                               
            --#end   
            
            --# LOG('SLD AREA2: ', sldArea)
            -- Sets the bubble shields hitpoints 
            if table.find(bp.Categories ,'EXPERIMENTAL') then                 
			
                if self:GetMaxHealth() * 0.1 >= 1000 then 
				
                    sldHealth = self:GetMaxHealth() * 0.1
					
                else
				
                    sldHealth = 5000
					
                end 
				
            else
			
                sldHealth = 2000
				
            end
			
            -- Adjust the energy cost to match the shield strength 
            local eCost = 10 * (sldHealth / 1000)
			
            self:SetMaintenanceConsumptionInactive() 
            self:SetEnergyMaintenanceConsumptionOverride(eCost) 
            
            SetConsumptionPerSecondEnergy( self, eCost)             

            -- Adds the shield toggle to the shielded unit 
            self:AddToggleCap('RULEUTC_ShieldToggle') 
            
            -- Remove the old shield if any 
            if self.MyShield then
			
                self:DestroyShield()                                            
				
            end

            -- Create the shield on the unit 
            self.MyShield = Shield { 
                Owner = self,       
                Mesh = '/effects/entities/AeonShield01/AeonShield01_mesh',                                        
                MeshZ = '/effects/entities/Shield01/Shield01z_mesh',                            
                ImpactMesh = '/effects/entities/ShieldSection01/ShieldSection01_mesh',                        
                ImpactEffects = 'AeonShieldHit01',                                 
                Size = sldArea,                                
                ShieldMaxHealth = sldHealth,
                ShieldRechargeTime = 10,
                ShieldEnergyDrainRechargeTime = 10,
                ShieldVerticalOffset = -offSet * 0.706,                 
                ShieldRegenRate = sldHealth * 0.025,
                ShieldRegenStartTime =  1,                                               
                PassOverkillDamage = false, 
            } 
            
            -- Activate the bubble shield
            self:SetFocusEntity(self.MyShield) 
            self:EnableShield() 
			
            TrashAdd( self.Trash,self.MyShield)      
			
        end 
		
    end,   

	--  Summary  :  SHIELD Scripts required for drone spawned personal shields.
	--  Note     :  This script enables a drone to enhance MLU's (Moble Land Units) 
	--              and Structures with shields. The type of shield and enhancement
	--              strength given a unit is determined by that units type and tech.
    SpawnPersonalShield  = function(self) 
	
        if not self.Dead then 

            -- Get units bp and Initialize variables
            local bp = ALLBPS[self.BlueprintID]
            local bpDisplay = bp.Display
			local maxhealth = self:GetMaxHealth()
            local sldHealth, rChgTime, eCost, impactFx, regenstart                         
            
            -- Sets the shield hitpoints by tech level 
            if table.find(bp.Categories ,'EXPERIMENTAL') then
			
                if maxhealth * 0.12 >= 8000 then 
                    sldHealth = 8000                    
                else
                    sldHealth = maxhealth * 0.12
                end               
				
                rChgTime = 30 
				
            elseif table.find(bp.Categories ,'TECH3') then 
			
                sldHealth = maxhealth * .25   
                rChgTime = 20
				
            elseif table.find(bp.Categories ,'TECH2') then 
			
                sldHealth = maxhealth * .33
                rChgTime = 15 
				
            else
                sldHealth = maxhealth * .5
                rChgTime = 10
            end  
			
            eCost = (sldHealth * 0.1) 
			regenstart = 2
			
			-- mobile units cant recharge as quickly
			if table.find(bp.Categories, 'MOBILE' ) then
				rChgTime = rChgTime * 1.5
				regenstart = 3
			end
			
            -- Adjust the energy cost to match the shield strength             
            if bp.Economy.MaintenanceConsumptionPerSecondEnergy > 0 then
                eCost = eCost + bp.Economy.MaintenanceConsumptionPerSecondEnergy
            end

            self:SetMaintenanceConsumptionInactive() 
            self:SetEnergyMaintenanceConsumptionOverride(eCost)
            
            SetConsumptionPerSecondEnergy( self, eCost) 
            
            -- Adds the shield toggle to the shielded unit 
            self:AddToggleCap('RULEUTC_ShieldToggle')               
            
            -- Remove the old shield if any 
            if self.MyShield then
                self:DestroyShield()                                            
            end 
            
            -- Set the Impact FX based upon faction type
            if table.find(bp.Categories, 'AEON') then 
                impactFx = 'AeonShieldHit01'               
            elseif table.find(bp.Categories, 'CYBRAN') then 
                impactFx = 'CybranShieldHit01'                                          
            elseif table.find(bp.Categories, 'UEF') then 
                impactFx = 'UEFShieldHit01'    
            else 
                impactFx = 'SeraphimShieldHit01'                                                                                                                                             
            end            
            
            -- Get the units mesh information                                                                   
            self.MyShield = UnitShield {
                Owner = self,
                ImpactEffects = impactFx,                     
                CollisionSizeX = bp.SizeX * 0.55 or 1,
                CollisionSizeY = bp.SizeY * 0.55 or 1,
                CollisionSizeZ = bp.SizeZ * 0.55 or 1,
                CollisionCenterX = bp.CollisionOffsetX or 0,
                CollisionCenterY = bp.CollisionOffsetY or 0,
                CollisionCenterZ = bp.CollisionOffsetZ or 0,
                OwnerShieldMesh = bpDisplay.PShieldMeshBlueprint,
                RegenAssistMult = 60,
                ShieldMaxHealth = sldHealth,
                ShieldRechargeTime = rChgTime,
                ShieldEnergyDrainRechargeTime = 8,
                ShieldRegenRate = sldHealth * 0.025,
                ShieldRegenStartTime =  regenstart,
                PassOverkillDamage = true, 
            }                                              

            -- Activate the personal shield
            self:SetFocusEntity(self.MyShield)
			
			ForkTo( FloatingEntityText, self.EntityID, "Initiating Personal Shield - "..sldHealth.." strength")
			
            self:EnableShield()
            TrashAdd( self.Trash,self.MyShield)                               
        end              
    end,

	-- Black Ops Unleashed - cloaking mod
	-- All credit to the Black Ops team - I merely optimized some aspects and moved the functions into the core
    
	-- This thread runs constantly in the background for ALL units that generate cloaking fields bigger than themselves.
	-- It ensures that the cloak effect and cloak field are always in the correct state for units that are in the field
	-- This task hogs a buttload of CPU - original wait period was 2 ticks - now 80 
	CloakEffectControlThread = function(self,blueprint)
    
		local bp = blueprint or ALLBPS[self.BlueprintID]
		local brain = GetAIBrain(self)
		
		-- local a bunch of repetitive functions
		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		local IsIntelEnabled = EntityMethods.IsIntelEnabled
        
        WaitTicks(61)
	
		if not self.Dead then
		
			if not bp.Intel.CustomCloak then
			
				local flushpass = 0
                local cloakradius = bp.Intel.CloakFieldRadius or 0
				local cloakrange = cloakradius - 3
               
				while not self.Dead and (cloakrange > 0 or bp.Intel.Cloak == true) do
					
					self:UpdateCloakEffect(bp) 	-- update the cloak effect for the source unit
					
					-- only units with a cloaking field do this part
					if cloakrange > 0 then

						if IsIntelEnabled( self, 'CloakField') then
                        
                            --LOG("*AI DEBUG CloakField enabled - range is "..cloakrange)

                            local position = self:GetPosition()

							-- Range must be (radius - 3) because it seems GPG did that for the actual field for some reason.
							-- Anything beyond (radius - 3) is not cloaked by the cloak field
                            -- this is likely due to the way intel radii are stepped by 4 ogrids

							-- flush intel 
							-- cloak field generating structures will flush ALL intel in their range (not radius)
							-- on every fourth loop (32 seconds) -- this was important to the AI
							-- giving it time to 'see' what was cloaked if spotted - allows the intel to register
                            if flushpass > 3 then
                            
                                if EntityCategoryContains( STRUCTURE, self ) then
                                    FlushIntelInRect( position[1]-cloakrange, position[3]-cloakrange, position[1]+cloakrange, position[3]+cloakrange )
                                end
                                
                                flushpass = 0
							else
							
								flushpass = flushpass + 1
							end
                            
                            -- pick up other units within cloakrange
                            if cloakrange > 1 then
							
                                local UnitsInRange = GetUnitsAroundPoint( brain, ALLUNITS, position, cloakrange, 'Ally' )
						
                                -- start up the CloakFieldThread for any units found & kill any existing thread
                                -- notice this runs every pass, so units will re-cloak after 8 seconds when revealed
                                for num, unit in UnitsInRange do

                                    unit.InCloakField = true
							
                                    if unit.InCloakFieldThread then
								
                                        KillThread(unit.InCloakFieldThread)
									
                                        unit.InCloakFieldThread = nil
									
                                    end
							
                                    unit.InCloakFieldThread = unit:ForkThread(unit.InCloakFieldWatchThread, ALLBPS[unit.BlueprintID])
								
                                end
                                
							end
							
						end
						
					end
					
					WaitTicks(79)

				end
				
			end
			
		end
		
	end,

	-- Will deactivate the cloak effect if it is not renewed by a cloak field
	InCloakFieldWatchThread = function(self, bp)

		self:UpdateCloakEffect(bp)
		
		WaitTicks(80)
		
		self.InCloakField = false
		
		if self.InCloadFieldThread then
		
			KillThread(self.InCloaKFieldThread)
			self.InCloakFieldThread = nil
			
		end
		
		self:UpdateCloakEffect(bp)
		
	end,

	-- This is the core of the entire mod. The effect is actually applied here.
	UpdateCloakEffect = function(self, bp)

		if not self.Dead then
		
			local bp = bp or ALLBPS[self.BlueprintID]
			local bpDisplay = bp.Display
			
			if not bp.Intel.CustomCloak then
			
				local cloaked = self.InCloakField or self:IsIntelEnabled('Cloak')

				if (not cloaked and self.CloakEffectEnabled) or GetHealth(self) <= 0 then
				
					SetMesh( self, bpDisplay.MeshBlueprint, true)
					self.CloakEffectEnabled = nil
					
				elseif (cloaked and not self.CloakEffectEnabled) and bpDisplay.CloakMeshBlueprint then
				
					SetMesh( self, bpDisplay.CloakMeshBlueprint , true)
					self.CloakEffectEnabled = true
				end
			end
		end

	end,

	-- Overrode this so that there will be no doubt if the cloak effect is active or not
	SetMesh = function(self, meshBp, keepActor)
	
		SetMesh( self, meshBp, keepActor )
		
	end,

}

--[[

	-- triggered when the transport is given a load order
    OnStartTransportLoading = function(self, fluff)
		LOG("*AI DEBUG OnStartTransportLoading "..ALLBPS[self.BlueprintID].Description.." "..repr(fluff) )
    end,

	-- triggered  when the transport is no longer loading (success or cancelled)
    OnStopTransportLoading = function(self, fluff)
		LOG("*AI DEBUG OnStopTransportLoading "..ALLBPS[self.BlueprintID].Description.." "..repr(fluff) )
    end,

	-- not quite sure how this one works - it seems to come after the OnStartTransportLoading
    OnTransportOrdered = function(self, fluff)
		LOG("*AI DEBUG OnTransportOrdered "..ALLBPS[self.BlueprintID].Description.." "..repr(fluff) )
    end,

	-- triggered when the transport (not the unit) cancels a transport order
    OnTransportAborted = function(self)
        LOG("*AI DEBUG OnTransportAborted "..ALBPS[self.BlueprintID].Description)
    end,

    DestroyedOnTransport = function(self)
        LOG("*AI DEBUG DestroyedOnTransport "..ALBPS[self.BlueprintID].Description)
    end,
--]]

--[[	

    OnDetectedBy = function(self, index)
    
        LOG("*AI DEBUG OnDetectedBy "..ArmyBrains[self.ArmyIndex].Nickname.." "..repr(self.BlueprintID).." detected by Index "..ArmyBrains[index].Nickname.." "..repr(index) )

        local GetBlip = UnitMethods.GetBlip
        local IsSeenNow = moho.blip_methods.IsSeenNow

        local blip = GetBlip(self,index)    

        LOG("*AI DEBUG blip "..repr(blip).." Seen Ever is "..repr(moho.blip_methods.IsSeenEver(blip, index)) )
        
        local function TestAgain(self, index, blip)

            WaitTicks(31)

            if IsSeenNow( blip, index ) then
                LOG("*AI DEBUG "..ArmyBrains[index].Nickname.." After 3 seconds detected "..GetAIBrain(self).Nickname.." "..repr(ALLBPS[self.BlueprintID].Description).." is Seen Now" )
            end
        end
        
        if GetGameTick() > 1 and (not IsAlly( index, self.ArmyIndex)) and not moho.blip_methods.IsSeenEver( blip, index) then
        
            local badbrain = GetAIBrain(self)
        
            LOG("*AI DEBUG "..ArmyBrains[index].Nickname.." detected "..badbrain.Nickname.." at "..GetGameTick().." "..repr(ALLBPS[self.BlueprintID].Description) )
	
            LOG("*AI DEBUG "..ArmyBrains[index].Nickname.." detected "..badbrain.Nickname.."  Seen Ever is "..repr( moho.blip_methods.IsSeenEver( blip, index)))
		
            LOG("*AI DEBUG "..ArmyBrains[index].Nickname.." detected "..badbrain.Nickname.."  Seen Now is "..repr( IsSeenNow( blip,index)))

            self:ForkThread( TestAgain, index, blip )        
        end

        if self.DetectedByHooks then
            for k,v in self.DetectedByHooks do
                v(self,index)
            end
        end

        local bp = GetBlueprint(self).Audio
		
        if bp then
		
            local aiBrain = ArmyBrains[index]
            local factionIndex = aiBrain.FactionIndex
			
            if factionIndex == 1 then
                if bp['ExperimentalDetectedByUEF'] then
                    aiBrain:ExperimentalDetected(bp['ExperimentalDetectedByUEF'])
                elseif bp['EnemyForcesDetectedByUEF'] then
                    aiBrain:EnemyForcesDetected(bp['EnemyForcesDetectedByUEF'])
                end
				
            elseif factionIndex == 2 then
                if bp['ExperimentalDetectedByAeon'] then
                    aiBrain:ExperimentalDetected(bp['ExperimentalDetectedByAeon'])
                elseif bp['EnemyForcesDetectedByAeon'] then
                    aiBrain:EnemyForcesDetected(bp['EnemyForcesDetectedByAeon'])
                end
				
            elseif factionIndex == 3 then
                if bp['ExperimentalDetectedByCybran'] then
                    aiBrain:ExperimentalDetected(bp['ExperimentalDetectedByCybran'])
                elseif bp['EnemyForcesDetectedByCybran'] then
                    aiBrain:EnemyForcesDetected(bp['EnemyForcesDetectedByCybran'])
                end
            end
        end

    end,

    -- this allows you to execute a function when the unit (self) has been detected 
    AddDetectedByHook = function(self,hook)
	
        if not self.DetectedByHooks then
            self.DetectedByHooks = {}
        end
		
		LOG("*AI DEBUG "..GetAIBrain(self).Nickname.." Adding DetectedByHook for "..repr(ALLBPS[self.BlueprintID].Description).." on "..repr(hook))
		
        LOUDINSERT(self.DetectedByHooks,hook)
    end,

    RemoveDetectedByHook = function(self,hook)
	
        if self.DetectedByHooks then
		
            for k,v in self.DetectedByHooks do
                if v == hook then
                    table.remove(self.DetectedByHooks,k)
                    return
                end
            end
        end
    end,

	-- this function tests to see if the intel features of the unit need power to operate
	-- will return false if no energy required
	-- or true and the amount required

    ShouldWatchIntel = function(self)
		
        if not self.Dead then
			-- are we trying to consume energy
			local bpVal = self:GetConsumptionPerSecondEnergy()
		
			-- do we actually have any intel features turned on
			if bpVal > 0 then    
				local intelTypeTbl = {'Radar','Sonar','Omni','RadarStealthField','SonarStealthField','CloakField','Jammer','Cloak','Spoof','RadarStealth','SonarStealth'}

				for k,v in intelTypeTbl do
					if self:IsIntelEnabled(v) then
						return true, bpVal
					end
				end
			end
		end

        return false
    end,

    GetTransportClass = function(self)
        local bp = GetBlueprint(self).Transport
        return bp.TransportClass
    end,

    OnMotionTurnEventChange = function(self, newEvent, oldEvent)
		LOG("*AI DEBUG MOTIONTurnEVENTCHANGE")

        if newEvent == 'Straight' then
            self:PlayUnitSound('MoveStraight')
        elseif newEvent == 'Turn' then
            self:PlayUnitSound('MoveTurn')
        elseif newEvent == 'SharpTurn' then
            self:PlayUnitSound('MoveSharpTurn')
        end
    end,

    OnConsumptionActive = function(self)
		LOG("*AI DEBUG UNIT OnConsumptionActive")
    end,

    OnConsumptionInActive = function(self)
		LOG("*AI DEBUG UNIT OnConsumptionInactive")
    end,

    OnKilledVO = function(self)
        local bp = GetBlueprint(self).Audio
        if bp then
            for num, aiBrain in BRAINS do
                local factionIndex = aiBrain.FactionIndex
                if factionIndex == 1 then
                    if bp['ExperimentalUnitDestroyedUEF'] then
                        aiBrain:ExperimentalUnitDestroyed(bp['ExperimentalUnitDestroyedUEF'])
                    end
                elseif factionIndex == 2 then
                    if bp['ExperimentalUnitDestroyedAeon'] then
                        aiBrain:ExperimentalUnitDestroyed(bp['ExperimentalUnitDestroyedAeon'])
                    end
                elseif factionIndex == 3 then
                    if bp['ExperimentalUnitDestroyedCybran'] then
                        aiBrain:ExperimentalUnitDestroyed(bp['ExperimentalUnitDestroyedCybran'])
                    end
                end
            end
        end
    end,

    OnStartBuilderTracking = function(self)
    end,

    OnStopBuilderTracking = function(self)
    end,

    OnBuildProgress = function(self, unit, oldProg, newProg)
    end,

--]]
