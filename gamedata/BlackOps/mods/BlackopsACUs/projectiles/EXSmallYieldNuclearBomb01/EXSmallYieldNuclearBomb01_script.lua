--
-- UEF Small Yield Nuclear Bomb
--
local TIFSmallYieldNuclearBombProjectile = import('/mods/BlackOpsACUs/lua/EXBlackopsprojectiles.lua').UEFACUClusterMIssileProjectile02
local TMissileCruiseProjectile = import('/lua/terranprojectiles.lua').TMissileCruiseProjectile02

EXSmallYieldNuclearBomb01 = Class(TIFSmallYieldNuclearBombProjectile) {
	--PolyTrail = '/effects/emitters/default_polytrail_04_emit.bp',
    --FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
	--FxTrailOffset = 0,
	--FxTrailScale = 3.5,
	--FxLandHitScale = 0.5,
    --FxUnitHitScale = 0.5,
	
    --OnImpact = function(self, TargetType, TargetEntity)
    --    if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
    --        # Play the explosion sound
    --        local myBlueprint = self:GetBlueprint()
    --        if myBlueprint.Audio.Explosion then
    --            self:PlaySound(myBlueprint.Audio.Explosion)
    --        end
    --       
	--		nukeProjectile = self:CreateProjectile('/mods/Blackopsacus/effects/Entities/EXCluster01EffectController01/EXCluster01EffectController01_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
    --        nukeProjectile:PassData(self.Data)
    --    end
    --    TIFSmallYieldNuclearBombProjectile.OnImpact(self, TargetType, TargetEntity)
    --end,    

}

TypeClass = EXSmallYieldNuclearBomb01