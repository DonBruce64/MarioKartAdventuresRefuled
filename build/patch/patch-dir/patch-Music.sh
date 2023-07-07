#!/bin/bash

#------------------------------------------------------------------------------
# patch-Music.sh
#------------------------------------------------------------------------------
#
# scripts to patch the music files for Mario Kart Adventures.
#
# Music Naming Convention:
# 
#		$type-$cup_$slot$lapState
#
# Example 1: the [r]ace music in the [2]nd cup in the [4]th slot for a [f]inal lap:
#
#		r-2_4_f.brstm
#
# Example 2: the [b]attle arena music in the [2]nd cup in the [5]th slot during [n]ormal play:
#
#		b-2_5_n.brstm
#
#
# Character voices are patched differently.  These can't be edited by scripts as they are part of the revo_kart.brsar file.  So we pre-patch this file use it as needed in this script.  The character race voices can be modified directly BrawlBox, as they show up on the left side in the VO folder ....somewhat.  Most of the voice clips show up on the left side, but for some reason the the SELECT (kart select) and STRM (slipstream) voices show up but cannot be changed from the left side.  This is likely due to them being a different format.
#
# All select voices are located in Sound Index 637 (GRP) as a long list of tiles.  Starting at index 16, each character has varying amount of clips.  Some have only a few, some have more.  If the character can talk, then they will usually have their final two clips being their voice for blue battle and red battle selection.  Though some are an exception to this, like Peach, who should have such a voice clip according to the BRSAR tree, but doesn't in this file.  In general, it's 3 clips for the character selection, 3 for kart, one for blue team, and one for red team.
#Also note that Dry Bones does not have a set of sounds as his sounds are done differently than all others and aren't WAV files in this block.
#
#For all characters, here are the sound indexes in the 637 file.
#  Mario 16-23
#  Luigi 24-31
#  Yoshi 32-37
#  Peach 38-41
#  Daisy 42-49
#  Birdo 50-52
#  Bowser Jr 53-57
#  Diddy Kong 58-60
#  Baby Mario 61-68
#  Baby Luigi 69-76
#  Baby Peach 77-84
#  Baby Daisy 85-90
#  Toadette 91-95
#  Toad 96-100
#  Koopa Troopa 102-104
#  Wario 105-112
#  Waluigi 113-120
#  Bowser 121-125
#  Donkey Kong 126-128
#  King Boo 129-131
#  Funky Kong 132-137
#  Dry Bowser 138-140
#  Rosalina 141-143
#
# Slipstream/drafting sounds (STRM) are all in random places, but are usually in the GRP/VO/XX/PC and GRP/VO/XX/NPC files, where XX is the character code.  There are usually two for each character, with one being all the files you get on the menu on the left side (RWSD), and the other being these sounds (RBNK).
#
# Thankfully, you don't have to remember any of this, as you can use the ExportBRSAR.py and ImportBRSAR.py provided in this patch in conjunction with BrawlCrate for auto import/export functionality.  These scripts will dump and format not only the left-side files, but the various stream banks as well as the 637 files.  The only issue is that the BrawlCrate folks wrap WAV->RWSD functionality inside a dialog box, so you'll need to have something to auto-click the box when it pops up if you want do not go crazy importing all the files.  Or, you can just hit tab and enter with a hotkey (a rate of 100ms between tab/enter and 500ms between commands works well).  Don't worry about the tab-enter fouling things, as when it's done it'll just get stuck in a random property box in BrawlCrate and sit there accepting the entry until you stop it.
#
# written by Helix, modified by don_bruce
#
#------------------------------------------------------------------------------


#import global variables
if [ -f ./../config.def ]; then 
	. ./../config.def
fi

yes="1=yes"
no="0=no"

echo ""
echo ""
echo "Adding your music!" 

