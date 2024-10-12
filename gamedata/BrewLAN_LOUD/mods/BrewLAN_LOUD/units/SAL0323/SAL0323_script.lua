local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAMWillOWisp = import('/lua/aeonweapons.lua').AAMWillOWisp

SAL0323 = Class(AStructureUnit) {

    Weapons = {

        AntiMissile = Class(AAMWillOWisp) {
        
                PlayRackRecoil = function(self, rackList)

                    AAMWillOWisp.PlayRackRecoil(self, rackList)

                    if not self.RotatorManipulator then
                        self.RotatorManipulator = CreateRotator(self.unit, 'Barrel', 'z', 20, 40, 40, 40)
                        self.RotatorManipulator:SetGoal(45)
                        self.RotatorManipulatorCounter = 1
                    else
                        self.RotatorManipulatorCounter = self.RotatorManipulatorCounter + 1
                        self.RotatorManipulator:SetGoal(45 * self.RotatorManipulatorCounter)
                    end
                    
                    self.unit.Trash:Add(self.RotatorManipulator)

                end,
                
                PlayRackRecoilReturn = function(self, rackList)

                    AAMWillOWisp.PlayRackRecoilReturn(self, rackList)

                    if self.RotatorManipulatorCounter == 8 then
                        self.RotatorManipulator:Destroy()
                        self.RotatorManipulator = nil
                    end
                end,
            
            },
    },

}

TypeClass = SAL0323

