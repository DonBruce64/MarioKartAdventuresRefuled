#!/bin/bash

#------------------------------------------------------------------------------
# patch-UI.sh
#------------------------------------------------------------------------------
#
# scripts to patch the UI files for Mario Kart Advnetures.  This patches the following UI things in the following order:
#
#	- Boot screens
# - Cup icons and tpl videos
# - General menu items
#	- Position icons
#	- Title backgrounds
#
# Each one of these are in their own folders for clarity.  Names have been converted to "sensible" versions where appropriate.  However, the "menu" files are in their stock name format as they are very specific where they go, and it is assumed that only advanced modders will be changing the style of the menu and thus will be able to handle the odd naming format that MKWII uses.  Therefore, we do not translate these names in this script.
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
srcid=$1

#declare arrays
TPL_PATCH_FILES="Award Channel Event Font Globe MenuMulti MenuOther MenuSingle Present Race Title"
CUP_ICON_NAMES=(tt_cup_icon_kinoko_00 tt_cup_icon_flower_00 tt_cup_icon_star_00 tt_cup_icon_oukan_00 tt_cup_icon_koura_00 tt_cup_icon_banana_00 tt_cup_icon_konoha_00 tt_cup_icon_thunder_00)
CUP_THP_NAMES=(kinoko flower star special koura banana konoha thunder)
MENU_FILES='	
	bg/timg/tt_obi_bottom_curve_000.tpl
	bg/timg/tt_obi_bottom_left_000.tpl
	bg/timg/tt_obi_bottom_right_000.tpl
	bg/timg/tt_obi_check_000.tpl
	bg/timg/tt_obi_top_curve_000.tpl
	bg/timg/tt_obi_bottom_curve_000.tpl
	bg/timg/tt_obi_top_left_000.tpl
	bg/timg/tt_obi_top_right_000.tpl
	bg/timg/tt_go_obi_top_waku.tpl
	
	button/timg/tt_classic_icon_sphere_128.tpl	
	button/timg/tt_wii_icon_128.tpl
	button/timg/tt_coin_type1_128.tpl

	control/timg/tt_classic_icon_sphere_128.tpl
	control/timg/tt_wii_icon_128.tpl
	control/timg/tt_coin_type1_128.tpl
		
	indicator_font.brfnt
	kart_kanji_font.brfnt
	mario_font_number_blue.brfnt
	mario_font_number_red.brfnt
	tt_kart_extension_font.brfnt
	tt_kart_font_rodan_ntlg_pro_b.brfnt
'

echo ""
echo ""
echo "Hmmm... what to do next..."

#------------------------------------------------------------------------------
#First patch the text for the language changes.
#This must be done before extracting the files, otherwise we can't do the changes.
for file in "./files/Scene/UI/*.szs"; do
	langFile="./ui/${CFG_MSGLANG}.txt"
	if [[ -f "$langFile" ]]; then
		wszst patch $file --patch-bmg "replace=$langFile" -q
	fi
done

