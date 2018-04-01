local TSeaUnit = import('/lua/terranunits.lua').TSeaUnit
local WeaponsFile = import('/lua/terranweapons.lua')

local TAMPhalanxWeapon = WeaponsFile.TAMPhalanxWeapon
local TDFHiroPlasmaCannon = WeaponsFile.TDFHiroPlasmaCannon
local TANTorpedoAngler = WeaponsFile.TANTorpedoAngler
local TIFSmartCharge = WeaponsFile.TIFSmartCharge

UES0302 = Class(TSeaUnit) {

    Weapons = {
	
        HiroCannon = Class(TDFHiroPlasmaCannon) {},
        AntiTorpedo = Class(TIFSmartCharge) {},
        Torpedo = Class(TANTorpedoAngler) {},
        PhalanxGun = Class(TAMPhalanxWeapon) {},
        
        OnKilled = function(self)
		
            local wep1 = self:GetWeaponByLabel('HiroCannonFront')
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
            
            local wep2 = self:GetWeaponByLabel('HiroCannonBack')
            local bp2 = wep2:GetBlueprint()
			
            if bp2.Audio.BeamStop then
                wep2:PlaySound(bp2.Audio.BeamStop)
            end
			
            if bp2.Audio.BeamLoop and wep2.Beams[1].Beam then
                wep2.Beams[1].Beam:SetAmbientSound(nil, nil)
            end
			
            for k, v in wep2.Beams do
                v.Beam:Disable()
            end
            
            TSeaUnit.OnKilled(self)
			
        end,        
    },
	
}
TypeClass = UES0302