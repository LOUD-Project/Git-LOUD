local SShieldLandUnit = import('/lua/defaultunits.lua').MobileUnit

--local SeraLambdaFieldRedirector = import('/mods/BlackOpsUnleashed/lua/BlackOpsdefaultantiprojectile.lua').SeraLambdaFieldRedirector
local SeraLambdaFieldDestroyer = import('/mods/BlackOpsUnleashed/lua/BlackOpsdefaultantiprojectile.lua').SeraLambdaFieldDestroyer


BSB0005 = Class(SShieldLandUnit) {

    Parent = nil,

    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    OnCreate = function(self, builder, layer)
       
        SShieldLandUnit.OnCreate(self, builder, layer)
        
    	--local bp = self:GetBlueprint().Defense.SeraLambdaFieldRedirector01
        
        local bp3 = self:GetBlueprint().Defense.SeraLambdaFieldDestroyer01
        
        --local SeraLambdaFieldRedirector01 = SeraLambdaFieldRedirector {Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }

        local SeraLambdaFieldDestroyer01 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp3.Radius,
            AttachBone = bp3.AttachBone,
            RedirectRateOfFire = bp3.RedirectRateOfFire
        }
        
        --self.Trash:Add(SeraLambdaFieldRedirector01)

        self.Trash:Add(SeraLambdaFieldDestroyer01)
        self.UnitComplete = true
    end,
    
    --Make this unit invulnerable
    OnDamage = function()
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
        SShieldLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    DeathThread = function(self)
        self:Destroy()
    end,  
}


TypeClass = BSB0005

