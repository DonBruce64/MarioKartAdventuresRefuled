#!/bin/bash

#------------------------------------------------------------------------------
# patch-Characters.sh
#------------------------------------------------------------------------------
#
# scripts to patch the character files for Mario Kart Adventures.
# It patches in this order:
#
#	- Character .tpls ("picture" and "icon", icon is what is on the mini-map)
#	- Driver .brres Models (The model during character selection, both on the side an in the kart.), and then .png textures.  Note: any png textures in the driver folder will also be applied to the driver model on the karts.  This happens before the texture file parsing for karts, so if you want to specify different textures for the driver on each kart while still changing the main menu driver texture, you may.
#	- Award .brres Models (Used during award ceremonies.), and then .png textures.
#	- Select screen kart models.  (The kart model used on the character select screen.  Does not include driver, but does include drive animation logic.).  These are located in the menu_karts folder and can either be .szs for replacing all files, .brres for individual kart models, or .png for just the texture.  Race and battle allkarts are split by _race and _battle suffixes, whereas kart models are their brres name, and textures go in a folder with that model name.  Note: the parser will pull textures for karts from the race_karts folder if it exists, and there are no textures in the menu_karts folder, so you only need to include the textures in one location if you want them to be the same.
#	- Race kart models (The actual kart and driver seen during race.)  These are located in the race_karts folder and can either be szs for replacing all files, brres for individual kart models, or just .png textures.
#
# - Notes:
# - For all texture mods, the files are located in a folder that has the same name as the brres model.  For folders with a .szs file with multiple models, this will result in multiple texture folders for each model.
# - For all kart models, there exists files with a suffix of _2 and _4.  These models are lower-res ones that are used in 2-player and 4-player games respectively.  If they aren't included, they aren't modified, unless the option to use the single-player models in place of them is turned on.  Most of the time on emulator this is fine.  Console may not like it as much depending on model complexity and other models loaded at the time.  In all cases, textures apply to all models in a group, so you don't need to worry about suffixes if you're just doing a texture mod.
# - Note that miis, unlike all other racers, don't have a special model for two-player mode (have a model with a _2 suffix).
# - While you can change the kart miis ride in, you can't change their character model.  This is because the model and texture is pulled from the Miiverse.  Same goes for their tpl picture and icon.
# - Daisy, Peach, and Rosalina have biker-specific models to go with their vehicles.  Normally, the driver is part of the kart, both in the race and the selection screen.  However, for awards, they stand on their own.  To account for this, a _biker model or texture folder can be included in the award folder to allow for these special models/textures to be used.  If found, it is used.  If not, then the biker model will just use the normal model/texture mods to ensure consistency.
# - In this script, we replaced models and re-pack the szs file before we replace textures.  This is because WSZST will either create a zsz file with the modified brres file, or with our textures, depending on the paramters given.  However, it won't do both, because it doesn't know to use the textures in the model vs the ones provided.
#
#
# written by don_bruce
# based on patch-100.sh by Wiimm
#
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# setup
FAST=
[[ $WSZST_FAST = 1 || $1 == --fast ]] && FAST=--fast
if [ -f ./../config.def ]; then 
	. ./../config.def
fi

#lists of files containing .tpl images of characters.
TPL_PATCH_FILES="Award Channel Event Font Globe MenuMulti MenuOther MenuSingle Present Race Title"
TPL_FILE_LOCATIONS="award/timg/tt_  control/timg/tt_ button/timg/tt_ game_image/timg/tt_ game_image/timg/st_ result/timg/tt_"

#Names of characters in English and standard format.
CHARACTER_NAMES=(baby_daisy baby_luigi baby_mario baby_peach birdo daisy diddy_kong donkey_kong funky_kong dry_bowser dry_bones toadette toad bowser bowser_jr luigi mario koopa_troopa peach rosalina king_boo waluigi wario yoshi mii_a_female mii_a_male mii_b_female mii_b_male)

#Names of characters as expected by MKWii .tpl names.
#This MUST be in the same order as the CHARACTER_NAMES! 
TPL_NAMES=(baby_daisy baby_luigi baby_mario baby_peach catherine daisy diddy donky funky hone_koopa karon kinopico kinopio koopa koopa_jr luigi mario noko peach roseta teresa waluigi wario yoshi null null null null)

