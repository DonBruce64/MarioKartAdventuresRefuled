      __  __            _         _  __          _     
     |  \/  | __ _ _ __(_) ___   | |/ /__ _ _ __| |_   
     | |\/| |/ _` | '__| |/ _ \  | ' // _` | '__| __|  
     | |  | | (_| | |  | | (_) | | . \ (_| | |  | |_   
     |_|  |_|\__,_|_|  |_|\___/_ |_|\_\__,_|_|   \__|  
    / \   __| |_   _____ _ __ | |_ _   _ _ __ ___  ___ 
   / _ \ / _` \ \ / / _ \ '_ \| __| | | | '__/ _ \/ __|
  / ___ \ (_| |\ V /  __/ | | | |_| |_| | | |  __/\__ \
 /_/   \_\__,_| \_/ \___|_| |_|\__|\__,_|_|  \___||___/
                                                        
                                                        

##############################################################
Setup and Installation
##############################################################

0. If you're building this patch from GitHub source, see Building From Source at the end of this Readme.  Otherwise, just go to step 1 if you found this in a zip file released online.

1. Unpack the directory that you downloaded from the internet. There should be a folder named "build" with a bunch of .sh scripts with names like create-image.sh, view-image.sh, etc. inside of it. This is the folder you will use to make your game. 

2. Obtain an .ISO of Mario Kart Wii that works for your region (NTSC is for America, NTSC-J is for Asia, PAL is for Europe). The legal way to do this is to your softmod a wii and to run an ISO loader from it. Many of the ISO loader applications have the ability to backup an ISO from a disc to a hard drive. The one that we use is USB Loader GX. We do not support piracy.  In fact, we strongly encourage you to research any characters, music, or tracks that you like in this game. You might find a new game to play out of it ;) 

3. Take your legal ISO of Mario Kart Wii and place it in the build folder.

4. Run "create-image". For windows, double click on the create-image.bat. For OSX or Linux, open terminal, navigate to this directory, and run the command "bash create-image.sh"

5. Answer what format you want the game in (typically ISO), what language you want the game in, and whether or not you want a separate save game for this game. It is recommended to use a separate savegame to avoid corrupting the save file, but we don't follow our own advice...

6. Run this ISO on your Wii.  Or your Dolphin emumator.



##############################################################
The Patching Process
##############################################################

-All of our tracks, characters, and items were taken from custom mario kart wikis and message boards. There is also a small subset of content that was made by us for this game. As for music, we are moving our music selection towards one that is entirely opensource and free-to-distribute and thus we find all of our music online. Most of our music is either a video game remix or rearrangement, or an free-to-distribute 8-bit song. If you like a song, we strongly encourage you to check out the musician. The same goes for tracks or other content in-game. For example, SpyKid and xBlue98 have incredible tracks that we didn't include in this game. Please check out our CREDITS.txt file for a full list of credits for all the content. 

- MKA makes hevy use of scripts to automatically patch your base game.  Each script is responsible for patching a different section of the game.  Broadly defined, this consists of custom charachters (models, karts, textures), custom tracks, custom items, custom music, and custom items.  Note that some patching is linked.  For example, patching tracks will result in their names on the menu changing, and their previews changing.  If you want more granular control, turn on the advanced options.

- Since all patching happens via these scripts, it is possible to inject or modify the content of this patch before running them.  This allows you to switch out any MKA mods with ones you want.  For more detail on this, check each script that is included in the patch.tar file.  In general, you can just replace the files in the patch with your own and the scripts will do the rest.  Heck, you can even completely move things around.  Want to change the track order?  Just re-name the files to a different order.  Want Sonic to replace Peach rather than Lugi?  Just delete the peach folder, and name the luigi one peach.  Note: audio is currently not something we can modify with the scripts, so if you do this and also select audio as something to change, then Luigi will still sound like Sonic.

- Easier naming conventions have been established for nearly all files in this patch.  These have a logical naming convention instead of being named things such as r_sfc_obake, STRM_N_FACTORY, fm_item_kinoko_l, etc.

- For all tracks, the lap count is set to 3 by default, and the speed modifier is set to 1.0.  Both can be changed in the track files with the appropriate programs.  While CPUs are affected by the lap count, they are not affected by the speed changes.  Thefore, the AIParam.bas file should be modified in any custom tracks to adjust computer speed (if it has not been done already by the author).  BAS files are only 20 bytes long, containing 5 floats.  However, the only value you need to worry about is 0x00, which is the speed advantage.  This value is added to the CPUs' base speed, so adjust this to make AI faster if you increased the speed of the track.

-If you decide to re-arrange or replace courses, ensure that you follow the special slot rules here: http://wiki.tockdom.com/wiki/Slot.  Most of these rules are based on what objects are in the files.  Personal opinion: just include all the super-special objects in any custom course you use so it can go into any slot.

-If you want to replace the sounds for the characters, you will need to use an external program like BrawlBox to modofy the revo_kart.brsar file.  See the patch-Music script in the patch.tar for more details on this process.



##############################################################
Plans for Future Releases
##############################################################

- Add CT code and with it add speedometer, automatic brsar patching, etc.
- add revo_kart patching scripts, remove revo_kart from distribution (not likely, but hey, one can dream!)
- Remove even more nintendo content from scripts

##############################################################
TEAM
##############################################################

Helix (v0.1 - V0.81): writes scripts and breaks stuff.
Nickname (v0.7 - V0.81): chooses and makes all the new music and sound effects, German translator
DonBruce (v0.9 - present): spends too much time fixing up abandoned projects


##############################################################
CHANGE LOG
##############################################################


v0.6:
- Initial playable alpha release
- ISO Patcher only
- NTSC only
- 10 Characters, 13 texture modded characters
- 32 new custom tracks, 4 retro battle track ports, 6 original battle tracks


v0.7:
- Final playable alpha release
- ISO Patcher and Riivolution
- NTSC, NTSC-J, PAL
- 16 custom characters, 6 texture modded characters
- 32 new custom tracks, 4 retro battle track ports, 6 texture modded battle tracks
- 1 updated track (River of Dreams) 

v0.8
- First Beta release
- ISO Patcher only
- NTSC, NTSC-J, PAL
- English and German Translations
- 14 custom characters, 8 texture modded characters
- 1 custom kart
- 4 new songs for tracks, 4 new songs for Battle Arenas, 6 new songs for menus
- Mario Kart 8 content updates. Includes 12 colors of Yoshi, 12 colors of Shy Guy, Baby Rosalina, metal mario texture mod, and a mercedes Benz kart for medium characters 
- Fixes to miscellaneous character bugs
- new texture modded characters
- new texture modded itemboxes


v0.81
- Spanish translation for both PAL and NTSC added
- Small fixes to textures, sound equalization
- The game can now be output as a Riivolution game if built with Windows or Linux
- Advanced options added to patch only the music, only the characters, only the tracks, or only the UI. You can also patch a subset of these.

v0.9
- Start of Don Bruce's edits.  Keeping this thing alive!

-----Char Changes
- Swapped Kamek for Crash Bandicoot with full sounds due to there not being enough sounds for Kamek.
- Added sounds for Pac-Man, and moved him to Birdo's slot.  Birdo has fewer unique sounds, so this suits Pac-Man better than Jr's slot.  Sounds used were from Pac-Man, Donkey Kong, and Donkey Kong Jr.
- Put in Scout in the slot vacated by Pac-Man.  Is a complete replacement, rather than Rayman over Birdo, who was missing sounds.
- Un-Did the Baby Daisy/Peach swap.  Baby "Rosalina" is now on her proper slot over Baby Peach.  Cuts down on pre-patch jank and build time.
- Swapped Baby Daisy for Kirby with full sounds.  No award model, but has everything else.
- Swapped Roy for King Boo (Luigi's Mansion Model).  Can't change King Boo's sounds due to them being MIDI-like, and it's really odd to have Roy sounding like a ghost.  Plus, there's not that many voice clips of him, so he'd always sound like someone else no matter who we put him over.
- Swapped ROB for Dr. Eggman  with full sounds as ROB doesn't have enough sounds.  ROB also doesn't have an award model or a low-detail models, whereas Eggman does.  This means no more ROBs that look like Wario at a distance.
- Updated Wreck it Ralph models.  Comes with cart selection models and new carts.
- Replaced SuperMario64DS Sonic model with ALE XD model.  Should fix the random Sonic crashes and texture spazzing.  Kept the sounds though.

-----Track Changes
- Added speed and lap mod support via main.dol patching.  This allows for faster tracks like Mario GP, and replacing Big Blue with the non-boost updated version.  This required updates to the WIT tools that are used to build the hack.

---Cup 1
- Slot 1: Removed Volcaninc Skyway and moved Pysduck Islands (really Psyduck Cliffs) into the vacted slot.  Updated Pysduck Cliffs to newest version, and removed Rooster Island since there shouldn't be any more slowdowns.
- Slot 2: Moved Wetland Woods to this slot.
- Slot 3: Moved Sunset Ridge to this slot.  Updated from RC3 and RC2 in multiplayer to RC5.  Since slow-motion bug is fixed, the lower-version isn't needed for multiplayer anymore and was removed.
- Slot 4: Added Retro Raceway.

---Cup 2
- Changed title, theme, and cup icon.
- Slot 1: Moved out Wetland Woods to Cup 1, Slot 2.  Added Concord Town.
- Slot 2: Updated Seaside Resort from 1.1 to 1.4.opt
- Slot 3: Moved Volcano Beach into this slot and updated from 1.0 to 1.5.
- Slot 4: Moved Bayside Boulevard into this slot, and updated from 1.0 to 1.2.

---Cup 3
- Changed title, theme, and cup icon.
- Slot 1: Moved Bayside Boulevard to Cup 2.  Added Lunar Road
- Slot 2: Moved Twinkle Circuit to this slot.
- Slot 3: Moved celestial ruins to this slot and updated to 2.4.1.
- Slot 4: Moved River of Dreams to this slot and updated to 1.3.6.

---Cup 4
- Changed title, theme, and cup icon.
- Slot 1: Moved Celestial Ruins to Cup 3 and replaced with Syline Avenue.
- Slot 2: No changes!
- Slot 3: Moved Twinkle Circuit to Cup 3, moved updated Rush City Run to this slot, updated to Beta 5.opt.
- Slot 4: Moved Halogen Highway into this slot and updated to 1.0.

---Cup 5
- Swapped position of Candy Mountains and Outset Island.
- Moved Castle Grounds to slot 3.
- Moved Cool Cool Mountain Slide to slot 4.

---Cup 6
- Slot 1: Changed lap count from 3 to 5.
- Slot 2: No changes!
- Slot 3: Updated to version RC1c.
- Slot 4: Updated to version 1.1, 1.0 size.

---Cup 7
- Changed title, theme, and cup icon.
- Slot 1: Moved River of Dreams to Cup 3 and replaced with Sunset Raceway
- Slot 2: Moved Sunset Ridge to Cup 1 and replaced with Seaside Circuit
- Slot 3: Moved Big Blue to this slot and updated to 1.4, which removes whole-track boost panel.  Candy Coaster was removed.
- Slot 4: Moved Halogen Highway to Cup 4 and replaced with a sped-up version of GP Mario Beach

---Cup 8
- Changed title.
- Slot 1: Updated to version 3.5.4.
- Slot 2: Moved Sunset Ridge to Cup 1 and moved Dreamwold Cloudway to this slot and updated it to version 2.3.
- Slot 3: Moved Six King Labyrinth to this slot.
- Slot 4: Moved Strobenz Desert to this slot.


- Updated nearly all the tracks.  Amazing how much things change in 6 years...  Note that not all tracks went to their newest version.  Seems some authors don't like the tighter tracks and have started upscaling things randomly.  Safe to say, super large (boring) tracks aren't the focus of this pack...
- Removed the "alternate" tracks.  This was due to existing tracks not being optimized properly.  These tracks have since been updated to be better optimized, so lag no longer occurs.  The code to handle this is kept in the script, however, just in case someone wants to change out the course later.
- Removed a few tracks that were tough for players to complete, mainly due to paths (Aquadrom Stage in particular).  If the course was difficult, but fair, it went to the Elite Four cup.  Strobenz Desert comes to mind here.
- Moved courses around and updated cup names to reflect new order.  Cups are now named to reflect what's in them.  Which I think is actually a Mario Kart first?
- A few courses got speed or lap changes from what they are by default from the creator.  This was to make the length approxamately the same for each course.  The same goes for speed changes, as some courses, like Mario GP, are rather boring without them.
- Changed out a few songs to fit with the track changes.
- Removed track previews as they weren't correct with switches, and if we go to 8+ cup support they'll cause issues.

##############################################################
Building From Source
##############################################################

Git doesn't like large files.  Therefore, the "source code", if you will, cannot include the .tar file that's used in the patch scripts itself.  This, combined with the fact there are no known scripts for auto-patching BRSAR files, and the size of that file being too large for Git, means there are steps to take the files here on Git and turn them into a working patch for end-users.

1. Patch the revo_kart.brsar file from the base game, and add it to to build/patch/patch-dir/music.  This needs to be patched as according to the instructions located in patch-Music.sh.  In general, this requires importing all the files located in the build/sounds/wavfiles folder using the plugins in the build/sounds/plugins with BrawlCrate.  Remove the build/sounds folder after patching.

2. Take the entire build/patch folder, and compress it into patch.tar.  Ensure that patch-dir is the root directory for this tar.  Remove the build/patch folder after turning it into a tar.

3. Compress the entire repository into a zip file.  This includes the build folder, and the two .txt files, but NOT the hidden .git folder and .gitignore file.

4. Distribute file and prosper.