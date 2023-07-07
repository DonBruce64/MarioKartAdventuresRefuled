#!/bin/bash
# (c) wiimm (at) wiimm.de -- 2013-08-21

T_NO="no"
T_YES="yes"

T_LANGUAGE_INFO="\nSetup the language for messages only.\n"
T_LANGUAGE="Language"

T_MSGLANG_INFO=$( cat <<- __EOT__

	Setup the language for game messages. English and German are available.\n
	__EOT__
)
T_MSGLANG="Gaming language"

T_ISOMODE_INFO="\nDefine the file format of the new image.\n"
T_ISOMODE="Image file format"
T_ISOMODE_RIIV1=$( cat <<- __EOT__

	Instead of creating an image Riivolution output is also possible. If using
	the keyword 'riiv' then a Riivolution directory is created as template for
	a SD-Card. This variant needs also an original image disc to create and
	patch the files.\n
	__EOT__
)
T_ISOMODE_RIIV2=$( cat <<- __EOT__

	Instead of creating an image, Riivolution output is also possible. If 
	using one of the keywords 'riiv' or 'riiv-' then a Riivolution directory
	is created as template for a SD-Card.

	The first variant ('riiv') is recommended and needs also an original image
	disc to create and patch the files. The second variant ('riiv-') does not
	need the original image and creates a poor version by copying only the
	tracks and some other stuff without patching messages or images.\n
	__EOT__
)
T_ISOMODE_RIIV3=$( cat <<- __EOT__

	Instead of creating an image Riivolution output is also possible. If using
	the keyword 'riiv' then a Riivolution directory is created as template for
	a SD-Card. This variant does need also an original image disc.\n
	__EOT__
)

T_SPLITISO_INFO="\nShould output files >4GB divided into several pieces?\n"
T_SPLITISO="Split new images at 4GB"

T_SAVEGAME_INFO=$( cat <<- __EOT__

	Do you want to share save data for this game with Mario Kart Wii?
	If you say yes, you will be able to use your pre-existing Mario Kart Wii data so you will not need to unlock karts or tracks. However, do not use ghosts in time trials.\n
	__EOT__
)
T_PRIV_SAVEGAME="Share save data with Mario Kart Wii?"


T_SAVEGAME_INFO=$( cat <<- __EOT__

	Do you want to share save data for this game with Mario Kart Wii?
	If you say yes, you will be able to use your pre-existing Mario Kart Wii data so you will not need to unlock karts or tracks. However, do not use ghosts in time trials.\n
	__EOT__
)


T_ADVANCE_OPTIONS_INFO=$( cat <<- __EOT__

	Do you want to use advanced settings? This allows you to choose a different 
	source image to patch over. Also, you can choose to use a subset of the 
	features of the patch. All these features are EXPERIMENTAL. 
	This patch is not guarenteed to work over another custom game. \n
	__EOT__
)
T_ADVANCE_OPTIONS="Use Advance Settings? (Note: EXPERIMENTAL)"

T_DIFFERENT_INPUT_INFO=$( cat <<- __EOT__


	Do you want to patch a game other than original Mario Kart Wii source? Keep in mind, this is not guarenteed to work. Leave blank if you plan on just patching the original Mario Kart Wii Disc Image. For best results, patch other games that were built with ISO Patcher. Also, do not try to patch riivolution versions. If you do not wish to use this feature, just leave it blank. \n
	__EOT__
)

T_DIFFERENT_INPUT="Patch a different game? Input gameID (RMCE71, RMCE22, etc.)"


T_DIFFERENT_OUTPUT_INFO=$( cat <<- __EOT__


	Do you want to output a game image with a different ID? Third character of 
	image ID determined by the source region. E=NTSC J=NTSC-J P=PAL
	Use this option if you want to store multiple versions of the game with
	different settings. 
	WARNING: this will overwrite other custom games if they share an ID.
	THESE IDS ARE TAKEN AND WILL NOT WORK:
	01 (Mario Kart Wii)
	02-59 (Wiimms Mario Kart Fun)
	60-99 (Various Custom Games)
	A0-A8 (Mario Kart Adventures)
	A9 (Mario Kart Adventures test and custom builds)
	Format:last two characters only
	Example: NTSC image with A9 Ending (RMCEA9), type "A9"\n
	
	__EOT__
)

