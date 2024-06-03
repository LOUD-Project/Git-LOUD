--------------------------------------------------------------------------------
--  Summary:  Cybran Mobile Radar script
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CRadarUnit = import('/lua/defaultunits.lua').RadarUnit

local CDFElectronBolterWeapon = import('/lua/cybranweapons.lua').CDFElectronBolterWeapon
local BrewLANLOUDPath = import( '/lua/game.lua' ).BrewLANLOUDPath()

SRL0324 = Class(CLandUnit) {

    OnCreate = function(self)
        self.FxBlinkingLightsBag = {}
        CLandUnit.OnCreate(self)
        self.Bits = {}
    end,

    OnStopBeingBuilt = function(self, ...)

        CLandUnit.OnStopBeingBuilt(self, unpack(arg) )
	
        self:SetMaintenanceConsumptionActive()

        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('Cloak')
		
        self.Cloaked = false
		
        ChangeState( self, self.InvisState )
    end,

    OnScriptBitSet = function(self, bit)
	
        self.Bits[bit] = true
		
        CLandUnit.OnScriptBitSet(self, bit)
		
        ChangeState( self, self.VisibleState )
    end,

    OnScriptBitClear = function(self, bit)
	
        self.Bits[bit] = false
		
        CLandUnit.OnScriptBitClear(self, bit)
		
        ChangeState( self, self.InvisState )
    end,

    OnIntelDisabled = function(self,intel)

        CRadarUnit.OnIntelDisabled(self,intel)
		
        if self.Threads and self.Threads[4][1] then
		
            self:DestroyIdleEffects()
            self:DestroyBlinkingLights()
            self:CreateBlinkingLights('Red')
			
        end
		
        if self.Threads then
		
            self.Threads[4][1] = false
			
            local bp = self:GetBlueprint()
			
            self.AnimManip:SetRate(-2)
			
            CreateSplatOnBone(self, {0, 0, 0}, 0, BrewLANLOUDPath .. "/units/SRL0324/SRL0324_DeploySplat.dds", 1.75, 1.75, 100, 120, self:GetArmy() )
			
            self:SetCollisionShape(
                'Box',
                bp.CollisionOffsetX or 0,
                bp.CollisionOffsetY or 0,
                bp.CollisionOffsetZ or 0,
                bp.SizeX * 0.5,
                bp.SizeY * 0.5,
                bp.SizeZ * 0.5
            )
        end
    end,

    OnIntelEnabled = function(self,intel)

        CRadarUnit.OnIntelEnabled(self,intel)
		
        if self.Threads and not self.Threads[4][1] then
		
            local bp = self:GetBlueprint()
			
            self.AnimManip:SetRate(2)
			
            self:SetCollisionShape(
                'Box',
                bp.CollisionOffsetX or 0,
                (bp.CollisionOffsetY or 0) * 3,
                bp.CollisionOffsetZ or 0,
                bp.SizeX * 0.5,
                bp.SizeY * 1.5,
                bp.SizeZ * 0.5
            )
            self:DestroyBlinkingLights()
            self:CreateBlinkingLights('Green')

        end
		
        if not self.Threads then
		
            self.Threads = { {'Sensor_D001'},{'Sensor_D002'},{'Sensor_D003'} }
			
            for i, v in self.Threads do
                self.Threads[i][2] = CreateRotator(self, v[1], 'z', 0, 10, 4, 10)
                self.Trash:Add(self.Threads[i][2])
            end
			
            self.Threads[4] = { true, self:ForkThread(self.DishBehavior) }
			
            self.Trash:Add(self.Threads[4][2])
			
            self.AnimManip = CreateAnimator(self)
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationOpen)
			
        else
		
            self.Threads[4][1] = true
			
        end
		
    end,

    DishBehavior = function(self)
	
        while true do
		
            if self.Threads[4][1] then
			
                for i, v in self.Threads do
				
                    if i < 4 and math.random(1,3) == 3 then
                        WaitFor(self.Threads[i][2])
                        self.Threads[i][2]:SetGoal(math.random(0,45) )
                    end
					
                end
				
            end
			
            WaitTicks(math.random(4,8))
			
        end
		
    end,

    CreateBlinkingLights = function(self, color)
	
        if CRadarUnit.CreateBlinkingLights then
			CRadarUnit.CreateBlinkingLights(self, color)
        end
    end,

    DestroyBlinkingLights = function(self)
	
        if CRadarUnit.DestroyBlinkingLights then
			CRadarUnit.DestroyBlinkingLights(self)
        end
		
    end,

    OnStartTransportBeamUp = function(self, transport, bone)
	
        CLandUnit.OnStartTransportBeamUp(self, transport, bone)
		
        ChangeState( self, self.VisibleState )
		
        self.LastTransportedTime = GetGameTimeSeconds()
    end,

    InvisState = State() {
	
        Main = function(self)
		
            self.Cloaked = false
			
            local bp = self:GetBlueprint()
			
            if bp.Intel.StealthWaitTime then
                WaitSeconds( bp.Intel.StealthWaitTime )
            end

            if not self.Bits[3] then
                self:EnableUnitIntel('RadarStealth')
                self:EnableUnitIntel('Cloak')
                self:EnableUnitIntel('Omni')
                self:EnableUnitIntel('Radar')
				
                self:SetMaintenanceConsumptionActive()
				
				self:AddToggleCap('RULEUTC_IntelToggle')
				
                self.Cloaked = true
				
            end
			
        end,

        OnMotionHorzEventChange = function(self, new, old)
		
            if new != 'Stopped' then

                ChangeState( self, self.VisibleState )

            end
			
            CLandUnit.OnMotionHorzEventChange(self, new, old)
			
        end,
		
    },

    VisibleState = State() {
	
        Main = function(self)

            if self.Cloaked then
			
                self:DisableUnitIntel('RadarStealth')
                self:DisableUnitIntel('Cloak')
                self:DisableUnitIntel('Omni')
                self:DisableUnitIntel('Radar')
				
                self:SetMaintenanceConsumptionInactive()

            end
			
        end,

        OnMotionHorzEventChange = function(self, new, old)
		
            if new == 'Stopped' and (self.LastTransportedTime or 0) + 2 < GetGameTimeSeconds() then
			
				self:AddToggleCap('RULEUTC_IntelToggle')
				
                ChangeState( self, self.InvisState )

            end
			
            CLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
		
    },
	
}

TypeClass = SRL0324
