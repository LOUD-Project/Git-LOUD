-----------------------------------------------------------------------------
--  File     : /mods/4DC/projectiles/Gauss_EnergyBolt/Gauss_EnergyBolt_script.lua
--
--  Author(s): EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--
--  Summary  : Aeon Gauss projectile
--
--  Copyright © 2010 4DC  All rights reserved.
-----------------------------------------------------------------------------

local GaussProjectile = import('/lua/aeonprojectiles.lua').AShieldDisruptorProjectile
Guass_Projectile = import('/mods/4DC/lua/CustomAbilities/4D_ProjectileSuperClass/4D_ProjectileSuperClass.lua').GaussRifle1( GaussProjectile )

GaussEnergyBolt = Class(Guass_Projectile) {}
TypeClass = GaussEnergyBolt