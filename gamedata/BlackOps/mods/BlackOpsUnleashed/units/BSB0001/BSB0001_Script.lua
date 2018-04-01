
local SShieldLandUnit = import('/lua/seraphimunits.lua').SShieldLandUnit
local SeraLambdaFieldRedirector = import('/mods/BlackOpsUnleashed/lua/BlackOpsdefaultantiprojectile.lua').SeraLambdaFieldRedirector
local SeraLambdaFieldDestroyer = import('/mods/BlackOpsUnleashed/lua/BlackOpsdefaultantiprojectile.lua').SeraLambdaFieldDestroyer

local CreateAttachedEmitter = CreateAttachedEmitter

BSB0001 = Class(SShieldLandUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,

ShieldEffects = {
        '/effects/emitters/seraphim_shield_generator_t3_03_emit.bp',
        '/effects/emitters/seraphim_shield_generator_t2_03_emit.bp',
    },
	
	OnCreate = function(self, builder, layer)
	
        SShieldLandUnit.OnCreate(self, builder, layer)
		
        self.ShieldEffectsBag = {}
		
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        
        local army = self:GetArmy()
        
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, army, v ):ScaleEmitter(0.6) )
        end
        
        local bpd = self:GetBlueprint().Defense
        
    	local bp = bpd.SeraLambdaFieldRedirector01
        local bp2 = bpd.SeraLambdaFieldRedirector02
        local bp3 = bpd.SeraLambdaFieldRedirector03
        local bp4 = bpd.SeraLambdaFieldDestroyer01
        local bp5 = bpd.SeraLambdaFieldDestroyer02
        
        local SeraLambdaFieldRedirector01 = SeraLambdaFieldRedirector {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
		
        local SeraLambdaFieldRedirector02 = SeraLambdaFieldRedirector {
            Owner = self,
            Radius = bp2.Radius,
            AttachBone = bp2.AttachBone,
            RedirectRateOfFire = bp2.RedirectRateOfFire
        }
		
        local SeraLambdaFieldRedirector03 = SeraLambdaFieldRedirector {
            Owner = self,
            Radius = bp3.Radius,
            AttachBone = bp3.AttachBone,
            RedirectRateOfFire = bp3.RedirectRateOfFire
        }
		
        local SeraLambdaFieldDestroyer01 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp4.Radius,
            AttachBone = bp4.AttachBone,
            RedirectRateOfFire = bp4.RedirectRateOfFire
        }
		
        local SeraLambdaFieldDestroyer02 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp5.Radius,
            AttachBone = bp5.AttachBone,
            RedirectRateOfFire = bp5.RedirectRateOfFire
        }
		
        self.Trash:Add(SeraLambdaFieldRedirector01)
        self.Trash:Add(SeraLambdaFieldRedirector02)
        self.Trash:Add(SeraLambdaFieldRedirector03)
        self.Trash:Add(SeraLambdaFieldDestroyer01)
        self.Trash:Add(SeraLambdaFieldDestroyer02)
        self.UnitComplete = true
    end,
	
    --Make this unit invulnerable
    OnDamage = function()
    end,
	
    OnKilled = function(self, instigator, type, overkillRatio)
        SShieldLandUnit.OnKilled(self, instigator, type, overkillRatio)
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


TypeClass = BSB0001

