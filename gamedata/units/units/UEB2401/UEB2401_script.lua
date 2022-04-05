local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

UEB2401 = Class(TStructureUnit) {

    Weapons = {
	
        MainGun = Class(TIFArtilleryWeapon) {
		
            FxMuzzleFlashScale = 3,
            
            IdleState = State(TIFArtilleryWeapon.IdleState) {
			
                OnGotTarget = function(self)
				
                    TIFArtilleryWeapon.IdleState.OnGotTarget(self)
					
                    if not self.ArtyAnim then
					
                        self.ArtyAnim = CreateAnimator(self.unit)
                        self.ArtyAnim:PlayAnim(self.unit:GetBlueprint().Display.AnimationOpen)
                        self.unit.Trash:Add(self.ArtyAnim)
						
                    end
                end,
            },
        },
    },
}

TypeClass = UEB2401