T_DIFFERENT_OUTPUT="Use a different output ID? Input last two letters (A9, F2, B3, etc.)"


T_PARTIAL_PATCH_MUSIC_INFO=$( cat <<- __EOT__

	Do you want to include the music and character voices? Certain music tracks are switched around so that they fit in
	better with the mario kart wii songs. For example, the song over Haunted Woods in our game is put over the song for the Boo track. This standardizes the music for other releases automatically. \n
	__EOT__
)

T_PARTIAL_PATCH_MUSIC="Patch the music, character voices, and in-game sounds?"

T_MUSIC_REORDER_INFO=$( cat <<- __EOT__

	Do you want to reorder the music? This option changes the music from Mario Kart Adventures ordering to standard Mario Kart Wii ordering. This means if you are patching the music over the original Mario Kart Wii or you are using the music in a build based off of CTGP, snow themed music is on snow themed tracks, bowser themed music is over Bowser tracks.
	NOTE: Unless the game you are patching automatically adds song looping, songs may not loop if you choose this option and do not update revo_kart yourself. \n
	__EOT__
)

T_MUSIC_REORDER="Do you want to change the music in this patch so that it fits better in Mario Kart Wii or CTGP?"

T_PARTIAL_PATCH_ITEMS_INFO=$( cat <<- __EOT__

	Do you want to include the items?\n 
	__EOT__
)

T_PARTIAL_PATCH_ITEMS="Use the items from Mario Kart Adventures?"

T_PARTIAL_PATCH_CHARACTERS_INFO=$( cat <<- __EOT__

	Do you want to include the characters? This may lead to more frequent blackscreen in less stable custom games. \n
	__EOT__
)
T_PARTIAL_PATCH_CHARACTERS="Use the characters from Mario Kart Adventures?"

T_MULTI_CHAR_OVERWRITE_INFO=$( cat <<- __EOT__

	Do you want the scripts to correct missing multiplayer character models? The correction makes it so that if computer players are playing a character while you play multiplayer, they appear as the custom character. However, this makes crashes in multiplayer more frequent, since the script replaces the multiplayer models with a complex single player model. Future versions of Mario Kart Adventures will fix this issue but for now this is a quick fix you can toggle on and off.\n
	Choose NO if you prefer stability over detail. \n
	__EOT__
)

T_MULTI_CHAR_OVERWRITE="Allow the script to \"fix\" missing multiplayer models?"

T_PARTIAL_PATCH_TRACKS_INFO=$( cat <<- __EOT__

	Do you want to include the tracks? \n
	__EOT__
)
T_PARTIAL_PATCH_TRACKS="Use the tracks from Mario Kart Adventures?"


T_PARTIAL_PATCH_UI_INFO=$( cat <<- __EOT__

	Do you want to patch the UI? This will change menus, boot-up screens, preview 
	videos, and more. This may not work with another custom Mario Kart Wii 
	distribution.\n
	__EOT__
)
T_PARTIAL_PATCH_UI="Use the UI from Mario Kart Adventures?"

T_LOG_LIST_SOURCE="View possible [%s] sources"
T_LOG_RM_WORKDIR="Remove working dir"
T_LOG_EXTRACT_IMAGE="Extract files of source [%s]"
T_LOG_EXTRACT_RIIV="Extract Riiv files of [%s]"
T_LOG_COPY_IMAGE="Copy (hard link) files of source [%s]"
T_LOG_PATCH_FILE="Patch file '%s'"
T_LOG_PATCH="Use patch file '%s'"
T_LOG_PATCH_TRACK=" * Change the order of tracks and/or arenas\n"
T_LOG_PATCH_REGION=" * Set region ID to 0x%02x (=%u)\n"
T_LOG_ADD_IMAGE="Create new image [%s] on all connected WBFS drives"
T_LOG_CREATE_IMAGE="Create new image [%s] -> %s"
T_LOG_DONE_COUNT=">>>>>  %u %s image(s) created  <<<<<"

T_LOG_RIIV_START="Create Riivolution directory '%s'"
T_LOG_RIIV_SETUP=" * Setup\n"
T_LOG_RIIV_TRANSFER=" * Copy patched files\n"
T_LOG_RIIV_CREATE=" * Create '%s'\n"

T_LOG_RIIV_TIMESTAMP="\nSet time stamps of files\n"
