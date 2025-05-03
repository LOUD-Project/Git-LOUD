local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

UEB2401 = Class(TStructureUnit) {

    Weapons = {
	
        MainGun = Class(TIFArtilleryWeapon) {
		
            FxMuzzleFlashScale = 3,
            
            IdleState = State(TIFArtilleryWeapon.IdleState) {
			
                OnGotTarget = function(self)
				
                    TIFArtilleryWeapon.IdleState.OnGotTarget(self)

                    if not self.unit:IsDead() then 
                        self.ShotCounter = GetGameTimeSeconds() 
                    end					

                    if not self.ArtyAnim then
					
                        self.ArtyAnim = CreateAnimator(self.unit)
                        self.ArtyAnim:PlayAnim(self.unit:GetBlueprint().Display.AnimationOpen)
                        self.unit.Trash:Add(self.ArtyAnim)
						
                    end
                end,
            },

            OnLostTarget = function(self) 

                if not self.unit:IsDead() then 
                    self.ShotCounter = GetGameTimeSeconds() 
                end 

                TIFArtilleryWeapon.OnLostTarget(self) 
            end, 

            CreateProjectileAtMuzzle = function(self, muzzle)

                local proj = TIFArtilleryWeapon.CreateProjectileAtMuzzle(self, muzzle)

                self:SetFiringRandomness((self:GetBlueprint().FiringRandomness * (math.sin(GetGameTimeSeconds()/20)*.3 + 1)) * math.max(2 - (math.max(GetGameTimeSeconds() - self.ShotCounter, 60)-60)/60, .25 ) )

                --LOG("Randomness: " .. self:GetFiringRandomness())
                --LOG("Base rand: " .. self:GetBlueprint().FiringRandomness * (math.sin(GetGameTimeSeconds()/20)*.3 + 1))
                --LOG("Timer mult: " .. math.max(2 - (math.max(GetGameTimeSeconds() - self.ShotCounter, 60)-60)/60, .25 ))
            end,

        },
    },
}

TypeClass = UEB2401