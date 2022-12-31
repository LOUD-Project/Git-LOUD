--  Summary:  Field engineer boat

local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit
local CAAAutocannon = import('/lua/cybranweapons.lua').CAAAutocannon

local BrewLANLOUDPath = import( '/lua/game.lua' ).BrewLANLOUDPath()

local AssistThread = import(BrewLANLOUDPath .. '/lua/fieldengineers.lua').AssistThread
local EffectUtil = import('/lua/EffectUtilities.lua')

SRS0219 = Class(CSeaUnit) {
    DestructionTicks = 200,

    Weapons = {
        AAGun = Class(CAAAutocannon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateRotator(self, 'Cybran_Radar', 'y', nil, 90, 0, 0))
        self.Trash:Add(CreateRotator(self, 'Back_Radar', 'y', nil, -360, 0, 0))
        self.Trash:Add(CreateRotator(self, 'Front_Radar', 'y', nil, -180, 0, 0))
        self:ForkThread(AssistThread)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
    
        if self.Dead then return end

        -- reattach the permanent projectile
        for _, v in self.BuildProjectile do 
        
            TrashDestroy ( v.BuildEffectsBag )
        
            if v.Detached then
                v:AttachTo( self, v.Name )
            end
            
            v.Detached = false
            
            -- and scale down the emitters
            v.Emitter:ScaleEmitter(0.05)
            v.Sparker:ScaleEmitter(0.05)
        end
        
        CSeaUnit.OnStopBuild(self, unitBeingBuilt)
        
    end,
    
}

TypeClass = SRS0219
