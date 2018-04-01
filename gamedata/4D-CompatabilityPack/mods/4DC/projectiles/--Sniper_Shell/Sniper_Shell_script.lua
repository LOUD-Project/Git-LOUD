-----------------------------------------------------------------------------
--  File     : /mods/4DC/projectiles/Sniper_Shell/Sniper_Shell_script.lua
--
--  Author(s): EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--
--  Summary  : Aeon Sniper Shell projectile
--
--  Copyright © 2010 4DC  All rights reserved.
-----------------------------------------------------------------------------

local Sniper_ShellProjectile = import('/lua/aeonprojectiles.lua').AShieldDisruptorProjectile

Sniper_Shell = Class(Sniper_ShellProjectile) {}
TypeClass = Sniper_Shell