# Extract the region-specific UI files.
# Not sure why, but wszst doesn't follow its own rules when extracting things here.
# It extracts he normal files to the proper dir, but the boot ones get a .szs added to their folders, despite this not being default.  So we specifiy here.
normalFilesExtracted=()
bootFilesExtracted=()
if [[ "$srcid" == *"RMCE01"* ]]; then
	for file in Channel_U Race_U Race_Q Race_M Title_U Title_Q Title_M; do
		wszst extract -oq "./files/Scene/UI/${file}.szs"
		normalFilesExtracted[${#normalFilesExtracted[@]}]="./files/Scene/UI/${file}.d"
	done
	for file in English Spanish_US French; do
		wszst extract -aoq "./files/Boot/Strap/us/${file}.szs" -d "./files/Boot/Strap/us/${file}.d"
		bootFilesExtracted[${#bootFilesExtracted[@]}]="./files/Boot/Strap/us/${file}.d"
	done
fi

if [[ "$srcid" == *"RMCP01"* ]]; then
	for file in Race_E Race_F Race_G Race_I Race_S Title_E Title_F Title_G Title_I Title_S; do
		wszst extract -oq "./files/Scene/UI/${file}.szs"
		normalFilesExtracted[${#normalFilesExtracted[@]}]="./files/Scene/UI/${file}.d"
	done
	for file in Dutch English French German Italian Spanish_EU; do
		wszst extract -aoq "./files/Boot/Strap/eu/${file}.szs" -d "./files/Boot/Strap/eu/${file}.d"
		bootFilesExtracted[${#bootFilesExtracted[@]}]="./files/Boot/Strap/eu/${file}.d"
	done
fi

if [[ "$srcid" == *"RMCJ01"* ]]; then
	for file in Race_J Title_J; do
		wszst extract -oq "./files/Scene/UI/${file}.szs"
		normalFilesExtracted[${#normalFilesExtracted[@]}]="./files/Scene/UI/${file}.d"
	done
	for file in jp; do
		wszst extract -aoq "./files/Boot/Strap/jp/${file}.szs" -d "./files/Boot/Strap/jp/${file}.d"
		bootFilesExtracted[${#bootFilesExtracted[@]}]="./files/Boot/Strap/jp/${file}.d"
	done
fi

#Create array with all files to patch, as we need to include both normal, and extracted files.
allFilesToPatch=()
for file in $TPL_PATCH_FILES; do
	allFilesToPatch[${#allFilesToPatch[@]}]="./files/Scene/UI/${file}.d"
done
for file in ${normalFilesExtracted[@]}; do
	allFilesToPatch[${#allFilesToPatch[@]}]=$file
done

#------------------------------------------------------------------------------
# Patch all files


echo ""
echo ""
echo "I know! I'll start adding your fancy new UI..." 


#Patch the boot screens and get them out of the way.
for file in ${bootFilesExtracted[@]}; do
	for bootTexture in strapA_16_9_832x456 strapA_608x456 strapB_16_9_832x456 strapB_608x456; do
		source="./ui/boot/${bootTexture}.png"
		dest="${file}/Textures(NW4R)/${bootTexture}.png"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing BOOT TEXTURE $source $dest"
			ln -f "$source" "$dest"
		fi
	done
	wszst create -aoq $FAST "$file"
	rm -rf "$file"
done


#Patch cup icons and previews.
if [[ -d "./ui/cups" ]]; then
	index=1
	while [[ $index -le 8 ]]; do
		#First do cup icons.
		source="./ui/cups/${index}.tpl"
		for fileToPatch in ${allFilesToPatch[@]}; do
			for folderToPatch in button control demo; do
				dest="${fileToPatch}/${folderToPatch}/timg/${CUP_ICON_NAMES[$(($index-1))]}.tpl"
				if [[ -f $source && -f $dest ]]; then
					#echo "Replacing CUP TPL $source $dest"
					ln -f "$source" "$dest"
				fi
			done
		done
		
		#Now do previews.
		#Only patch the cup thps if the user is also patching the tracks.
		#If we don't have a custom tpl for the cup, make it null so it doesn't show the wrong tracks.
		if [[ $PARTIAL_PATCH_TRACKS == "1=yes"  && $ADVANCE_OPTIONS == "1=yes" ]] || [[ $ADVANCE_OPTIONS == "0=no" ]]; then
			source="./ui/cups/${index}.thp"
			if [[ ! -f $source ]]; then
				source="./ui/menu/null.thp"
			fi
			dest="./files/thp/course/${CUP_THP_NAMES[$(($index-1))]}.thp"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing CUP THP $source $dest"
				ln -f "$source" "$dest"
			fi
		fi
		let index++
	done
	
	#As a final thing, patch the cup selection preview.
	if [[ $PARTIAL_PATCH_TRACKS == "1=yes"  && $ADVANCE_OPTIONS == "1=yes" ]] || [[ $ADVANCE_OPTIONS == "0=no" ]]; then
		source="./ui/cups/select.thp"
		dest="./files/thp/course/cup_select.thp"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing CUP SELECT THP $source $dest"
			ln -f "$source" "$dest"
		fi
	fi
fi


#Patch menu files.
#These don't get "translated" and just use their raw names to their path.
if [[ -d "./ui/menu" ]]; then
	#Battle THPs
	for file in battle_cup_select battle_retro battle_wii battle_select; do
		source="./ui/menu/${file}.thp"
		#All battle files, except the battle_select file, show the courses.  If we are modifying the courses, we need to ensure custom files exist.  If they don't we use the null thp to make the video not play the wrong courses.
		if [[ ! $file == "battle_select" ]]; then
			if [[ $PARTIAL_PATCH_TRACKS == "1=yes"  && $ADVANCE_OPTIONS == "1=yes" ]] || [[ $ADVANCE_OPTIONS == "0=no" ]]; then
				if [[ ! -f $source ]]; then
					source="./ui/menu/null.thp"
				fi
			fi
		fi
		
		dest="./files/thp/battle/${file}.thp"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing BATTLE THP $source $dest"
			ln -f "$source" "$dest"
		fi
	done
	
	#Button THPs
	for file in class_top drift_select indiv_team multi_top single_top; do
		source="./ui/menu/${file}.thp"
		dest="./files/thp/button/${file}.thp"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing BUTTON THP $source $dest"
			ln -f "$source" "$dest"
		fi
	done
	
	#Ending THPs
	for file in ending_normal ending_normal_50 ending_true ending_true_50; do
		source="./ui/menu/${file}.thp"
		dest="./files/thp/ending/${file}.thp"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing ENDING THP $source $dest"
			ln -f "$source" "$dest"
		fi
	done
	
	#Title THPs
	for file in title title_50 title_SD title_SD_50 top_menu; do
		source="./ui/menu/${file}.thp"
		dest="./files/thp/title/${file}.thp"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing TITLE THP $source $dest"
			ln -f "$source" "$dest"
		fi
	done
	
	#Common files.
	for file in $MENU_FILES; do
		source="./ui/menu/${file##*/}"
		if [[ -f $source ]]; then
			for fileToPatch in ${allFilesToPatch[@]}; do
				dest="${fileToPatch}/${file}"
				if [[ -f $source && -f $dest ]]; then
					#echo "Replacing GENERIC FILE $source $dest"
					ln -f "$source" "$dest"
				fi
			done
		fi
	done
fi


#Patch position markers.
if [[ -d "./ui/positions" ]]; then
	index=1
	while [[ $index -le 12 ]]; do
		for fileToPatch in ${allFilesToPatch[@]}; do
			if [[ $index -lt 10 ]]; then
				tplName="0${index}.tpl"
			else
				tplName="${index}.tpl"
			fi
			source="./ui/positions/${index}.tpl"
			dest="${fileToPatch}/game_image/timg/tt_multi_position_no_st_64x64_${tplName}"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing INDICATOR TPL $source $dest"
				ln -f "$source" "$dest"
			fi
			dest="${fileToPatch}/game_image/timg/tt_position_no_st_64x64_${tplName}"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing INDICATOR TPL $source $dest"
				ln -f "$source" "$dest"
			fi
		done
		let index++
	done
fi


#Patch title files.
if [[ -d "./ui/title" ]]; then
	for file in ${allFilesToPatch[@]}; do
		#First replace ESRB file.
		source="./ui/title/esrb.tpl"
		dest="${file}/esrb/timg/esrb_EngUS.tpl"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing ESRB TEXTURE $source $dest"
			ln -f "$source" "$dest"
		fi
		
		#Now replace spash screens.  We use a common screen for all variants here.
		#First to be replaced is the standard screen.
		for tplName in tt_title_screen_mario tt_title_screen_mario0 tt_title_screen_mario2 tt_title_screen_luigi tt_title_screen_peachi tt_title_screen_koopa; do
			source="./ui/title/main.tpl"
			dest="${file}/title/timg/${tplName}.tpl"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing MAIN TITLE TEXTURE $source $dest"
				ln -f "$source" "$dest"
			fi
		done
		
		#Replace blurred title variant.
		for tplName in tt_title_bokeboke tt_title_screen_mario_bokeboke tt_title_screen_mario0_bokeboke tt_title_screen_mario2_bokeboke tt_title_screen_luigi_bokeboke tt_title_screen_peachi_bokeboke tt_title_screen_koopa_bokeboke; do
			source="./ui/title/main_blurred.tpl"
			dest="${file}/title/timg/${tplName}.tpl"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing BLURRED TITLE TEXTURE $source $dest"
				ln -f "$source" "$dest"
			fi
		done
		
		#Replace banner.
		for tplName in tt_title_screen_title_rogo_r_only tt_title_screen_title_rogo_tm_only tt_title_screen_title_rogo_japanese; do
			source="./ui/title/banner.tpl"
			dest="${file}/title/timg/${tplName}.tpl"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing MAIN BANNER TEXTURE $source $dest"
				ln -f "$source" "$dest"
			fi
		done
		
		#Replace blurred banner.
		for tplName in tt_title_screen_title_rogo_bokeboke tt_title_screen_title_rogo_japanese_boke; do
			source="./ui/title/banner_blurred.tpl"
			dest="${file}/title/timg/${tplName}.tpl"
			if [[ -f $source && -f $dest ]]; then
				#echo "Replacing BLURRED BANNER TEXTURE $source $dest"
				ln -f "$source" "$dest"
			fi
		done
	done
fi

#Compile files extracted here and exit.
for file in ${normalFilesExtracted[@]}; do
	wszst create -oq $FAST "$file"
	rm -rf "$file"
done


#Remove the ui folder with the leftover files.
rm -rf ./ui


true

