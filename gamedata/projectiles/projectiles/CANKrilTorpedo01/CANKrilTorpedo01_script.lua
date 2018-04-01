local CKrilTorpedo = import('/lua/cybranprojectiles.lua').CKrilTorpedo

local CreateEmitterAtEntity = CreateEmitterAtEntity

-- The Kril is a very energetic torpedo - sometimes jumping out of the water
-- it's initially poor turning radius increases over it's lifetime
CANKrilTorpedo01 = Class(CKrilTorpedo) {

    FxEnterWater= { '/effects/emitters/water_splash_plume_01_emit.bp' },
	TrailDelay = 2,                    

    OnCreate = function(self)
	
        CKrilTorpedo.OnCreate(self, true)
		
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
		
		self:ForkThread(self.IncreaseTurnRate)
		
    end,	
    
    OnEnterWater = function(self)
	
        CKrilTorpedo.OnEnterWater(self)
		
		self:SetBallisticAcceleration(0)	-- deter gravity

		self:ForkThread(self.EnableTargetTrack)
		
        local army = self:GetArmy()
		
        for i in self.FxEnterWater do  --splash
            CreateEmitterAtEntity( self, army, self.FxEnterWater[i] )
        end
		
    end,
	
	OnExitWater = function(self)
	
		self:SetBallisticAcceleration(-10)	-- gravity pulls it down
		
        local army = self:GetArmy()	
		
		for i in self.FxEnterWater do
            CreateEmitterAtEntity( self, army, self.FxEnterWater[i] )		
		end
		
		self:ForkThread(self.DisableTargetTrack)
		
	end,
	
	IncreaseTurnRate = function(self)
	
		WaitSeconds(3)
		
		self:SetTurnRate(80)
		
		WaitSeconds(3)
		
		self:SetTurnRate(160)
		
		WaitSeconds(2)
		
		self:SetTurnRate(240)
		
	end,
	
	DisableTargetTrack = function(self)
		
		WaitSeconds(0.5)
		
		self:TrackTarget(false)
		
	end,
	
	EnableTargetTrack = function(self)
	
		WaitSeconds(0.2)
		
		self:TrackTarget(true)
	
	end,
	
}

TypeClass = CANKrilTorpedo01