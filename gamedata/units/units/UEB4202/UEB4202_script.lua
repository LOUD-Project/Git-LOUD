local TShieldStructureUnit = import('/lua/terranunits.lua').TShieldStructureUnit

local CreateRotator = CreateRotator

UEB4202 = Class(TShieldStructureUnit) {
    
    ShieldEffects = {},
    
    OnStopBeingBuilt = function(self,builder,layer)
        TShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 10, 5, 10)
        self.Rotator2 = CreateRotator(self, 'B01', 'z', nil, -10, 5, -10)
        self.Trash:Add(self.Rotator1)
        self.Trash:Add(self.Rotator2)
		self.ShieldEffectsBag = {}
    end,

    OnShieldEnabled = function(self)
        TShieldStructureUnit.OnShieldEnabled(self)
        if self.Rotator1 then
            self.Rotator1:SetTargetSpeed(10)
        end
        if self.Rotator2 then
            self.Rotator2:SetTargetSpeed(-10)
        end
        
        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        
        local LOUDINSERT = table.insert
        local LOUDATTACHEMITTER = CreateAttachedEmitter
        local army = self:GetArmy()
        
        for _, v in self.ShieldEffects do
            LOUDINSERT( self.ShieldEffectsBag, LOUDATTACHEMITTER( self, 0, army, v ) )
        end
    end,

    OnShieldDisabled = function(self)
        TShieldStructureUnit.OnShieldDisabled(self)
        self.Rotator1:SetTargetSpeed(0)
        self.Rotator2:SetTargetSpeed(0)
        
        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
    
    UpgradingState = State(TShieldStructureUnit.UpgradingState) {
        Main = function(self)
            self.Rotator1:SetTargetSpeed(90)
            self.Rotator2:SetTargetSpeed(90)
            self.Rotator1:SetSpinDown(true)
            self.Rotator2:SetSpinDown(true)
            TShieldStructureUnit.UpgradingState.Main(self)
        end,
        
        
        EnableShield = function(self)
            TShieldStructureUnit.EnableShield(self)
        end,
        
        DisableShield = function(self)
            TShieldStructureUnit.DisableShield(self)
        end,
    }
    
}

TypeClass = UEB4202