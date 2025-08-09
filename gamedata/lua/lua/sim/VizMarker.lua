---  /lua/defaultvizmarkers.lua
---  Summary  :  Visibility Entities

local Entity = import('/lua/sim/Entity.lua').Entity

local WaitTicks = coroutine.yield

local VectorCached = { 0, 0, 0 }
local Warp = Warp

VizMarker = Class(Entity) {

    __init = function(self, spec)

        Entity.__init(self, spec)
        
        --LOG("*AI DEBUG Vizmarker __init is "..repr(spec))
        
        self.X = spec.X
        self.Z = spec.Z

        self.Army       = spec.Army
        self.LifeTime   = spec.LifeTime
        self.Radius     = spec.Radius

        self.Omni       = spec.Omni
        self.Radar      = spec.Radar
        self.Vision     = spec.Vision
        self.WaterVis   = spec.WaterVision
    end,

    OnCreate = function(self)
	
        Entity.OnCreate(self)
        
        local vec = VectorCached
        
        --LOG("*AI DEBUG Vizmarker OnCreate is "..repr(self))
        
        vec[1] = self.X
        vec[2] = 0
        vec[3] = self.Z

        Warp( self, vec )
		
        if self.Omni    != false then
            self:InitIntel(self.Army, 'Omni', self.Radius)
            self:EnableIntel('Omni')
        end
        if self.Radar   != false then
            self:InitIntel(self.Army, 'Radar', self.Radius)
            self:EnableIntel('Radar')
        end        
        if self.Vision  != false then
            self:InitIntel(self.Army, 'Vision', self.Radius)
            self:EnableIntel('Vision')
        end
        if self.WaterVis != false then
            self:InitIntel(self.Army, 'WaterVision', self.Radius)
            self:EnableIntel('WaterVision')
        end
 
        if self.LifeTime > 0 then
            self.LifeTimeThread = ForkThread(self.VisibleLifeTimeThread, self)
        end
    end,

    VisibleLifeTimeThread = function(self)
        WaitTicks(self.LifeTime * 10)
        self:Destroy()
    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        if self.LifeTimeThread then
            self.LifeTimeThread:Destroy()
        end
    end
}
