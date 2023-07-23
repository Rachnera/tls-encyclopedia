# A patch for the CSCA-Encyclopedia script; allows the descriptions in
# $game_party to be reloaded from the script file (for creating backwards-
# compatability of saves)


$imported = {} if $imported.nil?
$imported["CSCA-Encyclopedia-Patch"] = true
msgbox('Missing Script: CSCA Encyclopedia! The script must be included
for the patch to work.') if !$imported["CSCA-Encyclopedia"]

class Game_Party < Game_Unit
  def csca_reload_descriptions    
    for i in 0...CSCA_ENCYCLOPEDIA::DESCRIPTION.size
      @csca_descriptions[i] = CSCA_ENCYCLOPEDIA::DESCRIPTION[i]
    end
  end
end
