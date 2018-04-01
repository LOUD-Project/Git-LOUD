
local ShieldTauCannonProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').ShieldTauCannonProjectile

STauCannon = Class(ShieldTauCannonProjectile) {
		OnImpact = function(self, TargetType, TargetEntity)
			ShieldTauCannonProjectile.OnImpact(self, TargetType, TargetEntity)
			if TargetType == 'Shield' then
			    if self.Data > TargetEntity:GetHealth() then
			        Damage(self, {0,0,0}, TargetEntity, TargetEntity:GetHealth(), 'Normal')
			    else
					Damage(self, {0,0,0}, TargetEntity, self.Data, 'Normal')
		        end
			end				
		end,
	}

TypeClass = STauCannon