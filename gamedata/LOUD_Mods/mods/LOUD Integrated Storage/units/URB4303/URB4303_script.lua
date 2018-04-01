
local CShieldStructureUnit = import('/lua/cybranunits.lua').CShieldStructureUnit

URB4303 = Class(CShieldStructureUnit) {
    
    ShieldEffects = {
                    '/effects/emitters/cybran_shield_05_generator_01_emit.bp',
                    '/effects/emitters/cybran_shield_05_generator_02_emit.bp',
                    '/effects/emitters/cybran_shield_05_generator_03_emit.bp',
                    '/effects/emitters/cybran_shield_05_generator_04_emit.bp',
                    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        CShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.Rotator1 = CreateRotator(self, 'Shaft', 'z', nil, 30, 5, 30)
        self.Trash:Add(self.Rotator1)
		self.ShieldEffectsBag = {}
    end,

    OnShieldEnabled = function(self)
        CShieldStructureUnit.OnShieldEnabled(self)
        if self.Rotator1 then
            self.Rotator1:SetTargetSpeed(10)
        end
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
		
		local army = self:GetArmy()
		local LOUDINSERT = table.insert
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        for k, v in self.ShieldEffects do
            LOUDINSERT( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Shaft', army, v ) )
        end
    end,

    OnShieldDisabled = function(self)
        CShieldStructureUnit.OnShieldDisabled(self)
        self.Rotator1:SetTargetSpeed(0)
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
    
}

TypeClass = URB4303