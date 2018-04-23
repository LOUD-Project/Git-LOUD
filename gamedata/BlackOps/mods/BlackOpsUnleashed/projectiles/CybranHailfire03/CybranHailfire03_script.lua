local CybranHailfire03Projectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').CybranHailfire03Projectile

CAANanoDart02 = Class(CybranHailfire03Projectile) {

    OnCreate = function(self)
	
        CybranHailfire03Projectile.OnCreate(self)

    end,

}

TypeClass = CAANanoDart02
