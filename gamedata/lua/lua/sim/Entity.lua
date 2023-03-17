
Entity = Class(moho.entity_methods) {

    __init = function(self,spec)
        _c_CreateEntity(self,spec)
    end,

    __post_init = function(self,spec)
        self:OnCreate(spec)
    end,

    OnCreate = function(self,spec)
        --LOG("*AI DEBUG Entity OnCreate "..repr(self) )
        self.Spec = spec
    end,
    
    OnDestroy = function(self)
        --LOG("*AI DEBUG Entity OnDestroy")
    end,
}
