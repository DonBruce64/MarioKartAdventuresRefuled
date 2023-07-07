#!/bin/bash
# (c) wiimm (at) wiimm.de -- 2014-01-03

#
#------------------------------------------------------------------------------
# setup

printf "\nSetup...\n"

script="${0##*/}"
workdir=./patch-dir
srclist="*.iso *.ciso *.wdf *.wia *.wbfs"

CONFIG="./config.def"
CFG_LANGUAGE="$LC_MESSAGE"
[[ $CFG_LANGUAGE = "" ]] && CFG_LANGUAGE="${LC_CTYPE%%_*}"
[[ $CFG_LANGUAGE = "" ]] && CFG_LANGUAGE=en

CFG_MSGLANG="$CFG_LANGUAGE"
MSGLANG_LIST="english german spanish-EUR spanish-NA"
OUTPUT_LIST="A9"
GAME_LIST="RMCE23"

ISOMODE_LIST="iso ciso wdf wbfs wia"

[[ $VERBOSE = 1 ]] || VERBOSE=0
[[ $AUTORUN = 1 ]] || AUTORUN=0
for p in "$@"
do
    [[ $p == -v || $p = --verbose ]] && VERBOSE=1
    [[ $p == -a || $p = --autorun ]] && AUTORUN=1
    [[ $p == -h || $p = --help ]] && AUTORUN=1
done

#
#------------------------------------------------------------------------------
# system and bin path

#--- BASEDIR

if [[ ${BASH_SOURCE:0:1} == / ]]
then
    BASEDIR="${BASH_SOURCE%/*}"
    [[ $BASEDIR = "" ]] && BASEDIR=/
else
    BASEDIR="$PWD/$BASH_SOURCE"
    BASEDIR="${BASEDIR%/*}"
fi
#echo "0=$0"
#echo "BASH_ARGV=${BASH_ARGV[*]}"
((VERBOSE)) && echo "BASH_SOURCE = ${BASH_SOURCE[*]}"
((VERBOSE)) && echo "BASEDIR     = $BASEDIR"

#--- predefine

