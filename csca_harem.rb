=begin
CSCA Encyclopedia
version: 3.0.3 (Released: March 7, 2013), modified
Created by: Casper Gaming (http://www.caspergaming.com/)
Modified by Decanter for mid-game image changing on custom entries.

Compatibility:
Made for RPGVXAce
IMPORTANT: ALL CSCA Scripts should be compatible with each other unless
otherwise noted.
REQUIRES CSCA Core Script v1.0.5 or greater.
================================================================================
UPDATES:
version 1.1(April 14, 2012):
- Added ability to set enemy/item/etc. to discovered through script call.
- Bestiary MaxHP and MaxMP listed at top of parameters now instead of bottom.
- Ability to restrict which items, armors, weapons, and enemies are shown to
the player based on their ID(you can restrict which ID the list goes up to)

version 1.2(April 29, 2012):
- No more max items listed. If you want to leave an item/enemy/etc. unlisted now,
use the notetag <csca enc exclude>.

version 2.0(June 17, 2012):
- Resized the windows to display more info on each item.
- Added skills and states to the encyclopedia.
- All commands(bestiary, items, etc.) are now able to be disabled.
- Changed colors of some text.
- Fixed bug with item occasion of Never.
- Made code more efficient.

version 2.0b(June 17, 2012)
- Removed add to menu option. Use the CSCA Menu Organizer for that instead.

version 2.1(July 12, 2012)
- Added option to use a custom image for skills/items/etc. instead of just using
the blown up icon for said skill/item/etc. Size of image is 72x72.
- Added ability to change x coordinate of stat amounts.
- Added ability to customize order encyclopedia lists are shown.

version 2.2(August 13, 2012)
- Windows now resize properly with different resolutions.

version 2.2b(September 5, 2012)
- Optimized script.
- Added ability to set amount of a certain enemy defeated.

version 2.2c(September 11, 2012)
- Param text now displays at the correct x coordinate automatically.

version 3.0(October 6, 2012)
- Divided the totals window into 2 separate windows, one shows total completion %,
the other shows category completion %.
- Added support for CSCA Achievement System.
- Users can now create their own custom categories.

version 3.0.1(October 14, 2012)
- Added ability to re-order custom categories and default categories.

version 3.0.2(October 21, 2012)
- Added ability to change descriptions of custom entries

version 3.0.3(March 7, 2013)
- Compatibility patch for CSCA Currency System
- Removed some duplicate code (now in Core Script)
================================================================================
FEATURES:
This script creates an encyclopedia, with the option to insert it into the
default main menu. The encyclopedia contains a seperate list for items, armors,
weapons, and monsters(called bestiary).

BESTIARY: Shows enemy sprite(centered), name, currency gain, exp gain,
3 drop items, number of that enemy defeated, enemy parameters, location found,
and custom note.

ITEMS: Shows sprite (stretched bigger), item name, key item status, price,
HP Effect, MP Effect, TP Gain, success rate, occasion(menu/battle/none/both),
state applications and removals, number in possession, and custom note.

WEAPONS: Shows sprite (stretched bigger), weapon name, price, type, parameters,
speed bonus, state applications, attack element, number in possession, and
custom note.

ARMORS: Shows sprite (stretched bigger), armor name, slot, price, type,
parameters, state resists, and special effects(such as 2x gold), number in
possession, and custom note.

SKILLS: Shows sprite(stretched bigger), skill name, tp and mp cost, element,
damage type, state application and removal, scope, occasion, price(req. csca
skill shop), critical, variance, and custom note.

STATES: Shows sprite(stretched bigger), state name, priority, restriction,
removal types, chance of removal, max turns affected, min turns affected, and
custom note.

SETUP
This script requires setup further down.
Instructions included below.

IMPORTANT:
If using this script with an existing save file, you'll need to make the
following script call: $game_party.csca_init_encyclopedia

Note: If you are updating an existing version of this script, that script
call will revert everything back to undiscovered.

CREDIT:
Free to use in noncommercial games if credit is given to:
Casper Gaming (http://www.caspergaming.com/)

To use in a commercial game, please purchase a license here:
http://www.caspergaming.com/licenses.html

TERMS:
http://www.caspergaming.com/terms_of_use.html
=end
module CSCA_ENCYCLOPEDIA # Don't touch this.
  
  ####################
  # NOTETAG COMMANDS #
  ####################
  # If you have an item/whatever you don't want to be listed, put this notetag
  # code in the item/whatever's notebox: <csca enc exclude>
  #
  # To write a short note about anything, put this notetag code in the
  # item/enemy/state/etc. notebox: <cscanote: Your Text Here>
  #
  # To fill in an enemy's location info, put this notetag code in the enemy's
  # notebox: <cscafound: Your Text Here>
  #
  # To use a custom picture(size will be resized to 72x72 pixels) for the
  # picture shown for an item/skill/weapon/armor/state, put this notetag in the
  # item/skill/etc.'s notebox: <cscapic: picturename> (Do not include extension,
  # .png is assumed. Other formats will not work.)
  ################
  # SCRIPT CALLS #
  ################
  # The following script calls allow you to set certain items to discovered.
  # 
  # $game_party.csca_set_enemy_true(enemy_id)
  # $game_party.csca_set_item_true(item_id)
  # $game_party.csca_set_weapon_true(weapon_id)
  # $game_party.csca_set_armor_true(armor_id)
  # $game_party.csca_set_skill_true(skill_id)
  # $game_party.csca_set_state_true(state_id)
  # $game_party.csca_set_custom_true(custom_id)
  #
  #
  # To change the amount of a certain enemy defeated, make script call:
  #
  # $game_party.csca_add_defeated(enemy_id,amount)
  #
  #
  # To change descriptions for custom entries, use the following script call:
  #
  # $game_party.csca_change_desc(id, description)
  # Where id is the ID of the description you want to change, and description is
  # a new description array.
  #
  # $game_party.csca_change_img(id, image_path)
  # Where id is the ID of the image you want to change, and image_path is
  # a new image path relative to the main project folder.
#===============================================================================
  # Main Script Options
  
  # This controls which commands will show, the order, and the text shown.
  # DO NOT edit the first property(eg. :bestiary or :item).
  COMMANDS = [ # Do not touch.
 #[:symbol,   "Text", enabled?] (don't change default category symbols)
  [:combat,    "Combat"   , true], # Example for adding custom category
  [:noncombat,    "Non-Combat"   , true], # Example for adding custom category
  [:ruler,    "Leader"   , true], # Example for adding custom category
  [:other,    "Other"   , true], # Example for adding custom category
  [:bestiary, "Bestiary", false], # Re-order these any way you want.
  [:item,     "Items"   , false], # Re-order these any way you want.
  [:weapon,   "Weapons" , false], # Re-order these any way you want.
  [:armor,    "Armors"  , false], # Re-order these any way you want.
  [:skill,    "Skills"  , false], # Re-order these any way you want.
  [:state,    "States"  , false], # Re-order these any way you want.
  ] # Do not touch.
  
  ACTOR_ONLY = true # True means states will only be discovered when an actor
                    # is inflicted with them. False means either actors or
                    # enemies being inflicted will discover a state.
  
  TRIGGER = :C # Button used to toggle bestiary monster sprite and information.
  
  MONSTER_OPACITY = 75 # Opacity of the monster sprite while toggled off.
  # Range of valid numbers is 0 - 255, 0 being transparent.
#===============================================================================
  # Vocab. The following are text that appear in the windows.
  
  HEADER = "Harem" # Name window displayed at top during scene.
  
  UNKNOWN = "? ? ? ? ?" # Text to be displayed if item/monster/etc. is undiscovered.
  
  # Description for items/skills/weapons/armors/enemies not yet discovered.
  UNKNOWN_DESCR = "" # \n = new line
  
  # Text shown instructing players how to toggle opacity of the monster sprites.
  TRIGGER_TEXT = "Press Action button to toggle bestiary sprites."
  
  # This text shows after skill scopes that target dead allies. The default term
  # "Dead" may be too harsh for some games so this is changeable here.
  DEAD_TEXT = "(Dead)"
#===============================================================================
  # Colors. These numbers correspond to the index of the color squares in
  # the windowskin.
  
  GOOD_COLOR = 3 # Color for positive effects
  BAD_COLOR  = 2 # Color for negative effects
#===============================================================================
  # Custom Category Settings - for advanced users only.
  # With these options, you can create your own custom categories and define
  # what each list contains, what each object displays, etc.
  
  CUSTOM = [] # Do not touch.
  KEYS = [] # Do not touch.
  DESCRIPTION = [] # Do not touch.
  IMAGE = [] # Do not touch.
  
  # Description text shown in the information window of custom categories.
  # DESCRIPTION[x] = [x,["Descriptive Text","Separate lines with commas!"]]
  # the first value before the text lines is the ID of the description.
  # For example, DESCRIPTION[2838] = [2838,["text","here"]]
  DESCRIPTION[0] = [0,["Unbiasedly Best Succubus"]]
  DESCRIPTION[1] = [1,["Ardan Bounty Hunter"]]
  DESCRIPTION[2] = [2,["Self-proclaimed Cumdump"]]
  DESCRIPTION[3] = [3,["Ardan Warrior"]]
  DESCRIPTION[4] = [4,["Yhilini Merchant"]]
  DESCRIPTION[5] = [5,["Renthnoran Specialist"]]
  DESCRIPTION[6] = [6,["Bandit Exile"]]
  DESCRIPTION[7] = [7,["Elven Mage"]]
  DESCRIPTION[8] = [8,["Queen of Yhilin"]]
  DESCRIPTION[9] = [9,["Priestess of Ivala"]]
  DESCRIPTION[10] = [10,["Orc Breeding Savant"]]
  DESCRIPTION[11] = [11,["Empress of the Orgasmic Empire"]]
  DESCRIPTION[12] = [12,["Succubus Scion"]]
  DESCRIPTION[13] = [13,["Rewoman"]]
  DESCRIPTION[14] = [14,["Best Daughter"]]
  DESCRIPTION[15] = [15,["Wayward Claw"]]
  DESCRIPTION[16] = [16,["Admittedly Better Succubus"]]
  DESCRIPTION[17] = [17,["Hero Lady"]]
  DESCRIPTION[18] = [18,["Eclectic Mage"]]
  DESCRIPTION[19] = [19,["High Priestess of Ivala"]]
  DESCRIPTION[20] = [20,["Incubus King's Secretary"]]
  DESCRIPTION[21] = [21,["Queen of Ghenalon"]]
  DESCRIPTION[22] = [22,["Elder of Darghelon"]]
  DESCRIPTION[23] = [23,["Reliar of Gheldaron"]]
  DESCRIPTION[24] = [24,["Queen of Eustrin"]]
  DESCRIPTION[25] = [25,["Abomination (but she's hot)"]]
  DESCRIPTION[26] = [26,["Powerful Demon"]]
  DESCRIPTION[27] = [27,["Givini Warden of the South"]]
  DESCRIPTION[28] = [28,["Goddess of Earth"]]
  DESCRIPTION[29] = [29,["Hand of the Anak"]]
  DESCRIPTION[30] = [30,["Goddess of Purity"]]
  DESCRIPTION[31] = [31,["Goddess of Magic"]]
  DESCRIPTION[32] = [32,["Spoiler"]]
  DESCRIPTION[33] = [33,["Chaos"]]
  DESCRIPTION[34] = [34,["Genderbent Shardholder"]]
  DESCRIPTION[35] = [35, ["On Demand King"]]
  
  # Image shown in the information window of custom categories.
  # image path is relative to the main project folder. Omit or set to nil if not using.
  IMAGE[0] = "Graphics/Pictures/Yarra.png"
  IMAGE[1] = "Graphics/Pictures/Aka.png"
  IMAGE[2] = "Graphics/Pictures/Qum D'umpe.png"
  IMAGE[3] = "Graphics/Pictures/Hilstara.png"
  IMAGE[4] = "Graphics/Pictures/Megail.png"
  IMAGE[5] = "Graphics/Pictures/Trin.png"
  IMAGE[6] = "Graphics/Pictures/Varia.png"
  IMAGE[7] = "Graphics/Pictures/Altina.png"
  IMAGE[8] = "Graphics/Pictures/Janine 1.png"
  IMAGE[9] = "Graphics/Pictures/Carina.png"
  IMAGE[10] = "Graphics/Pictures/Balia.png"
  IMAGE[11] = "Graphics/Pictures/Esthera.png"
  IMAGE[12] = "Graphics/Pictures/Nalili.png"
  IMAGE[13] = "Graphics/Pictures/Dari2.png"
  IMAGE[14] = "Graphics/Pictures/Robin blond.png"
  IMAGE[15] = "Graphics/Pictures/Uyae.png"
  IMAGE[16] = "Graphics/Pictures/Riala.png"
  IMAGE[17] = "Graphics/Pictures/Ginasta.png"
  IMAGE[18] = "Graphics/Pictures/Wynn.png"
  IMAGE[19] = "Graphics/Pictures/Sarai.png"
  IMAGE[20] = "Graphics/Pictures/Iris.png"
  IMAGE[21] = "Graphics/Pictures/Fheliel.png"
  IMAGE[22] = "Graphics/Pictures/Lynine.png"
  IMAGE[23] = "Graphics/Pictures/Orilise.png"
  IMAGE[24] = "Graphics/Pictures/Neranda.png"
  IMAGE[25] = "Graphics/Pictures/Wendis greyT.png"
  IMAGE[26] = "Graphics/Pictures/Sabitha.png"
  IMAGE[27] = "Graphics/Pictures/Elleani.png"
  IMAGE[28] = "Graphics/Pictures/Tertia.png"
  IMAGE[29] = "Graphics/Pictures/Xestris.png"
  IMAGE[30] = "Graphics/Pictures/Ivala.png"
  IMAGE[31] = "Graphics/Pictures/Mithyn.png"
  IMAGE[32] = "Graphics/Pictures/Spoiler.png"
  IMAGE[33] = "Graphics/Pictures/Lilith grey.png"
  IMAGE[34] = "Graphics/Pictures/Estaven.png"
  IMAGE[35] = "Graphics/Pictures/Nyst.png"
  
  # KEYS[x] = [Name, image path, description array, key, id, custom text 1,
  # custom text 2]
  # the key determines which custom category this object will be shown in, it
  # MUST match one of the custom categories' keys.
  # id is the ID of the array, KEYS[0] has id of 0, KEYS[1] has id of 1, etc.
  # custom texts are short strings shown next to the image at the top, if not
  # using set to ""
  #
  # Comment out or Delete these if not using!
  KEYS[0] = ["Yarra",IMAGE[0],DESCRIPTION[0],
  :combat,0]
  KEYS[1] = ["Aka",IMAGE[1],DESCRIPTION[1],
  :combat,1]
  KEYS[2] = ["Qum D'umpe",IMAGE[2],DESCRIPTION[2],
  :combat,2]
  KEYS[3] = ["Hilstara",IMAGE[3],DESCRIPTION[3],
  :combat,3]
  KEYS[4] = ["Megail",IMAGE[4],DESCRIPTION[4],
  :noncombat,4]
  KEYS[5] = ["Trin",IMAGE[5],DESCRIPTION[5],
  :noncombat,5]
  KEYS[6] = ["Varia",IMAGE[6],DESCRIPTION[6],
  :combat,6]
  KEYS[7] = ["Altina",IMAGE[7],DESCRIPTION[7],
  :combat,7]
  KEYS[8] = ["Janine",IMAGE[8],DESCRIPTION[8],
  :ruler,8]
  KEYS[9] = ["Carina",IMAGE[9],DESCRIPTION[9],
  :combat,9]
  KEYS[10] = ["Balia",IMAGE[10],DESCRIPTION[10],
  :noncombat,10]
  KEYS[11] = ["Esthera",IMAGE[11],DESCRIPTION[11],
  :ruler,11]
  KEYS[12] = ["Nalili",IMAGE[12],DESCRIPTION[12],
  :combat,12]
  KEYS[13] = ["Dari",IMAGE[13],DESCRIPTION[13],
  :noncombat,13]
  KEYS[14] = ["Robin",IMAGE[14],DESCRIPTION[14],
  :combat,14]
  KEYS[15] = ["Uyae",IMAGE[15],DESCRIPTION[15],
  :combat,15]
  KEYS[16] = ["Riala",IMAGE[16],DESCRIPTION[16],
  :combat,16]
  KEYS[17] = ["Ginasta",IMAGE[17],DESCRIPTION[17],
  :combat,17]
  KEYS[18] = ["Wynn",IMAGE[18],DESCRIPTION[18],
  :noncombat,18]
  KEYS[19] = ["Sarai",IMAGE[19],DESCRIPTION[19],
  :ruler,19]
  KEYS[20] = ["Iris",IMAGE[20],DESCRIPTION[20],
  :noncombat,20]
  KEYS[21] = ["Fheliel",IMAGE[21],DESCRIPTION[21],
  :ruler,21]
  KEYS[22] = ["Lynine",IMAGE[22],DESCRIPTION[22],
  :ruler,22]
  KEYS[23] = ["Orilise",IMAGE[23],DESCRIPTION[23],
  :ruler,23]
  KEYS[24] = ["Neranda",IMAGE[24],DESCRIPTION[24],
  :ruler,24]
  KEYS[25] = ["Wendis",IMAGE[25],DESCRIPTION[25],
  :other,26]
  KEYS[26] = ["Sabitha",IMAGE[26],DESCRIPTION[26],
  :other,25]
  KEYS[27] = ["Elleani",IMAGE[27],DESCRIPTION[27],
  :ruler,27]
  KEYS[28] = ["Tertia",IMAGE[28],DESCRIPTION[28],
  :other,28]
  KEYS[29] = ["Xestris",IMAGE[29],DESCRIPTION[29],
  :ruler,29]
  KEYS[30] = ["Ivala",IMAGE[30],DESCRIPTION[30],
  :other,30]
  KEYS[31] = ["Mithyn",IMAGE[31],DESCRIPTION[31],
  :other,31]
  KEYS[32] = ["Spoiler",IMAGE[32],DESCRIPTION[32],
  :other,32]
  KEYS[33] = ["Lilith",IMAGE[33],DESCRIPTION[33],
  :other,33]
  KEYS[34] = ["Estaven",IMAGE[34],DESCRIPTION[34],
  :other,34]
  KEYS[35] = ["Nyst",IMAGE[35],DESCRIPTION[35],
  :other,35]
  
  # CUSTOM[x] = [Category Name, key, text for unknown description]
  # The key determines which KEYS will be shown in each category; their keys
  # MUST match!
  #
  # Comment out or Delete these if not using!
  CUSTOM[0] = ["Set",:combat,"t"]
  CUSTOM[1] = ["Set",:noncombat,"t"]
  CUSTOM[2] = ["Set",:ruler,"t"]
  CUSTOM[3] = ["Set",:other,"t"]
#===============================================================================
end # END SETUP #
$imported = {} if $imported.nil?
$imported["CSCA-Encyclopedia"] = true
msgbox('Missing Script: CSCA Core Script! CSCA Encyclopedia requires this
script to work properly.') if !$imported["CSCA-Core"]
class Scene_CSCA_Encyclopedia < Scene_MenuBase
  
  def start
    super
    create_head_window
    create_command_window
    create_dummy_window
    create_csca_info_window
    create_specific_total_window
    create_csca_list_window
    create_total_window
  end
  
  def create_background
    super
    @background_sprite.tone.set(0, 0, 0, 128)
  end
  
  def create_command_window
    @command_window = CSCA_Window_EncyclopediaMainSelect.new(0, @head_window.height)
    @command_window.viewport = @viewport
    @command_window.set_handler(:ok,     method(:on_category_ok))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  
  def create_head_window
    @head_window = CSCA_Window_Header.new(0, 0, CSCA_ENCYCLOPEDIA::HEADER)
    @head_window.viewport = @viewport
  end
  
  def create_dummy_window
    wx = (Graphics.width / 2) - 40
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(wx, wy, Graphics.width - wx, wh)
    @dummy_window.viewport = @viewport
  end
  
  def create_specific_total_window
    wy = @csca_info_window.height
    wh = @head_window.height
    wl = @dummy_window.width - 80
    @specific_total_window = CSCA_Window_EncyclopediaSpecificTotal.new(0, wy, wl, wh)
    @specific_total_window.viewport = @viewport
    @command_window.csca_specific_total_window = @specific_total_window
  end
  
  def create_total_window
    wy = @csca_list_window.y + @csca_list_window.height + @specific_total_window.height
    wh = @head_window.height
    wl = @csca_list_window.width
    @total_window = CSCA_Window_EncyclopediaTotal.new(0, wy, wl, wh)
    @total_window.viewport = @viewport
  end
  
  def create_csca_list_window
    height = @dummy_window.height - (@command_window.height * 2)
    width = @dummy_window.width - 80
    wy = @dummy_window.y
    @csca_list_window = CSCA_Window_ItemList.new(0, wy, width, height)
    @csca_list_window.viewport = @viewport
    @csca_list_window.help_window = @csca_info_window
    @csca_list_window.set_handler(:cancel, method(:on_list_cancel))
    @command_window.csca_list_window = @csca_list_window
  end
  
  def create_csca_info_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @csca_info_window = CSCA_Window_EncyclopediaInfo.new(@dummy_window.x, wy, @dummy_window.width, wh)
    @csca_info_window.viewport = @viewport
    @csca_info_window.hide
  end
  
  def on_category_ok
    @csca_list_window.activate
    @csca_list_window.select(0)
    @dummy_window.hide
    @csca_info_window.show
  end
  
  def on_list_cancel
    @csca_list_window.unselect
    @command_window.activate
    @csca_info_window.hide
    @dummy_window.show
  end
  
end
class CSCA_Window_EncyclopediaTotal < Window_Base
  
  def initialize(x, y, width, height)
    super(x, y, width, height)
    refresh
  end
  
  def refresh
    contents.clear
    draw_text(0,0,contents.width,line_height,sprintf("Total: %1.2f%% Complete",$game_party.csca_completion_percentage*100.00))
  end
end
class CSCA_Window_EncyclopediaSpecificTotal < Window_Base
  
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @category = :none
  end
  
  def category=(category)
    return if @category == category
    @category = category
    refresh
  end
  
  def refresh
    contents.clear
    case @category
    when :bestiary
      draw_text(0,0,contents.width,line_height,sprintf("%s: %1.2f%% Complete",
        $game_party.csca_category_text(:bestiary), $game_party.csca_completion_percentage_bestiary*100.00))
    when :item
      draw_text(0,0,contents.width,line_height,sprintf("%s: %1.2f%% Complete",
        $game_party.csca_category_text(:item), $game_party.csca_completion_percentage_items*100.00))
    when :weapon
      draw_text(0,0,contents.width,line_height,sprintf("%s: %1.2f%% Complete",
        $game_party.csca_category_text(:weapon), $game_party.csca_completion_percentage_weapons*100.00))
    when :armor
      draw_text(0,0,contents.width,line_height,sprintf("%s: %1.2f%% Complete",
        $game_party.csca_category_text(:armor), $game_party.csca_completion_percentage_armors*100.00))
    when :skill
      draw_text(0,0,contents.width,line_height,sprintf("%s: %1.2f%% Complete",
        $game_party.csca_category_text(:skill), $game_party.csca_completion_percentage_skills*100.00))
    when :state
      draw_text(0,0,contents.width,line_height,sprintf("%s: %1.2f%% Complete",
        $game_party.csca_category_text(:state), $game_party.csca_completion_percentage_states*100.00))
    else
      draw_text(0,0,contents.width,line_height,sprintf("%s: %1.2f%% Complete",
        $game_party.csca_custom_text(@category), $game_party.csca_completion_percentage_cust(@category)*100.00))
    end
  end
  
end
class CSCA_Window_EncyclopediaInfo < Window_Base
  def initialize(x, y, width, height)
    super(x, y, width, height)
  end

  def set_text(text)
    @text = text
    draw_unknown_text
  end

  def clear
    set_text("")
  end

  def set_item(item, sprite_in_front = 0)
    contents.clear
    contents.font.size = 24
    if $game_party.encyclopedia_discovered(item)
      if item.is_a?(RPG::Item)
        draw_item_information(item)
      elsif item.is_a?(RPG::Weapon)
        draw_weapon_information(item)
      elsif item.is_a?(RPG::Armor)
        draw_armor_information(item)
      elsif item.is_a?(RPG::State)
        draw_state_information(item)
      elsif item.is_a?(RPG::Skill)
        draw_skill_information(item)
      elsif item.is_a?(RPG::Enemy)
        if sprite_in_front == 1
          csca_draw_enemy_sprite(item)
          csca_draw_toggle_tutorial
        else
          draw_enemy_information(item)
        end
      else
        draw_custom_information(item) if !item.nil?
      end
    else
      if item.is_a?(RPG::Item)
        item_type = "item"
      elsif item.is_a?(RPG::Weapon)
        item_type = "weapon"
      elsif item.is_a?(RPG::Armor)
        item_type = "armor"
      elsif item.is_a?(RPG::Enemy)
        item_type = "enemy"
      elsif item.is_a?(RPG::State)
        item_type = "state"
      elsif item.is_a?(RPG::Skill)
        item_type = "skill"
      else
        if !item.nil?
          for i in 0...CSCA_ENCYCLOPEDIA::CUSTOM.size
            if CSCA_ENCYCLOPEDIA::CUSTOM[i][1] == item[3]
              item_type = CSCA_ENCYCLOPEDIA::CUSTOM[i][2] 
              break
            end
          end
        end
      end
      set_text(item ? sprintf(CSCA_ENCYCLOPEDIA::UNKNOWN_DESCR, item_type) : "")
    end
  end

  def draw_unknown_text
    draw_text_ex(4, 0, @text)
  end
  
  def draw_item_information(item)
    csca_draw_icon(item)
    csca_draw_name(item)
    contents.font.size = 20
    csca_draw_price(item)
    item.key_item? ? key_item = "Yes" : key_item = "No"
    draw_text(150,line_height,contents.width,line_height,key_item)
    change_color(system_color)
    draw_text(72,line_height,contents.width,line_height, "Key item:")
    draw_text(0,line_height*3,contents.width,line_height,"HP Effect:")
    draw_text(0,line_height*4-4,contents.width,line_height,"MP Effect:")
    draw_text(0,line_height*5-8,contents.width,line_height,"TP gain:")
    draw_text(0,line_height*6-12,contents.width,line_height,"Applies:")
    draw_text(0,line_height*7-10,contents.width,line_height,"Removes:")
    draw_text(0,line_height*8-10,contents.width,line_height,"Occasion:")
    draw_text(0,line_height*9-14,contents.width,line_height,"Success Rate:")
    change_color(normal_color)
    occasion = ""
    case item.occasion
    when 0; occasion = "Always"
    when 1; occasion = "Battle Only"
    when 2; occasion = "Menu only"
    when 3; occasion = "Never"
    end
    draw_text(78,line_height*8-10,contents.width,line_height,occasion)
    draw_text(110,line_height*9-14,contents.width,line_height,item.success_rate.to_s + "%")
    cscatpgain = 0
    for effect in item.effects
      next unless effect.code == 13
      cscatpgain += (effect.value1 * 100).to_i
    end
    cscatpgain += item.tp_gain
    cscatpgain = 100 if cscatpgain > 100
    change_color(text_color(CSCA_ENCYCLOPEDIA::GOOD_COLOR)) if cscatpgain > 0
    cscatpgain > 0 ? string = "+" : string = ""
    draw_text(70,line_height*5-8,contents.width,line_height,sprintf(string +
    "%d%%", cscatpgain))
    change_color(normal_color)
    csca_draw_value(11, 85,line_height*3, item) # 11 = HP
    csca_draw_value(12, 85,line_height*4-4, item) # 12 = MP
    csca_draw_states(0,item)
    csca_draw_states(1,item)
    csca_draw_possession(0,line_height*10-16,contents.width,line_height,item)
    csca_draw_custom_note(0,line_height*11-20,contents.width,line_height,item)
  end
  
  def draw_weapon_information(item)
    csca_draw_icon(item)
    csca_draw_name(item)
    contents.font.size = 20
    csca_draw_type(item,120,line_height,contents.width-120,line_height)
    csca_draw_price(item)
    csca_draw_all_params(item)
    change_color(system_color)
    draw_text(72,line_height,contents.width,line_height,"Type:")
    draw_text(0,line_height*7-16,contents.width,line_height,"Element:")
    draw_text(0,line_height*8-20,contents.width,line_height,"Speed:")
    draw_text(0,line_height*9-20,contents.width,line_height,"Applies:")
    change_color(normal_color)
    csca_draw_type(item,70,line_height*7-16,contents.width-70,line_height,1)
    csca_draw_wpn_speed(item)
    csca_draw_states(3,item)
    csca_draw_possession(0,line_height*10-16,contents.width,line_height,item)
    csca_draw_custom_note(0,line_height*11-20,contents.width,line_height,item)
  end
  
  def draw_armor_information(item)
    csca_draw_icon(item)
    csca_draw_name(item)
    contents.font.size = 20
    csca_draw_price(item)
    case item.etype_id
    when 1; type = "Shield"
    when 2; type = "Head"
    when 3; type = "Body"
    when 4; type = "Accessory"
    end
    draw_text(165,line_height,contents.width,line_height,type)
    csca_draw_all_params(item)
    change_color(system_color)
    draw_text(72,line_height,contents.width,line_height,"Armor Slot:")
    draw_text(0,line_height*7-12,contents.width,line_height,"Resists:")
    draw_text(0,line_height*8-12,contents.width,line_height,"Armor Type:")
    draw_text(0,line_height*9-16,contents.width,line_height,"Special:")
    change_color(normal_color)
    csca_draw_states(2,item)
    csca_draw_type(item,95,line_height*8-12,contents.width-100,line_height)
    string = "None"
    for feature in item.features
      string = feature.data_id if feature.code == 64
    end
    case string
    when 0; string = "50% Encounter Rate"
    when 1; string = "0% Encounter Rate"
    when 2; string = "0% Surprise Rate"
    when 3; string = "Raise Preemptive Rate"
    when 4; string = "200% Gold Drop Rate"
    when 5; string = "200% Item Drop Rate"
    end
    draw_text(70,line_height*9-16,contents.width,line_height,string)
    csca_draw_possession(0,line_height*10-16,contents.width,line_height,item)
    csca_draw_custom_note(0,line_height*11-20,contents.width,line_height,item)
  end
  
  def draw_state_information(item)
    csca_draw_icon(item)
    csca_draw_name(item)
    contents.font.size = 20
    change_color(system_color)
    draw_text(72,line_height,contents.width,line_height,"Restriction:")
    draw_text(72,line_height*2-4,contents.width,line_height,"Priority:")
    draw_text(0,line_height*3,contents.width,line_height,"Minimum Turns:")
    draw_text(0,line_height*4-4,contents.width,line_height,"Maximum Turns:")
    draw_text(0,line_height*5-8,contents.width,line_height,"Remove After Battle:")
    draw_text(0,line_height*6-12,contents.width,line_height,"Remove By Restriction:")
    draw_text(0,line_height*7-16,contents.width,line_height,"Remove By Damage:")
    draw_text(0,line_height*8-20,contents.width,line_height,"Chance On Damage:")
    draw_text(0,line_height*8,contents.width,line_height,"Remove By Walking:")
    draw_text(0,line_height*9-4,contents.width,line_height,"Steps To Remove:")
    change_color(normal_color)
    restriction_string = item.restriction
    case restriction_string
    when 0; restriction_string = "None"
    when 1; restriction_string = "Attack Enemies"
    when 2; restriction_string = "Attack Anyone"
    when 3; restriction_string = "Attack Allies"
    when 4; restriction_string = "Can't Move"
    end
    if item.auto_removal_timing != 1 && item.auto_removal_timing != 2
      max_turn = "N/A"
      min_turn = "N/A"
    else
      max_turn = item.max_turns.to_s
      min_turn = item.min_turns.to_s
    end
    item.remove_at_battle_end ? b_remove = "Yes" : b_remove = "No"
    item.remove_by_restriction ? r_remove = "Yes" : r_remove = "No"
    if item.remove_by_damage
      d_remove = "Yes"
      d_chance = item.chance_by_damage.to_s + "%"
    else
      d_remove = "No"
      d_chance = "N/A"
    end
    if item.remove_by_walking
      w_remove = "Yes"
      w_steps = item.steps_to_remove.to_s
    else
      w_remove = "No"
      w_steps = "N/A"
    end
    draw_text(170,line_height,contents.width,line_height,restriction_string)
    draw_text(147,line_height*2-4,contents.width,line_height,item.priority.to_s)
    draw_text(115,line_height*3,contents.width,line_height,min_turn)
    draw_text(115,line_height*4-4,contents.width,line_height,max_turn)
    draw_text(165,line_height*5-8,contents.width,line_height,b_remove)
    draw_text(180,line_height*6-12,contents.width,line_height,r_remove)
    draw_text(140,line_height*7-16,contents.width,line_height,d_remove)
    draw_text(140,line_height*8-20,contents.width,line_height,d_chance)
    draw_text(150,line_height*8,contents.width,line_height,w_remove)
    draw_text(135,line_height*9-4,contents.width,line_height,w_steps)
    csca_draw_custom_note(0,line_height*11-12,contents.width,line_height,item)
  end
  
  def draw_skill_information(item)
    csca_draw_icon(item)
    csca_draw_name(item)
    contents.font.size = 20
    change_color(system_color)
    draw_text(0,line_height*9-16,contents.width,line_height,"Element:")
    draw_text(72,line_height,contents.width,line_height,"MP Cost:")
    draw_text(72,line_height*2-4,contents.width,line_height,"TP Cost:")
    draw_text(0,line_height*3-4,contents.width,line_height,"Type:")
    draw_text(0,line_height*4-8,contents.width,line_height,"Damage:")
    draw_text(0,line_height*5-12,contents.width,line_height,"Critical:")
    draw_text(0,line_height*6-12,contents.width,line_height,"Applies:")
    draw_text(0,line_height*7-12,contents.width,line_height,"Removes:")
    draw_text(0,line_height*8-12,contents.width,line_height,"Variance:")
    draw_text(0,line_height*10-20,contents.width,line_height,"Scope:")
    $imported["CSCA-SkillShop"] ?
    draw_text(0,line_height*10,contents.width,line_height,"Price:") :
    draw_text(0,line_height*10,contents.width,line_height,"Occasion:")
    change_color(normal_color)
    damage_string = item.damage.type
    scope_string = item.scope
    occasion_string = item.occasion
    case damage_string
    when 0; damage_string = "None"
    when 1; damage_string = "HP Damage"
    when 2; damage_string = "MP Damage"
    when 3; damage_string = "HP Recovery"
    when 4; damage_string = "MP Recovery"
    when 5; damage_string = "HP Drain"
    when 6; damage_string = "MP Drain"
    end
    case scope_string
    when 0; scope_string = "None"
    when 1; scope_string = "One Enemy"
    when 2; scope_string = "All Enemies"
    when 3; scope_string = "One Random Enemy"
    when 4; scope_string = "Two Random Enemies"
    when 5; scope_string = "Three Random Enemies"
    when 6; scope_string = "Four Random Enemies"
    when 7; scope_string = "One Ally"
    when 8; scope_string = "All Allies"
    when 9; scope_string = "One Ally " + CSCA_ENCYCLOPEDIA::DEAD_TEXT
    when 10; scope_string = "All Allies " + CSCA_ENCYCLOPEDIA::DEAD_TEXT
    when 11; scope_string = "The user"
    end
    case occasion_string
    when 0; occasion_string = "Always"
    when 1; occasion_string = "Battle Only"
    when 2; occasion_string = "Menu only"
    when 3; occasion_string = "Never"
    end
    item.damage.critical ? critical = "Yes" : critical = "No"
    draw_text(140,line_height,contents.width,line_height,item.mp_cost.to_s)
    draw_text(140,line_height*2-4,contents.width,line_height,item.tp_cost.to_s)
    csca_draw_type(item,47,line_height*3-4,contents.width-70,line_height)
    csca_draw_type(item,70,line_height*9-16,contents.width-70,line_height,1)
    draw_text(65,line_height*4-8,contents.width,line_height,damage_string)
    draw_text(75,line_height*5-12,contents.width,line_height,critical)
    draw_text(75,line_height*8-12,contents.width,line_height,item.damage.variance.to_s + "%")
    csca_draw_states(0,item)
    csca_draw_states(1,item)
    draw_text(55,line_height*10-20,contents.width,line_height,scope_string)
    $imported["CSCA-SkillShop"] ?
    draw_text(55,line_height*10,contents.width,line_height,item.skill_price.to_s + Vocab::currency_unit) :
    draw_text(78,line_height*10,contents.width,line_height,occasion_string)
    csca_draw_custom_note(0,line_height*11-4,contents.width,line_height,item)
  end
  
  def draw_enemy_information(item)
    csca_draw_enemy_sprite(item, CSCA_ENCYCLOPEDIA::MONSTER_OPACITY)
    csca_draw_name(item, 1)
    contents.font.size = 20
    csca_draw_enemy_rewards(item, 0, line_height)
    csca_draw_enemy_rewards(item, 1, line_height*2-4)
    csca_draw_all_params(item, 1)
    draw_text(88,line_height*6,contents.width,line_height,"1.")
    draw_text(88,line_height*7-4,contents.width,line_height,"2.")
    draw_text(88,line_height*8-8,contents.width,line_height,"3.")
    csca_draw_enemy_treasures(item)
    change_color(system_color)
    draw_text(0,line_height*6,contents.width,line_height,"Treasures:")
    draw_text(0,line_height*9-12,contents.width,line_height,"Number Defeated:")
    draw_text(0,line_height*10-16,contents.width,line_height,"Found:")
    change_color(normal_color)
    string = $game_party.csca_enemies_defeated(item).to_s
    draw_text(130,line_height*9-12,contents.width,line_height," "+string)
    draw_text(45,line_height*10-16,contents.width,line_height," "+item.csca_locations)
    csca_draw_custom_note(0,line_height*11-20,contents.width,line_height,item)
    csca_draw_toggle_tutorial
  end
  
  def draw_custom_information(item)
    item[1].nil? ? x = 0 : x = 0
    unless item[1].nil?
      # handle both Decanter and Casper storage formats, for save backward compatibility
      if $game_party.csca_images.nil?
        bitmap = Bitmap.new(item[1])
      else
        bitmap = Bitmap.new($game_party.csca_images[item[4]])
      end
      target = Rect.new(0,10,272,288)
      contents.stretch_blt(target, bitmap, bitmap.rect, 255)
    end
    contents.font.bold = true
    draw_text(x,0,contents.width-72,line_height,item[0])
    contents.font.bold = false
    contents.font.size = 20
    y = line_height
    description = $game_party.csca_descriptions[item[2][0]]
    #p(item)
    #p(description)
    #p($game_party.csca_descriptions)
    for i in 0...description[1].size
      draw_text(0,y,contents.width,line_height,description[1][i])
      y += line_height-4
    end
    draw_text(x,y,contents.width-72,line_height,item[5])
    item[5] != "" ? y += line_height : y += 0
    draw_text(x,y,contents.width-72,line_height,item[6])
    item[6] != "" ? y += line_height-4 : y += 0
  end
  
  def csca_draw_possession(x,y,width,height,item)
    change_color(system_color)
    draw_text(x,y,width,height,"Possession:")
    change_color(normal_color)
    draw_text(x+95,y,width,height,$game_party.item_number(item).to_s)
  end
  
  def csca_draw_custom_note(x,y,width,height,item)
    change_color(system_color)
    draw_text(x,y,width,height,"Note:")
    change_color(normal_color)
    draw_text(x+40,y,width,height," "+item.csca_custom_note)
  end
  
  def csca_draw_toggle_tutorial
    contents.font.size = 16
    draw_text(0,line_height*12-12,contents.width,line_height,CSCA_ENCYCLOPEDIA::TRIGGER_TEXT,1)
  end
  
  def csca_draw_enemy_sprite(item, opacity = 255)
    bitmap = Cache.battler(item.battler_name, item.battler_hue)
    x = (contents.width / 2) - (bitmap.width / 2)
    y = (contents.height / 2) - (bitmap.height / 2)
    if bitmap.width > contents.width && bitmap.height > contents.height
      target = Rect.new(0, 0, contents.width, contents.height)
    elsif bitmap.width > contents.width
      target = Rect.new(0, y, contents.width, bitmap.height)
    elsif bitmap.height > contents.height
      target = Rect.new(x, 0, bitmap.width, contents.height)
    else
      target = Rect.new(x,y,bitmap.width,bitmap.height)
    end
    contents.stretch_blt(target, bitmap, bitmap.rect, opacity)
  end
  
  def csca_draw_enemy_treasures(enemy)
    drop1 = "Nothing"
    drop2 = "Nothing"
    drop3 = "Nothing"
    items = []
    for item in enemy.drop_items
      if items[0].nil?
        items[0] = item
        next
      end
      if items[1].nil?
        items[1] = item
        next
      end
      items[2] = item
    end
    case items[0].kind
    when 1; drop1 = $data_items[items[0].data_id].name
    when 2; drop1 = $data_weapons[items[0].data_id].name
    when 3; drop1 = $data_armors[items[0].data_id].name
    end
    case items[1].kind
    when 1; drop2 = $data_items[items[1].data_id].name
    when 2; drop2 = $data_weapons[items[1].data_id].name
    when 3; drop2 = $data_armors[items[1].data_id].name
    end
    case items[2].kind
    when 1; drop3 = $data_items[items[2].data_id].name
    when 2; drop3 = $data_weapons[items[2].data_id].name
    when 3; drop3 = $data_armors[items[2].data_id].name
    end
    draw_text(105,line_height*6,contents.width-96,line_height,drop1)
    draw_text(105,line_height*7-4,contents.width-96,line_height,drop2)
    draw_text(105,line_height*8-8,contents.width-96,line_height,drop3)
  end
  
  def csca_draw_enemy_rewards(item, type, y)
    if type == 0
      currency = $game_party.get_csca_cs_currency(item.currency_symbol) if $imported["CSCA-CurrencySystem"]
      reward = item.gold
      string1 = "Currency: "
      string2 = $imported["CSCA-CurrencySystem"] ? currency[:currency_unit] : Vocab::currency_unit
      x = 78
    else
      reward = item.exp
      string1 = "Experience: "
      string2 = ""
      x = 95
    end
    change_color(system_color)
    draw_text(0,y,contents.width,line_height,string1)
    change_color(type == 0 && $imported["CSCA-CurrencySystem"] ? currency[:color] : normal_color)
    number = $csca.split_number(reward)
    if number[0] >= 1
      draw_text(x,y,contents.width,line_height,sprintf("%d,%03d,%03d"+string2,number[0],number[1],number[2]))
    elsif number[0] == 0 && number[1] >= 1
      draw_text(x,y,contents.width,line_height,sprintf("%d,%03d"+string2,number[1],number[2]))
    else
      draw_text(x,y,contents.width,line_height,sprintf("%d"+string2,number[2]))
    end
    change_color(normal_color)
  end
  
  def csca_draw_icon(item)
    if item.csca_custom_picture == ""
      icon_index = item.icon_index
      bitmap = Cache.system("Iconset")
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      target = Rect.new(0,0,272,288)
      contents.stretch_blt(target, bitmap, rect)
    else
      bitmap = Bitmap.new("Graphics/Pictures/"+item.csca_custom_picture+".png")
      target = Rect.new(0,0,272,288)
      contents.stretch_blt(target, bitmap, bitmap.rect, 255)
    end
  end
  
  def csca_draw_name(item, center = 0)
    contents.font.bold = true
    center != 0 ? draw_text(0,0,contents.width,line_height,item.name,center) :
      draw_text(72,0,contents.width-72,line_height,item.name)
    contents.font.bold = false
  end
  
  def csca_draw_price(item)
    number = $csca.split_number(item.price)
    currency = $game_party.get_csca_cs_currency(item.currency_symbol) if $imported["CSCA-CurrencySystem"]
    unit = $imported["CSCA-CurrencySystem"] ? currency[:currency_unit] : Vocab::currency_unit
    change_color(system_color)
    draw_text(72,line_height*2-4,contents.width,line_height,"Price:")
    change_color(item.price > 0 && $imported["CSCA-CurrencySystem"] ? currency[:color] : normal_color)
    if number[0] >= 1
      draw_text(125,line_height*2-4,contents.width,line_height,sprintf("%d,%03d,%03d" + unit, number[0], number[1], number[2]))
    elsif number[0] == 0 && number[1] >= 1
      draw_text(125,line_height*2-4,contents.width,line_height,sprintf("%d,%03d" + unit, number[1], number[2]))
    elsif number[0] == 0 && number[1] == 0 && number[2] >= 1
      draw_text(125,line_height*2-4,contents.width,line_height,sprintf("%d" + unit, number[2]))
    else
      draw_text(125,line_height*2-4,contents.width,line_height,"N/A")
    end
    change_color(normal_color)
  end
  
  def csca_draw_all_params(item, type = 0)
    w = contents.width/2
    if type == 0
      y1 = line_height*3
      y2 = line_height*4-4
      y3 = line_height*5-8
      y4 = line_height*6-12
    else
      y4 = line_height*3-8
      y1 = line_height*4-12
      y2 = line_height*5-16
      y3 = line_height*6-20
    end
    change_color(system_color)
    param_0 = Vocab::param(0)+": "
    param_1 = Vocab::param(1)+": "
    param_2 = Vocab::param(2)+": "
    param_3 = Vocab::param(3)+": "
    param_4 = Vocab::param(4)+": "
    param_5 = Vocab::param(5)+": "
    param_6 = Vocab::param(6)+": "
    param_7 = Vocab::param(7)+": "
    draw_text(0,y1,contents.width,line_height,param_2)
    draw_text(w,y1,contents.width,line_height,param_3)
    draw_text(0,y2,contents.width,line_height,param_4)
    draw_text(w,y2,contents.width,line_height,param_5)
    draw_text(0,y3,contents.width,line_height,param_6)
    draw_text(w,y3,contents.width,line_height,param_7)
    draw_text(0,y4,contents.width,line_height,param_0)
    draw_text(w,y4,contents.width,line_height,param_1)
    change_color(normal_color)
    csca_draw_param(2,item,text_size(param_2).width,y1)
    csca_draw_param(3,item,w+text_size(param_3).width,y1)
    csca_draw_param(4,item,text_size(param_4).width,y2)
    csca_draw_param(5,item,w+text_size(param_5).width,y2)
    csca_draw_param(6,item,text_size(param_6).width,y3)
    csca_draw_param(7,item,w+text_size(param_7).width,y3)
    csca_draw_param(0,item,text_size(param_0).width,y4)
    csca_draw_param(1,item,w+text_size(param_1).width,y4)
  end
  
  def csca_draw_param(param_id, item, x, y)
    parameter = item.params[param_id]
    string = ""
    if parameter > 0
      unless item.is_a?(RPG::Enemy)
        change_color(text_color(CSCA_ENCYCLOPEDIA::GOOD_COLOR))
        string = "+"
      end
    elsif parameter < 0
      change_color(text_color(CSCA_ENCYCLOPEDIA::BAD_COLOR))
      string = ""
    else
      change_color(normal_color)
      string = ""
    end
    string += parameter.to_s
    draw_text(x,y,contents.width,line_height,string)
    change_color(normal_color)
  end
  
  def csca_draw_type(item,x,y,w,h,elm = 0)
    if item.is_a?(RPG::Armor)
      csca_array = $data_system.armor_types
      item.atype_id == 0 ? string = "None" : string = csca_array[item.atype_id]
    elsif item.is_a?(RPG::Weapon)
      case elm
      when 0
        csca_array = $data_system.weapon_types
        item.wtype_id == 0 ? string = "None" : string = csca_array[item.wtype_id]
      when 1
        csca_array = $data_system.elements
        string = "None"
        for feature in item.features
          case feature.code
          when 31
            feature.data_id == 0 ? string = "None" : string = csca_array[feature.data_id]
          end
        end
      end
    elsif item.is_a?(RPG::Skill)
      case elm
      when 0
        csca_array = $data_system.skill_types
        item.stype_id == 0 ? string = "None" : string = csca_array[item.stype_id]
      when 1
        csca_array = $data_system.elements
        item.damage.element_id < 0 ? string = "Normal Attack" :
        item.damage.element_id == 0 ? string = "None" : string = csca_array[item.damage.element_id]
      end
    end
    draw_text(x,y,w,h,string)
  end
  
  def csca_draw_wpn_speed(item)
    speed = 0
    for feature in item.features
      case feature.code
      when 33
        speed += feature.value.to_i
      end
    end
    if speed > 0
      change_color(text_color(CSCA_ENCYCLOPEDIA::GOOD_COLOR))
      string = "+"
    elsif speed < 0
      change_color(text_color(CSCA_ENCYCLOPEDIA::BAD_COLOR))
      string = ""
    else
      change_color(normal_color)
      string = ""
    end
    draw_text(50,line_height*8-20,contents.width,line_height,string + speed.to_s)
    change_color(normal_color)
  end

  def csca_draw_value(code,x,y,item)
    p = 0
    c = 0
    string = ""
    for effect in item.effects
      next unless effect.code == code
      p = (effect.value1 * 100).to_i
      c += effect.value2.to_i
    end
    c *= item.repeats
    if c != 0
      if c > 0
        change_color(text_color(CSCA_ENCYCLOPEDIA::GOOD_COLOR))
        string = "+"
      else
        change_color(text_color(CSCA_ENCYCLOPEDIA::BAD_COLOR))
        string = ""
      end
      draw_text(x,y,contents.width,line_height,sprintf(string+"%d", c))
    elsif p != 0
      if p > 0 
        change_color(text_color(CSCA_ENCYCLOPEDIA::GOOD_COLOR))
        string = "+"
      else
        change_color(text_color(CSCA_ENCYCLOPEDIA::BAD_COLOR))
        string = ""
      end
      draw_text(x,y,contents.width,line_height,sprintf(string+"%d%%", p))
    else
      draw_text(x,y,contents.width,line_height,"0")
    end
    change_color(normal_color)
  end
  
  def csca_draw_states(applies,item)
    icons = []
    if item.is_a?(RPG::Item) || item.is_a?(RPG::Skill)
      for effect in item.effects
        if applies == 0
          case effect.code
          when 21
            next unless effect.value1 > 0
            next if $data_states[effect.value1].nil?
            next if effect.data_id == 0
            icons.push($data_states[effect.data_id].icon_index)
          end
          icons.delete(0)
          break if icons.size >= 9
        else
          case effect.code
          when 22
            next unless effect.value1 > 0
            next if $data_states[effect.value1].nil?
            next if effect.data_id == 0
            icons.push($data_states[effect.data_id].icon_index)
          end
          icons.delete(0)
          break if icons.size >= 9
        end
      end
    elsif item.is_a?(RPG::Armor)
      for feature in item.features
        icons.push($data_states[feature.data_id].icon_index) if feature.code == 14
        icons.delete(0)
        break if icons.size >= 9
      end
    else
      for feature in item.features
        icons.push($data_states[feature.data_id].icon_index) if feature.code == 32
        icons.delete(0)
        break if icons.size >= 9
      end
    end
    case applies
    when 0; y = line_height*6-12
    when 1; y = line_height*7-10
    when 2; y = line_height*7-12
    when 3; y = line_height*9-20
    end
    csca_draw_icons(70, y, contents.width, icons)
  end
  
  def csca_draw_icons(x, y, width, icons)
    for icon_id in icons
      draw_icon(icon_id, x, y)
      x += 24
    end
    if icons.size == 0
      draw_text(70,y,contents.width,line_height,"Nothing")
    end
  end
  
end
class CSCA_Window_EncyclopediaMainSelect < Window_HorzCommand
  attr_reader :csca_list_window
  attr_reader :csca_specific_total_window
  
  def initialize(x, y)
    super(x,y)
  end
  
  def update
    super
    @csca_list_window.category = current_symbol if @csca_list_window
    @csca_specific_total_window.category = current_symbol if @csca_specific_total_window
  end
  
  def make_command_list
    for i in 0...CSCA_ENCYCLOPEDIA::COMMANDS.size
      if CSCA_ENCYCLOPEDIA::COMMANDS[i][2]
        add_command(CSCA_ENCYCLOPEDIA::COMMANDS[i][1],CSCA_ENCYCLOPEDIA::COMMANDS[i][0])
      end
    end
  end
  
  def csca_list_window=(csca_list_window)
    @csca_list_window = csca_list_window
    update
  end
  
  def csca_specific_total_window=(csca_specific_total_window)
    @csca_specific_total_window = csca_specific_total_window
    update
  end
  
  def window_width
    return Graphics.width
  end
  
end
class CSCA_Window_ItemList < Window_Selectable
  
  def initialize(x, y, width, height)
    super
    @category = :none
    @data = []
    @csca_monster_in_front = false
  end

  def category=(category)
    return if @category == category
    @category = category
    refresh
    self.oy = 0
  end

  def item_max
    @data ? @data.size : 1
  end

  def item
    @data && index >= 0 ? @data[index] : nil
  end

  def include?(item)
    case @category
    when :bestiary
      item.is_a?(RPG::Enemy) && !item.csca_encyclopedia_exclude?
    when :item
      item.is_a?(RPG::Item) && !item.csca_encyclopedia_exclude?
    when :weapon
      item.is_a?(RPG::Weapon) && !item.csca_encyclopedia_exclude?
    when :armor
      item.is_a?(RPG::Armor) && !item.csca_encyclopedia_exclude?
    when :state
      item.is_a?(RPG::State) && !item.csca_encyclopedia_exclude?
    when :skill
      item.is_a?(RPG::Skill) && !item.csca_encyclopedia_exclude?
    else
      false
    end
  end
  
  def cust_include?(item)
    item[3] == @category
  end
    
  def make_item_list
    @data = $data_items.select {|item| include?(item)}
    @data += $data_weapons.select {|item| include?(item)}
    @data += $data_armors.select {|item| include?(item)}
    @data += $data_enemies.select {|item| include?(item)}
    @data += $data_skills.select {|item| include?(item)}
    @data += $data_states.select {|item| include?(item)}
    @data += CSCA_ENCYCLOPEDIA::KEYS.select {|item| cust_include?(item)}
    @data.push(nil) if include?(nil)
  end

  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      draw_item_id(rect, index)
      if $game_party.encyclopedia_discovered(item)
        if item.is_a?(RPG::Enemy)
          draw_text(rect.x+40,rect.y,contents.width-40,line_height,item.name)
        elsif not_custom(item)
          draw_item_name(item, rect.x + 40, rect.y, true, contents.width - 60)
        else
          draw_text(rect.x+40,rect.y,contents.width-40,line_height,item[0])
        end
      else
        draw_unknown_text(rect)
      end
    end
  end

  def draw_item_id(rect, index)
    draw_text(rect, sprintf("%3d.", index + 1))
  end
  
  def draw_unknown_text(rect)
    draw_text(rect, sprintf("    %s", CSCA_ENCYCLOPEDIA::UNKNOWN))
  end
  
  def not_custom(item)
    item.is_a?(RPG::Item) || item.is_a?(RPG::Weapon) || item.is_a?(RPG::Armor) ||
    item.is_a?(RPG::Skill) || item.is_a?(RPG::State) || item.is_a?(RPG::Enemy)
  end

  def update_help
    if @category == :bestiary && @csca_monster_in_front == true
      @help_window.set_item(item, 1)
    else
      @help_window.set_item(item, 0)
    end
  end

  def refresh
    refresh_button_input
    make_item_list
    create_contents
    draw_all_items
  end
  
  def update
    super
    refresh_button_input
  end
  
  def refresh_button_input
    if Input.trigger?(CSCA_ENCYCLOPEDIA::TRIGGER) && @csca_monster_in_front && @category == :bestiary
      @csca_monster_in_front = false
      Sound.play_ok
      update_help
    elsif Input.trigger?(CSCA_ENCYCLOPEDIA::TRIGGER) && !@csca_monster_in_front && @category == :bestiary
      @csca_monster_in_front = true
      Sound.play_ok
      update_help
    end
  end
  
end
class Game_Party < Game_Unit
  attr_reader :csca_enemies
  attr_reader :csca_items
  attr_reader :csca_weapons
  attr_reader :csca_armors
  attr_reader :csca_defeated_number
  attr_reader :csca_states
  attr_reader :csca_skills
  attr_reader :csca_custom_enc
  attr_reader :csca_descriptions
  attr_reader :csca_images
  
  alias csca_init_all_items init_all_items
  def init_all_items
    csca_init_all_items
    csca_init_encyclopedia
  end
  
  def csca_init_encyclopedia
    @csca_enemies = []
    @csca_items = []
    @csca_weapons = []
    @csca_armors = []
    @csca_defeated_number = []
    @csca_states = []
    @csca_skills = []
    @csca_custom_enc = []
    @csca_descriptions = []
    @csca_images = []
    @enemy_number = 0
    for i in 0..$data_enemies.size
      @csca_enemies[i] = false
      @csca_defeated_number[i] = 0
    end
    for i in 0..$data_items.size
      @csca_items[i] = false
    end
    for i in 0..$data_weapons.size
      @csca_weapons[i] = false
    end
    for i in 0..$data_armors.size
      @csca_armors[i] = false
    end
    for i in 0..$data_skills.size
      @csca_skills[i] = false
    end
    for i in 0..$data_states.size
      @csca_states[i] = false
    end
    for i in 0...CSCA_ENCYCLOPEDIA::KEYS.size
      @csca_custom_enc[i] = false
    end
    for i in 0...CSCA_ENCYCLOPEDIA::DESCRIPTION.size
      @csca_descriptions[i] = CSCA_ENCYCLOPEDIA::DESCRIPTION[i]
    end
    for i in 0...CSCA_ENCYCLOPEDIA::IMAGE.size
      @csca_images[i] = CSCA_ENCYCLOPEDIA::IMAGE[i]
    end
  end
  
  alias csca_gain_item gain_item
  def gain_item(item, amount, include_equip = false)
    csca_gain_item(item, amount)
    csca_set_discovered(item)
  end
  
  def csca_change_desc(id, description)
    @csca_descriptions[id] = [id,description]
  end
  
  def csca_change_img(id, image_path)
    @csca_images[id] = image_path
  end
  
  def csca_set_discovered(item, discover = true)
    if item.is_a?(RPG::Item)
      @csca_items[item.id] = discover
    elsif item.is_a?(RPG::Weapon)
      @csca_weapons[item.id] = discover
    elsif item.is_a?(RPG::Armor)
      @csca_armors[item.id] = discover
    elsif item.is_a?(RPG::Enemy)
      @csca_enemies[item.id] = discover
    elsif item.is_a?(RPG::Skill)
      @csca_skills[item.id] = discover
    elsif item.is_a?(RPG::State)
      @csca_states[item.id] = discover
    elsif !item.nil?
      @csca_custom_enc[item] = discover
    end
  end
  
  def csca_set_defeated(enemy, number = 1)
#    @csca_defeated_number[enemy.id] += number
  end
  
  def csca_enemies_defeated(enemy)
    @csca_defeated_number[enemy.id]
  end
  
  def encyclopedia_discovered(item)
    if item.is_a?(RPG::Item)
      @csca_items[item.id]
    elsif item.is_a?(RPG::Weapon)
      @csca_weapons[item.id]
    elsif item.is_a?(RPG::Armor)
      @csca_armors[item.id]
    elsif item.is_a?(RPG::Enemy)
      @csca_enemies[item.id]
    elsif item.is_a?(RPG::Skill)
      @csca_skills[item.id]
    elsif item.is_a?(RPG::State)
      @csca_states[item.id]
    else
      unless item.nil?
        @csca_custom_enc[item[4]]
      end
    end
  end
  
  def enemies_discovered
    number = 0
    for i in 0..@csca_enemies.size
      if @csca_enemies[i] == true && !$data_enemies[i].csca_encyclopedia_exclude?
        number += 1
      end
    end
    return number
  end
  
  def items_discovered
    number = 0
    for i in 0..@csca_items.size
      if @csca_items[i] == true && !$data_items[i].csca_encyclopedia_exclude?
        number += 1
      end
    end
    return number
  end
  
  def weapons_discovered
    number = 0
    for i in 0..@csca_weapons.size
      if @csca_weapons[i] == true && !$data_weapons[i].csca_encyclopedia_exclude?
        number += 1
      end
    end
    return number
  end
  
  def armors_discovered
    number = 0
    for i in 0..@csca_armors.size
      if @csca_armors[i] == true && !$data_armors[i].csca_encyclopedia_exclude?
        number += 1
      end
    end
    return number
  end
  
  def states_discovered
    number = 0
    for i in 0..@csca_states.size
      if @csca_states[i] == true && !$data_states[i].csca_encyclopedia_exclude?
        number += 1
      end
    end
    return number
  end
  
  def skills_discovered
    number = 0
    for i in 0..@csca_skills.size
      if @csca_skills[i] == true && !$data_skills[i].csca_encyclopedia_exclude?
        number += 1
      end
    end
    return number
  end
  
  def custom_enc_discovered(symbol)
    number = 0
    for i in 0..@csca_custom_enc.size
      if @csca_custom_enc[i] == true && CSCA_ENCYCLOPEDIA::KEYS[i][3] == symbol
        number += 1
      end
    end
    return number
  end
  
  def csca_set_enemy_true(enemy_id)
    csca_set_discovered($data_enemies[enemy_id])
  end
  
  def csca_set_item_true(item_id)
    csca_set_discovered($data_items[item_id])
  end
  
  def csca_set_armor_true(armor_id)
    csca_set_discovered($data_armors[armor_id])
  end
  
  def csca_set_weapon_true(weapon_id)
    csca_set_discovered($data_weapons[weapon_id])
  end
  
  def csca_set_state_true(state_id)
    csca_set_discovered($data_states[state_id])
  end
  
  def csca_set_skill_true(skill_id)
    csca_set_discovered($data_skills[skill_id])
  end
  
  def csca_set_custom_true(custom_id)
    csca_set_discovered(custom_id)
  end
  
  def csca_add_defeated(enemy_id,amount)
    csca_set_defeated($data_enemies[enemy_id],amount)
  end
  
  def csca_total_enemies
    total = 0
    for i in 0..$data_enemies.size
      if $data_enemies[i].is_a?(RPG::Enemy)
        total += 1 if !$data_enemies[i].csca_encyclopedia_exclude?
      end
    end
    return total
  end
  
  def csca_total_items
    total = 0
    for i in 0..$data_items.size
      if $data_items[i].is_a?(RPG::Item)
        total += 1 if !$data_items[i].csca_encyclopedia_exclude?
      end
    end
    return total
  end
  
  def csca_total_weapons
    total = 0
    for i in 0..$data_weapons.size
      if $data_weapons[i].is_a?(RPG::Weapon)
        total += 1 if !$data_weapons[i].csca_encyclopedia_exclude?
      end
    end
    return total
  end
  
  def csca_total_armors
    total = 0
    for i in 0..$data_armors.size
      if $data_armors[i].is_a?(RPG::Armor)
        total += 1 if !$data_armors[i].csca_encyclopedia_exclude?
      end
    end
    return total
  end
  
  def csca_total_skills
    total = 0
    for i in 0..$data_skills.size
      if $data_skills[i].is_a?(RPG::Skill)
        total += 1 if !$data_skills[i].csca_encyclopedia_exclude?
      end
    end
    return total
  end
  
  def csca_total_states
    total = 0
    for i in 0..$data_states.size
      if $data_states[i].is_a?(RPG::State)
        total += 1 if !$data_states[i].csca_encyclopedia_exclude?
      end
    end
    return total
  end
  
  def csca_total_custom_enc(symbol)
    total = 0
    for i in 0...CSCA_ENCYCLOPEDIA::KEYS.size
      total += 1 if CSCA_ENCYCLOPEDIA::KEYS[i][3] == symbol
    end
    return total
  end
  
  def csca_completion_percentage_bestiary
    csca_total_enemies == 0 ? 0 : (enemies_discovered.to_f/csca_total_enemies)
  end
  
  def csca_completion_percentage_items
    csca_total_items == 0 ? 0 : (items_discovered.to_f/csca_total_items)
  end
  
  def csca_completion_percentage_weapons
    csca_total_weapons == 0 ? 0 : (weapons_discovered.to_f/csca_total_weapons)
  end
  
  def csca_completion_percentage_armors
    csca_total_armors == 0 ? 0 : (armors_discovered.to_f/csca_total_armors)
  end
  
  def csca_completion_percentage_skills
    csca_total_skills == 0 ? 0 : (skills_discovered.to_f/csca_total_skills)
  end
  
  def csca_completion_percentage_states
    csca_total_states == 0 ? 0 : (states_discovered.to_f/csca_total_states)
  end
  
  def csca_completion_percentage_cust(symbol)
    total = csca_total_custom_enc(symbol)
    total == 0 ? 0 : (custom_enc_discovered(symbol).to_f/total)
  end
    
  
  def csca_completion_percentage
    total = 0
    total += csca_total_enemies if csca_command_enabled?(:bestiary)
    total += csca_total_items if csca_command_enabled?(:item)
    total += csca_total_weapons if csca_command_enabled?(:weapon)
    total += csca_total_armors if csca_command_enabled?(:armor)
    total += csca_total_skills if csca_command_enabled?(:skill)
    total += csca_total_states if csca_command_enabled?(:state)
    total += CSCA_ENCYCLOPEDIA::KEYS.size
    disc = 0
    disc += enemies_discovered if csca_command_enabled?(:bestiary)
    disc += items_discovered if csca_command_enabled?(:item)
    disc += weapons_discovered if csca_command_enabled?(:weapon)
    disc += armors_discovered if csca_command_enabled?(:armor)
    disc += skills_discovered if csca_command_enabled?(:skill)
    disc += states_discovered if csca_command_enabled?(:state)
    for i in 0...CSCA_ENCYCLOPEDIA::KEYS.size
      disc += 1 if @csca_custom_enc[i]
    end
    return disc.to_f/total
  end
  
  def csca_commands
    CSCA_ENCYCLOPEDIA::COMMANDS
  end
  
  def csca_command_enabled?(category)
    for i in 0..csca_commands.size
      next if csca_commands[i].nil?
      return true if csca_commands[i][0] == category && csca_commands[i][2]
    end
    return false
  end
  
  def csca_category_text(category)
    for i in 0..csca_commands.size
      return csca_commands[i][1] if csca_commands[i][0] == category
    end
    return ""
  end
  
  def csca_custom_text(symbol)
    for i in 0..CSCA_ENCYCLOPEDIA::CUSTOM.size
      if CSCA_ENCYCLOPEDIA::CUSTOM[i][1] == symbol
        return CSCA_ENCYCLOPEDIA::CUSTOM[i][0]
      end
    end
    return ""
  end
  
end
class Game_Enemy < Game_Battler
  alias csca_collapse perform_collapse_effect
  def perform_collapse_effect
    csca_collapse
    $game_party.csca_set_discovered(enemy)
    $game_party.csca_set_defeated(enemy)
  end
end
class Game_Actor < Game_Battler
  alias csca_enc_learn_skill learn_skill
  def learn_skill(skill_id)
    $game_party.csca_set_discovered($data_skills[skill_id]) unless skill_learn?($data_skills[skill_id])
    csca_enc_learn_skill(skill_id)
  end
end
class Game_Battler < Game_BattlerBase
  alias csca_enc_add_new_state add_new_state
  def add_new_state(state_id)
    $game_party.csca_set_discovered($data_states[state_id]) if csca_actor_check
    csca_enc_add_new_state(state_id)
  end
  def csca_actor_check
    return true if actor?
    return true if !actor? && !CSCA_ENCYCLOPEDIA::ACTOR_ONLY
    return false
  end
end
class RPG::BaseItem
  def csca_encyclopedia_exclude?
    @note =~ /<csca enc exclude>/i
  end
  def csca_custom_note
    @note =~ /<cscanote: (.*)>/i ? $1.to_s : ""
  end
  def csca_custom_picture
    @note =~ /<cscapic: (.*)>/i ? $1.to_s : ""
  end
end
class RPG::Enemy < RPG::BaseItem
  def csca_locations
    @note =~ /<cscafound: (.*)>/i ? $1.to_s : ""
  end
end
