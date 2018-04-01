SANAjelluAntiTorpedo01 = Class(import('/lua/seraphimprojectiles.lua').SAnjelluTorpedoDefenseProjectile) {

	OnLostTarget = function(self)

        self:SetAcceleration(-3.6)
        self:SetLifetime(0.2)

    end,
	
}

TypeClass = SANAjelluAntiTorpedo01