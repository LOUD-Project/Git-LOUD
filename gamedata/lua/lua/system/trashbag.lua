--local getn = table.getn

-- TrashBag is a class to help manage objects that need destruction. You add objects to it with Add().
-- When TrashBag:Destroy() is called, it calls Destroy() in turn on all its contained objects.

-- If an object in a TrashBag is destroyed through other means, it automatically disappears from the TrashBag.
-- This doesn't necessarily happen instantly, so it's possible in this case that Destroy() will be called twice.
-- So Destroy() should always be idempotent.

TrashBag = Class {

    __mode = 'v',
    
    Count = 1,

    -- Add an object to the TrashBag.
    Add = function(self, obj)
	
        if obj != nil then

			self[self.Count] = obj
            self.Count = self.Count + 1
			
		end
		
    end,

    -- Call Destroy() for all objects in this bag.
    Destroy = function(self)

        for i = 1,self.Count -1 do

            if self[i] then
                self[i]:Destroy()
			end
        end

		self = {}
    end
}