#----------------------------------------------------------
# This part of the patch is only accessible through advanced options. In order to access it
# you need this exact settings configuration:
#
#  Use Advanced Settings? yes
#  Use Mario Kart Adventure's Music? yes
#  Reorder music? yes
#
#
# If this setting is enabled, the songs get reordered to better fit the tracks on Mario Kart 
# Wii. This is best for using our music with a CTGP-based custom game, as we don't fix the 
# revo_kart loop points. In CTGP, loop points are fixed automatically. 

if [[ $PARTIAL_PATCH_MUSIC ==  $yes &&  $ADVANCE_OPTIONS == $yes && $MUSIC_REORDER == $yes ]]; then
	echo ""
	echo ""
	echo "** Reordering your music so that it better fits the order for Mario Kart Wii..."
	newFiles=(         r-1_3   r-1_4   r-2_4   r-3_4   r-4_1   r-4_3   r-5_3   r-6_1   r-6_2   r-7_1   r-7_2   r-7_4   r-8_3   e-desert_1   e-desert_2   b-1_2   b-2_2   b-2_4   b-2_5 )
	filesToReplace=(   r-5_3   r-3_4   r-3_2   r-1_4   r-7_2   r-6_1   r-7_4   r-1_3   r-7_3   r-6_2   r-8_3   r-2_4   r-4_3   r-4_1        r-7_1        b-2_4   b-2_5   b-1_2   b-2_2 )
	
	# First, copy all the music that we want into a folder with its proper names to a
	# temporary folder. It is a bad idea to copy all the files directly to their new 
	# locations since you run the risk of prematurely overwriting files you intend to keep.
	musicPath=./music/tracks
	mkdir -p ${musicPath}/new
	for (( i = 0 ; i < ${#newFiles[@]} ; i=$i+1 ));
	do
		if [[ -f ${musicPath}/${newFiles[${i}]}_n.brstm ]]; then
			#echo "new path ${musicPath}/${filesToReplace[${i}]}.brstm"
			ln -f "${musicPath}/${newFiles[${i}]}_n.brstm" "${musicPath}/new/${filesToReplace[${i}]}_n.brstm"
		fi
		if [[ -f ${musicPath}/${newFiles[${i}]}_f.brstm ]]; then
			ln -f "${musicPath}/${newFiles[${i}]}_f.brstm" "${musicPath}/new/${filesToReplace[${i}]}_f.brstm"
		fi
	done
	# Then, apply the music all at once over the original music, now that all the songs are in a temporary folder.
	for (( i = 0 ; i < ${#filesToReplace[@]} ; i=$i+1 ));
	do
		if [[ -f ${musicPath}/new/${filesToReplace[${i}]}_n.brstm ]]; then
			#echo "this is all together ${musicPath}/${filesToReplace[${i}]}_n.brstm"
			ln -f "${musicPath}/new/${filesToReplace[${i}]}_n.brstm" "${musicPath}/${filesToReplace[${i}]}_n.brstm"
		fi
		
		if [[ -f ${musicPath}/new/${filesToReplace[${i}]}_f.brstm ]]; then
			ln -f "${musicPath}/new/${filesToReplace[${i}]}_f.brstm" "${musicPath}/${filesToReplace[${i}]}_f.brstm"
		fi
	done
fi

# We're about to rename files that have an simpler naming convention so that they work with Mario Kart Wii.
# 
# First, declare some helper functions...


# for their final music and a handful of new race tracks have a capital F for their final lap music
# This fix is only needed for linux; windows doesn't care about filename capitalization
function capitalFFix()
{
	if [[ "${2}" == "f" ]]; then
		musicfilename="${1}F" 
	else
	    musicfilename="${1}${2}" 
	fi
}

# If every other letter is capital, then the final letter is capital
# This fix is only needed for linux; windows doesn't care about filename capitalization
function allCapitalFix()
{
	if [[ "${2}" == "f" ]]; then
		musicfilename="${1}F" 
	else
	    musicfilename="${1}N" 
	fi
}


# Now we start the patch, since all the music that we plan to patch is 
# ready, its just in the wrong location with the wrong name. 
# First patch the track music.
for file in ./music/tracks/*.brstm
do

	#Strip the file prefix to get the actual file name.
	substr=${file:15}
	substr=${substr%.*}
	type=(${substr//-/ })
	index=(${type[1]//_/ })
	musicfilename=""
	shouldPatch=1
	if [[ ${type[0]} == "b" ]]; then
		case ${index[0]} in 
			1) 
				case ${index[1]} in 
					1) capitalFFix "n_block_" "${index[2]}" ;;
					2) capitalFFix "n_venice_" "${index[2]}" ;;
					3) capitalFFix "n_skate_" "${index[2]}" ;;
					4) capitalFFix "n_casino_"  "${index[2]}" ;;
					5) capitalFFix "n_ryuusa_"  "${index[2]}" ;; 
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac		
				;;
			2) 
				case ${index[1]} in 
					1) capitalFFix "r_sfc_battle_" "${index[2]}" ;;
					2) capitalFFix "r_agb_battle_" "${index[2]}"  ;;
					3) capitalFFix "r_64_battle_" "${index[2]}" ;;
					4) capitalFFix "r_GC_Battle32_" "${index[2]}"  ;;
					5) capitalFFix "r_ds_battle_" "${index[2]}" ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac		
				;;
			*)
				echo "ERROR: improperly formatted file: $file"
				shouldPatch=0
				;;
		esac	
	elif [[ ${type[0]} == "r" ]]; then
		case ${index[0]} in 
			1) 
				case ${index[1]} in 
					1) musicfilename="n_Circuit32_${index[2]}" ;;
					2) capitalFFix "n_Farm_" "${index[2]}"  ;;
					3) capitalFFix "n_Kinoko_" "${index[2]}" ;;
					4) allCapitalFix "STRM_N_FACTORY_" "${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac		
				;;
			2) 
				case ${index[1]} in 
					1) echo "ERROR: cup 2, track 1 is the sane music as cup 1, track 1.  You cannot replace it!" ; shouldPatch=0 ;;
					2) musicfilename="n_Shopping32_${index[2]}"  ;;
					3) capitalFFix "n_Snowboard32_" "${index[2]}" ;;
					4) allCapitalFix "STRM_N_TRUCK_" "${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac					
				;;
			3) 
				case ${index[1]} in 
					1) musicfilename="n_Daisy32_${index[2]}" ;;
					2) allCapitalFix "STRM_N_WATER_" "${index[2]}"  ;;
					3) capitalFFix "n_maple_" "${index[2]}" ;;
					4) musicfilename="n_Volcano32_${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac	
				;;
			4) 
				case ${index[1]} in 
					1) allCapitalFix "STRM_N_DESERT_" "${index[2]}" ;;
					2) allCapitalFix "STRM_N_RIDGEHIGHWAY_" "${index[2]}"  ;;
					3) allCapitalFix "STRM_N_KOOPA_" "${index[2]}" ;;
					4) musicfilename="n_Rainbow32_${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac	
				;;
			5) 
				case ${index[1]} in 
					1) musicfilename="r_GC_Beach32_${index[2]}" ;;
					2) musicfilename="r_DS_Jungle32_${index[2]}"  ;;
					3) musicfilename="r_SFC_Obake32_${index[2]}" ;;
					4) musicfilename="r_64_Circuit32_${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac	
				;;
			6) 
				case ${index[1]} in 
					1) musicfilename="r_64_Sherbet32_${index[2]}" ;;
					2) musicfilename="r_AGB_Beach32_${index[2]}"  ;;
					3) musicfilename="r_DS_Town32_${index[2]}" ;;
					4) musicfilename="r_GC_Stadium32_${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac	
				;;
			7) 
				case ${index[1]} in 
					1) musicfilename="r_DS_Desert32_${index[2]}" ;;
					2) musicfilename="r_AGB_Kuppa32_${index[2]}"  ;;
					3) musicfilename="r_64_Jungle32_${index[2]}" ;;
					4) musicfilename="r_GC_Circuit32_${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac	
				;;
			8) 
				case ${index[1]} in 
					1) musicfilename="r_SFC_Circuit32_${index[2]}" ;;
					2) musicfilename="r_DS_Garden32_${index[2]}"  ;;
					3) musicfilename="r_GC_Mountain32_${index[2]}" ;;
					4) musicfilename="r_64_Kuppa32_${index[2]}"  ;;
					*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
				esac	
				;;
			*)
				echo "ERROR: improperly formatted file: $file"
				shouldPatch=0
				;;
		esac			
	elif [[ ${type[0]} == "e" ]]; then
		#Extra track for custom music only, not actually patched normally.
		shouldPatch=0
	fi
	
	
	if [[ "$shouldPatch" == "1" ]]; then
		#echo "$file  ->  ./files/sound/strm/$musicfilename.brstm" 
		ln -f "$file" "./files/sound/strm/$musicfilename.brstm" 
	fi
done

# Now patch the ui files
for file in ./music/ui/*.brstm
do
	#Strip the file prefix to get the actual file name.
	substr=${file:11}
	substr=${substr%.*}
	musicfilename=""
	shouldPatch=1
	case ${substr} in 
		"menu_options") musicfilename="o_Option_32" ;;
		"menu_wifi") musicfilename="o_Wi-Fi_waiting32" ;;
		"menu_unlock") musicfilename="strm_me" ;;
		
		"fanfare_intro_race") musicfilename="o_Crs_In_Fan" ;;
		"fanfare_intro_battle") musicfilename="o_Crs_In_Fan_battle" ;;
		"fanfare_intro_mission") musicfilename="o_Crs_In_Fan_mission" ;;
		"fanfare_intro_wifi") musicfilename="o_Crs_In_Fan_Wifi" ;;
		
		"fanfare_start_race") musicfilename="o_Start32_fan" ;;
		"fanfare_start_timetrial") musicfilename="o_Start2_32_fan" ;;
		
		"fanfare_finish_race_winner") musicfilename="o_FanfareGP1_only32" ;;
		"fanfare_finish_race_good") musicfilename="o_FanfareGP2_only32" ;;
		"fanfare_finish_race_bad") musicfilename="o_FanfareGPdame_only32" ;;
		"fanfare_finish_battle_good") musicfilename="o_FanfareMIwin_only32" ;;
		"fanfare_finish_battle_bad") musicfilename="o_FanfareMIlose_only32" ;;
		"fanfare_finish_timetrial_winner") musicfilename="o_FanfareTA1st_only32" ;;
		
		"result_race_win") musicfilename="o_FanfareGP1_32" ;;
		"result_race_good") musicfilename="o_FanfareGP2_32" ;;
		"result_race_lose") musicfilename="o_FanfareGPdame_32" ;;
		
		"result_battle_bestplayer") musicfilename="o_FanfareTA1st_32" ;;
		"result_battle_winningteam") musicfilename="o_FanfareMIwin_32" ;;
		"result_battle_draw") musicfilename="o_FanfareBTdraw_32" ;;
		"result_battle_lose") musicfilename="o_FanfareMIlose_32" ;;
		
		"result_boss_win") musicfilename="o_FanfareMIWinBoss_32" ;;
		
		"award_win") musicfilename="o_hyousyou_winningrun" ;;
		"award_win_short") musicfilename="o_hyousyou_normal" ;;
		"award_win_shortest") musicfilename="o_hyousyou_cut" ;;
		"award_lose") musicfilename="o_hyousyou_lose" ;;
		
		
		*) echo "ERROR: improperly formatted file $file " ; shouldPatch=0 ;;
	esac		
	
	if [[ "$shouldPatch" == "1" ]]; then
		#echo "$file  ->  ./files/sound/strm/$musicfilename.brstm" 
		ln -f "$file" "./files/sound/strm/$musicfilename.brstm" 
	fi
done


#------------------------------------------------------------------------------
#patch SFX sound file
ln -f "./music/revo_kart.brsar" "./files/sound/revo_kart.brsar"

true

