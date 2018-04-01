
WldUIProvider = Class(moho.WldUIProvider_methods) {
    __init = function(self)
        InternalCreateWldUIProvider(self)
    end,

    StartLoadingDialog = function(self)
    end,

    UpdateLoadingDialog = function(self, elapsedTime)
    end,

    StopLoadingDialog = function(self)
    end,

    StartWaitingDialog = function(self)
    end,

    UpdateWaitingDialog = function(self, elapsedTime)
    end,

    StopWaitingDialog = function(self)
    end,

    CreateGameInterface = function(self)
    end,

    DestroyGameInterface = function(self)
    end,
    
    GetPrefetchTextures = function(self)
        return nil
    end,
}

