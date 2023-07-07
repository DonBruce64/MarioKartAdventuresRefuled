#!/bin/bash

#----- setup

. ./bin/setup.sh

#----- user questions (developers: edit this part)

ASK_LANGUAGE=0	# ask for dialog language
ASK_MSGLANG=1	# ask for game message language
ASK_ISOMODE=1	# ask for image output format
ASK_SPLITISO=0	# ask for splitting images
ASK_SAVEGAME=1	# ask for alternate savegame

ENABLE_RIIV=6	# Mode of Riivolution support
		#   0: disabled
		#   1: MKWii: full patch mode, original image needed
		#   2: MKWii: replace file only distribution
		#   3: Any game: auto create a riivolution setup
		#   4: Any game: use ./riivolution.xml as control file
		#	and PATCH/files/... as data base. Both will be copied
		#	and renamemd to the 'riiv-sd-card' directory.
		#   5: Setup like mode #4 and call script "./riivolution.sh NAME"
		#	to create the riivolution pack.
		#   6: Setup like mode #1 except written specifically for 
		#	Mario Kart Adventures.
		
ask_config	# execute query

#----- more setup

config_options
. ./bin/options.sh "${CFG_OPT[@]}" "$@"
workdir=./patch-dir

#----- patching jobs (developers: edit this part)

. param.sh

title="$REV_TITLE"
[[ $REV_VERSION = "" ]] || title="$REV_TITLE $REV_VERSION"

if [ -f ./config.def ]
then 
	. ./config.def
fi


if [ "$ADVANCE_OPTIONS" == "1=yes" ]
then
	if [ "$DIFFERENT_INPUT" == "" ] && [ "$DIFFERENT_OUTPUT" == "" ]
	then 
		# using advanced settings but not using any build specific settings
		# job source_id dest_id "title" patch_file
		job RMCP01 "RMCP${REV_SUBID}" "$title" patch.tar || exit 1
		job RMCE01 "RMCE${REV_SUBID}" "$title" patch.tar || exit 1
		job RMCJ01 "RMCJ${REV_SUBID}" "$title" patch.tar || exit 1
	elif [ "$DIFFERENT_INPUT" == "" ] && [ ${#DIFFERENT_OUTPUT} == 2 ]
	then
		# using advanced settings to change output but still patching Mario Kart Source
		# job source_id dest_id "title" patch_file
		job RMCP01 "RMCP${DIFFERENT_OUTPUT}" "$title" patch.tar || exit 1
		job RMCE01 "RMCE${DIFFERENT_OUTPUT}" "$title" patch.tar || exit 1
		job RMCJ01 "RMCJ${DIFFERENT_OUTPUT}" "$title" patch.tar || exit 1
	elif [ ${#DIFFERENT_INPUT} == 5 ] && [ "$DIFFERENT_OUTPUT" == "" ]
	then
		# this shouldn't be possible without modifying the build scripts
		echo "Your settings do not make sense. have you been modding the build scripts?"
	else
		# using advanced settings and patching a different game
		# setup scripts force users to change the output if they try to patch a different game.
		job $DIFFERENT_INPUT "RMC${DIFFERENT_INPUT:3:1}${DIFFERENT_OUTPUT}" "$title" patch.tar || exit 1
	fi
else
	#nothing special by default 
	# job source_id dest_id "title" patch_file
	job RMCP01 "RMCP${REV_SUBID}" "$title" patch.tar || exit 1
	job RMCE01 "RMCE${REV_SUBID}" "$title" patch.tar || exit 1
	job RMCJ01 "RMCJ${REV_SUBID}" "$title" patch.tar || exit 1
fi


#----- termination status

printlog "$T_LOG_DONE_COUNT" "$done_count" "$mode"
exit 0
