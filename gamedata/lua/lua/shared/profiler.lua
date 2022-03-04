-- Author(s): Willem "Jip" Wijnia
-- As of 03/03/2022, FAF's Lua code is distributed without license, and used as such.
-- Consent of the author(s) was granted for this usage.

--- Constructs an empty table that the profiler can populate.
function CreateEmptyProfilerTable() 
    return {
        -- what
        Lua = {
            -- namewhat
              ["global"]    = { }
            , ["upval"]     = { }
            , ["local"]     = { }
            , ["method"]    = { }
            , ["field"]     = { }
            , ["other"]     = { }
        },

        -- what
        C = {
            -- namewhat
              ["global"]    = { }
            , ["upval"]     = { }
            , ["local"]     = { }
            , ["method"]    = { }
            , ["field"]     = { }
            , ["other"]     = { }
        },

        -- what
        main = {
            -- namewhat
              ["global"]    = { }
            , ["upval"]     = { }
            , ["local"]     = { }
            , ["method"]    = { }
            , ["field"]     = { }
            , ["other"]     = { }
        },

        -- what
        unknown = {
          -- namewhat
            ["global"]    = { }
          , ["upval"]     = { }
          , ["local"]     = { }
          , ["method"]    = { }
          , ["field"]     = { }
          , ["other"]     = { }
      },
    }
end
