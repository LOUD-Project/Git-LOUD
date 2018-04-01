#******************************************************************
#**  File     :  /lua/blip.lua
#**  Author(s):
#**  Summary  : The recon blip lua module
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#******************************************************************

local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove

Blip = Class(moho.blip_methods) {

    AddDestroyHook = function(self,hook)
        if self.DestroyHooks then
			LOUDINSERT(self.DestroyHooks,hook)
		else
            self.DestroyHooks = {}
			LOUDINSERT(self.DestroyHooks,hook)
        end
    end,

    RemoveDestroyHook = function(self,hook)
        if self.DestroyHooks then
            for k,v in self.DestroyHooks do
                if v == hook then
                    LOUDREMOVE(self.DestroyHooks,k)
                    return
                end
            end
        end
    end,

    OnDestroy = function(self)
        if self.DestroyHooks then
            for _,v in self.DestroyHooks do
                v(self)
            end
        end
    end,
}
