--------------------------------------------------------------------------------
--   Author:  Sean 'Balthazar' Wheeldon
--------------------------------------------------------------------------------
local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SIFSuthanusArtilleryCannon = import('/lua/seraphimweapons.lua').SIFSuthanusArtilleryCannon

SSB2404 = Class(SStructureUnit) {
    Weapons = {

        MainGun = Class(SIFSuthanusArtilleryCannon) { 

            IdleState = State(SIFSuthanusArtilleryCannon.IdleState) {

                OnGotTarget = function(self)

                    SIFSuthanusArtilleryCannon.IdleState.OnGotTarget(self)

                    if not self.unit:IsDead() then 
                        self.ShotCounter = GetGameTimeSeconds() 
                    end
                end,
            },

            OnLostTarget = function(self) 

                if not self.unit:IsDead() then 
                    self.ShotCounter = GetGameTimeSeconds() 
                end 

                SIFSuthanusArtilleryCannon.OnLostTarget(self) 
            end, 

            CreateProjectileAtMuzzle = function(self, muzzle)

                local proj = SIFSuthanusArtilleryCannon.CreateProjectileAtMuzzle(self, muzzle)

                self:SetFiringRandomness((self:GetBlueprint().FiringRandomness * (math.sin(GetGameTimeSeconds()/20)*.3 + 1)) * math.max(2 - (math.max(GetGameTimeSeconds() - self.ShotCounter, 60)-60)/60, .25 ) )

                --LOG("Randomness: " .. self:GetFiringRandomness())
                --LOG("Base rand: " .. self:GetBlueprint().FiringRandomness * (math.sin(GetGameTimeSeconds()/20)*.3 + 1))
                --LOG("Timer mult: " .. math.max(2 - (math.max(GetGameTimeSeconds() - self.ShotCounter, 60)-60)/60, .25 ))
            end,

            PlayRackRecoil = function(self, rackList)   

                SIFSuthanusArtilleryCannon.PlayRackRecoil(self, rackList)

                if not self.Rotator then
                    self.Rotator = CreateRotator(self.unit, 'Spinner', 'x')
                end
                
                self.Rotator:SetSpeed(240)

                if not self.Goal then
                    self.Goal = 360
                end

                self.Goal = self.Goal - 120

                if self.Goal <= 0 then
                    self.Goal = 360
                end 

                self.Rotator:SetGoal(self.Goal)
            end, 
        },
    },
}

TypeClass = SSB2404
