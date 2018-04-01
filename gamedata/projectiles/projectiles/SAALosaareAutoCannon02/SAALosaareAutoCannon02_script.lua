#****************************************************************************
#**
#**  File     :  /data/projectiles/SAALosaareAutoCannon02/SAALosaareAutoCannon02_script.lua
#**  Author(s):  Greg Kohne, Gordon Duclos
#**
#**  Summary  :  Losaare AA AutoCannon Projectile script, XSA0401
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local SLosaareAAAutoCannon = import('/lua/seraphimprojectiles.lua').SLosaareAAAutoCannon

SAALosaareAutoCannon02 = Class(SLosaareAAAutoCannon) {

  OnImpact = function(self, TargetType, TargetEntity)
      SLosaareAAAutoCannon.OnImpact(self, TargetType, TargetEntity)

  end,

}
TypeClass = SAALosaareAutoCannon02