#Codes of characters as expected by MKWii .brres names.
#This MUST be in the same order as the CHARACTER_NAMES!
CHARACTER_CODES=(bds blg bmr bpc ca ds dd dk fk bk ka kk ko kp jr lg mr nk pc rs kt wl wr ys ma_mii_f ma_mii_m mb_mii_f mb_mii_m)

#Codes and suffixes of all karts.  Used for iterating over all karts for driver texture mods.
KART_CODES=(sa sb sc sd sdf se ma mb mc md mdf me la lb lc ld ldf le)
KART_SUFFIXES=(kart kart_red kart_blue bike bike_red bike_blue)


#------------------------------------------------
# Iterate over all character names to patch them.  We first check if files exist.  If so, we patch them.
echo ""
echo ""
echo "All right, let's get our new drivers set up!"
echo "First things first: we need to get their pictures taken."

#First patch text for the new character names.
for file in "./files/Scene/UI/*.szs"; do
	langFile="./characters/${CFG_MSGLANG}.txt"
	if [[ -f "$langFile" ]]; then
		wszst patch $file --patch-bmg "replace=$langFile" -q
	fi
done

#Now patch menu files.  We are assured to have these.
index=0
while [[ $index -lt ${#CHARACTER_NAMES[@]} ]]; do
	characterName="${CHARACTER_NAMES[$index]}"
	directory="./characters/$characterName"
	characterCode="${CHARACTER_CODES[$index]}"
	if [[ -d "$directory" ]]; then
		#Patch menu files.  This includes the icons for the character select screen, winning standings, and race track heads (32x32).
		for fileToPatch in $TPL_PATCH_FILES; do
			for tplLocation in $TPL_FILE_LOCATIONS; do
				#If we have a .tpl in the file to patch, and we have the .tpl for that file, patch it.
				#For .tpls, the _st files are for the course icons and have a 32x32 suffix.  All others have 64x64.
				tplName="$tplLocation${TPL_NAMES[$index]}"
				if [[ "$tplLocation" == *tt_ ]]; then
					tplName="${tplName}_64x64.tpl"
					source="$directory/picture.tpl"
				else
					tplName="${tplName}_32x32.tpl"
					source="$directory/icon.tpl"
				fi
				
				dest="./files/Scene/UI/${fileToPatch}.d/$tplName"
				if [[ -f $source && -f $dest ]]; then
					#echo "Replacing TPL $source $dest"
					ln -f "$source" "$dest"
				fi
			done
		done
	fi
	let index++
done


echo ""
echo ""
echo "Done!  Now to take their measurements."


#Patch driver and allkart brres model files.
wszst extract -oq "./files/Scene/Model/Driver.szs"
wszst extract -oq "./files/Demo/Award.szs"
index=0
while [[ $index -lt ${#CHARACTER_NAMES[@]} ]]; do
	characterName="${CHARACTER_NAMES[$index]}"
	directory="./characters/$characterName"
	characterCode="${CHARACTER_CODES[$index]}"
	if [[ -d "$directory" ]]; then	
		if [[ -d $directory/driver ]]; then
			#Daisy, Peach, and Rosalina all have _menu on their driver model names for some reason.  We need to account for this.
			source="$directory/driver/driver.brres"
			dest="./files/Scene/Model/Driver.d/$characterCode"
			if [[ "$characterCode" == "ds" || "$characterCode" == "pc" || "$characterCode" == "rs" ]]; then
				dest="$dest""_menu.brres"
			else
				dest="$dest"".brres"
			fi
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing DRIVER MODEL $source $dest"
				ln -f "$source" "$dest"
			fi
		fi
		
		if [[ -d $directory/award ]]; then
			source="$directory/award/award.brres"
			dest="./files/Demo/Award.d/$characterCode.brres"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing AWARD MODEL $source $dest"
				ln -f "$source" "$dest"
			fi
			
			#Daisy, Peach, and Rosalina all have biker models with 3 as a suffix.  Need to account for these for Award models.
			if [[ "$characterCode" == "ds" || "$characterCode" == "pc" || "$characterCode" == "rs" ]]; then
				source="$directory/award/award_biker.brres"
				dest="./files/Demo/Award.d/$characterCode""3.brres"
				if [[ -f $source && -f $dest ]]; then
					#echo "Replacing BIKER AWARD MODEL $source $dest"
					ln -f "$source" "$dest"
				else
					#Need to use standard award model since we don't have a biker-specific one.
					#If we don't, then the award will be the un-modified one.
					source="$directory/award/award.brres"
					if [[ -f $source && -f $dest ]]; then
						#echo "Replacing BIKER AWARD MODEL with default award."
						ln -f "$source" "$dest"
					fi
				fi
			fi
		fi
	fi
	let index++
done
wszst create -oq $FAST "./files/Scene/Model/Driver.d"
rm -rf "./files/Scene/Model/Driver.d"
wszst create -oq $FAST "./files/Demo/Award.d"
rm -rf "./files/Demo/Award.d"


echo ""
echo ""
echo "It appears some drivers are changing costumes.  Those sneaky devils..."


#Patch driver and allkart texture files.
wszst extract -aoq "./files/Scene/Model/Driver.szs"
wszst extract -aoq "./files/Demo/Award.szs"
index=0
while [[ $index -lt ${#CHARACTER_NAMES[@]} ]]; do
	characterName="${CHARACTER_NAMES[$index]}"
	directory="./characters/$characterName"
	characterCode="${CHARACTER_CODES[$index]}"
	if [[ -d "$directory" ]]; then	
		if [[ -d $directory/driver ]]; then
			if [[ -d $directory/driver/driver ]]; then
				for file in $directory/driver/driver/*.png; do
					source="$file"
					if [[ "$characterCode" == "ds" || "$characterCode" == "pc" || "$characterCode" == "rs" ]]; then
						dest="./files/Scene/Model/Driver.d/${characterCode}_menu.brres.d/Textures(NW4R)/${file##*/}"
					else
						dest="./files/Scene/Model/Driver.d/${characterCode}.brres.d/Textures(NW4R)/${file##*/}"
					fi
					if [[ -f $source && -f $dest ]]; then
						#echo "Replacing DRIVER TEXTURE $source $dest"
						ln -f "$source" "$dest"
					fi
				done
			fi
		fi
		
		if [[ -d $directory/award ]]; then
			if [[ -d $directory/award/award ]]; then
				for file in $directory/award/award/*.png; do
					source="$file"
					dest="./files/Demo/Award.d/${characterCode}.brres.d/Textures(NW4R)/${file##*/}"
					if [[ -f $dest ]]; then
						#echo "Replacing AWARD TEXTURE $source $dest"
						ln -f "$source" "$dest"
						
						#Replace biker here too.  We will re-replace this with tbe biker-specific texture later if we have it.
						if [[ "$characterCode" == "ds" || "$characterCode" == "pc" || "$characterCode" == "rs" ]]; then
							dest="./files/Demo/Award.d/${characterCode}3.brres.d/Textures(NW4R)/${file##*/}"
							ln -f "$source" "$dest"
						fi
					fi
				done
			fi
			
			#Check for a biker folder for biker textures.
			if [[ -d $directory/award/award_biker ]]; then
				for file in $directory/award/award_biker/*.png; do
					source="$file"
					dest="./files/Demo/Award.d/${characterCode}3.brres.d/Textures(NW4R)/${file##*/}"
					if [[ -f $source && -f $dest ]]; then
						#echo "Replacing BIKER AWARD TEXTURE $source $dest"
						ln -f "$source" "$dest"
					fi
				done
			fi
		fi
	fi
	let index++
done
wszst create -aoq $FAST "./files/Scene/Model/Driver.d"
rm -rf "./files/Scene/Model/Driver.d"
wszst create -aoq $FAST "./files/Demo/Award.d"
rm -rf "./files/Demo/Award.d"


echo ""
echo ""
echo "Great, all our drivers are ready!  Let's set them up with their new wheels."


#Patch allkart szs files, or individual models.
index=0
while [[ $index -lt ${#CHARACTER_NAMES[@]} ]]; do
	characterName="${CHARACTER_NAMES[$index]}"
	directory="./characters/$characterName"
	characterCode="${CHARACTER_CODES[$index]}"
	if [[ -d "$directory" ]]; then
		if [[ -d $directory/menu_karts ]]; then
			#Patch allkart files based on szs files present.
			#This happens for both race menu and battle menu.
			source="$directory/menu_karts/allkart_race.szs"
			dest="./files/Scene/Model/Kart/${characterCode}-allkart.szs"
			if [[ -f $source ]]; then
				#echo "Replacing RACE ALLKART $source $dest"
				ln -f "$source" "$dest"
			fi
			
			source="$directory/menu_karts/allkart_battle.szs"
			dest="./files/Scene/Model/Kart/${characterCode}-allkart_BT.szs"
			if [[ -f $source ]]; then
				#echo "Replacing BATTLE ALLKART $source $dest"
				ln -f "$source" "$dest"
			fi
			
			#Main szs files are replaced.  Extract files and check for models.
			#Only extract the files if models exist in the current directory.
			filesExtracted=0
			for file in $directory/menu_karts/*.brres; do
				if [[ -f $file ]]; then
					if [[ $filesExtracted -eq 0 ]]; then
						wszst extract -oq "./files/Scene/Model/Kart/${characterCode}-allkart.szs"
						wszst extract -oq "./files/Scene/Model/Kart/${characterCode}-allkart_BT.szs"
						filesExtracted=1
					fi
					
					source="$file"
					dest="./files/Scene/Model/Kart/${characterCode}-allkart.d/${file##*/}"
					if [[ -f $dest ]]; then
						#echo "Replacing ALLKART MODEL $source $dest"
						ln -f "$source" "$dest"
					fi
					dest="./files/Scene/Model/Kart/${characterCode}-allkart_BT.d/${file##*/}"
					if [[ -f $dest ]]; then
						#echo "Replacing ALLKART BATTLE MODEL $source $dest"
						ln -f "$source" "$dest"
					fi
				fi
			done
			
			if [[ $filesExtracted -eq 1 ]]; then
				wszst create -oq $FAST "./files/Scene/Model/Kart/${characterCode}-allkart.d"
				rm -rf "./files/Scene/Model/Kart/${characterCode}-allkart.d"
				wszst create -oq $FAST "./files/Scene/Model/Kart/${characterCode}-allkart_BT.d"
				rm -rf "./files/Scene/Model/Kart/${characterCode}-allkart_BT.d"
			fi
		fi
	fi
	let index++
done


echo ""
echo ""
echo "Checking to see if any karts need some paint touch-up..."


#Patch allkart textures.
index=0
while [[ $index -lt ${#CHARACTER_NAMES[@]} ]]; do
	characterName="${CHARACTER_NAMES[$index]}"
	directory="./characters/$characterName"
	characterCode="${CHARACTER_CODES[$index]}"
	if [[ -d "$directory" ]]; then
		#Add race folder, then this folder.
		#This allows for a single texture folder source on the race side, as allkart models are (usually) the same texture.
		directoriesToCheck=()
		if [[ -d $directory/race_karts ]]; then
			for subDirectory in $directory/race_karts/*; do
				if [[ -d $subDirectory ]]; then
					directoriesToCheck[${#directoriesToCheck[@]}]=$subDirectory
				fi
			done
		fi
		if [[ -d $directory/menu_karts ]]; then
			for subDirectory in $directory/menu_karts/*; do
				if [[ -d $subDirectory ]]; then
					directoriesToCheck[${#directoriesToCheck[@]}]=$subDirectory
				fi
			done
		fi
		
		filesExtracted=0
		directoryIndex=0
		while [[ $directoryIndex -lt ${#directoriesToCheck[@]} ]]; do
			subDirectory="${directoriesToCheck[$directoryIndex]}"
			brresName="${subDirectory##*/}"
			for file in $subDirectory/*.png; do
				if [[ -f $file ]]; then
					if [[ $filesExtracted -eq 0 ]]; then
						wszst extract -aoq "./files/Scene/Model/Kart/${characterCode}-allkart.szs"
						wszst extract -aoq "./files/Scene/Model/Kart/${characterCode}-allkart_BT.szs"
						filesExtracted=1
					fi
					
					source="$file"
					dest="./files/Scene/Model/Kart/${characterCode}-allkart.d/${brresName}.brres.d/Textures(NW4R)/${file##*/}"
					if [[ -f $dest ]]; then
						#echo "Replacing ALLKART TEXTURE $source $dest"
						ln -f "$source" "$dest"
					fi
					dest="./files/Scene/Model/Kart/${characterCode}-allkart_BT.d/${brresName}.brres.d/Textures(NW4R)/${file##*/}"
					if [[ -f $source && -f $dest ]]; then
						#echo "Replacing ALLKART BATTLE TEXTURE $source $dest"
						ln -f "$source" "$dest"
					fi
				fi
			done
			let directoryIndex++
		done
		
		if [[ $filesExtracted -eq 1 ]]; then
			wszst create -aoq $FAST "./files/Scene/Model/Kart/${characterCode}-allkart.d"
			wszst create -aoq $FAST "./files/Scene/Model/Kart/${characterCode}-allkart_BT.d"
		fi
	fi
	let index++
done

		
echo ""
echo ""
echo "Fine-tuning the karts for races..."


#Patch kart models.
index=0
while [[ $index -lt ${#CHARACTER_NAMES[@]} ]]; do
	characterName="${CHARACTER_NAMES[$index]}"
	directory="./characters/$characterName"
	characterCode="${CHARACTER_CODES[$index]}"
	if [[ -d "$directory" ]]; then		
		if [[ -d $directory/race_karts ]]; then
			#Patch the race karts.
			#First check for new .szs files.  These need to be patched first in case we mod models.
			szsFilesModified=()
			for file in $directory/race_karts/*.szs; do
				source=$file
				dest="${file##*/}"
				dest="${dest%.*}"
				if [[ $dest == *"_2" ]]; then
					dest="./files/Race/Kart/${dest%_2}-${characterCode}_2.szs"
				else
					if [[ $dest == *"_4" ]]; then
						dest="./files/Race/Kart/${dest%_4}-${characterCode}_4.szs"
					else
						dest="./files/Race/Kart/${dest%}-${characterCode}.szs"
					fi
				fi
				
				if [[ -f $source && -f $dest ]]; then
					szsFilesModified[${#szsFilesModified[@]}]=$dest
					#echo "Replacing KART $source $dest"
					ln -f "$source" "$dest"
				fi
			done
			
			
			#Now check for brres models.
			filesExtracted=()
			for file in $directory/race_karts/*.brres; do
				source="$file"
				if [[ -f $source ]]; then
					dest="${file##*/}"
					dest="${dest%.*}"
					if [[ $dest == *"_2" ]]; then
						dest="${dest%_2}-${characterCode}_2"
					else
						if [[ $dest == *"_4" ]]; then
							dest="${dest%_4}-${characterCode}_4"
						else
							dest="${dest%}-${characterCode}"
						fi
					fi
					szsFile="./files/Race/Kart/${dest}.szs"
					extractionDir="./files/Race/Kart/${dest}.d"
					if [[ ! "${filesExtracted[*]}" =~ "$extractionDir" ]]; then
							wszst extract -oq "$szsFile"
							filesExtracted[${#filesExtracted[@]}]="$extractionDir"
							szsFilesModified[${#szsFilesModified[@]}]="$szsFile"
					fi
					dest="${extractionDir}/kart_model.brres"
					if [[ -f $dest ]]; then
						#echo "Replacing KART MODEL $source $dest"
						ln -f "$source" "$dest"
					fi
				fi
			done
			
			#Now that we are done modifying the files, compile them.
			for file in ${filesExtracted[@]}; do
				wszst create -oq $FAST "$file"
				rm -rf "$file"
			done
			
			if [[ $MULTI_CHAR_OVERWRITE == "1=yes" ]]; then
				# Here is a sloppy trick to make the game feel a bit more complete. However, be warned that this makes the game less stable, and does not work in all cases. This allows us to load custom character models even on the _2 and _4 player models, howeverwe are copying the more complex single player models over the multiplayer ones, so it leads to more crashes and sometimes the models fail to load at all. We provide the option to toggle this on and off in Advanced Settings since we recognize its not a clean hack.  Note that this hack does not run if the multi-player models are present.
				fileIndex=0
				while [[ $fileIndex -lt ${#szsFilesModified[@]} ]]; do
					fileModified="${szsFilesModified[$fileIndex]}"
					if [[ $fileModified != *_2.* && $fileModified != *_4.* ]]; then
						#Standard file modified.  Check if we modified the non-standard ones.
						#If not, apply the mods to them.
						if [[ ! "${szsFilesModified[*]}" =~ "${fileModified}_2" ]]; then
							#echo "Using kart $fileModified as ${fileModified}_2 HACK!"
							ln -f $fileModified "${fileModified}_2"
						fi
						if [[ ! "${szsFilesModified[*]}" =~ "${fileModified}_4" ]]; then
							#echo "Using kart $fileModified as ${fileModified}_4 HACK!"
							ln -f $fileModified "${fileModified}_4"
						fi
					fi
					let fileIndex++
				done
			fi
		fi
	fi
	let index++
done

		
echo ""
echo ""
echo "Doing some finishing touches on the karts..."


#Patch kart textures.
index=0
while [[ $index -lt ${#CHARACTER_NAMES[@]} ]]; do
	characterName="${CHARACTER_NAMES[$index]}"
	directory="./characters/$characterName"
	characterCode="${CHARACTER_CODES[$index]}"
	if [[ -d "$directory" ]]; then
		filesExtracted=()
		#Check for driver textures.  These go into all karts.
		if [[ -d $directory/driver/driver ]]; then
			for code in "${KART_CODES[@]}"; do
				for suffix in "${KART_SUFFIXES[@]}" ; do
					kartName="${code}_${suffix}-${characterCode}"
					kartModelLevels=("$kartName" "${kartName}_2" "${kartName}_4")
					for modelLevel in "${kartModelLevels[@]}" ; do
						szsFile="./files/Race/Kart/${modelLevel}.szs"
						if [[ -f $szsFile ]]; then
							extractionDir="./files/Race/Kart/${modelLevel}.d"
							if [[ ! "${filesExtracted[*]}" =~ "$extractionDir" ]]; then
									wszst extract -aoq "$szsFile"
									filesExtracted[${#filesExtracted[@]}]="$extractionDir"
							fi
							for file in $directory/driver/driver/*.png; do
								source="$file"
								if [[ -f $source ]]; then
									dest="${extractionDir}/driver_model.brres.d/Textures(NW4R)/${file##*/}"
								fi
								if [[ -f $dest ]]; then
									#echo "Replacing GLOBAL KART DRIVER TEXTURE $source $dest"
									ln -f "$source" "$dest"
								fi
							done
						fi
					done
				done
			done
		fi
	
		if [[ -d $directory/race_karts ]]; then
			#Finally, check for kart textures.  These could be for the kart, or the driver specifically to this kart, so we check both.
			for subDirectory in $directory/race_karts/*; do
				if [[ -d $subDirectory ]]; then
					kartName="${subDirectory##*/}-${characterCode}"
					for file in $subDirectory/*.png; do
						source="$file"
						if [[ -f $source ]]; then
							kartModelLevels=("$kartName" "${kartName}_2" "${kartName}_4")
							for modelLevel in "${kartModelLevels[@]}" ; do
								szsFile="./files/Race/Kart/${modelLevel}.szs"
								if [[ -f $szsFile ]]; then
									extractionDir="./files/Race/Kart/${modelLevel}.d"
									if [[ ! "${filesExtracted[*]}" =~ "$extractionDir" ]]; then
										wszst extract -aoq "$szsFile"
										filesExtracted[${#filesExtracted[@]}]="$extractionDir"
									fi
									
									dest="${extractionDir}/kart_model.brres.d/Textures(NW4R)/${file##*/}"
									if [[ -f $dest ]]; then
										#echo "Replacing KART TEXTURE $source $dest"
										ln -f "$source" "$dest"
									fi
									dest="${extractionDir}/driver_model.brres.d/Textures(NW4R)/${file##*/}"
									if [[ -f $dest ]]; then
										#echo "Replacing KART DRIVER TEXTURE $source $dest"
										ln -f "$source" "$dest"
									fi
								fi
							done
						fi
					done
				fi
			done
		fi
					
		#Now that we are done modifying the files, compile them.
		for file in ${filesExtracted[@]}; do
			wszst create -aoq $FAST "$file"
			rm -rf "$file"
		done
	fi
	let index++
done

#Remove the character folder with the leftover files.
rm -rf /characters

true
