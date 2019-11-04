-- _Zulan_.._\(.\)
-- \1 = 'build_&', ['Shift-\1'] = 'build_&_shift',,

hotbuildDefaultKeyMap = {
  W = 'build__Zulan_11_W',
  ['Shift-W'] = 'build__Zulan_11_W_shift',
  ['Alt-W'] = 'build__Zulan_11_W_alt',

  E = 'build__Zulan_12_E',
  ['Shift-E'] = 'build__Zulan_12_E_shift',
  ['Alt-E'] = 'build__Zulan_12_E_alt',

  R = 'build__Zulan_13_R',
  ['Shift-R'] = 'build__Zulan_13_R_shift',
  ['Alt-R'] = 'build__Zulan_13_R_alt',

  T = 'build__Zulan_14_T',
  ['Shift-T'] = 'build__Zulan_14_T_shift',
  ['Alt-T'] = 'build__Zulan_14_T_alt',

  -- EN FIX!
  Y = 'build__Zulan_15_Z',
  ['Shift-Y'] = 'build__Zulan_15_Z_shift',
  ['Alt-Y'] = 'build__Zulan_15_Z_alt',

  U = 'build__Zulan_16_U',
  ['Shift-U'] = 'build__Zulan_16_U_shift',
  ['Alt-U'] = 'build__Zulan_16_U_alt',
  
  -- Row 2 - ASDFGHJKL
  
  S = 'build__Zulan_21_S',
  ['Shift-S'] = 'build__Zulan_21_S_shift',
  ['Alt-S'] = 'build__Zulan_21_S_alt',

  D = 'build__Zulan_22_D',
  ['Shift-D'] = 'build__Zulan_22_D_shift',
  ['Alt-D'] = 'build__Zulan_22_D_alt',

  F = 'build__Zulan_23_F',
  ['Shift-F'] = 'build__Zulan_23_F_shift',
  ['Alt-F'] = 'build__Zulan_23_F_alt',

  G = 'build__Zulan_24_G',
  ['Shift-G'] = 'build__Zulan_24_G_shift',
  ['Alt-G'] = 'build__Zulan_24_G_alt',

  H = 'build__Zulan_25_H',
  ['Shift-H'] = 'build__Zulan_25_H_shift',
  ['Alt-H'] = 'build__Zulan_25_H_alt',

  J = 'build__Zulan_26_J',
  ['Shift-J'] = 'build__Zulan_26_J_shift',
  ['Alt-J'] = 'build__Zulan_26_J_alt',

  K = 'build__Zulan_27_K',
  ['Shift-K'] = 'build__Zulan_27_K_shift',
  ['Alt-K'] = 'build__Zulan_27_K_alt',

  L = 'build__Zulan_28_L',
  ['Shift-L'] = 'build__Zulan_28_L_shift',
  ['Alt-L'] = 'build__Zulan_28_L_alt',

  -- Row 3 - ZXCVBNM
  
  X = 'build__Zulan_32_X',
  ['Shift-X'] = 'build__Zulan_32_X_shift',
  ['Alt-X'] = 'build__Zulan_32_X_alt',
  
  C = 'build__Zulan_33_C',
  ['Shift-C'] = 'build__Zulan_33_C_shift',
  ['Alt-C'] = 'build__Zulan_33_C_alt',

  V = 'build__Zulan_34_V',
  ['Shift-V'] = 'build__Zulan_34_V_shift',
  ['Alt-V'] = 'build__Zulan_34_V_alt',
  
  B = 'build__Zulan_35_B',
  ['Shift-B'] = 'build__Zulan_35_B_shift',
  ['Alt-B'] = 'build__Zulan_35_B_alt',
  
  N = 'build__Zulan_36_N',
  ['Shift-N'] = 'build__Zulan_36_N_shift',
  ['Alt-N'] = 'build__Zulan_36_N_alt',
  
  M = 'build__Zulan_37_M',
  ['Shift-M'] = 'build__Zulan_37_M_shift',
  ['Alt-M'] = 'build__Zulan_37_M_alt',

  Q = 'patrol',  ['Shift-Q'] = 'shift_patrol',
  A = 'reclaim', ['Shift-A'] = 'shift_reclaim',
  Tab = 'pause_unit',
  ---['SGP'] = 'toggle_repeat_build', -- Does unfortunately not work
  Z = 'toggle_repeat_build',
  
  Tilde = 'toggle_all', -- ^° on german keyboard

  Esc = 'stop',
  F3 = 'escape',
  
  -- Actions done rarely, still useful
  ['Alt-L'] = 'show_enemy_life', -- Evil :)
  ['Alt-P'] = 'track_unit_second_mon',

  -- Diplomacy
  F11  = 'give_mass_to_ally',  
  ['Ctrl-F11'] = 'give_energy_to_ally',
  F12 = 'give_units_to_ally',
  ['Ctrl-F12'] = 'give_all_units_to_ally'
}
