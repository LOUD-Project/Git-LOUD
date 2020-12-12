--****************************************************************************
--**
--**  File     :  /mods/Wyvern1/projectiles/Miasma_Bomb/Miasma_Bomb_script.lua
--**  Author(s):  Matt Vainio
--**
--**  Summary  :  Heavy Miasma Bomb, UEA0305
--**
--**  Copyright � 2010 Wyvern Studios
--****************************************************************************
local MiasmaBombProjectile = import('/lua/terranprojectiles.lua').TNapalmHvyCarpetBombProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local utilities = import('/lua/utilities.lua')

Miasma_Bomb = Class(MiasmaBombProjectile) {
    OnImpact = function(self, TargetType, TargetEntity)       
        -- Sounds for all other impacts, ie: Impact<TargetTypeName>
        local bp = self:GetBlueprint().Audio
        local snd = bp['Impact'.. TargetType]
        if snd then
            self:PlaySound(snd)
            -- Generic Impact Sound
        elseif bp.Impact then
            self:PlaySound(bp.Impact)
        end        
		self:CreateImpactEffects( self:GetArmy(), self.FxImpactNone, self.FxNoneHitScale )
		local x,y,z = self:GetVelocity()
		local speed = utilities.GetVectorLength(Vector(x*10,y*10,z*10))		
		-- One initial projectile following same directional path as the original
        self:CreateChildProjectile('/projectiles/AIFMiasmaShell02/AIFMiasmaShell02_proj.bp' ):SetVelocity(x,y,z):SetVelocity(speed):PassDamageData(self.DamageData)               
        self:Destroy()
    end,  	    
}
TypeClass = Miasma_Bomb