ORIGPATH="$PATH"
BINDIR="$BASEDIR/cygwin"
((VERBOSE)) && echo "BINDIR      = $BINDIR"
if [[ -d $BINDIR ]]
then
    chmod u+x "$BINDIR"/* 2>/dev/null
    export PATH="$BINDIR:$ORIGPATH"
fi

#--- find system

SYSTEM="$( uname -s | tr '[A-Z]' '[a-z]' )"
MACHINE="$( uname -m | tr '[A-Z]' '[a-z]' )"
((VERBOSE)) && echo "SYSTEM      = $SYSTEM"
((VERBOSE)) && echo "MACHINE     = $MACHINE"

case "$SYSTEM-$MACHINE" in
    darwin-*)		HOST=mac ;;
    linux-x86_64)	HOST=linux64 ;;
    linux-*)		HOST=linux32 ;;
    cygwin*)		HOST=cygwin ;;
    *)			HOST=- ;;
esac

#--- setup BINDIR and PATH

BINDIR="$BASEDIR/$HOST"
((VERBOSE)) && echo "BINDIR      = $BINDIR"
if [[ -d $BINDIR ]]
then
    chmod u+x "$BINDIR"/* 2>/dev/null
    export PATH="$BINDIR:$ORIGPATH"
fi

((VERBOSE)) && echo "AUTORUN     = $AUTORUN"

#
#------------------------------------------------------------------------------
# check tools

needed_tools="awk bash cat chmod cp cut diff find ln mkdir mv rm
	sed sort tar touch tr uname uniq unzip wc which
	wit wszst wbmgt wimgt wstrt"

err=

for tool in $needed_tools
do
    if ! which $tool >/dev/null 2>&1
    then
	err="$err $tool"
    fi
done

if [[ $err != "" ]]
then
    echo "*** Missing tools:$err" >&2
    exit 1
fi

#
#------------------------------------------------------------------------------
# function printlog()

function printlog()
{
    ((quiet)) && return 0
    local msg="$(printf "$@")"
    local sep="#######################################"
    sep="#$sep$sep"
    local len len1 len2
    let len=${#msg}
    let len1=(57-len)/2
    let len2=57-len1
    printf "\n%s\n########## %*s%-*s ##########\n%s\n\n" \
	"$sep" $len1 "" $len2 "$msg" "$sep"
}

#
#------------------------------------------------------------------------------
# configuration

for d in "$BASEDIR" "$BASEDIR/.." .
do
    LANG_SRC="$d/locale"
    if [[ -d $LANG_SRC ]]
    then
	LANG_LIST="$( cd "$LANG_SRC"; echo *.sh | sed 's/.sh//g' )"
	[[ $LANG_LIST == "*" ]] || break
    fi
done
((VERBOSE)) && echo "LANG_SRC    = $LANG_SRC"
((VERBOSE)) && echo "LANG_LIST   = $LANG_LIST"

if [[ -s $CONFIG ]]
then
    eval $(sed 's/^/CFG_/' "$CONFIG")
fi

function save_config()
{
    cat <<- --EOT-- >"$CONFIG"
	LANGUAGE="$CFG_LANGUAGE"
	MSGLANG="$CFG_MSGLANG"
	ISOMODE="$CFG_ISOMODE"
	SPLITISO="$CFG_SPLITISO"
	PRIV_SAVEGAME="$CFG_PRIV_SAVEGAME"
	ADVANCE_OPTIONS="$CFG_ADVANCE_OPTIONS"
	DIFFERENT_INPUT="$CFG_DIFFERENT_INPUT"
	DIFFERENT_OUTPUT="$CFG_DIFFERENT_OUTPUT"
	PARTIAL_PATCH_MUSIC="$CFG_PARTIAL_PATCH_MUSIC"
	MUSIC_REORDER="$CFG_MUSIC_REORDER"
	PARTIAL_PATCH_ITEMS="$CFG_PARTIAL_PATCH_ITEMS"
	PARTIAL_PATCH_CHARACTERS="$CFG_PARTIAL_PATCH_CHARACTERS"
	MULTI_CHAR_OVERWRITE="$CFG_MULTI_CHAR_OVERWRITE"
	PARTIAL_PATCH_TRACKS="$CFG_PARTIAL_PATCH_TRACKS"
	PARTIAL_PATCH_UI="$CFG_PARTIAL_PATCH_UI"
	--EOT--
}

function print_config()
{
    local format=" %-30s : %s\n"
    printf "\n---------------------------------------\n"
    printf "$format" "$T_LANGUAGE" "$CFG_LANGUAGE"
    printf "$format" "$T_MSGLANG" "$CFG_MSGLANG"
    printf "$format" "$T_ISOMODE" "$CFG_ISOMODE"
    printf "$format" "$T_SPLITISO" "$CFG_SPLITISO"
	printf "$format" "$T_ADVANCE_OPTIONS" "$CFG_ADVANCE_OPTIONS"
    printf "$format" "$T_PRIV_SAVEGAME" "${CFG_PRIV_SAVEGAME#*=}"

    printf -- "---------------------------------------\n\n"
}

function validate_config()
{
    [[ $CFG_LANGUAGE = "" ]]		&& return 1
    [[ $CFG_MSGLANG = "" ]]		&& return 1
    [[ $CFG_ISOMODE = "" ]]		&& return 1
    [[ $CFG_SPLITISO = "" ]]		&& return 1
    [[ $CFG_PRIV_SAVEGAME = "" ]]	&& return 1
	[[ $CFG_ADVANCE_OPTIONS="" ]]	&& return 1
	[[ $CFG_DIFFERENT_INPUT="" ]]	&& return 1
	[[ $CFG_DIFFERENT_OUTPUT="" ]]	&& return 1
	[[ $CFG_PARTIAL_PATCH_MUSIC="" ]]	&& return 1
	[[ $CFG_MUSIC_REORDER="" ]]	&& return 1
	[[ $CFG_PARTIAL_PATCH_ITEMS="" ]]	&& return 1
	[[ $CFG_PARTIAL_PATCH_CHARACTERS="" ]]	&& return 1
	[[ $CFG_MULTI_CHAR_OVERWRITE="" ]]	&& return 1
	[[ $CFG_PARTIAL_PATCH_TRACKS="" ]]	&& return 1
	[[ $CFG_PARTIAL_PATCH_UI="" ]]	&& return 1
    return 0
}

function config_options()
{
    CFG_OPT=("--riiv-mode=$ENABLE_RIIV")
    [[ ${CFG_ISOMODE} != "" ]]		&& CFG_OPT=("${CFG_OPT[@]}" --${CFG_ISOMODE})
    [[ ${CFG_SPLITISO:0:1} = 1 ]]	&& CFG_OPT=("${CFG_OPT[@]}" --split)
    [[ ${CFG_PRIV_SAVEGAME:0:1} = 0 ]]	&& CFG_OPT=("${CFG_OPT[@]}" --savegame)
	[[ ${CFG_ADVANCE_OPTIONS:0:1} = 1 ]]	&& [[ ${#CFG_DIFFERENT_INPUT} == "5" || ${CFG_DIFFERENT_INPUT} == "" ]]
	[[ ${CFG_PARTIAL_PATCH_MUSIC:0:1} = 1 ]] &&  [[ ${CFG_MUSIC_REORDER:0:1} = 1 ]]
	[[ ${CFG_PARTIAL_PATCH_ITEMS:0:1} = 1 ]] && [[ ${CFG_PARTIAL_PATCH_CHARACTERS:0:1} = 1 ]]
	[[ ${CFG_MULTI_CHAR_OVERWRITE:0:1} = 1 ]] && [[ ${CFG_PARTIAL_PATCH_TRACKS:0:1} = 1 ]]
	[[ ${#CFG_DIFFERENT_OUTPUT} == "2" ]] && [[ ${CFG_PARTIAL_PATCH_UI:0:1} = 1 ]]
}

#
#------------------------------------------------------------------------------
# load_locale()

function load_locale()
{
    local src="$LANG_SRC/$1.sh"
    [[ -s $src ]] && . "$src"
}

load_locale en			# loads english texts 
load_locale "$CFG_LANGUAGE"	# now scan predefined language

#
#------------------------------------------------------------------------------
# read_char()

function read_char()
{
    local prompt="$1"
    local default="$2"
    shift 2
    while true
    do
	local in
	read -n1 -p "$prompt [$default]: " -s in || exit 1
	if [[ $in = "" ]]
	then
	    echo "$default"
	    echo "$default" >&2
	    return 0
	fi

	for (( i=1; i <= $#; i++ ))
	do
	    local p="${!i}"
	    if [[ $in == ${p:0:1} ]]
	    then
		echo "${p:1}"
		echo "${p:1}" >&2
		return 0
	    fi
	done
	echo >&2
    done
}

#
#------------------------------------------------------------------------------
# read_mode()

function read_mode()
{
    local prompt="$1"
    local default="$2"
    shift 2
    while true
    do
	local in
	read -p "$prompt [$default]: " in || exit 1
	[[ $in = "" ]] && in="$default"
	local len=${#in}
	local found=
	local count=0
	for (( i=1; i <= $#; i++ ))
	do
	    local p="${!i}"
	    if [[ $in == $p ]]
	    then
		echo "$p"
		return 0
	    fi
	    if ((len)) && [[ $in == ${p:0:(len)} ]]
	    then
		let count++
		found="$p"
	    fi
	done
	if (( count == 1 ))
	then
	    echo "$found"
	    return 0
	fi
    done
}

#
#------------------------------------------------------------------------------
# read_noyes()

function read_noyes()
{
    local prompt="$1"
    local default="$2"
    [[ ${2:0:1} = 0 ]] && default="$T_NO"
    [[ ${2:0:1} = 1 ]] && default="$T_YES"
    local answer="$(read_mode "$prompt ($T_NO,$T_YES)" "$default" "$T_NO" "$T_YES" 0 1 )"
    [[ $answer = $T_NO  || $answer = 0 ]] && answer="0=$T_NO"
    [[ $answer = $T_YES || $answer = 1 ]] && answer="1=$T_YES"
    echo "$answer"
    return 0
}

#
#------------------------------------------------------------------------------
# check_game_input()

function check_game_input()
{
	printf "* $T_DIFFERENT_INPUT:"
	read CFG_DIFFERENT_INPUT
	while [[ ${#CFG_DIFFERENT_INPUT} != 6 && ${#CFG_DIFFERENT_INPUT} != 0 ]]
	do
		printf "** Not a valid format.\n"
		printf "* $T_DIFFERENT_INPUT:"
		read CFG_DIFFERENT_INPUT
	done	
	if [[  ${#CFG_DIFFERENT_INPUT} == 0 ]]
	then
		printf "** Input left blank. Defaults to RMCx01\n"
		CFG_DIFFERENT_INPUT=""
	fi
}


#
#------------------------------------------------------------------------------
# check_game_output()

function check_game_output()
{
	shouldTryAgain="yes"
	#for Mario Kart Adventures, odd numbers are full distributions
	#even numbers are custom distributions for MKA.
	BANLIST="A1 A3 A5 A7"
	while [[ $shouldTryAgain == "yes" ]]
	do
		shouldTryAgain="no"
		printf "* $T_DIFFERENT_OUTPUT:"
		read CFG_DIFFERENT_OUTPUT
		#first, check if patch size was left blank
		if [[ ${#CFG_DIFFERENT_OUTPUT} == 0 ]]
		then
			if [[ ${#CFG_DIFFERENT_INPUT} == 0 ]]
			then
				printf "** Input left blank. Defaults to A2\n"
				CFG_DIFFERENT_OUTPUT="A2"
			else
				printf "** Input left blank but your previous setting states you are patching another game with Mario Kart Adventures.\n"
				printf "**** Defaults to A9\n"
				CFG_DIFFERENT_OUTPUT="A9"
			fi				
		#now check for valid inputs that are not just integers and are the correct size
		elif [[ ${#CFG_DIFFERENT_OUTPUT} == 2 ]]
		then 
			if ! [[ -n ${CFG_DIFFERENT_OUTPUT//[0-9]/} ]]
			then
				printf "There are many custom distributions with IDs 00-99. Please choose an ID with a letter in it.\n"
				shouldTryAgain="yes"
			fi
			
			#cycle through all possible names on banlist
			for x in BANLIST
			do
				if [[ ${CFG_DIFFERENT_INPUT} == ${x} ]]
				then
					#name exists, try again
					printf "** This output is a known distribution. Please choose a different output.\n"
					shouldTryAgain="yes"
				fi
			done			
		else
			printf "** That was not in the correct format. Please try again. \n"
			shouldTryAgain="yes"
		fi
	done
}

#
#------------------------------------------------------------------------------
# ask_config()

function ask_config()
{

    #----- dialog language

    if [[ $AUTORUN != 1 && ${ASK_LANGUAGE:=1} = 1 ]]
    then
	printf "$T_LANGUAGE_INFO\n"
	CFG_LANGUAGE="$(read_mode "* $T_LANGUAGE (${LANG_LIST// /,})" "$CFG_LANGUAGE" $LANG_LIST)"
    fi
    load_locale "$CFG_LANGUAGE"


    #----- game language
	printf "________________________________________________________\n"
    if [[ $AUTORUN != 1 && ${ASK_MSGLANG:=1} = 1 ]]
    then
	printf "$T_MSGLANG_INFO\n"
	CFG_MSGLANG="$(read_mode "* $T_MSGLANG (${MSGLANG_LIST// /,})" "$CFG_MSGLANG" $MSGLANG_LIST)"
    fi
    export CFG_MSGLANG


    #----- iso mode (or Riivolution)

    [[ -d $BASEDIR/riivolution ]] || ENABLE_RIIV=0

    local info="$T_ISOMODE_INFO"
    local list="$ISOMODE_LIST"
    if [[ $ENABLE_RIIV = 1 ]]
    then
	info="${info}${T_ISOMODE_RIIV1}"
	list="$list riiv"
    elif [[ $ENABLE_RIIV = 2 ]]
    then
	info="${info}${T_ISOMODE_RIIV2}"
	list="$list riiv riiv-"
    elif (( ENABLE_RIIV > 2 ))
    then
	info="${info}${T_ISOMODE_RIIV3}"
	list="$list riiv"
    fi
	
	printf "________________________________________________________\n"
    if [[ $AUTORUN != 1 && ${ASK_ISOMODE:=1} = 1 ]]
    then
	printf "$info\n"
	CFG_ISOMODE="$(read_mode "* $T_ISOMODE (${list// /,})" "$CFG_ISOMODE" $list)"
    fi

    CREATE_RIIV=0
    [[ $CFG_ISOMODE = riiv ]] && CREATE_RIIV=1
    [[ $CFG_ISOMODE = riiv- ]] && CREATE_RIIV=2


    #----- split image
    if [[ $AUTORUN != 1 && ${ASK_SPLITISO:=1} = 1 && $CREATE_RIIV = 0 ]]
    then
	printf "$T_SPLITISO_INFO\n"
	CFG_SPLITISO="$(read_noyes "* $T_SPLITISO" "$CFG_SPLITISO")"
    fi


    #----- alternate save game
	printf "________________________________________________________\n"
    if [[ $AUTORUN != 1 && ${ASK_SAVEGAME:=1} = 1  && $CREATE_RIIV = 0 ]]
    then
	printf "$T_SAVEGAME_INFO\n"
	CFG_PRIV_SAVEGAME="$(read_noyes "* $T_PRIV_SAVEGAME" "$CFG_PRIV_SAVEGAME")"
    fi

	if [ $CFG_ISOMODE == "riiv" ]
	then
		CFG_ADVANCE_OPTIONS="0=no" 
	else [ $CFG_ISOMODE != "riiv" ]
		#----- advance options
		if [[ $AUTORUN != 1 && $CREATE_RIIV = 0 ]]
		then
		printf "________________________________________________________\n"
		printf "$T_ADVANCE_OPTIONS_INFO\n"
		CFG_ADVANCE_OPTIONS="$(read_noyes "* $T_ADVANCE_OPTIONS" "$CFG_ADVANCE_OPTIONS")"
		
		if [ $CFG_ADVANCE_OPTIONS == "1=yes" ]
		then
			printf "________________________________________________________\n"
			printf "$T_DIFFERENT_INPUT_INFO\n"
			check_game_input
			
			printf "________________________________________________________\n"
			printf "$T_DIFFERENT_OUTPUT_INFO\n"			
			check_game_output
				
			printf "________________________________________________________\n"
			printf "$T_PARTIAL_PATCH_MUSIC_INFO\n"
			CFG_PARTIAL_PATCH_MUSIC="$(read_noyes "* $T_PARTIAL_PATCH_MUSIC" "$CFG_PARTIAL_PATCH_MUSIC")"
			if [ $CFG_PARTIAL_PATCH_MUSIC == "1=yes" ]
			then
				printf "________________________________________________________\n"
				printf "$T_MUSIC_REORDER_INFO\n"
				CFG_MUSIC_REORDER="$(read_noyes "* $T_MUSIC_REORDER" "$CFG_MUSIC_REORDER")"
			fi
			
			printf "________________________________________________________\n"
			printf "$T_PARTIAL_PATCH_UI_INFO\n"
			CFG_PARTIAL_PATCH_UI="$(read_noyes "* $T_PARTIAL_PATCH_UI" "$CFG_PARTIAL_PATCH_UI")"
			
			printf "________________________________________________________\n"
			printf "$T_PARTIAL_PATCH_ITEMS_INFO\n"
			CFG_PARTIAL_PATCH_ITEMS="$(read_noyes "* $T_PARTIAL_PATCH_ITEMS" "$CFG_PARTIAL_PATCH_ITEMS")"
			
			printf "________________________________________________________\n"
			printf  "$T_PARTIAL_PATCH_CHARACTERS_INFO\n"
			CFG_PARTIAL_PATCH_CHARACTERS="$(read_noyes "* $T_PARTIAL_PATCH_CHARACTERS" "$CFG_PARTIAL_PATCH_CHARACTERS")"
			if [ $CFG_PARTIAL_PATCH_CHARACTERS == "1=yes" ]
			then
				printf "________________________________________________________\n"
				printf "$T_MULTI_CHAR_OVERWRITE_INFO\n"
				CFG_MULTI_CHAR_OVERWRITE="$(read_noyes "* $T_MULTI_CHAR_OVERWRITE" "$CFG_MULTI_CHAR_OVERWRITE")"
			fi
			
			printf "________________________________________________________\n"
			printf  "$T_PARTIAL_PATCH_TRACKS_INFO\n"
			CFG_PARTIAL_PATCH_TRACKS="$(read_noyes "* $T_PARTIAL_PATCH_TRACKS" "$CFG_PARTIAL_PATCH_TRACKS")"
			printf "________________________________________________________\n"
			printf "________________________________________________________\n"
		fi
	fi
	fi
    #----- save config
    save_config
}

#
#------------------------------------------------------------------------------
# end

