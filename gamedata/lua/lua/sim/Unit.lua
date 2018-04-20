#**  File     :  /lua/unit.lua

local Entity = import('/lua/sim/Entity.lua').Entity

local CreateWreckageEffects = import('/lua/defaultexplosions.lua').CreateWreckageEffects
local CreateScalableUnitExplosion = import('/lua/defaultexplosions.lua').CreateScalableUnitExplosion

local EffectTemplate = import('/lua/EffectTemplates.lua')

local EffectUtilities = import('/lua/EffectUtilities.lua')
local CleanupEffectBag = import('/lua/EffectUtilities.lua').CleanupEffectBag
local CreateUnitDestructionDebris = import('/lua/EffectUtilities.lua').CreateUnitDestructionDebris

local Game = import('/lua/game.lua')

local GetEnemyUnitsInSphere = import('/lua/utilities.lua').GetEnemyUnitsInSphere
local GetRandomFloat = import('/lua/utilities.lua').GetRandomFloat

local Shield = import('/lua/shield.lua').Shield
local UnitShield = import('/lua/shield.lua').UnitShield
local AntiArtilleryShield = import('/lua/shield.lua').AntiArtilleryShield

local ApplyBuff = import('/lua/sim/buff.lua').ApplyBuff

local BuffFieldBlueprints = import('/lua/sim/BuffField.lua').BuffFieldBlueprints
local RRBC = import('/lua/sim/RebuildBonusCallback.lua').RegisterRebuildBonusCheck

local ApplyCheatBuffs = import('/lua/ai/aiutilities.lua').ApplyCheatBuffs

local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDENTITY = EntityCategoryContains
local LOUDPARSE = ParseEntityCategory
local LOUDMAX = math.max
local LOUDSIN = math.sin
local LOUDCOS = math.cos

local LOUDEMITATENTITY = CreateEmitterAtEntity
local LOUDEMITATBONE = CreateEmitterAtBone
local LOUDATTACHEMITTER = CreateAttachedEmitter
local LOUDATTACHBEAMENTITY = AttachBeamEntityToEntity

local DamageArea = DamageArea
local GetTerrainHeight = GetTerrainHeight
local GetTerrainType = GetTerrainType

local PlatoonExists = moho.aibrain_methods.PlatoonExists
local SetMesh = moho.entity_methods.SetMesh

local PlaySound = moho.entity_methods.PlaySound

local LOUDSTATE = ChangeState
local ForkThread = ForkThread
local ForkTo = ForkThread
local WaitFor = WaitFor
local WaitTicks = coroutine.yield
	
--LOG('entity_methods.__index = ',moho.entity_methods.__index,' ',repr(moho.entity_methods))
--LOG(' URGH ',repr(moho))
--LOG('scripttask_methods.__index = ',moho.ScriptTask_methods.__index,' ',repr(moho.ScriptTask_methods))
--LOG('blip_methods.__index = ',moho.blip_methods.__index,' ',repr(moho.blip_methods))
--LOG('manipulator_methods.__index = ',moho.manipulator_methods.__index,' ',repr(moho.manipulator_methods))
--LOG('navigator_methods.__index = ',moho.navigator_methods.__index,' ',repr(moho.navigator_methods))
--LOG('projectile_methods.__index = ',moho.projectile_methods.__index,' ',repr(moho.projectile_methods))
--LOG('prop_methods.__index = ',moho.prop_methods.__index,' ',repr(moho.prop_methods))
--LOG('shield_methods.__index = ',moho.shield_methods.__index,' ',repr(moho.shield_methods))
--LOG('unit_methods.__index = ',moho.unit_methods.__index,' ',repr(moho.unit_methods))
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

local GetArmy = moho.entity_methods.GetArmy
local GetBlueprint = moho.entity_methods.GetBlueprint
local GetEntityId = moho.entity_methods.GetEntityId
local GetHealth = moho.entity_methods.GetHealth
local GetMaxHealth = moho.entity_methods.GetMaxHealth
local GetWeapon = moho.unit_methods.GetWeapon
local GetWeaponCount = moho.unit_methods.GetWeaponCount
local HideBone = moho.unit_methods.HideBone
local SetProductionActive = moho.unit_methods.SetProductionActive
local IsAllied = IsAlly
local IsValidBone = moho.entity_methods.IsValidBone

