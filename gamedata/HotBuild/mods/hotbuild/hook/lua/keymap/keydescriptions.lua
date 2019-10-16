do
  LOG("Hotbuild --> Loading keydescriptions")
  local kd = import('/mods/hotbuild/hotbuild.lua').getKeyDescriptions();
--    LOG("Loading hotbuild key descriptions: " .. repr(kd))
  for key, description in kd do
    keyDescriptions[key] = description
  end
end
