--****************************************************************************
--**  File     :  /mods/4DC/projectiles/Mortar/Mortar_script.lua
--**
--**  Author(s):  EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--**
--**  Summary  :  UEF Mortar Shell
--**
--**  Copyright � 2010 4DC  All rights reserved.
--****************************************************************************
local TFragmentationGrenade = import('/lua/terranprojectiles.lua').TFragmentationGrenade
local EffectTemplate = import('/lua/EffectTemplates.lua')

Mortar = Class(TFragmentationGrenade) {}
TypeClass = Mortar