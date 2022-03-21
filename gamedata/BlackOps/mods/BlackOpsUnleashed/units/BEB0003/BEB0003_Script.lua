local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CreateAttachedEmitter = CreateAttachedEmitter

BEB0003 = Class(SStructureUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,

ShieldEffects = {
       '/effects/emitters/terran_shield_generator_t2_01_emit.bp',
        '/effects/emitters/terran_shield_generator_t2_02_emit.bp',
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
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Effect01', self:GetArmy(), v ):ScaleEmitter(0.5) )
        end
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


TypeClass = BEB0003

