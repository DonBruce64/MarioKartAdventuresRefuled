#!/bin/bash


#------------------------------------------------------------------------------
# patch-Tracks.sh
#------------------------------------------------------------------------------
#
# scripts to patch the track files for Mario Kart Adventures.
# 
#
# Track Naming Convention:
# 
#		$type-$cup_$slot_$playerMode
#   You do not need to include a _m version for multi-player, as this script will use the _s single-player version for it.
#   However, you CAN include both if you wish.  Useful if the single-player course causes lag in multi-player and should be substituted.
#
#
# Example 1: the [r]ace track in the [2]nd cup in the [4]th slot for [s]ingle player mode:
#
#		r-2_4_s.wu8
#
# Example 2: the [b]attle arena in the [2]nd cup in the [5]th slot in [m]ulti player mode:
#
#		b-2_5_m.wu8
#
# Example 3: the [a]ward course for [w]inner in [s]ingle player mode:
#
#		a-w_s.wu8
#
# Other award types are [d]raw, [l]ooser, and [e]nd course.
# 
#
#
# written by Helix, modified by don_bruce
#
#------------------------------------------------------------------------------


#First patch text for the new track names.
echo ""
echo ""
echo "But really..."
for i in "./files/Scene/UI/*.szs"; do
	wszst patch  $i --patch-bmg "replace=./tracks/${CFG_MSGLANG}_tracks.txt" -q
done

#Now we patch the authors.
#Show authors of tracks in previews instead of showing track title again by patching only the Race_* with author names
echo ""
echo ""
echo "Why are you still reading this? If you must know, I'm currently adding the tracks... "	
for i in "./files/Scene/UI/Race_*"; do
	wszst patch  $i --patch-bmg "replace=./tracks/${CFG_MSGLANG}_authors.txt" -q
done


echo ""
echo "" 
echo "Stop watching me update. I'm self concious..."


#Before doing any track patching, we need an auto-add library to convert the wu8 files to szs.
wszst autoadd -q ./files/Race/Course/ -D ./auto-add

#  This for loop is devoted to taking a simpler naming convention and converting it to Mario Kart Wii's original naming scheme. 
for file in ./tracks/*_s.wu8
do
	#Strip the file prefix to get the actual file name.
	substr=${file:9}
	#immediately excludes files that don't contain the delimiters from processing
	if [[ $substr == *-* ]] && [[ $substr == *_* ]] 
	then
		#string format is type-index[0]_index[1]_index[2]
		type=(${substr//-/ })
		index=(${type[1]//_/ })
		trackname=""
		if [[ ${type[0]} == "b" ]]
		then
			case ${index[0]} in 
				1) 
					case ${index[1]} in 
						1) trackname="block_battle" ;;
						2) trackname="venice_battle"  ;;
						3) trackname="skate_battle" ;;
						4) trackname="casino_battle"  ;;
						5) trackname="sand_battle" ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac		
					;;
				2) 
					case ${index[1]} in 
						1) trackname="old_battle4_sfc" ;;
						2) trackname="old_battle3_gba"  ;;
						3) trackname="old_matenro_64" ;;
						4) trackname="old_CookieLand_gc"  ;;
						5) trackname="old_house_ds" ;;
						*) echo "ERROR: improperly formatted file $file "  ;;
					esac		
					;;
				*)
					echo "ERROR: improperly formatted file: $file"
					;;
			esac	
		elif [[ ${type[0]} == "r" ]]
		then
			case ${index[0]} in 
				1) 
					case ${index[1]} in 
						1) trackname="beginner_course" ;;
						2) trackname="farm_course"  ;;
						3) trackname="kinoko_course" ;;
						4) trackname="factory_course"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac		
					;;
				2) 
					case ${index[1]} in 
						1) trackname="castle_course"  ;;
						2) trackname="shopping_course" ;;
						3) trackname="boardcross_course"  ;;
						4) trackname="truck_course"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac					
					;;
				3) 
					case ${index[1]} in 
						1) trackname="senior_course" ;;
						2) trackname="water_course"  ;;
						3) trackname="treehouse_course" ;;
						4) trackname="volcano_course"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac	
					;;
				4) 
					case ${index[1]} in 
						1) trackname="desert_course" ;;
						2) trackname="ridgehighway_course"  ;;
						3) trackname="koopa_course" ;;
						4) trackname="rainbow_course"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac	
					;;
				5) 
					case ${index[1]} in 
						1) trackname="old_peach_gc" ;;
						2) trackname="old_falls_ds"  ;;
						3) trackname="old_obake_sfc" ;;
						4) trackname="old_mario_64"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac	
					;;
				6) 
					case ${index[1]} in 
						1) trackname="old_sherbet_64" ;;
						2) trackname="old_heyho_gba"  ;;
						3) trackname="old_town_ds" ;;
						4) trackname="old_waluigi_gc"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac	
					;;
				7) 
					case ${index[1]} in 
						1) trackname="old_desert_ds" ;;
						2) trackname="old_koopa_gba"  ;;
						3) trackname="old_donkey_64" ;;
						4) trackname="old_mario_gc"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac	
					;;
				8) 
					case ${index[1]} in 
						1) trackname="old_mario_sfc" ;;
						2) trackname="old_garden_ds"  ;;
						3) trackname="old_donkey_gc" ;;
						4) trackname="old_koopa_64"  ;;
						*) echo "ERROR: improperly formatted file $file " ;;
					esac	
					;;
				*)
					echo "ERROR: improperly formatted file: $file"
					;;
			esac			
		elif [[ ${type[0]} == "a" ]]
		then
			case ${index[0]} in 
				w) trackname="winningrun_demo" ;;
				d) trackname="draw_demo" ;;
				l) trackname="loser_demo" ;;
				e) trackname="ending_demo" ;;
				*)
					echo "ERROR: improperly formatted file: $file"
					;;
			esac	
		fi
		
		#Convert file to szs before adding, then remove extracted wu8 file.
		wszst compress --szs  $file -orq
		rm -f $file
		
		#If we have a multi-player-specific file that matches this single-player file, parse it too.
		if [[ -f "${file:0:(${#file}-6)}_m.wu8" ]]
		then
			wszst compress --szs "${file:0:(${#file}-6)}_m.wu8" -orq
			rm -f "${file:0:(${#file}-6)}_m.wu8"
		else
			ln -f  "${file:0:(${#file}-6)}_s.szs" "${file:0:(${#file}-6)}_m.szs"
		fi
		
		ln -f "${file:0:(${#file}-6)}_s.szs" "./files/Race/Course/${trackname}.szs" 
		ln -f "${file:0:(${#file}-6)}_m.szs"  "./files/Race/Course/${trackname}_d.szs"	
		#echo "${file:0:(${#file}-6)}_m.szs ->  ./files/Race/Course/${trackname}_d.szs"
	else
		echo "ERROR: improperly formatted file $file "
	fi
done


#---------------------------------------------------
# Patch the main.dol file with the lap and speed modifier.  This is required as some tracks change their lap and speed counts.
#Need to update WIT to do this, current WIT doesn't support it.
wstrt patch ./sys/main.dol --add-section "LapAndSpeedModifer.wch" -q

true

