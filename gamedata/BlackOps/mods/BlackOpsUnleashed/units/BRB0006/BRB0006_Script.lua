local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CreateAttachedEmitter = CreateAttachedEmitter

BRB0003 = Class(SStructureUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,

	ShieldEffects = {
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_03_generator_02_emit.bp',
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_05_generator_01_emit.bp',
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_05_generator_02_emit.bp',
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_05_generator_03_emit.bp',    -- flashes
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_02_generator_02_emit.bp',
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_02_generator_03_emit.bp',    -- flash rest are lightning
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_01_generator_02_emit.bp',
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_04_generator_02_emit.bp',
       '/mods/BlackOpsUnleashed/effects/emitters/cybran_shield_04_generator_03_emit.bp',    -- flashes
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
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Effect01', self:GetArmy(), v ):ScaleEmitter(0.4) )
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


TypeClass = BRB0003

