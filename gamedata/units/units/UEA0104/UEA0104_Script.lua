local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local CreateDefaultHitExplosionAtBone = import('/lua/defaultexplosions.lua').CreateDefaultHitExplosionAtBone
local GetRandomFloat = import('/lua/utilities.lua').GetRandomFloat
local GetRandomInt = import('/lua/utilities.lua').GetRandomInt

local WeaponsFile = import('/lua/terranweapons.lua')

local TAALinkedRailgun    = WeaponsFile.TAALinkedRailgun
local TDFRiotWeapon             = WeaponsFile.TDFRiotWeapon

WeaponsFile = nil

local ForkThread = ForkThread
local WaitTicks = coroutine.yield

UEA0104 = Class(TAirUnit) {
    AirDestructionEffectBones = { 'Char04', 'Char03', 'Char02', 'Char01',
                                'Front_Right_Exhaust','Front_Left_Exhaust','Back_Right_Exhaust','Back_Left_Exhaust',
                                'Right_Arm05','Right_Arm07','Right_Arm02','Right_Arm03', 'Right_Arm04','Right_Arm01'},


    BeamExhaustCruise = '/effects/emitters/transport_thruster_beam_01_emit.bp',
    BeamExhaustIdle = '/effects/emitters/transport_thruster_beam_02_emit.bp',

    Weapons = {
        LinkedRailGun = Class(TAALinkedRailgun) {},
        RiotGun = Class(TDFRiotWeapon) {},
    },

    DestructionTicks = 250,
    EngineRotateBones = {'Front_Right_Engine', 'Front_Left_Engine', 'Back_Left_Engine', 'Back_Right_Engine', },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.EngineManipulators = {}

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
		
        self:ForkThread(self.ExpandThread)
		
    end,

    -- When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
	
        attached:DetachFrom()
		
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
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
		
            CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[GetRandomInt( 1, numExplosions )], 0.5 )
            WaitTicks( GetRandomFloat( 0.2, 0.9 ) * 10)
			
        end
		
    end,

    OnCreate = function(self)
	
        TAirUnit.OnCreate(self)
		
        --CreateSlider(unit, bone, [goal_x, goal_y, goal_z, [speed, 
        self.Sliders = {}
        self.Sliders[1] = CreateSlider(self, 'Char01')
        self.Sliders[1]:SetGoal(0, 0, -35)
        self.Sliders[2] = CreateSlider(self, 'Char02')
        self.Sliders[2]:SetGoal(0, 0, -15)
        self.Sliders[3] = CreateSlider(self, 'Char03')
        self.Sliders[3]:SetGoal(0, 0, 15)
        self.Sliders[4] = CreateSlider(self, 'Char04')
        self.Sliders[4]:SetGoal(0, 0, 35)
		
        for k, v in self.Sliders do
		
            v:SetSpeed(-1)
            self.Trash:Add(v)
			
        end
		
    end,
    
    ExpandThread = function(self)
	
        if self.Sliders then
		
            for k, v in self.Sliders do
			
                v:SetGoal(0, 0, 0)
                v:SetSpeed(10)
				
            end
			
            WaitFor(self.Sliders[4])
			
            for k, v in self.Sliders do
			
                v:Destroy()
				
            end
			
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

TypeClass = UEA0104