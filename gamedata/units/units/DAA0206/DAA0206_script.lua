local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local DefaultProjectileWeapon = import('/lua/sim/defaultweapons.lua').DefaultProjectileWeapon

DAA0206 = Class(AAirUnit) {
    Weapons = {
        Suicide = Class(DefaultProjectileWeapon) {}
    },
    
    OnRunOutOfFuel = function(self)
        self:Kill()
    end,
    
    ProjectileFired = function(self)
        self:GetWeapon(1).IdleState.Main = function(self) end
        self:PlayUnitSound('Killed')
		self:PlayUnitSound('Destroyed')
        self:Destroy()  			
    end,
}

TypeClass = DAA0206
