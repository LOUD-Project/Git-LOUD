# Selection Deprioritizer

SupCom mod that prevents accidental selection of certain units.

Offers three categories of deselection, all of which can be turned on and off independently with flags, located in
the `SelectionDeprioritizer.lua`. All filters are ignored if the `Shift` key is held.

* Deselects based on Domains (i.e., Naval, Land, Air)
* Deselects units if there is a mixture of regular units and those who match a list of "exotic" units
* Deselects units if they are assisting something else.
    * If all units are assisting the same thing, nothing is changed
    * If you double click* on a unit that is assisting something, only other units which are assisting the same unit are kept

\*double click is loosely defined as having a selection of one unit, and then make another selection which includes that unit

Install the mod in mods/SelectionDeprioritizer i.e.:
%USERPROFILE%\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\Mods\