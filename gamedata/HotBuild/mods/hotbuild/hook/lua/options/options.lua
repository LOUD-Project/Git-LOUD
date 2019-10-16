do
table.insert(options.ui.items, 
  {
    title = "Hotbuild: Enable Cycle Preview",
    key = 'hotbuild_cycle_preview',
    type = 'toggle',
    default = 1,
    custom = {
      states = {
        {text = "<LOC _Off>", key = 0 },
        {text = "<LOC _On>", key = 1 },
      },
    },
  })
  
table.insert(options.ui.items, 
{
  title = "Hotbuild: cycle reset time (ms)",
  key = 'hotbuild_cycle_reset_time',
  type = 'slider',
  default = 1100,
  custom = {
    min = 100,
    max = 5000,
    inc = 100,
  },
})
end
