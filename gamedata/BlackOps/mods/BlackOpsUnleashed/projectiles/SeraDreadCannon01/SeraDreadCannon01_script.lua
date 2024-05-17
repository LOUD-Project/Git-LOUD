local SDFSinnuntheWeaponProjectile = import('/lua/seraphimprojectiles.lua').SDFSinnuntheWeaponProjectile

SDFSinnuntheWeapon01 = Class(SDFSinnuntheWeaponProjectile) {

    AttackBeams = {'/effects/emitters/seraphim_othuy_beam_01_emit.bp'},
	
    SpawnEffects = {
		'/effects/emitters/seraphim_othuy_spawn_01_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_02_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_03_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_04_emit.bp',
	},

	OnCreate = function(self)
		SDFSinnuntheWeaponProjectile.OnCreate(self)
    end,

    OnImpact = function(self, targetType, targetEntity)
	
		SDFSinnuntheWeaponProjectile.OnImpact(self, targetType, targetEntity)
		
		local position = self:GetPosition()
        local spiritUnit = CreateUnitHPR('BSL0404', self:GetArmy(), position[1], position[2], position[3], 0, 0, 0)
        
        -- Create effects for spawning of energy being
		for k, v in self.SpawnEffects do
			CreateAttachedEmitter(spiritUnit, -1, self:GetArmy(), v ):ScaleEmitter(0.5)
		end
		
    end,

}

TypeClass = SDFSinnuntheWeapon01

