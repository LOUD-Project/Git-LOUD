-- Code by David Kastrup
-- Borrowed from http://lua-users.org/wiki/DirTreeIterator
local dirtree ={
    _VERSION = '0.1',
    _DESCRIPTION = 'Recursive Directory Tree File List',
}

require "lfs"

function dirtree(dir)
  assert(dir and dir ~= "", "directory parameter is missing or empty")
  if string.sub(dir, -1) == "/" then
    dir=string.sub(dir, 1, -2)
  end

  local function yieldtree(dir)
    for entry in lfs.dir(dir) do
      if entry ~= "." and entry ~= ".." then
        entry=dir.."/"..entry
	local attr=lfs.attributes(entry)
	coroutine.yield(entry,attr)
	if attr.mode == "directory" then
	  yieldtree(entry)
	end
      end
    end
  end

  return coroutine.wrap(function() yieldtree(dir) end)
end

return dirtree