Unit = Class(moho.unit_methods) {

    BuffTypes = {
        Regen = { BuffType = 'VET_REGEN', BuffValFunction = 'Add', BuffDuration = -1, BuffStacks = 'REPLACE' },
        Health = { BuffType = 'VET_HEALTH', BuffValFunction = 'Mult', BuffDuration = -1, BuffStacks = 'REPLACE' },
		VisionRadius = { BuffType = 'VET_VISION', BuffValFunction = 'Add', BuffDuration = -1, BuffStacks = 'REPLACE' },
    },

    Weapons = {},

    FxDamageScale = 1,
	
    -- FX Damage tables. A random damage effect table of emitters is choosen out of this table
    FxDamage1 = { EffectTemplate.DamageSmoke01, EffectTemplate.DamageSparks01 },
    FxDamage2 = { EffectTemplate.DamageFireSmoke01, EffectTemplate.DamageSparks01 },
    FxDamage3 = { EffectTemplate.DamageFire01, EffectTemplate.DamageSparks01 },
	
    -- This will be true for all units being constructed as upgrades
    DisallowCollisions = false,

    -- Destruction params
    PlayDestructionEffects = true,
    ShowUnitDestructionDebris = true,
    DestructionPartsHighToss = {},
    DestructionPartsLowToss = {},
    DestructionPartsChassisToss = {},

    GetSync = function(self)
	
        if not Sync.UnitData[GetEntityId(self)] then
		
            Sync.UnitData[GetEntityId(self)] = {}
			
        end
		
        return Sync.UnitData[GetEntityId(self)]
		
    end,

    OnPreCreate = function(self)

        self.Sync = { army = GetArmy(self), id = GetEntityId(self) }

        setmetatable(self.Sync,SyncMeta)

        if not self.Trash then
            self.Trash = TrashBag()
        end
        
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
		
		self.PlatoonHandle = false
		self.WeaponCount = 0
		
    end,

    OnCreate = function(self)

        Entity.OnCreate(self)
		
		self.CacheLayer = moho.unit_methods.GetCurrentLayer(self)
        
        if self.LandBuiltHiddenBones then
		
			if self.CacheLayer == 'Land' then
			
				for _,v in self.LandBuiltHiddenBones do
				
					if IsValidBone(self,v) then
					
						HideBone(self,v, true)
						
					end
					
				end
				
			end
			
        end
		
		self.WeaponCount = GetWeaponCount(self)
		
		local bp = GetBlueprint(self)
		
        local vol = bp.SizeX * bp.SizeY * bp.SizeZ
		
        local damageamounts = 1
        
        if vol >= 30 then
		
            damageamounts = 4
            self.FxDamageScale = 1.2
			
        elseif vol >= 15 then
		
            damageamounts = 3
            self.FxDamageScale = 1.1
			
        elseif vol >= 1 then
		
            damageamounts = 2
			
        end

        self.FxDamage1Amount = self.FxDamage1Amount or damageamounts
        self.FxDamage2Amount = self.FxDamage2Amount or damageamounts
        self.FxDamage3Amount = self.FxDamage3Amount or damageamounts
		
        self.DamageEffectsBag = { {}, {}, {}, }
        
        self.MovementEffectsBag = {}
        --self.IdleEffectsBag = {}
        --self.BeamExhaustEffectsBag = {}
        --self.TransportBeamEffectsBag = {}

        self.BuildEffectsBag = TrashBag()

        self.OnBeingBuiltEffectsBag = TrashBag()

        self:SetConsumptionPerSecondEnergy( bp.Economy.MaintenanceConsumptionPerSecondEnergy or 0 )
        self:SetConsumptionPerSecondMass( bp.Economy.MaintenanceConsumptionPerSecondMass or 0 )
		
        self:SetProductionPerSecondEnergy( bp.Economy.ProductionPerSecondEnergy or 0 )
        self:SetProductionPerSecondMass( bp.Economy.ProductionPerSecondMass or 0 )

        SetProductionActive(self,true)

        self.Buffs = { BuffTable = {}, Affects = {}, }

        self:SetIntelRadius('Vision', bp.Intel.VisionRadius or 0)

		self.CanTakeDamage = true

		self.CanBeKilled = true
		
        if bp.Display.AnimationDeath and LOUDGETN(bp.Display.AnimationDeath) > 0 then
		
			self.PlayDeathAnimation = true
			
        end
        
        --self.MaintenanceConsumption = false
        --self.ActiveConsumption = false
		
        --self.ProductionEnabled = true
		
        self.EnergyModifier = 0
        self.MassModifier = 0

        self.VeteranLevel = 0

        self.Dead = false		
		self.PlatoonHandle = false

		-- apply cheat buffs to AI units
        if self:GetAIBrain().CheatingAI then
		
			ApplyCheatBuffs(self)
			
        end
		
		-- this routine gets launched on EVERY unit
		-- since it really only does anything if the blueprint has the
		-- correct audio section - then this should only be launched if
		-- that is the case - instead of every unit
        self:LaunchIntelWatch(bp)		

		-- from CBFP
        if bp.Transport and bp.Transport.DontUseForcedAttachPoints then
		
            self:RemoveTransportForcedAttachPoints()
			
        end
		
        self:InitBuffFields( bp )
        self:DisableRestrictedWeapons()
        self:OnCreated()  
		
    end,

    OnCreated = function(self)
        self:DoUnitCallbacks('OnCreated')
    end,

    ForkThread = function(self, fn, ...)
	
        local thread = ForkThread(fn, self, unpack(arg))
		
        self.Trash:Add(thread)
		
        return thread
		
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

                if not BuffFieldBp or type(BuffFieldBp) != 'table' then
				
                    WARN('BuffField: no blueprint data for buff field '..repr(scriptName))
                    continue
					
                end

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
		
        for i = 1, self.WeaponCount do
		
            local wep = self:GetWeapon(i)
            local bp = wep:GetBlueprint()
			
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
    LaunchIntelWatch = function(self, bp)
	
        if ArmyIsCivilian( self:GetAIBrain().ArmyIndex ) == false then

			for _,faction in {'UEF', 'Aeon', 'Cybran', 'Seraphim'} do

                if bp.Audio['EnemyUnitDetected'..faction] then
                
                    self.SeenEver = {}
                    self.SeenEverDelay = {}
		
                    -- this puts an entry for every army into this unit
                    for _, brain in ArmyBrains do
					
                        self.SeenEver[brain.ArmyIndex] = false
                        self.SeenEverDelay[brain.ArmyIndex] = 0
						
                    end                    
                    
                    return self:ForkThread( self.WatchIntelFromOthers, bp, self:GetAIBrain() )
					
				end
				
			end
			
        end
		
    end,
	
	-- from All Your Voice mod
	-- this loop runs for units in order to play VOs to Human players
	-- in a nutshell, this loop runs every 5.8 seconds to see if the unit
	-- is visible to enemy players - and if so - it plays the audio cue
	-- if the unit becomes undetected, the audio cue will be reset but
    WatchIntelFromOthers = function(self, bp, mybrain)
		
		local GetBlip = moho.unit_methods.GetBlip
		local IsSeenEver = moho.blip_methods.IsSeenEver
		local WaitTicks = coroutine.yield
		
		local audio = bp.Audio
        
        local enemy_index = {}
        local enemy_count = 1
        
        for _, brain in ArmyBrains do
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
				
                WaitTicks(2)
				
			end
			
			WaitTicks(58)
			
		end
		
    end,

    SetDead = function(self)

		self.Dead = true
		
		self.Brain = nil
	
		self.Weapons = nil

		self.FxScale = nil
		self.FxDamageScale = nil
		self.FxDamage1 = nil
		self.FxDamage2 = nil
		self.FxDamage3 = nil
		
		self.DisallowCollisions = nil

		self.EconomyProductionInitiallyActive = nil

		self.FxDamage1Amount = nil
		self.FxDamage2Amount = nil
		self.FxDamage3Amount = nil

		self.HasFuel = nil
		self.Buffs = nil
        
		self.MaintenanceConsumption = nil
		self.ActiveConsumption = nil
		self.ProductionEnabled = nil
		self.EnergyModifier = nil
		self.MassModifier = nil
		
		self.VeteranLevel = nil
		
    end,

    IsDead = function(self)
	
        return self.Dead
		
    end,
	
	CreateUnitDestructionDebris = function( self, high, low, chassis )
	
		self:ForkThread( CreateUnitDestructionDebris, self, high, low, chassis )
		
	end,

    GetCachePosition = function(self)
	
        return self:GetPosition()
		
    end,

    GetFootPrintSize = function(self)
	
        local fp = GetBlueprint(self).Footprint
		
        if fp.SizeX > fp.SizeZ then
		
			return fp.SizeX
			
		end
		
		return fp.SizeZ
		
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
	
        local bp = GetBlueprint(self)
		
        return bp.SizeX, bp.SizeY, bp.SizeZ
		
    end,

    GetRandomOffset = function(self, scalar)

		local LOUDCOS = math.cos
		local LOUDSIN = math.sin
		
        local sx, sy, sz = self:GetUnitSizes()
        local heading = self:GetHeading()
		local LC = LOUDCOS(heading)
		local LS = LOUDSIN(heading)
		local RD = Random()

        sx = sx * scalar
        sy = sy * scalar
        sz = sz * scalar
		
        local rx = RD * sx - (sx * 0.5)
        local y  = RD * sy + (GetBlueprint(self).CollisionOffsetY or 0)
        local rz = RD * sz - (sz * 0.5)
        local x = LC*rx - LS*rz
        local z = LS*rx - LC*rz
		
        return x,y,z
		
    end,

    LifeTimeThread = function(self, lifetime)
	
		WaitTicks(lifetime*10)
		
		self:Destroy()
		
    end,

    SetTargetPriorities = function(self, priTable)
	
        for i = 1, self.WeaponCount do
		
            local wep = GetWeapon(self,i)
			
            wep:SetWeaponPriorities(priTable)
			
        end
		
    end,
    
    SetLandTargetPriorities = function(self, priTable)
	
        for i = 1, self.WeaponCount do
		
            local wep = GetWeapon(self,i)
            
            for onLayer, targetLayers in wep:GetBlueprint().FireTargetLayerCapsTable do
			
                if string.find(targetLayers, 'Land') then
				
                    wep:SetWeaponPriorities(priTable)
					
                    break
					
                end
				
            end
			
        end
		
    end,

    OnScriptBitSet = function(self, bit)
	
        if bit == 0 then			-- shield toggle
		
            --self:PlayUnitAmbientSound( 'ActiveLoop' )
		    self:EnableShield()
			
        elseif bit == 1 then 		-- weapon toggle

        elseif bit == 2 then 		-- jamming toggle
		
            --self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Jammer')
			
        elseif bit == 3 then 		-- intel toggle
		
            --self:StopUnitAmbientSound( 'ActiveLoop' )
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
		
            --self:StopUnitAmbientSound( 'ActiveLoop' )
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
		
            --self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
			self:DisableUnitIntel('CloakField')
        end
    end,

    OnScriptBitClear = function(self, bit)
	
        if bit == 0 then
		
            --self:StopUnitAmbientSound( 'ActiveLoop' )
            self:DisableShield()
			
        elseif bit == 1 then

        elseif bit == 2 then
		
            --self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Jammer')
			
        elseif bit == 3 then
		
            --self:PlayUnitAmbientSound( 'ActiveLoop' )
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
		
            --self:PlayUnitAmbientSound( 'ActiveLoop' )
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
		
            --self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
			self:EnableUnitIntel('CloakField')
			
        end
		
    end,

    OnPaused = function(self)
	
        self:SetActiveConsumptionInactive()
        --self:StopUnitAmbientSound( 'ConstructLoop' )
        -- self:DoUnitCallbacks('OnPaused')
		
    end,

    OnUnpaused = function(self)
		
        if self:IsUnitState('Building') or self:IsUnitState('Upgrading') or self:IsUnitState('Repairing') then
		
            self:SetActiveConsumptionActive()
            --self:PlayUnitAmbientSound( 'ConstructLoop' )
			
        end
		
        -- self:DoUnitCallbacks('OnUnpaused')
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
			
                self.ToggleCaps[counter+1] = v
				counter = counter + 1
				
            end
			
            self:RemoveToggleCap(v)
			
        end
		
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
	
        self:DoUnitCallbacks( 'OnStartBeingCaptured', captor )
        --self:PlayUnitSound('StartBeingCaptured')
    end,

	-- when you finish being captured by something else
    OnStopBeingCaptured = function(self, captor)
	
        self:DoUnitCallbacks( 'OnStopBeingCaptured', captor )
        --self:PlayUnitSound('StopBeingCaptured')
    end,

	-- when you are captured
    OnCaptured = function(self, captor)
	
        if self and not self.Dead and captor and not captor.Dead and self:GetAIBrain() ~= captor:GetAIBrain() then
		
            if not self:IsCapturable() then
			
                self:Kill()
                return
				
            end
			
            -- kill non capturable things on a transport
            if LOUDENTITY( categories.TRANSPORTATION, self ) then
			
                local cargo = self:GetCargo()
				
                for _,v in cargo do
				
                    if not v.Dead and not v:IsCapturable() then
					
                        v:Kill()
						
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
            local captorArmyIndex = captor.Sync.army
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
	
        self:DoUnitCallbacks( 'OnFailedBeingCaptured', captor )
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
	
		--LOG("*AI DEBUG Turning ON MaintenanceConsumption for "..repr(self:GetBlueprint().Description))
		
        self.MaintenanceConsumption = true
        self:UpdateConsumptionValues()
		
    end,

    SetMaintenanceConsumptionInactive = function(self)
	
		--LOG("*AI DEBUG Turning OFF MaintenanceConsumption")
		
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
		
		--self:SetActiveConsumptionInactive()
		
        SetProductionActive(self,false)
		
        --self:DoUnitCallbacks('OnProductionPaused')
		
    end,

    OnProductionUnpaused = function(self)
	
        self:SetMaintenanceConsumptionActive()
		
		--self:SetActiveConsumptionActive()
		
        SetProductionActive(self,true)
		
        --self:DoUnitCallbacks('OnProductionUnpaused')
		
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
	
        return self:GetBuildRate() 
		
    end,

    -- Called when we start building a unit, turn on/off, get/lose bonuses, or on
    -- any other change that might affect our build rate or resource use.
    UpdateConsumptionValues = function(self)
	
        local energy_rate = 0
        local mass_rate = 0
		
		if not self.Dead then
	
			local GetBuildRate = moho.unit_methods.GetBuildRate
		
			local myBlueprint = GetBlueprint(self)

			if self.ActiveConsumption then

				local focus = self:GetFocusUnit()
				
				if focus and self.WorkItem and self.WorkProgress < 1 and (focus:IsUnitState('Enhancing') or focus:IsUnitState('Building')) then
				
					self.WorkItem = focus.WorkItem    #-- set our workitem to the focus unit work item, is specific for enhancing
					
				end
				
				local time = 1
				local mass = 0
				local energy = 0
			
				-- if the unit is enhancing (as opposed to upgrading ie. - commander, subcommander)
				if self.WorkItem then
				
					time, energy, mass = Game.GetConstructEconomyModel(self, self.WorkItem)
				
				-- if the unit is assisting something that is building ammo
				elseif focus and focus:IsUnitState('SiloBuildingAmmo') then
					
					--GPG: If building silo ammo; create the energy and mass costs based on build rate
					--of the silo against the build rate of the assisting unit
					time, energy, mass = focus:GetBuildCosts(focus.SiloProjectile)

					local siloBuildRate = focus:GetBuildRate() or 1
					
					energy = (energy / siloBuildRate) * (self:GetBuildRate() or 1)
					mass = (mass / siloBuildRate) * (self:GetBuildRate() or 1)
				
				-- if the unit is building, upgrading or assisting an upgrade, or repairing something
				elseif focus then
					
					--GPG: bonuses are already factored in by GetBuildCosts
					time, energy, mass = self:GetBuildCosts(focus:GetBlueprint())
					
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
			
			-- LOUD -- add in the specific -- but possibly seperate -- active costs (ie. - for moving)
			if myBlueprint.Economy.ActiveConsumptionPerSecondEnergy or myBlueprint.Economy.ActiveConsumptionPerSecondMass then
			
				LOG("*AI DEBUG Specified Active Consumption")
				
				energy_rate = energy_rate + (myBlueprint.Economy.ActiveConsumptionPerSecondEnergy or 0)
				mass_rate = mass_rate + (myBlueprint.Economy.ActiveConsumptionPerSecondMass or 0)
				
			end		

			-- LOUD -- add in the maintenance costs -- for unit features (ie. - Shields, effects)
			if self.MaintenanceConsumption then
			
				-- apply bonuses
				energy_rate = energy_rate + ((self.EnergyMaintenanceConsumptionOverride or myBlueprint.Economy.MaintenanceConsumptionPerSecondEnergy) or 0) * (100 + (self.EnergyModifier or 0)) * (self.EnergyMaintAdjMod or 1) * 0.01
				mass_rate = mass_rate + (myBlueprint.Economy.MaintenanceConsumptionPerSecondMass or 0) * (100 + (self.MassModifier or 0)) * (self.MassMaintAdjMod or 1) * 0.01
				
			end
	
			-- enforce the minimum rates
			energy_rate = math.max(energy_rate, myBlueprint.Economy.MinConsumptionPerSecondEnergy or 0)
			mass_rate = math.max(mass_rate, myBlueprint.Economy.MinConsumptionPerSecondMass or 0)
			
		end
		
        self:SetConsumptionPerSecondEnergy(energy_rate)
        self:SetConsumptionPerSecondMass(mass_rate)

        if (energy_rate > 0) or (mass_rate > 0) then
		
            self:SetConsumptionActive(true)
			
        else
		
            self:SetConsumptionActive(false)
			
        end
		
    end,

    UpdateProductionValues = function(self)
	
		if GetBlueprint(self).Economy then
	
			local bpEcon = GetBlueprint(self).Economy
		
			self:SetProductionPerSecondEnergy((bpEcon.ProductionPerSecondEnergy or 0) * (self.EnergyProdAdjMod or 1))
			self:SetProductionPerSecondMass((bpEcon.ProductionPerSecondMass or 0) * (self.MassProdAdjMod or 1))
			
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

		-- if the unit is in a platoon that exists and that platoon has a CallForHelpAI
		-- I should probably do this thru a callback but it's much easier to find and work
		-- with it here until I have it right
		if self.PlatoonHandle.CallForHelpAI then
		
			local aiBrain = self:GetAIBrain()
			local platoon = self.PlatoonHandle
			
			if (not platoon.UnderAttack) and aiBrain:PlatoonExists( platoon ) then
			
				-- turn on the UnderAttack flag and process it
				platoon:ForkThread(platoon.PlatoonUnderAttack, aiBrain)
				
			end
			
		end
		
        if self.CanTakeDamage then
		
            self:DoOnDamagedCallbacks(instigator)
            self:DoTakeDamage(instigator, amount, vector, damageType)
			
        end
		
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
		
		local GetHealth = moho.entity_methods.GetHealth
	
        local preAdjHealth = GetHealth(self)
		
        moho.entity_methods.AdjustHealth( self, instigator, -amount)
		
        if moho.entity_methods.GetHealth(self) < 1 then
		
            if damageType == 'Reclaimed' then
			
                self:Destroy()
				
            else
			
                local excessDamageRatio = 0.0
				
                -- Calculate the excess damage amount
                local excess = preAdjHealth - amount
                local maxHealth = moho.entity_methods.GetMaxHealth(self)
				
                if (excess < 0 and maxHealth > 0) then
				
                    excessDamageRatio = -excess / maxHealth
					
                end
				
                moho.entity_methods.Kill( self, instigator, damageType, excessDamageRatio)
				
            end
			
        end
		
		
        if not self.Dead and LOUDENTITY(categories.COMMAND, self) then
		
			self:GetAIBrain():OnPlayCommanderUnderAttackVO()
			
        end
		
    end,

    OnHealthChanged = function(self, new, old)
	
        self:ManageDamageEffects( new, old )

        self:DoOnHealthChangedCallbacks( new, old )
		
    end,

    ManageDamageEffects = function(self, newHealth, oldHealth)

		if not self.Dead then
		
			-- Health values come in at fixed 25% intervals
			if newHealth < oldHealth then
			
				-- if we have any damage effects in the blueprint
				if self.FxDamage1Amount or self.FxDamage2Amount or self.FxDamage3Amount then
			
					if oldHealth == 0.75 then
				
						for i = 1, self.FxDamage1Amount do
							self:PlayDamageEffect(self.FxDamage1, self.DamageEffectsBag[1])
						end
					
					elseif oldHealth == 0.5 then
				
						for i = 1, self.FxDamage2Amount do
							self:PlayDamageEffect(self.FxDamage2, self.DamageEffectsBag[2])
						end
					
					elseif oldHealth == 0.25 then
				
						for i = 1, self.FxDamage3Amount do
							self:PlayDamageEffect(self.FxDamage3, self.DamageEffectsBag[3])
						end
					
					end
					
				end
				
			else

				-- if there are any ongoing damage effects --
				if self.DamageEffectsBag[1] or self.DamageEffectsBag[2] or self.DamageEffectsBag[3] then
				
					if newHealth <= 0.25 and newHealth > 0 and self.DamageEffectsBag[3] then
				
						for k, v in self.DamageEffectsBag[3] do
							v:Destroy()
						end
					
					elseif newHealth <= 0.5 and newHealth > 0.25 and self.DamageEffectsBag[2] then
				
						for k, v in self.DamageEffectsBag[2] do
							v:Destroy()
						end
					
					elseif newHealth <= 0.75 and newHealth > 0.5 and self.DamageEffectsBag[1] then
				
						for k, v in self.DamageEffectsBag[1] do
							v:Destroy()
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
		
        if not effects then
			return
		end
		
        local army = self.Sync.army
		
		local Random = Random
		local LOUDGETN = table.getn
		local LOUDINSERT = table.insert
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		
        local totalBones = self:GetBoneCount()
        local bone = Random(1, totalBones) - 1
        local bpDE = GetBlueprint(self).Display.DamageEffects
		
		local fx, bpFx
		
        for k, v in effects do
			
            if bpDE then
			
                bpFx = bpDE[ Random(1, table.getsize(bpDE)) ]
				
                fx = LOUDATTACHEMITTER(self, bpFx.Bone or 0,army, v):ScaleEmitter(self.FxDamageScale):OffsetEmitter(bpFx.OffsetX or 0, bpFx.OffsetY or 0, bpFx.OffsetZ or 0)
				
            else
			
                fx = LOUDATTACHEMITTER(self, bone, army, v):ScaleEmitter(self.FxDamageScale)
				
            end
			
            LOUDINSERT(fxBag, fx)
			
        end
		
    end,

    DestroyAllDamageEffects = function(self)
	
		if self.DamageEffectsBag then
			
			for kb, vb in self.DamageEffectsBag do
			
				for ke, ve in vb do
				
					ve:Destroy()
					
				end
				
			end
			
		end
		
    end,

    CheckCanBeKilled = function(self,other)
	
        return self.CanBeKilled
		
    end,
	
    --Sets if the unit can be killed.  val = true means it can be killed.
    SetCanBeKilled = function(self, val)
	
        self.CanBeKilled = val
		
    end,

    -- On killed: this function plays when the unit takes a mortal hit.  It plays all the default death effect
    OnKilled = function(self, instigator, type, overkillRatio)
	
		--LOG("*AI DEBUG "..self:GetBlueprint().Description.." killed by "..instigator:GetAIBrain().Nickname.." "..instigator:GetBlueprint().Description.." "..repr(instigator))
        
		self:PlayUnitSound('Killed')

        if LOUDENTITY(categories.FACTORY, self) then
		
            if self.UnitBeingBuilt and not self.UnitBeingBuilt.Dead and self.UnitBeingBuilt:GetFractionComplete() != 1 then
			
                self.UnitBeingBuilt:Kill()
				
            end
			
        end

        if self.PlayDeathAnimation then 
		
			if not self:IsBeingBuilt() then
			
			    self:ForkThread(self.PlayAnimationThread, 'AnimationDeath')
				
				self:SetCollisionShape('None')
				
			end
			
        end
		
		self:DoUnitCallbacks( 'OnKilled' )
		
		if self.TopSpeedEffectsBag then
		
			self:DestroyTopSpeedEffects()
			
		end
		
		if self.BeamExhaustEffectsBag then
		
		    self:DestroyBeamExhaust()
			
		end

        if self.UnitBeingTeleported and not self.UnitBeingTeleported.Dead then
		
            self.UnitBeingTeleported:Destroy()
            self.UnitBeingTeleported = nil
			
        end

        -- Notify instigator that you killed me - do not grant kills for walls
		if not LOUDENTITY(categories.WALL, self) then
		
			if instigator and IsUnit(instigator) then
			
				instigator:ForkThread( instigator.OnKilledUnit, self )
				
			end
			
		else
		
			-- remove the kill before the instigator has a chance to test veterancy
			if instigator and IsUnit(instigator) then
			
				local kills = instigator:GetStat('KILLS', 0).Value
				
				instigator:SetStat('KILLS', kills - 1)
				
			end
			
		end
		
        if self.DeathWeaponEnabled != false then
		
            self:DoDeathWeapon()
			
        end
		
        self:DisableShield()
        self:DisableUnitIntel()

        self:ForkThread(self.DeathThread, overkillRatio, instigator)
		
    end,
	
    PlayAnimationThread = function(self, anim, rate)
	
        local bp = GetBlueprint(self)
		
        if bp.Display[anim] then
        
            local animBlock = self:ChooseAnimBlock( bp.Display[anim] )
			
            if animBlock.Mesh then
			
                self:SetMesh(animBlock.Mesh)
				
            end
			
            if animBlock.Animation then
			
                --self:StopRocking()
                local rate = rate or 1
				
                if animBlock.AnimationRateMax and animBlock.AnimationRateMin then
				
                    rate = Random(animBlock.AnimationRateMin * 10, animBlock.AnimationRateMax * 10) / 10
					
                end
				
                self.DeathAnimManip = CreateAnimator(self):PlayAnim(animBlock.Animation):SetRate(rate)

                self.Trash:Add(self.DeathAnimManip)
				
                WaitFor(self.DeathAnimManip)
				
				self.DeathAnimManip = nil
            end
			
        end
		
    end,

    DeathThread = function( self, overkillRatio, instigator)

        if self.DeathAnimManip then
		
			WaitFor(self.DeathAnimManip)
			
		end
		
		WaitTicks(3)
		
		self:DestroyAllDamageEffects()

        if self.PlayDestructionEffects then
		
			self:CreateDestructionEffects( self, overkillRatio )
			
		end
		
		self:PlayUnitSound('Destroyed')
		
		if overkillRatio <= 0.15 then
		
			self:CreateWreckage( overkillRatio )
			
		end
        
        if ( self.ShowUnitDestructionDebris and overkillRatio ) then
		
            if overkillRatio <= 0.25 then
			
                self:ForkThread(CreateUnitDestructionDebris, self, true, true, false )
				
            else
			
                self:ForkThread(CreateUnitDestructionDebris, self, false, true, true )
				
            end
			
        end

        WaitTicks((self.DeathThreadDestructionWaitTime or 0.2) * 10)
		
        self:Destroy()
		self = nil
		
    end,

    CreateWreckage = function( self, overkillRatio )

        if GetBlueprint(self).Wreckage.WreckageLayers[self.CacheLayer] then
		
			self:CreateWreckageProp(overkillRatio)
			
        end
		
    end,

    CreateWreckageProp = function( self, overkillRatio )
	
		local bp = GetBlueprint(self)
		local wreck = bp.Wreckage.Blueprint
		
		if wreck then
			
			local pos = self:GetPosition()
			local mass = bp.Economy.BuildCostMass * (bp.Wreckage.MassMult or 0)
			local energy = bp.Economy.BuildCostEnergy * (bp.Wreckage.EnergyMult or 0)
			local time = (bp.Wreckage.ReclaimTimeMultiplier or 1)

			local prop = CreateProp( pos, wreck )

			prop:AddBoundedProp(mass)

			prop:SetScale(bp.Display.UniformScale)
			prop:SetOrientation(self:GetOrientation(), true)
			prop:SetPropCollision('Box', bp.CollisionOffsetX, bp.CollisionOffsetY, bp.CollisionOffsetZ, bp.SizeX* 0.5, bp.SizeY* 0.5, bp.SizeZ * 0.5)
			prop:SetMaxReclaimValues(time, time, mass, energy)

			mass = (mass - (mass * (overkillRatio or 1))) * self:GetFractionComplete()
			energy = (energy - (energy * (overkillRatio or 1))) * self:GetFractionComplete()
			time = time - (time * (overkillRatio or 1))

			prop:SetReclaimValues(time, time, mass, energy)
			prop:SetMaxHealth(bp.Defense.Health)
			prop:SetHealth(self, bp.Defense.Health * (bp.Wreckage.HealthMult or 1))

            if not bp.Wreckage.UseCustomMesh then
			
    	        prop:SetMesh(bp.Display.MeshBlueprintWrecked)
				
            end
			
			if bp.Wreckage.LifeTime then
			
				ForkTo( self.LifeTimeThread, prop, bp.Wreckage.LifeTime)
				
			end

            TryCopyPose(self,prop,false)

            prop.AssociatedBP = GetBlueprint(self).BlueprintId
			prop.IsWreckage = true
			
			--CreateWreckageEffects(self,prop)
			
			return prop
			
		end
		
    end,

	-- when you kill a unit
    OnKilledUnit = function(self, unitKilled)
		
		if not self.Dead then
		
			self:CheckVeteranLevel()
			
		end
		
    end,

    DoDeathWeapon = function(self)
	
        if self:IsBeingBuilt() then
		
			return
			
		end
		
        local weapons = GetBlueprint(self).Weapon or {}
		
        for _, v in weapons do
		
            if(v.Label == 'DeathWeapon') then
				
                if v.FireOnDeath == true then
				
                    self:SetWeaponEnabledByLabel('DeathWeapon', true)
                    self:GetWeaponByLabel('DeathWeapon'):Fire()
					
                else
				
                    self:ForkThread(self.DeathWeaponDamageThread, v.DamageRadius, v.Damage, v.DamageType, v.DamageFriendly)
					
                end
				
                break
				
            end
			
        end
		
    end,

    OnCollisionCheck = function(self, other, firingWeapon)
	
        if self.DisallowCollisions then
		
            return false
			
        end		
		
		local LOUDENTITY = EntityCategoryContains
		local LOUDPARSE = ParseEntityCategory
		
        if LOUDENTITY(categories.PROJECTILE, other) then
		
			local GetArmy = moho.entity_methods.GetArmy
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
		
		local DNCList = GetBlueprint(other).DoNotCollideList
		
		if DNCList then
		
			for _,v in DNCList do
			
				if LOUDENTITY(LOUDPARSE(v), self) then
				
					return false
					
				end
				
			end
			
		end

		local DNCList = GetBlueprint(self).DoNotCollideList	
		
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
			if other.LastImpact == GetEntityId(self) then
			
				return false
				
			end
			
		end

        if not self.Dead and self.EXPhaseEnabled == true then
		
            if LOUDENTITY(categories.PROJECTILE, other) then 
			
                local random = Random(1,100)
				
                -- Allows % of projectiles to pass
                if random <= self.EXPhaseShieldPercentage then
				
                    -- Returning false allows the projectile to pass thru
                    return false
					
                end
				
            end
			
        end

        return true
		
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)
	
        if self.DisallowCollisions then
		
			return false
			
        end		
		

		local bp = firingWeapon:GetBlueprint()
        local collidefriendly = bp.CollideFriendly

		-- check for allied passthrough if same army or allied army
		if not collidefriendly then
		
			local GetArmy = moho.entity_methods.GetArmy
		
			local army1 = GetArmy(self)
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
        --self:DoUnitCallbacks('OnTMLaunched')
    end,

    OnSMLaunched = function(self)
        --self:DoUnitCallbacks('OnSMLaunched')
    end,

    CheckCountedMissileAmmoIncrease = function(self)
	
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
				
            end
			
            if tacticalCount > lastTimeTacticalCount then
			
                self:OnTMLAmmoIncrease()
				
            end

            lastTimeNukeCount = nukeCount 
            lastTimeTacticalCount = tacticalCount
			
            WaitTicks(60)
			
        end
		
    end,

    OnTMLAmmoIncrease = function(self)
        --self:DoUnitCallbacks('OnTMLAmmoIncrease')
    end,

    OnSMLAmmoIncrease = function(self)
        --self:DoUnitCallbacks('OnSMLAmmoIncrease')
    end,

    CreateDestructionEffects = function( self, overKillRatio )
	
        CreateScalableUnitExplosion( self, overKillRatio )
		
    end,

    DeathWeaponDamageThread = function( self , damageRadius, damage, damageType, damageFriendly)
	
        WaitTicks(1)
		
        DamageArea(self, self:GetPosition(), damageRadius or 1, damage or 1, damageType or 'Normal', damageFriendly or false)
		
    end,
	
    DoDestroyCallbacks = function(self)
	
        if self.EventCallbacks.OnDestroyed then
		
            for k, cb in self.EventCallbacks.OnDestroyed do
			
                if cb then
				
                    cb( self:GetAIBrain(), self )
					
                end
				
            end
			
        end
		
    end,

    OnDestroy = function(self)

		self.PlatoonHandle = nil
        
		local ID = GetEntityId(self)

		-- Don't allow anyone to stuff anything else in the table
		self.Sync = false

		Sync.ReleaseIds[ID] = true

		-- If factory, destroy what I'm building if I die
		if LOUDENTITY(categories.FACTORY, self) then
		
			if self.UnitBeingBuilt and not self.UnitBeingBuilt.Dead and self.UnitBeingBuilt:GetFractionComplete() != 1 then
			
				self.UnitBeingBuilt:Destroy()
				
			end
			
		end
        
		self.Trash:Destroy()

		if self.IntelThread then
		
			KillThread(self.IntelThread)
			
			self.IntelThread = nil
			
		end

		if self.BuildArmManipulator then
		
			self.BuildArmManipulator = nil
			
		end
        
		if self.BuildEffectsBag then
		
			self.BuildEffectsBag:Destroy()
			self.BuildEffectsBag = nil
			
		end
		
		if self.CaptureEffectsBag then
		
			self.CaptureEffectsBag:Destroy()
			self.CaptureEffectsBag = nil
			
		end
		
		if self.ReclaimEffectsBag then
		
			self.ReclaimEffectsBag:Destroy()
			self.ReclaimEffectsBag = nil
			
		end
		
		if self.OnBeingBuiltEffectsBag then
		
			self.OnBeingBuiltEffectsBag:Destroy()
			self.OnBeingBuiltEffectsBag = nil
			
		end
		
		if self.UpgradeEffectsBag then
		
			self.UpgradeEffectsBag:Destroy()
			self.UpgradeEffectsBag = nil
			
		end 
		
		if self.TeleportDrain then
		
			RemoveEconomyEvent( self, self.TeleportDrain)
			
		end
        
		RemoveAllUnitEnhancements(self)
		
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
		
            local aiBrain = self:GetAIBrain()
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
	
        local bp = GetBlueprint(self).Audio
		
        if bp then
			
			local mybrain = self:GetAIBrain()
			
			for _, brain in ArmyBrains do
        
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
	
        local mybrain = self:GetAIBrain()
		
        for _, brain in ArmyBrains do
		
			if brain.BrainType == "Human" then
				
                if brain != mybrain then
				
                    brain:NuclearLaunchDetected()
					
                end
				
			end
			
        end
		
    end,

    SetAllWeaponsEnabled = function(self, enable)
	
        for i = 1, self.WeaponCount do
		
            local wep = GetWeapon(self,i)
			
            wep:SetWeaponEnabled(enable)
			
            wep:AimManipulatorSetEnabled(enable)
			
        end
		
    end,

    SetWeaponEnabledByLabel = function(self, label, enable)
	
        local wep = self:GetWeaponByLabel(label)
		
        if not wep then return end
		
        if not enable then
		
            wep:OnLostTarget()
			
        end
		
        wep:SetWeaponEnabled(enable)
        wep:AimManipulatorSetEnabled(enable)
		
    end,

    GetWeaponManipulatorByLabel = function(self, label)
	
        local wep = self:GetWeaponByLabel(label)
		
		return wep.AimControl

    end,

    GetWeaponByLabel = function(self, label)
	
        local wep
		
        for i = 1, GetWeaponCount(self) do
		
            wep = GetWeapon(self,i)
			
            if (wep:GetBlueprint().Label == label) then
			
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

    OnStartBeingBuilt = function(self, builder, layer)

		self:CheckUnitRestrictions()
	
        self:StartBeingBuiltEffects(builder, layer)
		
        local aiBrain = self:GetAIBrain()
		
		local LOUDENTITY = EntityCategoryContains
		local LOUDGETN = table.getn
		
        if aiBrain.UnitBuiltTriggerList and LOUDGETN(aiBrain.UnitBuiltTriggerList) > 0 then
		
            for k,v in aiBrain.UnitBuiltTriggerList do
			
                if LOUDENTITY(v.Category, self) then
				
                    self:ForkThread(self.UnitBuiltPercentageCallbackThread, v.Percent, v.Callback)
					
                end
				
            end
			
        end
		
        local builderUpgradesTo = builder:GetBlueprint().General.UpgradesTo or false
		
        if not builderUpgradesTo or self:GetUnitId() != builderUpgradesTo then

            if EntityCategoryContains( categories.STRUCTURE, self) then
			
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
        local fraction = unitBeingBuilt:GetFractionComplete()
		
        if fraction > (self.InitialFractionComplete or 0) then
		
            unitBeingBuilt:OnRebuildBonusIsIllegal()
			
        end
		
        self.InitialFractionComplete = nil
		
    end,

    CheckRebuildBonus = function(self)
	
        -- this section is rebuild bonus check 2 [159]
        -- This code checks if the unit is allowed to be accelerate-built. If not the unit is destroyed (for lack 
        -- of a SetFractionComplete() function). Added by brute51
        if self:GetFractionComplete() > 0 then
		
            local cb = function(bpUnitId)
			
                if self:GetUnitId() == bpUnitId then 
				
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
        if Game.UnitRestricted(self) and IsUnit(self) and self:GetFractionComplete() != 1 then
		
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
	
		local WaitTicks = coroutine.yield

        while not self.Dead and self:GetHealthPercent() < percent do
		
            WaitTicks(12)
			
        end
		
        local aiBrain = self:GetAIBrain()
		
        for k,v in aiBrain.UnitBuiltTriggerList do
		
            if v.Callback == callback then
			
                callback(self)
                aiBrain.UnitBuiltTriggerList[k] = nil
				
            end
			
        end
		
    end,

    OnStopBeingBuilt = function(self, builder, layer)
		
		local bp = GetBlueprint(self)

		self:SetupIntel(bp)
	
		-- This is here to catch those units EXCEPT Factories and SubCommanders that might have enhancements
		-- by specifying the Sequence of enhancements we can invoke them on individual units
		if bp.Enhancements then
			
			if bp.Enhancements.Sequence then
			
				local aiBrain = self:GetAIBrain()
			
				if aiBrain.BrainType != 'Human' and not ( EntityCategoryContains( categories.FACTORY, self ) or EntityCategoryContains( categories.SUBCOMMANDER, self )) then
					
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
			
				self:SetHealth( self, builder:GetHealthPercent() * bp.Defense.MaxHealth )
				self.DisallowCollisions = false
				
			end
			
		end
		
		if bp.Defense.LifeTime then
		
			ForkTo( self.LifeTimeThread, self, bp.Defense.Lifetime )
			
		end
		
        if bp.SizeSphere then
		
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere )
			
        end
		
		self:PlayUnitSound('DoneBeingBuilt')

		--self:PlayUnitAmbientSound( 'ActiveLoop' )

		self:HideLandBones()
		
		self:DoUnitCallbacks('OnStopBeingBuilt')

		-- if self.IdleEffectsBag then
			-- if (LOUDGETN(self.IdleEffectsBag) == 0) then
				-- self:CreateIdleEffects()
			-- end
		-- end

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
		
			self.PermOpenAnimManipulator = CreateAnimator(self):PlayAnim(bp.Display.AnimationPermOpen)
			self.Trash:Add(self.PermOpenAnimManipulator)
			
		end

		-- Initialize movement effects subsystems, idle effects, beam exhaust, and footfall manipulators
		if bp.Display.MovementEffects then
		
			local bpTable = bp.Display.MovementEffects
        
			if bpTable.Land or bpTable.Air or bpTable.Water or bpTable.Sub or bpTable.BeamExhaust then
		
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
			self.EXPhaseShieldPercentage = 0
			self.EXPhaseEnabled = false
			self.EXTeleportCooldownCharge = false
			self.EXPhaseCharge = 0
		end
		
		self:ForkThread(self.CloakEffectControlThread, bp)		
		
    end,

    StartBeingBuiltEffects = function(self, builder, layer)
	
		local BuildMeshBp = GetBlueprint(self).Display.BuildMeshBlueprint
		
		if BuildMeshBp then
		
			self:SetMesh( BuildMeshBp, true)
			
		end
		
    end,

    StopBeingBuiltEffects = function(self, builder, layer)
	
        local bp = GetBlueprint(self).Display
		
        local useTerrainType = false
		
        if bp then
		
            if bp.TerrainMeshes then
			
                local bpTM = bp.TerrainMeshes
                local pos = self:GetPosition()
                local terrainType = GetTerrainType( pos[1], pos[3] )
				
                if bpTM[terrainType.Style] then
				
                    self:SetMesh(bpTM[terrainType.Style])
                    useTerrainType = true
					
                end
				
            end
			
            if not useTerrainType then
			
                self:SetMesh(bp.MeshBlueprint, true)
				
            end
			
			-- added so that cloak effects are applied if unit was already cloaked
			if self.InCloakField then
			
				self.CloakEffectEnabled = nil
				self:UpdateCloakEffect(bp)
				
			end
			
        end
		
		if self.OnBeingBuiltEffectsBag then
		
			self.OnBeingBuiltEffectsBag:Destroy()
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
	
        local bp = GetBlueprint(self)
		
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
		
        self.Trash:Add(self.BuildArmManipulator)
		
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
	
        self:UpdateConsumptionValues()
	
		if order == 'Repair' and unitBeingBuilt.WorkItem != self.WorkItem then
		
			self:InheritWork(unitBeingBuilt)
			
		end
		
        local bp = GetBlueprint(self)
		
        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
		
            self:StartBuildingEffects(unitBeingBuilt, order)
			
        end
		
        self:DoOnStartBuildCallbacks(unitBeingBuilt)
		
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('Construct')
        --self:PlayUnitAmbientSound('ConstructLoop')
		
        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
		
			--LOG("*AI DEBUG Disallowing Collisions on "..unitBeingBuilt:GetBlueprint().Description)
			
            unitBeingBuilt.DisallowCollisions = true
			
        end
        
        if unitBeingBuilt:GetBlueprint().Physics.FlattenSkirt and not unitBeingBuilt:HasTarmac() then
		
            if self.TarmacBag and self:HasTarmac() then
			
                unitBeingBuilt:CreateTarmac(true, true, true, self.TarmacBag.Orientation, self.TarmacBag.CurrentBP )
				
            else
			
                unitBeingBuilt:CreateTarmac(true, true, true, false, false)
				
            end
			
        end
		
        self.CurrentBuildOrder = order		
		
    end,

    OnStopBuild = function(self, unitBeingBuilt)
		
        self:StopBuildingEffects(unitBeingBuilt)
        self:SetActiveConsumptionInactive()
		
        self:DoOnUnitBuiltCallbacks(unitBeingBuilt)
		
        --self:StopUnitAmbientSound('ConstructLoop')
        self:PlayUnitSound('ConstructStop')
		
    end,

    GetUnitBeingBuilt = function(self)
	
        return self.UnitBeingBuilt
		
    end,

    OnFailedToBuild = function(self)
	
        self:DoOnFailedToBuildCallbacks()
        self:SetActiveConsumptionInactive()
        --self:StopUnitAmbientSound('ConstructLoop')
		
    end,

    OnPrepareArmToBuild = function(self)
    end,

    StartBuildingEffects = function(self, unitBeingBuilt, order)
	
        self.BuildEffectsBag:Add( self:ForkThread( self.CreateBuildEffects, unitBeingBuilt, order ) )
		
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
    end,

    StopBuildingEffects = function(self, unitBeingBuilt)
	
        self.BuildEffectsBag:Destroy()
		
    end,

    -- Setup the initial intel of the unit.  Return true if it can, false if it can't.
	-- this will set all intel types to OFF except for vision
    SetupIntel = function(self,bp)
	
        local bp = bp.Intel or GetBlueprint(self).Intel
		
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
			
            return true
			
        end
		
        return false
		
    end,

    DisableUnitIntel = function(self, intel)
	
		local DisableIntel = moho.entity_methods.DisableIntel
		
		local intDisabled = false
		
        if self.Dead or not self.IntelDisables then return end
		
        if intel then
		
            self.IntelDisables[intel] = self.IntelDisables[intel] + 1
			
            if self.IntelDisables[intel] == 1 then
			
				--LOG("*AI DEBUG UNIT DisableUnitIntel for "..repr(intel))
				
				self:DisableIntel(intel)
				
				intDisabled = true
				
			end
			
        else
		
            for k, v in self.IntelDisables do
			
                self.IntelDisables[k] = v + 1
				
                if self.IntelDisables[k] == 1 then
				
					--LOG("*AI DEBUG basic Intel "..repr(k).." set off")
					
                    self:DisableIntel(k)
					
                    intDisabled = true
					
                end
				
            end
			
        end
		
        if intDisabled then
		
			self:OnIntelDisabled()
			
		end
		
    end,

    EnableUnitIntel = function(self, intel)
	
		if not self.Dead then
		
			local EnableIntel = moho.entity_methods.EnableIntel
		

			local intEnabled = false
			
			if self.CacheLayer == 'Seabed' or self.CacheLayer == 'Sub' or self.CacheLayer == 'Water' then
			
				EnableIntel(self,'WaterVision')
				
				if self.CacheLayer == 'Seabed' then
				
					self:DisableIntel('Vision')
					
				end
				
			end
			
			-- if an intel type and the intel table is ready
			-- since this will fire before intel table is setup
			if self.IntelDisables then
			
				-- used to enable a specific intel
				if intel then
			
					if self.IntelDisables[intel] == 1 then
					
						--LOG("*AI DEBUG UNIT EnableUnitIntel for "..repr(intel))
						
						EnableIntel(self,intel)
						
						intEnabled = true
						
					end
				
					self.IntelDisables[intel] = self.IntelDisables[intel] - 1
				
				else
				
					-- loop thru all intel types and try to turn them on
					for k, v in self.IntelDisables do
				
						if v == 1 then
		
							EnableIntel(self,k)

							if self:IsIntelEnabled(k) then
							
								--LOG("*AI DEBUG basic Intel "..repr(k).." enabled")
								
								intEnabled = true
								
							end
							
						end
					
						self.IntelDisables[k] = v - 1
						
					end
					
				end
				
			end
			
			if not GetBlueprint(self).Intel.FreeIntel then
			
				if self.IntelThread then
				
					KillThread(self.IntelThread)
					
					self.IntelThread = nil
					
				end
				
				if not self.IntelThread then
				
					self.IntelThread = self:ForkThread(self.IntelWatchThread)
					
				end
				
			end  
      
			if intEnabled then
			
				self:OnIntelEnabled()
				
			end
			
		end
		
    end,

	-- modified for BO:U cloaking credit to Black Ops team
    OnIntelEnabled = function(self)
	
		if not self.Dead then
		
			self:UpdateCloakEffect()
			
		end
		
    end,

    OnIntelDisabled = function(self)
	
		if not self.Dead then
		
			self:UpdateCloakEffect()
			
		end
		
    end,

    IntelWatchThread = function(self)
	
		local aiBrain = self:GetAIBrain()
		
        local bp = self:GetBlueprint()
	
		local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetScriptBit = moho.unit_methods.GetScriptBit
		local IsIntelEnabled = moho.entity_methods.IsIntelEnabled
		local TestToggleCaps = moho.unit_methods.TestToggleCaps
		local WaitTicks = coroutine.yield
		
		local bpVal = self:GetConsumptionPerSecondEnergy()
		local intelTypeTbl = {'Radar','Sonar','Omni','RadarStealthField','SonarStealthField','CloakField','Jammer','Cloak','Spoof','RadarStealth','SonarStealth'}

		-- incorporated this function for speed
		local function ShouldWatchIntel(self,bpVal)
		
			if not self.Dead then
			
				-- do we actually have any intel features turned on
				if bpVal > 0 then

					for k,v in intelTypeTbl do
					
						if IsIntelEnabled(self,v) then
						
							return true
							
						end
						
					end
					
				end
				
			end
			
			return false
			
		end

        local recharge = bp.Intel.ReactivateTime or 10
		
		recharge = 1 + (recharge * 10)	-- convert to ticks from seconds

        while ShouldWatchIntel(self, bpVal) and not self.Dead do
		
            WaitTicks(20)
			
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
				
					WaitTicks(recharge)
					
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
			
        end
		
    end,

    InheritWork = function(self, target)
	
        self.WorkItem = target.WorkItem
        self.WorkItemBuildCostEnergy = target.WorkItemBuildCostEnergy
        self.WorkItemBuildCostMass = target.WorkItemBuildCostMass
        self.WorkItemBuildTime = target.WorkItemBuildTime
		
    end,

    ClearWork = function(self)
	
        self.WorkItem = nil
        self.WorkItemBuildCostEnergy = nil
        self.WorkItemBuildCostMass = nil
        self.WorkItemBuildTime = nil
		
    end,

    OnWorkBegin = function(self, work)
	
        local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(GetEntityId(self))
        local tempEnhanceBp = GetBlueprint(self).Enhancements[work]

        if tempEnhanceBp.Prerequisite then
		
            if unitEnhancements[tempEnhanceBp.Slot] != tempEnhanceBp.Prerequisite then
			
                error('*ERROR: Ordered enhancement '..work..' does not have the proper prereq! ', 2)
                return false	-- should we be forking to OnWorkFail at this point ?
				
            end
			
        elseif unitEnhancements[tempEnhanceBp.Slot] then
		
			--LOG("*AI DEBUG "..self:GetAIBrain().Nickname.." "..self:GetBlueprint().Description.." Slot required is " .. tempEnhanceBp.Slot )
			
            error('*ERROR: Ordered enhancement '..work..' does not have the proper slot available!', 2)
            return false	-- as above, to OnWorkFail ?
			
        end
		
        self.WorkItem = tempEnhanceBp
        self.WorkItemBuildCostEnergy = tempEnhanceBp.BuildCostEnergy
        self.WorkItemBuildCostMass = tempEnhanceBp.BuildCostEnergy
        self.WorkItemBuildTime = tempEnhanceBp.BuildTime
        self.WorkProgress = 0
		
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('EnhanceStart')
		
        --self:PlayUnitAmbientSound('EnhanceLoop')
		
        self:UpdateConsumptionValues()
		
        self:CreateEnhancementEffects(work)
		
        LOUDSTATE(self,self.WorkingState)
		
    end,

    OnWorkEnd = function(self, work)
	
        self:SetActiveConsumptionInactive()
        self:PlayUnitSound('EnhanceEnd')
		
        --self:StopUnitAmbientSound('EnhanceLoop')
		
        self:CleanupEnhancementEffects()
		
    end,

    OnWorkFail = function(self, work)
	
        self:SetActiveConsumptionInactive()
		
        self:PlayUnitSound('EnhanceFail')
		
        --self:StopUnitAmbientSound('EnhanceLoop')
		
        self:ClearWork()
		
        self:CleanupEnhancementEffects()
		
    end,

    CreateEnhancement = function(self, enh)
		
        local bp = GetBlueprint(self).Enhancements[enh]
		
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
		
        self:RequestRefreshUI()
		
    end,

    CreateEnhancementEffects = function( self, enhancement )
    
        local bp = GetBlueprint(self).Enhancements[enhancement]
        
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
		
			self.UpgradeEffectsBag:Destroy()
			self.UpgradeEffectsBag = nil
			
		end
		
    end,

    HasEnhancement = function(self, enh)
	
        local entId = GetEntityId(self)
        local unitEnh = SimUnitEnhancements[entId]
		
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

        --LOG( 'GetTerrainTypeEffects for '..repr(TerrainType.Name)..' '..repr(TerrainType.Description)..' on '..repr(layer)..' '..repr(type))
		
        return TerrainType[FxType][layer][type] or {}
		
    end,

    CreateTerrainTypeEffects = function( self, effectTypeGroups, FxBlockType, FxBlockKey, TypeSuffix, EffectBag, TerrainType )

        local effects = {}

        for _, vTypeGroup in effectTypeGroups do
		
            if TerrainType then
			
                effects = TerrainType[FxBlockType][FxBlockKey][vTypeGroup.Type] or {}
				
            else
			
                effects = self.GetTerrainTypeEffects( FxBlockType, FxBlockKey, self:GetPosition(), vTypeGroup.Type, TypeSuffix )
				
            end
			
			if not table.empty(effects) then
			
				for kb, vBone in vTypeGroup.Bones do
				
					for ke, vEffect in effects do
					
						local emit = LOUDATTACHEMITTER( self, vBone, self.Sync.army, vEffect ):ScaleEmitter(vTypeGroup.Scale or 1)
						
						if vTypeGroup.Offset then
						
							emit:OffsetEmitter(vTypeGroup.Offset[1] or 0, vTypeGroup.Offset[2] or 0,vTypeGroup.Offset[3] or 0)
							
						end
						
						if EffectBag then
						
							LOUDINSERT( EffectBag, emit )
							
						end
						
					end
					
				end
				
			end
			
        end
		
    end,

    CreateIdleEffects = function( self )

        local bpTable = GetBlueprint(self).Display.IdleEffects
		
		-- if there are idle effects -- many dont have them
		if bpTable then

			if bpTable[self.CacheLayer].Effects then
			
				if not self.IdleEffectsBag then
				
					self.IdleEffectsBag = {}
					
				end
			
				self:CreateTerrainTypeEffects( bpTable[self.CacheLayer].Effects, 'FXIdle', self.CacheLayer, nil, self.IdleEffectsBag )
				
			end
			
		end
		
    end,

    DestroyIdleEffects = function( self )
	
		CleanupEffectBag(self,'IdleEffectsBag')
		
    end,

    UpdateBeamExhaust = function( self, motionState )

        local bpTable = GetBlueprint(self).Display.MovementEffects.BeamExhaust
		
        if not bpTable then
		
            return false
			
        end

        if motionState == 'Idle' then
		
            if self.BeamExhaustCruise  then
			
                self:DestroyBeamExhaust()
				
            end
			
            if self.BeamExhaustIdle and (bpTable.Idle != false) then	-- (LOUDGETN(self.BeamExhaustEffectsBag) == 0) and
			
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
	
        return Game.GetConstructEconomyModel(self, target_bp.Economy)
		
    end,

    -- Return the total time in seconds, cost in energy, and cost in mass to reclaim the given target from 100%.
    -- The energy and mass costs will normally be negative, to indicate that you gain mass/energy back.
    GetReclaimCosts = function(self, target_entity)
	
        local bp = GetBlueprint(self)
        local target_bp = target_entity:GetBlueprint()
		
        if IsUnit(target_entity) then

            local mtime = target_bp.Economy.BuildCostEnergy / self:GetBuildRate()
            local etime = target_bp.Economy.BuildCostMass / self:GetBuildRate()
            local time = mtime
			
            if mtime < etime then
			
                time = etime
				
            end
            
            time = time * (self.ReclaimTimeMultiplier or 1)
			
            return (time/10), target_bp.Economy.BuildCostEnergy, target_bp.Economy.BuildCostMass
			
        elseif IsProp(target_entity) then
		
            local time, energy, mass =  target_entity:GetReclaimCosts(self)
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
	
        return GetHealth(self) / GetBlueprint(self).Defense.MaxHealth
		
    end,

    ValidateBone = function(self, bone)
	
        if IsValidBone(self,bone) then
		
            return true
			
        end
		
        error('*ERROR: Trying to use the bone, ' .. bone .. ' on unit ' .. self:GetUnitId() .. ' and it does not exist in the model.', 2)
		
        return false
		
    end,

    CheckBuildRestriction = function(self, target_bp)

        if self:CanBuild(target_bp.BlueprintId) then
		
            return true
			
		end
		
        return false
		
    end,

    PlayUnitSound = function(self, sound)
		
        local bp = GetBlueprint(self).Audio
		
        if bp and bp[sound] then
		
            PlaySound( self, bp[sound])
            return true
			
        end
		
        return false
		
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
            self.Trash:Add(sndEnt)
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
		
				if v and unit and not unit.Dead and LOUDENTITY(v.Category, unit) then
			
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
			
                if v and unit and not unit.Dead and LOUDENTITY(v.Category, unit) then
				
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
            return
			
        end
		
        table.insert( self.EventCallbacks.OnTMLAmmoIncrease, fn )
		
        if not self.MLAmmoCheckThread then
		
            self.MLAmmoCheckThread = self:ForkThread(self.CheckCountedMissileAmmoIncrease)
			
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
		
        table.insert( self.EventCallbacks.OnTimedEvent, {fn = fn, interval = interval} )
		
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
            self.WorkItemBuildCostEnergy = nil
            self.WorkItemBuildCostMass = nil
            self.WorkItemBuildTime = nil
            self:PlayUnitSound('EnhanceEnd')
			
            --self:StopUnitAmbientSound('EnhanceLoop')
			
            self:EnableDefaultToggleCaps()
			
			self:OnCmdrUpgradeFinished()
			
            LOUDSTATE(self, self.IdleState)
			
        end,
		
    },

	-- this call can be made in two ways - one with a PosEntity value and one without
	-- and self can either be a target unit or the origin unit of the buff
	-- this makes it very flexible but tricky to read and you need to know where the call
	-- was made from before you can follow the flow
	-- the allow and disallow parsing has turned out to be problematic as well needing to be seperated by commas
	-- and not seeming to recognize the '-' (minus) operator
    AddBuff = function(self, buffTable, PosEntity)
	
        local bt = buffTable.BuffType

        local allow = categories.ALLUNITS
		
        if buffTable.TargetAllow then
            allow = LOUDPARSE(buffTable.TargetAllow)
        end
		
        local disallow = false
		
        if buffTable.TargetDisallow then
			disallow = LOUDPARSE(buffTable.TargetDisallow)
        end

        if bt == 'STUN' then

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
				
				if not targets then
				
					return
					
				end
				
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
		
            self:SetHealth(self, GetHealth(self) + (buffTable.Value or 0))
			
        elseif bt == 'SPEEDMULT' then
		
            self:SetSpeedMult(buffTable.Value or 0)
			
        elseif bt == 'MAXFUEL' then
		
            self:SetFuelUseTime(buffTable.Value or 0)
			
        elseif bt == 'FUELRATIO' then
		
            self:SetFuelRatio(buffTable.Value or 0)
			
        elseif bt == 'HEALTHREGENRATE' then
		
            self:SetRegenRate(buffTable.Value or 0)
			
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
		
            weapon:ChangeMaxRadius(buffTable.Value or weapon:GetBlueprint().MaxRadius)
			
        elseif bt == 'FIRINGRANDOMNESS' then
		
            weapon:SetFiringRandomness(buffTable.Value or 0)
			
        else
		
            self:AddBuff(buffTable)
			
        end
		
    end,
    
    -- This function should be used for kills made through the script, since kills through the engine (projectiles etc...) are already counted.
    AddKills = function(self, numKills)
	
        -- Add the kills, then check veterancy junk.
        local unitKills = self:GetStat('KILLS', 0).Value + numKills
		
        self:SetStat('KILLS', unitKills)
        
        local vet = GetBlueprint(self).Veteran or Game.VeteranDefault
        
        local vetLevels = table.getsize(vet)
		
        if self.VeteranLevel == vetLevels then
		
            return
			
        end

        local nextLvl = self.VeteranLevel + 1
        local nextKills = vet[('Level' .. nextLvl)]
        
        -- check if we gained more than one level
        while unitKills >= nextKills and self.VeteranLevel < vetLevels do
		
            self:SetVeteranLevel(nextLvl)
            
            nextLvl = self.VeteranLevel + 1
            nextKills = vet[('Level' .. nextLvl)]
			
        end 
		
    end,

    -- use this to go through the AddKills function rather than directly setting veterancy
    SetVeterancy = function(self, veteranLevel)
	
        veteranLevel = veteranLevel or 5
		
        if veteranLevel == 0 or veteranLevel > 5 then
		
            return
			
        end
		
        local bp = GetBlueprint(self)
		
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
	
        return self.VeteranLevel
		
    end,

    -- Check if we should veteran up.
    CheckVeteranLevel = function(self)
	
        local bp = GetBlueprint(self).Veteran or Game.VeteranDefault or false
		
        if (not bp) or not bp[('Level'..self.VeteranLevel + 1)] then
            return
        end
		
		local brain = self:GetAIBrain()
		
        if self:GetStat('KILLS', 0).Value >= bp[('Level' .. self.VeteranLevel + 1)] * ( 1.0 / (brain.VeterancyMult or 1.0) ) then

            self:SetVeteranLevel(self.VeteranLevel + 1)
			
			-- unit cap is increased by the veteran level * veterancy multiplier 
			SetArmyUnitCap( brain.ArmyIndex, GetArmyUnitCap(brain.ArmyIndex) + ( self.VeteranLevel * (brain.VeterancyMult or 1.0) ))
			
        end
		
    end,

    -- Set the veteran level to the level specified
    SetVeteranLevel = function(self, level)
		
        self.VeteranLevel = level
		
        -- Get the units override buffs if they exist
        local bp = GetBlueprint(self).Buffs
		
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
		
        --self:DoUnitCallbacks('OnVeteran')
		
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
		
            WARN('*WARNING: Tried to generate a buff of unknown type to units: ' .. buffType .. ' - UnitId: ' .. self:GetUnitId() )
			
            return nil
			
        end
        
        -- Generate a buffname based on the unitId
        local buffName = self:GetUnitId() .. levelName .. buffType
        
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
	
        LOUDATTACHEMITTER(self, 0, GetArmy(self), 'destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(1)
		
    end,

    CreateBeamExhaust = function( self, bpTable, beamBP )
	
        local effectBones = bpTable.Bones
		
        -- if not effectBones or (effectBones and (LOUDGETN(effectBones) == 0)) then
            -- LOG('*WARNING: No beam exhaust effect bones defined for unit ',repr(self:GetUnitId()),', Effect Bones must be defined to play beam exhaust effects. Add these to the Display.MovementEffects.BeamExhaust.Bones table in unit blueprint.' )
            -- return false
        -- end
		
        local army = GetArmy(self)
		
		
        for kb, vb in effectBones do
		
			if not self.BeamExhaustEffectsBag then
			
				self.BeamExhaustEffectsBag = {}
				
			end
		
            LOUDINSERT( self.BeamExhaustEffectsBag, CreateBeamEmitterOnEntity(self, vb, army, beamBP ))
			
        end
		
    end,

    DestroyBeamExhaust = function( self )
	
        CleanupEffectBag(self,'BeamExhaustEffectsBag')
		
    end,

    CreateShield = function(self, shieldSpec)
	
        local bp = GetBlueprint(self)
		
        local bpShield = shieldSpec or bp.Defense.Shield
		
        if bpShield then
		
            self:DestroyShield()
			
            self.MyShield = Shield {
                Owner = self,
				Mesh = bpShield.Mesh or '',
				MeshZ = bpShield.MeshZ or '',
				ImpactMesh = bpShield.ImpactMesh or '',
				ImpactEffects = bpShield.ImpactEffects or '',    
                Size = bpShield.ShieldSize or 10,
                ShieldMaxHealth = bpShield.ShieldMaxHealth or 250,
                ShieldRechargeTime = bpShield.ShieldRechargeTime or 10,
                ShieldEnergyDrainRechargeTime = bpShield.ShieldEnergyDrainRechargeTime or 10,
                ShieldVerticalOffset = bpShield.ShieldVerticalOffset or -1,
                ShieldRegenRate = bpShield.ShieldRegenRate or 1,
                ShieldRegenStartTime = bpShield.ShieldRegenStartTime or 5,
                PassOverkillDamage = bpShield.PassOverkillDamage or false,
            }
			
            self:SetFocusEntity( self.MyShield )
			
            self:EnableShield()
			
            self.Trash:Add( self.MyShield )

        end
		
    end,

    CreatePersonalShield = function(self, shieldSpec)
	
        local bp = GetBlueprint(self)
		
        local bpShield = shieldSpec or bp.Defense.Shield
		
        if bpShield then
		
            self:DestroyShield()
			
            if bpShield.OwnerShieldMesh then
			
                self.MyShield = UnitShield {
                    Owner = self,
					ImpactEffects = bpShield.ImpactEffects or '',                     
                    CollisionSizeX = bp.SizeX * 0.55 or 1,
                    CollisionSizeY = bp.SizeY * 0.55 or 1,
                    CollisionSizeZ = bp.SizeZ * 0.55 or 1,
                    CollisionCenterX = bp.CollisionOffsetX or 0,
                    CollisionCenterY = bp.CollisionOffsetY or 0,
                    CollisionCenterZ = bp.CollisionOffsetZ or 0,
                    OwnerShieldMesh = bpShield.OwnerShieldMesh,
                    ShieldMaxHealth = bpShield.ShieldMaxHealth or 250,
                    ShieldRechargeTime = bpShield.ShieldRechargeTime or 10,
                    ShieldEnergyDrainRechargeTime = bpShield.ShieldEnergyDrainRechargeTime or 10,
                    ShieldRegenRate = bpShield.ShieldRegenRate or 1,
                    ShieldRegenStartTime = bpShield.ShieldRegenStartTime or 5,
                    PassOverkillDamage = bpShield.PassOverkillDamage != false, -- default to true
                }
				
                self:SetFocusEntity(self.MyShield)
				
                self:EnableShield()
				
                self.Trash:Add(self.MyShield)
				
            else
			
                LOG('*WARNING: TRYING TO CREATE PERSONAL SHIELD ON UNIT ',repr(self:GetUnitId()),', but it does not have an OwnerShieldMesh=<meshBpName> defined in the Blueprint.')
				
            end
			
        end
		
    end,

    CreateAntiArtilleryShield = function(self, shieldSpec)
	
        local bp = GetBlueprint(self)
		
        local bpShield = shieldSpec
	
        if bpShield then
		
            self:DestroyShield()
			
            self.MyShield = AntiArtilleryShield {
                Owner = self,
				Mesh = bpShield.Mesh or '',
				MeshZ = bpShield.MeshZ or '',
				ImpactMesh = bpShield.ImpactMesh or '',
				ImpactEffects = bpShield.ImpactEffects or '',                
                Size = bpShield.ShieldSize or 10,
                ShieldMaxHealth = bpShield.ShieldMaxHealth or 250,
                ShieldRechargeTime = bpShield.ShieldRechargeTime or 10,
                ShieldEnergyDrainRechargeTime = bpShield.ShieldEnergyDrainRechargeTime or 10,
                ShieldVerticalOffset = bpShield.ShieldVerticalOffset or -1,
                ShieldRegenRate = bpShield.ShieldRegenRate or 1,
                ShieldRegenStartTime = bpShield.ShieldRegenStartTime or 5,
                PassOverkillDamage = bpShield.PassOverkillDamage or false,
            }
			
            self:SetFocusEntity(self.MyShield)
			
            self:EnableShield()
			
            self.Trash:Add(self.MyShield)
			
        end
		
    end,

    OnShieldEnabled = function(self)
	
        --self:PlayUnitSound('ShieldOn')
		
        -- drain energy
        self:SetMaintenanceConsumptionActive()
		
    end,

    OnShieldDisabled = function(self)
	
        --self:PlayUnitSound('ShieldOff')
		
        -- Turn off energy drain
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
		
            self:ClearFocusEntity()
            self.MyShield:Destroy()
            self.MyShield = nil
			
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
	
        self:DoUnitCallbacks('OnShieldIsUp')
		
    end,

	OnShieldIsDown = function(self)
	
        self:DoUnitCallbacks('OnShieldIsDown')
		
	end,

    OnShieldIsCharging = function(self)
	
        self:DoUnitCallbacks('OnShieldIsCharging')
		
    end,

    MarkWeaponsOnTransport = function(self, unit, transport)
	
        -- Mark the weapons on a transport
        if unit then
		
            for i = 1, GetWeaponCount(unit) do
			
                local wep = GetWeapon(unit,i) or false
				
				if wep then
				
					wep:SetOnTransport(transport)
					
				end
				
            end
			
        end
		
    end,
    
	-- issued by the Transport as a unit loads on
    OnTransportAttach = function(self, attachBone, unit)
	
        --self:PlayUnitSound('Load')
		
        self:MarkWeaponsOnTransport(unit, true)
		
        if unit:ShieldIsOn() then
		
            unit:DisableShield()
            unit:DisableDefaultToggleCaps()
			
        end
		
		unit:SetDoNotTarget(true)
        unit:SetCanTakeDamage(false)
		
        if not LOUDENTITY(categories.PODSTAGINGPLATFORM, self) then
		
            self:RequestRefreshUI()
			
        end
		
        unit:OnAttachedToTransport(self)
		
        self:DoUnitCallbacks( 'OnTransportAttach', unit )
		
    end,

	-- issued by the Transport as units are detached
    OnTransportDetach = function(self, attachBone, unit)
	
        --self:PlayUnitSound('Unload')
		
        self:MarkWeaponsOnTransport(unit, false)
		
		if not unit:ShieldIsOn() then
		
			unit:EnableShield()
			unit:EnableDefaultToggleCaps()
			
		end
		
		unit:SetDoNotTarget(false)
        unit:SetCanTakeDamage(true)

        if not LOUDENTITY(categories.PODSTAGINGPLATFORM, self) then
		
            self:RequestRefreshUI()
			
        end
		
        unit:TransportAnimation(-1)
		
        unit:OnDetachedToTransport(self)
		
        self:DoUnitCallbacks( 'OnTransportDetach', unit )
		
    end,

    OnAddToStorage = function(self, unit)
		
        if LOUDENTITY(categories.CARRIER, unit) then
		
            self:MarkWeaponsOnTransport(self, true)
			
            HideBone(self,0, true)
			
            self:SetCanTakeDamage(false)
            self:SetReclaimable(false)
            self:SetCapturable(false)
			
            if LOUDENTITY(categories.TRANSPORTATION, self) then
			
                local cargo = self:GetCargo()
				
                if LOUDGETN(cargo) > 0 then
				
                    for _, v in cargo do
					
                        v:MarkWeaponsOnTransport(self, true)
                        v:HideBone(0, true)
                        v:SetCanTakeDamage(false)
                        v:SetReclaimable(false)
                        v:SetCapturable(false)
                        --v:DisableShield()
						
                    end
					
                end
				
            end
			
        end
		
    end,

    OnRemoveFromStorage = function(self, unit)
		
        if LOUDENTITY(categories.CARRIER, unit) then
		
            self:SetCanTakeDamage(true)
            self:SetReclaimable(true)
            self:SetCapturable(true)
            self:ShowBone(0, true)
            self:MarkWeaponsOnTransport(self, false)
			
            if LOUDENTITY(categories.TRANSPORTATION, self) then
			
                local cargo = self:GetCargo()
				
                if LOUDGETN(cargo) > 0 then
				
                    for _, v in cargo do
					
                        v:MarkWeaponsOnTransport(self, false)
                        v:ShowBone(0, true)
                        v:SetCanTakeDamage(true)
                        v:SetReclaimable(true)
                        v:SetCapturable(true)
                        --v:EnableShield()
						
                    end
					
                end
				
            end
			
        end
		
    end,
	
	-- issued when a unit gets teleported
    OnTeleportUnit = function(self, teleporter, location, orientation)
	
		local id = GetEntityId(self)
		
		-- Teleport Cooldown Charge
		-- Range Check to location
		local maxRange = self:GetBlueprint().Defense.MaxTeleRange
		local myposition = self:GetPosition()
		local destRange = VDist2(location[1], location[3], myposition[1], myposition[3])
		
		if maxRange and destRange > maxRange then
		
			FloatingEntityText(id,'Destination Out Of Range')
			
			return
			
		end
		
		-- Teleport Interdiction Check
		for num, brain in ArmyBrains do
		
			local unitlist = brain:GetListOfUnits(categories.ANTITELEPORT, false)
			
			for i, unit in unitlist do
			
				--	if it's an ally, then we skip.
				if not IsEnemy(self:GetArmy(), unit:GetArmy()) then 
				
					continue
					
				end
				
				local noTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
				local atposition = unit:GetPosition()
				local selfpos = self:GetPosition()
				local targetdest = VDist2(location[1], location[3], atposition[1], atposition[3])
				local sourcecheck = VDist2(selfpos[1], selfpos[3], atposition[1], atposition[3])
				
				if noTeleDistance and noTeleDistance > targetdest then
				
					FloatingEntityText(id,'Teleport Destination Scrambled')
					return
					
				elseif noTeleDistance and noTeleDistance >= sourcecheck then
				
					FloatingEntityText(id,'Teleport Generator Scrambled')
					return
					
				end
				
			end
			
		end
		
        -- Economy Check and Drain
		local bp = self:GetBlueprint()
		local telecost = bp.Economy.TeleportBurstEnergyCost or 0
        local mybrain = self:GetAIBrain()
        local storedenergy = mybrain:GetEconomyStored('ENERGY')
		
		if telecost > 0 and not self.TeleportCostPaid then
		
			if storedenergy >= telecost then
			
				mybrain:TakeResource('ENERGY', telecost)
				self.TeleportCostPaid = true
				
			else
			
				FloatingEntityText(id,'Insufficient Energy For Teleportation')
				return
				
			end
			
		end
		
		#-- original code
        if self.TeleportDrain then
		
            RemoveEconomyEvent( self, self.TeleportDrain)
			
            self.TeleportDrain = nil
			
        end
		
        if self.TeleportThread then
		
            KillThread(self.TeleportThread)
			
            self.TeleportThread = nil
			
        end
		
        EffectUtilities.CleanupTeleportChargeEffects(self)
		
        self.TeleportThread = self:ForkThread(self.InitiateTeleportThread, teleporter, location, orientation)
		
    end,
	
	-- Like PlayTeleportChargeEffects, but scaled based on the size of the unit
	-- After calling this, you should still call CleanupTeleportChargeEffects
	PlayScaledTeleportChargeEffects = function(self)
	
		local army = self:GetArmy()
		local bp = self:GetBlueprint()

		local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
		local yOffset = (bp.Physics.MeshExtentsY or bp.SizeY or 1) / 2
		
		self.TeleportChargeBag = { }
		
		for k, v in EffectTemplate.GenericTeleportCharge01 do
		
			local fx = CreateEmitterAtEntity(self, army, v):OffsetEmitter(0, yOffset, 0):ScaleEmitter(scaleFactor)
			
			self.Trash:Add(fx)
			
			table.insert(self.TeleportChargeBag, fx)
			
		end
		
	end,
	
	-- Like PlayTeleportOutEffects, but scaled based on the size of the unit 
	PlayScaledTeleportOutEffects = function(self)
	
		local army = self:GetArmy()
		local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
		
		for k, v in EffectTemplate.GenericTeleportOut01 do
		
			CreateEmitterAtEntity(self, army, v):ScaleEmitter(scaleFactor)
			
		end
		
	end,
	
	-- Like PlayTeleportInEffects, but scaled based on the size of the unit
	PlayScaledTeleportInEffects = function(self)
	
		local army = self:GetArmy()
		local bp = self:GetBlueprint()
		local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
		
		local yOffset = (bp.Physics.MeshExtentsY or bp.SizeY or 1) / 2
		
		for k, v in EffectTemplate.GenericTeleportIn01 do
		
			CreateEmitterAtEntity(self, army, v):OffsetEmitter(0, yOffset, 0):ScaleEmitter(scaleFactor)
			
		end
		
	end,	
	
	CleanupTeleportChargeEffects = function(self)
	
		EffectUtilities.CleanupTeleportChargeEffects(self)
		
	end,

    OnFailedTeleport = function(self)
	
        if self.TeleportDrain then
		
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
        self.UnitBeingTeleported = nil
		
		-- from BO:U
		if not self.Dead and not self.EXPhaseEnabled == false then   
		
			self.EXPhaseEnabled = false
			self.EXPhaseCharge = 0
			self.EXPhaseShieldPercentage = 0
			
			local bp = self:GetBlueprint()
			local bpDisplay = bp.Display
			
			if self.EXPhaseCharge == 0 then
			
				self:SetMesh(bpDisplay.MeshBlueprint, true)
				
			end
			
        end
		
    end,

    UpdateTeleportProgress = function(self, progress)
	
        self:SetWorkProgress(progress)
		
    end,

    InitiateTeleportThread = function(self, teleporter, location, orientation)
	
        self:OnTeleportCharging(location)
	
        local tbp = teleporter:GetBlueprint()
        local ubp = GetBlueprint(self)
		
        self.UnitBeingTeleported = self
        self:SetImmobile(true)
        self:PlayUnitSound('TeleportStart')
        --self:PlayUnitAmbientSound('TeleportLoop')
		
        local bp = GetBlueprint(self).Economy
		
        local energyCost, time
		
        if bp then
		
            local mass = bp.BuildCostMass * math.min(.1, bp.TeleportMassMod or 0.01)
            local energy = bp.BuildCostEnergy * math.min(.01, bp.TeleportEnergyMod or 0.001)
			
            energyCost = mass + energy
			
			-- teleport never takes more than 5 seconds --
            time = math.min(5, energyCost * math.max(.02, bp.TeleportTimeMod or 0.0001))
			
			--LOG('*UNIT DEBUG: TELEPORTING, bp values Mass '..repr(mass)..'  Energy '..repr(energy)..'  Combined Cost '..repr(energyCost)..' time = '..repr(time) )
			
        end

        self.TeleportDrain = CreateEconomyEvent(self, energyCost or 100, 0, time or 5, self.UpdateTeleportProgress)

        -- teleport charge effect
        EffectUtilities.PlayTeleportChargeEffects(self)

        WaitFor( self.TeleportDrain  ) 		-- Perform fancy Teleportation FX here

        if self.TeleportDrain then
		
            RemoveEconomyEvent(self, self.TeleportDrain )
			
            self.TeleportDrain = nil
			
        end

        EffectUtilities.PlayTeleportOutEffects(self)

        EffectUtilities.CleanupTeleportChargeEffects(self)

        WaitTicks(1)

        self:SetWorkProgress(0.0)
        Warp(self, location, orientation)
		
        EffectUtilities.PlayTeleportInEffects(self)

        WaitTicks(1) 	-- Perform cooldown Teleportation FX here
        
        --self:StopUnitAmbientSound('TeleportLoop')
        self:PlayUnitSound('TeleportEnd')
        self:SetImmobile(false)
        self.UnitBeingTeleported = nil
        self.TeleportThread = nil
		
        self:OnTeleported(location)
		
    end,
	
    OnTeleportCharging = function(self, location)
	
        --self:DoUnitCallbacks('OnTeleportCharging', location)
		
    end,

    OnTeleported = function(self, location)
	
        --self:DoUnitCallbacks('OnTeleported', self, location)
		
    end,
	
	--  Summary  :  SHIELD Scripts required for drone spawned bubble shields.
	--  Copyright © 2010 4DC  All rights reserved.
    SpawnDomeShield = function(self) 
	
        if not self.Dead then    
		
            -- Get units bp 
            local bp = self:GetBlueprint() 
            
            -- Initialize variables 
            local sldArea, offSet, sldHealth            
            local x, y, z = self:GetUnitSizes()   
            
            self.XzySize = {}      
            table.insert(self.XzySize, x)
            table.insert(self.XzySize, y)   
            table.insert(self.XzySize, z)                                       
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
            self:SetConsumptionPerSecondEnergy(eCost)             

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
			
            self.Trash:Add(self.MyShield)      
			
        end 
		
    end,   

	--  Summary  :  SHIELD Scripts required for drone spawned personal shields.
	--  Note     :  This script enables a drone to enhance MLU's (Moble Land Units) 
	--              and Structures with shields. The type of shield and enhancement
	--              strength given a unit is determined by that units type and tech.
    SpawnPersonalShield  = function(self) 
	
        if not self.Dead then 

            -- Get units bp and Initialize variables
            local bp = self:GetBlueprint() 
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
            self:SetConsumptionPerSecondEnergy(eCost) 
            
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
			
			ForkTo( FloatingEntityText, self.Sync.id, "Initiating Personal Shield - "..sldHealth.." strength")
			
            self:EnableShield()
            self.Trash:Add(self.MyShield)                               
        end              
    end,

	-- Black Ops Unleashed - cloaking mod
	-- All credit to the Black Ops team - I merely optimized some aspects and moved the functions into the core
    
	-- This thread runs constantly in the background for ALL units. It ensures that the cloak effect and cloak field are always in the correct state
	-- This task hogs a buttload of CPU - original wait period was 2 ticks - now 80 
	CloakEffectControlThread = function(self,blueprint)
	
		local bp = blueprint or self:GetBlueprint()
		local brain = self:GetAIBrain()
		
		-- local a bunch of repetitive functions
		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		local IsIntelEnabled = moho.entity_methods.IsIntelEnabled
	
		if not self.Dead then
		
			if not bp.Intel.CustomCloak then
			
				local bpDisplay = bp.Display
				local flushpass = 0
				
				local cloakrange = (bp.Intel.CloakFieldRadius - 3) or 0
				
				while not self.Dead and (bp.Intel.CloakFieldRadius > 0 or bp.Intel.Cloak == true) do
					
					self:UpdateCloakEffect(bp) 	-- update the cloak effect for the source unit
					
					-- only units with a cloaking field do this part
					if bp.Intel.CloakFieldRadius > 3 then
					
						local CloakFieldIsActive = IsIntelEnabled( self, 'CloakField')
					
						if CloakFieldIsActive then
						
							local position = self:GetPosition()
							
							-- Range must be (radius - 3) because it seems GPG did that for the actual field for some reason.
							-- Anything beyond (radius - 3) is not cloaked by the cloak field
							-- flush intel 
							
							-- cloak field generating structures will flush ALL intel in their radius
							-- there are no cloak field generating UNITS so this should work just fine
							-- on every fourth loop (32 seconds) -- this was important to the AI
							-- giving it time to 'see' what is cloaked if it spotted it - for it's Intel routines
							if EntityCategoryContains(categories.STRUCTURE,self) and flushpass > 3 then
							
								FlushIntelInRect( position[1]-cloakrange, position[3]-cloakrange, position[1]+cloakrange, position[3]+cloakrange )
								flushpass = 0
								
							else
							
								flushpass = flushpass + 1
								
							end
							
							local UnitsInRange = GetUnitsAroundPoint( brain, categories.ALLUNITS, position, cloakrange, 'Ally' )
						
							-- start up the CloakFieldThread for any units found
							-- kill any existing thread if there is one
							-- notice that this runs every pass, so units will re-cloak after only 8 seconds when revealed
							for num, unit in UnitsInRange do

								unit.InCloakField = nil
							
								if unit.InCloakFieldThread then
								
									KillThread(unit.InCloakFieldThread)
									
									unit.InCloakFieldThread = nil
									
								end
							
								unit.InCloakFieldThread = unit:ForkThread(unit.InCloakFieldWatchThread, unit:GetBlueprint())
								
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
		
		self.InCloakField = nil
		
		if self.InCloadFieldThread then
		
			KillThread(self.InCloaKFieldThread)
			self.InCloakFieldThread = nil
			
		end
		
		self:UpdateCloakEffect(bp)
		
	end,

	-- This is the core of the entire mod. The effect is actually applied here.
	UpdateCloakEffect = function(self, bp)
	
		if not self.Dead then
		
			local bp = bp or self:GetBlueprint()
			local bpDisplay = bp.Display
			
			if not bp.Intel.CustomCloak then
			
				local cloaked = self.InCloakField or self:IsIntelEnabled('Cloak')
				
				if (not cloaked and self.CloakEffectEnabled) or self:GetHealth() <= 0 then
				
					self:SetMesh(bpDisplay.MeshBlueprint, true)
					self.CloakEffectEnabled = nil
					
				elseif (cloaked and not self.CloakEffectEnabled) and bpDisplay.CloakMeshBlueprint then
				
					self:SetMesh(bpDisplay.CloakMeshBlueprint , true)
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

    OnDetectedBy = function(self, index)
	
		LOG("*AI DEBUG OnDetectedBy "..repr(self:GetBlueprint().Description).." by "..ArmyBrains[index].Nickname )
		
		LOG("*AI DEBUG SeenEver is "..repr( moho.blip_methods.IsSeenEver( moho.unit_methods.GetBlip(self,index), index)))
		
		LOG("*AI DEBUG SeenNow  is "..repr( moho.blip_methods.IsSeenNow( moho.unit_methods.GetBlip(self,index),index)))
	
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

	-- superceded by DefaultUnits --
    OnRunOutOfFuel = function(self)
	
        self.HasFuel = false
		
		if self.TopSpeedEffectsBag then
			self:DestroyTopSpeedEffects()
		end
		
        self:DoUnitCallbacks('OnRunOutOfFuel')
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

    DestroyedOnTransport = function(self)
    end,

	-- triggered when the transport (not the unit) cancel the transport
    OnTransportAborted = function(self)
    end,

	-- not quite sure how this one works - it seems to come after the OnStartTransportLoading
    OnTransportOrdered = function(self)
		LOG("*AI DEBUG OnTransportOrdered "..self:GetBlueprint().Description)
    end,

	-- triggered when the transport is given a load order
    OnStartTransportLoading = function(self)
		LOG("*AI DEBUG OnStartTransportLoading "..self:GetBlueprint().Description)
    end,

	-- triggered  when the transport is no longer loading (success or cancelled)
    OnStopTransportLoading = function(self)
		LOG("*AI DEBUG OnStopTransportLoading "..self:GetBlueprint().Description)
    end,

    OnStartRefueling = function(self)
        self:PlayUnitSound('Refueling')
        self:DoUnitCallbacks('OnStartRefueling')
    end,


    OnGotFuel = function(self)
        self.HasFuel = true
        self:DoUnitCallbacks('OnGotFuel')
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
            for num, aiBrain in ArmyBrains do
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

	-- this appears interesting - looks like you put in a function that would be
	-- executed whenever the index detects the unit
    AddDetectedByHook = function(self,hook)
	
        if not self.DetectedByHooks then
            self.DetectedByHooks = {}
        end
		
		LOG("*AI DEBUG Adding DetectedByHook for "..repr(self:GetBlueprint().Description.." on "..repr(hook)))
		
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

--]]