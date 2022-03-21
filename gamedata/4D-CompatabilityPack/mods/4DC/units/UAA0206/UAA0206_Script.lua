local AAirUnit = import('/lua/defaultunits.lua').AirUnit

AAirUnit = import('/mods/4DC/lua/CustomAbilities/4D_DefensiveTeleportation/4D_DefensiveTeleportation.lua').DefensiveTeleportation( AAirUnit ) 

local IonWeapon = import('/lua/terranweapons.lua').TDFHiroPlasmaCannon

UAA0206 = Class(AAirUnit) {

    Weapons = {
        Ion_Beam = Class(IonWeapon) {},
    },
    
    OnKilled = function(self)
	
        -- Disables the weapon and weapon effects upon death
        local wep1 = self:GetWeaponByLabel('Ion_Beam')
        local bp1 = wep1:GetBlueprint()
		
        if bp1.Audio.BeamStop then
            wep1:PlaySound(bp1.Audio.BeamStop)
        end
		
        if bp1.Audio.BeamLoop and wep1.Beams[1].Beam then
            wep1.Beams[1].Beam:SetAmbientSound(nil, nil)
        end
		
        for k, v in wep1.Beams do
            v.Beam:Disable()
        end
		
        AAirUnit.OnKilled(self)
		
    end,
    
}

TypeClass = UAA0206