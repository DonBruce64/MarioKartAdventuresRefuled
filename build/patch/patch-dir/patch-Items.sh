#!/bin/bash

#------------------------------------------------------------------------------
# patch-Items.sh
#------------------------------------------------------------------------------
#
# scripts to patch the item files for Mario Kart Advnetures
# It patches in this order:
#
#	- Item .tpls
#	- Item models
#
# written by don_bruce
# based on patch-100.sh by Wiimm
#
#------------------------------------------------------------------------------


#---------------------------------------------------
# setup
FAST=
[[ $WSZST_FAST = 1 || $1 == --fast ]] && FAST=--fast
if [ -f ./../config.def ]; then 
	. ./../config.def
fi

#paths
TPL_PATCH_FILES="Award Channel Event Font Globe MenuMulti MenuOther MenuSingle Present Race Title"

#Names of items in English and standard format.
#Note that entries may be here mulitiple times if we have multiple models or textures inside the folder to parse.
ITEM_NAMES=(banana banana_triple blooper bob_omb bob_omb_explosion bullet_bill bullet_bill_kart fake_item_box golden_mushroom green_shell green_shell_triple item_box lightning mega_mushroom mushroom mushroom_double mushroom_triple pow_block pow_block_status red_shell red_shell red_shell_triple blue_shell star thunder_cloud item_border)

#Names of items as expected by MKWii .tpl names.
#This MUST be in the same order as the ITEM_NAMES! 
TPL_NAMES=(tt_item_banana item_banana_3 fm_item_gesso tt_item_bomb_hei null tt_item_killer null tt_item_dummybox tt_item_GoldenKinoko tt_item_kame_green tt_item_kame_green_3 item_box tt_item_thunder fm_item_kinoko_l tt_item_kinoko tt_item_kinoko_2 tt_item_kinoko_3 fm_item_pow null tt_item_kame_red tt_item_honeBall tt_item_kame_red_3 tt_item_kame_wing tt_item_star fm_item_pikakumo tt_item_box_glass_type_02)

#Names of items as expected by MKWii .brres names.
#This MUST be in the same order as the ITEM_NAMES! 
BRRES_NAMES=(banana null gesso bomb bombCore item_killer kart_killer itemBoxNiseRtpa kinoko_p koura_green null item_box thunder big_kinoko kinoko null null pow_bloc pow_bloc_plane koura_red null null togezo_koura star kumo null)



#----------------------------------------
# Patch icons on the roulette via the tpl files, and patch in-game models via the brres files.  Finally, patch in the animation files.


echo ""
echo ""
echo "Adding your items! This is a quick one!"


index=0
while [[ $index -lt ${#ITEM_NAMES[@]} ]]; do
	source="./items/${ITEM_NAMES[$index]}.tpl"
	tplPath="game_image/timg/${TPL_NAMES[$index]}.tpl"
	for fileToPatch in $TPL_PATCH_FILES; do
		dest="./files/Scene/UI/${fileToPatch}.d/$tplPath"
		if [[ -f $source && -f $dest ]]; then
			#echo "Replacing TPL $source $dest"
			ln -f "$source" "$dest"
		fi
	done
	let index++
done

#Need to extract the common file to patch it.  This is only used for items, and won't be already extracted at this point.
wszst extract -oq "./files/Race/Common.szs"
index=0
while [[ $index -lt ${#ITEM_NAMES[@]} ]]; do
	source="./items/${ITEM_NAMES[$index]}.brres"
	dest="./files/Race/Common.d/${BRRES_NAMES[$index]}.brres"
	if [[ -f $source && -f $dest ]]; then
		#echo "Replacing BRRES $source $dest"
		ln -f "$source" "$dest"
	fi
	let index++
done

source="./items/RKRace.breff"
dest="./files/Race/Common.d/Effect/RKRace.breff"
if [[ -f $source && -f $dest ]]; then
	#echo "Replacing BRREF $source $dest"
	ln -f "$source" "$dest"
fi
source="./items/RKRace.breft"
dest="./files/Race/Common.d/Effect/RKRace.breft"
if [[ -f $source && -f $dest ]]; then
	#echo "Replacing BRREFT $source $dest"
	ln -f "$source" "$dest"
fi

wszst create -oq "./files/Race/Common.d"
rm -rf "./files/Race/Common.d"


#Remove the item folder with the leftover files.
rm -rf ./items

true

