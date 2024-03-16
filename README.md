# Warframe HUD

This is a total in-game HUD conversion that aims to recreate Warframe's HUD as close as possible. It includes features like floating enemy labels, damage pops (with Warframe style damage type icons where applicable) and a list of currently active buffs. It uses completely custom fonts that are closer to Warframe's as well as many custom icons for HUD elements and waypoints.

## What's Changed in this Fork
This single line has been added to /req/HUDFloatingUnitLabel.lua such that the unit level text is replaced with the unit hp on every update of the health pop up

~~~lua
-- Inside this function
function HUDFloatingUnitLabel:update(t, dt)
  ----------------------------
  -- Original function body --
  ----------------------------
  
  self._level_text:set_text(tostring(hp))
end
~~~

I also removed the auto-update link to avoid future updates from affecting this change.

I made this change because I prefer to have the unit health there instead. I don't plan on opening a PR for this as I assume this change is not what the mod author has in mind for the HUD.
