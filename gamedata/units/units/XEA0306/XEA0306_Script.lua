local explosion = import('/lua/defaultexplosions.lua')
local util = import('/lua/utilities.lua')

local TAirUnit = import('/lua/terranunits.lua').TAirUnit

local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher
local TDFHeavyPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFHeavyPlasmaCannonWeapon

XEA0306 = Class(TAirUnit) {

    AirDestructionEffectBones = {'FrontRight_Engine_Exhaust','FrontLeft_Engine_Exhaust','BackRight_Engine_Exhaust','BackLeft_Engine_Exhaust'},

    ShieldEffects = {'/effects/emitters/terran_shield_generator_mobile_01_emit.bp',
					 '/effects/emitters/terran_shield_generator_mobile_02_emit.bp',
	},

    BeamExhaustCruise = '/effects/emitters/transport_thruster_beam_01_emit.bp',
    BeamExhaustIdle = '/effects/emitters/transport_thruster_beam_02_emit.bp',
	
    Weapons = {
	
        AAMissle = Class(TSAMLauncher) {},
        PlasmaGun = Class(TDFHeavyPlasmaCannonWeapon) {},
		
    },

    DestructionTicks = 125,
    EngineRotateBones = {'FrontRight_Engine', 'FrontLeft_Engine', 'BackRight_Engine', 'BackLeft_Engine', },
    
    OnCreate = function(self)
	
        TAirUnit.OnCreate(self)
        
        self.UnfoldAnim = CreateAnimator(self)
		
        self.UnfoldAnim:PlayAnim('/units/xea0306/xea0306_aunfold.sca')
		
        self.UnfoldAnim:SetRate(0)
		
    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
        TAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.EngineManipulators = {}
        
        self.UnfoldAnim:SetRate(1)
        
        -- create the engine thrust manipulators
        for k, v in self.EngineRotateBones do
		
            table.insert(self.EngineManipulators, CreateThrustController(self, "thruster", v))
			
        end

        -- set up the thursting arcs for the engines
        for keys,values in self.EngineManipulators do
		
            #                      XMAX,XMIN,YMAX,YMIN,ZMAX,ZMIN, TURNMULT, TURNSPEED
            values:SetThrustingParam( -0.25, 0.25, -0.75, 0.75, -0.0, 0.0, 1.0, 0.25 )
			
        end

        self.LandingAnimManip = CreateAnimator(self)
        self.LandingAnimManip:SetPrecedence(0)
		
        self.Trash:Add(self.LandingAnimManip)
		
        self.LandingAnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand):SetRate(1)
		
    end,
	
	OnTransportAttach = function(self, attachBone, unit)
	
		TAirUnit.OnTransportAttach(self, attachBone, unit)
		
        unit:SetCanTakeDamage(not self.ShieldIsOn) #-- make transported unit invulnerable if transport is too
		
	end,
	
    OnTransportDetach = function(self, attachBone, unit)
	
        unit:SetCanTakeDamage(true) #-- Units dropped by the transport should be vulnerable
		
		TAirUnit.OnTransportDetach(self, attachBone, unit)
		
	end,
	
    OnShieldIsUp = function (self)
	
		self.ShieldIsOn = true
		
        TAirUnit.OnShieldIsUp(self)
		
        self:ShieldStatusChanged(true)
		
    end,
	
    OnShieldIsDown = function (self)
	
		self.ShieldIsOn = false
		
		TAirUnit.OnShieldIsDown(self)
		
		self:ShieldStatusChanged(false)
		
    end,	

	-- toggles the invulnerability of the units on the transport
    ShieldStatusChanged = function( self )

		-- toggles invulnerability of transport according to shield statue
        self:SetCanTakeDamage(not self.ShieldIsOn)
		
		if not self.Dead then
		
			local cargo = self:GetCargo()
			
        	for k, v in cargo do
			
				if not v.Dead then
				
		            v:SetCanTakeDamage(not self.ShieldIsOn)
					
				end
				
        	end
			
		end
		
		return
		
    end,
	
    --When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
	
        attached:DetachFrom()
		
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        if self.GetCargo then
		
            local cargo = self:GetCargo() #-- added by brute51  all carried units should be vulnerable again
			
            for k, v in cargo do
			
                v:SetCanTakeDamage(true) 
				
            end
			
        end	
		
        TAirUnit.OnKilled(self, instigator, type, overkillRatio)
		
        -- TransportDetachAllUnits takes 1 bool parameter. If true, randomly destroys some of the transported
        -- units, otherwise successfully detaches all.
        self:TransportDetachAllUnits(true)
		
    end,

    OnMotionVertEventChange = function(self, new, old)
	
        TAirUnit.OnMotionVertEventChange(self, new, old)
		
        if (new == 'Down') then
		
            self.LandingAnimManip:SetRate(-1)
			
        elseif (new == 'Up') then
		
            self.LandingAnimManip:SetRate(1)
			
        end
		
    end,

    -- Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function( self, scale )
	
        self:ForkThread(self.AirDestructionEffectsThread, self )
		
    end,

    AirDestructionEffectsThread = function( self )
	
        local numExplosions = math.floor( table.getn( self.AirDestructionEffectBones ) * 0.5 )
		
        for i = 0, numExplosions do
		
            explosion.CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[util.GetRandomInt( 1, numExplosions )], 0.5 )
            WaitSeconds( util.GetRandomFloat( 0.2, 0.9 ))
			
        end
		
    end,
    
    GetUnitSizes = function(self)
	
        local bp = self:GetBlueprint()
		
        if self:GetFractionComplete() < 1.0 then
		
            return bp.SizeX, bp.SizeY, bp.SizeZ * 0.5
			
        else
		
            return bp.SizeX, bp.SizeY, bp.SizeZ
			
        end
		
    end,    

}

TypeClass = XEA0306