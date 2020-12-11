--****************************************************************************
--** 
--**  File     :  /cdimage/units/XSB0001/XSB0001_script.lua 
--**  Author(s):  John Comes, David Tomandl 
--** 
--**  Summary  :  UEF Wall Piece Script 
--** 
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SeraLambdaField = import('/mods/BlackOpsACUs/lua/BlackOpsdefaultantiprojectile.lua').SeraLambdaFieldDestroyer


ESB0004 = Class(SStructureUnit) {


-- File pathing and special paramiters called ###########################

-- Setsup parent call backs between drone and parent
Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,

--
ShieldEffects = {
       # '/effects/emitters/seraphim_shield_generator_t2_01_emit.bp',
        '/effects/emitters/seraphim_shield_generator_t3_03_emit.bp',
        '/effects/emitters/seraphim_shield_generator_t2_03_emit.bp',
    },
	   OnCreate = function(self, builder, layer)
        SStructureUnit.OnCreate(self, builder, layer)
        self.ShieldEffectsBag = {}
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, self:GetArmy(), v ):ScaleEmitter(0.0625) )
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, self:GetArmy(), v ):ScaleEmitter(0.0625):OffsetEmitter(0, -0.125, 0) )
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, self:GetArmy(), v ):ScaleEmitter(0.0625):OffsetEmitter(0, 0.125, 0) )
        end
    	local bp = self:GetBlueprint().Defense.SeraLambdaField01
        local SeraLambdaField01 = SeraLambdaField {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
        self.Trash:Add(SeraLambdaField01)
        self.UnitComplete = true
    end,
    --Make this unit invulnerable
    OnDamage = function()
    end,
    OnKilled = function(self, instigator, type, overkillRatio)
        SStructureUnit.OnKilled(self, instigator, type, overkillRatio)
        if self.ShieldEffctsBag then
            for k,v in self.ShieldEffectsBag do
                v:Destroy()
            end
        end
    end,  
    DeathThread = function(self)
        self:Destroy()
    end,
}


TypeClass = ESB0004

