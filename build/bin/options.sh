#!/bin/bash
# (c) wiimm (at) wiimm.de -- 2014-01-03
# slight modifications by Helix

[[ $ORIGPATH == "" || $BINDIR == "" || $HOST == "" ]] && . ./bin/setup.sh

#
#------------------------------------------------------------------------------
# function print_help()

function print_help()
{
    cat <<- ---EOT---

	$script [option...]

	Options:

	  -h  --help     : print this help to stdout and 'exit 1'
	  -t  --test     : enter test mode => do nothing
	  -v  --verbose  : be verbose, disable --quiet
	  -vv            := -v -v
	  -q  --quiet    : be quiet, disable --verbose
	  -a  --autorun  : Read definition file and run without interaction

	  --source=file  : DIRECTORY: first try this directory as source
	                   FILE:      use this file as source
	  --dest=file    : DIRECTORY: create new image here and not in ./new-image/
	                   FILE:      use this a path and name for new image
	  
	  --riiv-mode=md : supported riivolution mode
	                 : 0=auto, 1:MKW full patch, 2:MKW, 3:other games

	      --iso      : force output to *.iso files (default)
	      --ciso     : force output to *.ciso files
	      --wdf      : force output to *.wdf files
	      --wia      : force output to *.wia files
	      --wbfs     : force output to *.wbfs files
	      --riiv     : create Riivolution setup instead of image
	      --riiv-    : like --riiv, but without patching any source file
	      --add      : call: wwt add -aovv
	                   (wwt is not part of this distribution)
	      --patch    : patch only and don't create an image.

	      --split    : split output at 4 GB
	      --fast     : enable fast mode

	  -s  --savegame : change ID to 'K.....' to enable separate savegame

	---EOT---

    exit 1
}

#
#------------------------------------------------------------------------------
# iterate options

testmode=0
verbose=0
quiet=0

riivsrc="$BASEDIR/riivolution"
riivpossible=0
[[ -d $riivsrc ]] && riivpossible=1
riivmode=0
riivopt=0

mode=iso
split=0
savegame=0
srcdir=
srcfile=
destfile=
fast=
create_distrib=0

done_count=0

#echo ">> $*"
while (( $# && !done ))
do
    case "$1" in
	-h|--help)	print_help ;;
	-t|--test)	testmode=1 ;;
	-v|--verbose)	let verbose++; quiet=0 ;;
	-vv)		let verbose+=2; quiet=0 ;;
	-q|--quiet)	verbose=0 quiet=1 ;;
	-a|--autorun)	;;
	-d|--distrib)	create_distrib=1;;

	--iso)		riivopt=0 mode=iso ;;
	--ciso)		riivopt=0 mode=ciso ;;
	--wdf)		riivopt=0 mode=wdf ;;
	--wia)		riivopt=0 mode=wia ;;
	--wbfs)		riivopt=0 mode=wbfs ;;
	--add)		riivopt=0 mode=add ;;
	--patch)	riivopt=0 mode=patch ;;
	--riiv)		((riivpossible)) && riivopt=1 mode=Riivolution ;;
	--riiv-)	((riivpossible)) && riivopt=2 mode=Riivolution- ;;

	--source=*)	srcdir="${1:9}" ;;
	--dest=*)	destfile="${1:7}" ;;
	--riiv-mode=*)	riivmode="${1:12}" ;;
	--split)	split=1 ;;
	--fast)		fast=--fast ;;
	-s|--savegame)	savegame=1 ;;

	--)		break ;;
	*)		echo ">>> $script: parameter ignored: $1" >&2
    esac
    shift
done

#
#------------------------------------------------------------------------------
# create distrib

if ((create_distrib))
then
    job=../create-distrib.sh 
    [[ -x $job ]] || job=../../create-distrib.sh
    [[ -x $job ]] && "$job"
fi

#
#------------------------------------------------------------------------------
# setup

opt_verbose=-vv
((quiet)) && opt_verbose=-q

opt_split=()
((split)) && opt_split=(--split=4g)

(( riivmode > ENABLE_RIIV )) && riivmode=$ENABLE_RIIV
(( riivopt > 0 && riivmode > 2 )) && riivopt=$riivmode
(( riivopt > ENABLE_RIIV )) && riivopt=$ENABLE_RIIV

TEST=
((testmode)) && TEST="echo WOULD DO:"

#-----

if ((verbose))
then
    echo
    wit --version
    wszst --version
    wbmgt --version
    wimgt --version
    wstrt --version
    echo
    printf "%-9s= %.60s\n" \
	"SYSTEM"	"$SYSTEM" \
	"MACHINE"	"$MACHINE" \
	"HOST"		"$HOST" \
	"BASEDIR"	"$BASEDIR" \
	"BINDIR"	"$BINDIR" \
	"PATH"		"$PATH" \
	"testmode"	"$testmode" \
	"src-dir"	"$srcdir" \
	"out-mode"	"$mode" \
	"split"		"$split" \
	"ena-riiv"	"$ENABLE_RIIV" \
	"riiv-mode"	"$riivmode" \
	"riiv-opt"	"$riivopt"
    echo
    sleep 2
fi | sed 's/^/##  /'

#
#------------------------------------------------------------------------------
# function job()

function job()
{
    (( riivopt && done_count )) && return 0
    DESTID="$2"

    if ((riivopt != 6 && riivopt > 1 ))
    then
	job_riiv2 "$@"
	return $?
    fi

    local srcid="$1"
    local destid="$2"
    local destname="$3"
    local patchfile="$4"

    ((savegame)) && destname="${destname}"


    #----- extract

    printlog "$T_LOG_LIST_SOURCE" "$srcid"
    n=0

    rm -rf "$workdir/sys-save"
    [[ -d "$workdir/sys" ]] && mv "$workdir/sys" "$workdir/sys-save"
    rm -rf "$workdir/sys"

    if [[ -f $srcdir ]]
    then
	srcfile="$srcdir"
	srcdir=
	n=$( wit filetype --no-header --include $srcid "$srcfile" | wc -l )
	((verbose)) && printf "source file, id=%s, OK=%d: %s\n" $srcid $n "$srcfile"
	((n)) || return 0
    elif [[ -d $srcdir ]]
    then
	n=$( wit filetype --no-header --include $srcid "$srcdir" | wc -l )
	((verbose)) && printf "source dir, id=%s, N=%d: %s\n" $srcid $n "$srcdir"
    fi

    [[ -d "$workdir/sys-save" ]] && mv "$workdir/sys-save" "$workdir/sys"

    if ((!n))
    then
	n=$( wit filetype --no-header --include $srcid | wc -l )
	((n)) || return 0
	srcdir=()
    fi

    if ((!quiet))
    then
	if [[ $srcfile = "" ]]
	then
	    wit filetype --long "${srcdir[@]}" . --include $srcid
	else
	    wit filetype --long "$srcfile" . --include $srcid
	fi
    fi

    ((quiet)) && echo "** Create $destname"
    let done_count++

    printlog "$T_LOG_RM_WORKDIR"
    local extractdir="$workdir"
    $TEST rm -rf "$extractdir"

    zero=""
    [[ -s ./zero-files.list ]] && zero='--zero-files=@./zero-files.list'

    if [[ -f $srcfile ]]
    then
	printlog "$T_LOG_EXTRACT_IMAGE" "$srcid"
	$TEST wit extract $opt_verbose -1p "$srcfile" --include $srcid \
		$zero --DEST "$extractdir" --psel data || exit 1
    elif [[ -d $srcdir ]]
    then
	printlog "$T_LOG_COPY_IMAGE" "$srcid"
	extractdir="$workdir.extract"
	$TEST rm -rf "$extractdir"
	$TEST cp -rl "$srcdir" "$extractdir"
    elif ((riivopt)) && [[ -f ./riiv-extract.list ]]
    then
	printlog "$T_LOG_EXTRACT_RIIV" "$srcid"
	$TEST wit extract $opt_verbose -1p . --include $srcid \
		--files=@./riiv-extract.list \
		--DEST "$extractdir" --psel data || exit 1
    else
	printlog "$T_LOG_EXTRACT_IMAGE" "$srcid"
	$TEST wit extract $opt_verbose -1p . --include $srcid \
		$zero --DEST "$extractdir" --psel data || exit 1
    fi

    if  ((riivopt))
    then
	#printf "$T_LOG_RIIV_TIMESTAMP"
	find "$extractdir" -type f -mtime -2 -exec touch -t 200801010000 {} \;
    fi


    #----- pre-patch

    if ((!testmode)) && [[ -f "./pre-patch.sh" ]]
    then
	export riivmode
	printlog "$T_LOG_PATCH" "pre-patch.sh"
	ln -f "./pre-patch.sh" "$extractdir/"
	( cd "$extractdir"; bash ./pre-patch.sh $fast ) || exit 1
    fi


    #----- extract patch file/dir

    printlog "$T_LOG_PATCH" "$patchfile"

    if [[ -d $patchfile ]]
    then
	local cpmode=
	((verbose>1)) && cpmode=-v
	#$TEST cp $cpmode -r --preserve=timestamps "$patchfile"/* "$workdir/"
	$TEST cp $cpmode -r "$patchfile"/* "$workdir/"
    elif [[ ${patchfile##*.} == zip ]]
    then
	local zipmode=-q
	((verbose>1)) && zipmode=
	$TEST unzip -o $zipmode "$patchfile" || exit 1
    else
	local tarmode=xf
	((verbose>1)) && tarmode=xvf
	$TEST tar $tarmode "$patchfile" --no-same-owner || exit 1
    fi

    if [[ $workdir != $extractdir ]]
    then
	cp -rl --remove-destination --dereference "$workdir"/* "$extractdir/"
	rm -rf "$workdir"
	mv "$extractdir" "$workdir"
    fi
    #((testmode)) || chmod -R a+Xrw "$workdir"

    rm -f "$workdir/setup.txt"
    printf "part-id = %s\npart-name = %s\n" \
			"$destid" "$destname" > "$workdir/setup.txt"

    local opt_id=(--id "$destid")
    if ((savegame))
    then
	opt_id=(--id=K --modify boot,tmd,ticket)
	if [[ -s "$workdir/savebanner.tpl" && -d "$workdir/files/Boot/" ]]
	then
	    echo " * use alternate 'savebanner.tpl'"
	    ln -f "$workdir/savebanner.tpl" "$workdir/files/Boot/"
	fi
    fi


    #----- post-patch.sh

    if ((!testmode)) && [[ -f "$workdir/post-patch.sh" ]]
    then
	export riivmode
	( cd "$workdir"; bash ./post-patch.sh $fast $srcid) || exit 1
	if [[ -d "$workdir/files/_mods" ]]
	then
	    rm -rf ./_mods
	    cp -rl "$workdir/files/_mods" ./
	fi
	
    fi
    #((testmode)) || chmod -R a+Xrw "$workdir"


    #----- compose a new image

    if [[ $destfile = "" ]]
    then
	if [[ $mode == wbfs ]]
	then
	    destfile=./new-image/%Y/%+
	else
	    destfile=./new-image/%X
	fi
    elif [[ -d $destfile || ${destfile##*/} = "" ]]
    then
	destfile="$destfile/%X"
    fi

    local opt_base=(--links --overwrite --titles=0 $opt_verbose "${opt_id[@]}")

    if ((riivopt))
    then
	job_riiv1 "$@"
    elif  [[ $mode = add ]]
    then
	printlog "$T_LOG_ADD_IMAGE" "$destid"
	$TEST wwt --all "${opt_base[@]}" add "$workdir" || exit 1
    elif [[ $mode != patch ]]
    then
	printlog "$T_LOG_CREATE_IMAGE" "$destid" "./new-image/*.$mode"
	$TEST wit copy "${opt_base[@]}" "$workdir" --DEST "$destfile" \
		--$mode "${opt_split[@]}" || exit 1
    fi
}

#
#------------------------------------------------------------------------------
# function job_riiv1()

function job_riiv1()
{
    # done_count already incremented
    setup_riiv "$@"
    ((testmode)) && return 0
    printf "$T_LOG_RIIV_TRANSFER"
    find "$workdir/files" -depth -name '.?*' -exec rm -rf {} \;
    ( cd "$workdir/files" && find . -type f -mtime -1 ) | \
	while read f
	do
	    dir="${f%/*}"
	    mkdir -p "$FDIR/$dir"
	    ln -f "$workdir/files/$f" "$FDIR/$f"
	done
	if((riivopt == 1))
	then
	    term_riiv_mkw "$@"
	elif((riivopt == 6))
	then
		term_riiv_mkwa "$@"
	else
		: #do nothing, shouldn't get here... 
	fi
}

#
#------------------------------------------------------------------------------
# function job_riiv2()

function job_riiv2()
{
    let done_count++
    setup_riiv "$@"

    case "$riivmode" in
	2) term_riiv_mkw "$@" ;;
	4) term_riiv_xml "$@" ;;
	5) term_riiv_script "$@" ;;
	*) term_riiv_other "$@" ;;
    esac
}

#
#------------------------------------------------------------------------------
# function setup_riiv()

function setup_riiv()
{
    local patchfile="$4"

    RIIV="./riiv-sd-card"
    if [[ $1 == "" ]]
    then
	mkdir -p "$RIIV"
	RIIV="$RIIV/$1"
    fi
    printlog "$T_LOG_RIIV_START" "$RIIV"
    printf "$T_LOG_RIIV_SETUP"

    rm -rf "$RIIV"
    cp -rl "$riivsrc" "$RIIV"
    #rm -rf "$RIIV"/.svn*
    mkdir -p "$RIIV/riivolution/config"

    TITLE="$REV_TITLE"
    [[ $TITLE = "" ]] && TITLE="$REV_NAME"
    [[ $TITLE = "" ]] && TITLE="MKW-$(date +%F)"
    NAME="$REV_NAME"
    [[ $NAME = "" ]] && NAME="$TITLE"
    DIR="$REV_ID"
    [[ $DIR = "" ]] && DIR="MKW-$(date +%F)"
    ID="${REV_ID//-/}"
    ID3="${ID//-/}"
    SAVEDIR="riivolution/save/${DIR%%-*}"

    FDIR="$RIIV/$DIR"
    mkdir -p "$FDIR" "$RIIV/$SAVEDIR"

    if [[ -d $patchfile ]]
    then
	local cpmode=
	((verbose>1)) && cpmode=-v
	local cpdest="$RIIV/${workdir##*/}/"
	mkdir -p "$cpdest"
	$TEST cp $cpmode -r --preserve=timestamps "$patchfile"/* "$cpdest"
    elif [[ ${patchfile##*.} == zip ]]
    then
	local zipmode=-q
	((verbose>1)) && zipmode=
	( cd "$RIIV" && $TEST unzip -o $zipmode "../$patchfile" ) || exit 1
    else
	local tarmode=xf
	((verbose>1)) && tarmode=xvf
	$TEST tar $tarmode "$patchfile" --no-same-owner -C "$RIIV" || exit 1
    fi

    $TEST mv "$RIIV/$workdir"/files/* "$FDIR"
    rm -rf "$RIIV/$workdir" "$FDIR/_mods"
	
	#nearly every character is modded, and many are modded after the original patch. 
	#TODO: write a character-list that autogenerats and tracks every modded character to create a smaller riivolution 
	#version. For now, just add all the character and all the allkart files:
	copyAll "./patch-dir/files/Race/Kart/*.szs" "Race/Kart"
	copyAll "./patch-dir/files/Scene/Model/Kart/*.szs" "Scene/Model/Kart"
	
	cp -r ./patch-dir/files/sound $RIIV/Mario.Kart.Adventures/sound
	cp -r ./patch-dir/files/thp $RIIV/Mario.Kart.Adventures/thp
}

#helper function
function copyAll {
	for i in $1; do
		ln -f "${i}" "$FDIR/${2}/${i:11:$len-ll}"
	done
}
#
#------------------------------------------------------------------------------
# function term_riiv_mkw()

function term_riiv_mkw()
{
    find "$RIIV" -depth -type d -name '.?*' -exec rm -rf {} \;
    rm -rf "$FDIR/_Wiimm"
    printf "$T_LOG_RIIV_CREATE" "$DIR.xml"
    {
	patch_xml "$RIIV/template/mario-kart-wii-1.xml"
	( cd "$FDIR" && riiv_files "$DIR" Scene/UI Boot/Strap rel Race/Course thp/course )
	[[ -d "$FDIR/sys" ]] && patch_xml "$RIIV/template/mario-kart-wii-2.xml"
	patch_xml "$RIIV/template/mario-kart-wii-3.xml"
	( cd "$FDIR" && riiv_files "$DIR" Race/Kart )
	patch_xml "$RIIV/template/mario-kart-wii-4.xml"

    } >"$RIIV/riivolution/$DIR.xml"
    rm -rf "$RIIV/template"
    #chmod -R a+Xrw "$RIIV"
}

#
#------------------------------------------------------------------------------
# function term_riiv_mkwa()

function term_riiv_mkwa()
{	
	mkdir -p "$RIIV/template"
	mkdir -p "$RIIV/riivolution"
    find "$RIIV" -depth -type d -name '.?*' -exec rm -rf {} \;
    rm -rf "$FDIR/_mods"
    printf "$T_LOG_RIIV_CREATE" "$DIR.xml"
    {
	patch_xml "$RIIV/template/mario-kart-wii-1.xml"
	( cd "$FDIR" && riiv_files "$DIR" Boot/Strap Demo Race/Course rel Scene/UI thp )
	( cd "$FDIR" && add_common ) 

		
	[[ -d "$FDIR/sys" ]] && patch_xml "$RIIV/template/mario-kart-wii-2.xml"
	patch_xml "$RIIV/template/mario-kart-wii-3.xml"
	
	( cd "$FDIR" && riiv_files "$DIR" Race/Kart Scene/Model/)
	
	patch_xml "$RIIV/template/mario-kart-wii-5.xml"
	( cd "$FDIR" && riiv_files "$DIR" sound)
	
	patch_xml "$RIIV/template/mario-kart-wii-4.xml"

	
    } >"$RIIV/riivolution/$DIR.xml"
    rm -rf "$RIIV/template"
    #chmod -R a+Xrw "$RIIV"
}


#
#------------------------------------------------------------------------------
# function term_riiv_other()

function term_riiv_other()
{
    rm -rf "$FDIR/_Wiimm"
    printf "$T_LOG_RIIV_CREATE" "$DIR.xml"
    {
	patch_xml "$RIIV/template/other-1.xml"
	( cd "$FDIR" && riiv_files "$DIR" . )
	patch_xml "$RIIV/template/other-2.xml"

    } >"$RIIV/riivolution/$DIR.xml"
    rm -rf "$RIIV/template"
}

#
#------------------------------------------------------------------------------
# function term_riiv_xml()

function term_riiv_xml()
{
    rm -rf "$FDIR/_Wiimm" "$RIIV/template"
    cp -p riivolution.xml "$RIIV/riivolution/$DIR.xml"
}

#
#------------------------------------------------------------------------------
# function term_riiv_script()

function term_riiv_script()
{
    rm -rf "$FDIR/_Wiimm"
    [[ -f riivolution.xml ]] && cp -p riivolution.xml "$RIIV/riivolution/$DIR.xml"
    DIR="$DIR" FDIR="$FDIR" RIIV="$RIIV" bash riivolution.sh "$@"
    rm -rf "$RIIV/template"
}

#
#------------------------------------------------------------------------------
# function copy_xml()

function patch_xml()
{

   sed "s|@@ID3@@|${DESTID:0:3}|g;
	s|@@ID4@@|${DESTID:0:4}|g;
	s|@@ID@@|$ID|g;
	s|@@NAME@@|$NAME|g;
	s|@@TITLE@@|$TITLE|g;
	s|@@DIR@@|$DIR|g; s|@@SAVEDIR@@|$SAVEDIR|g
	" "$1"
}

#
#------------------------------------------------------------------------------
# function riiv_files()

function riiv_files()
{
    local format="$(printf '  <file disc="/%%s" external="/%s/%%s" create="true" />\\n' "$1" )"
    local list=".list.tmp"
    rm -f "$list"
    shift

    local dlist=()
    for d in "$@"
    do
	[[ -d $d ]] && dlist=( "${dlist[@]}" "$d" )
    done
    (( ${#dlist[@]} )) || return 0

    find "${dlist[@]}" -type f -printf '%s\n' | sort -n | uniq |
     while read size
     do
	find "${dlist[@]}" -type f -size ${size}c | sed 's+^\./++' | sort >"$list"
	while [[ -s $list ]]
	do
	    cat /dev/null >"$list.new"
	    base=
	    while read file
	    do
		if [[ $file == *.wu8 ]]
		then
			#took files from the patch, remove these
			rm -rf $file 
		elif [[ $base = "" ]]
		then
		    base="$file"
		    printf "$format" "$file" "$base"
		elif diff -q "$file" "$base" >/dev/null
		then
		    rm -f "$file"
		    printf "$format" "$file" "$base"
		else
		    echo "$file" >>"$list.new"
		fi
	    done <"$list"
	    mv "$list.new" "$list"
	done
    done | sort

    rm -f "$list"
}


#
#------------------------------------------------------------------------------
# function add_common()
# 
# quick hack, to avoid using the standard method that recursively checks all subfolders

function add_common()
{
	echo " <file disc=\"/Race/Common.szs\" external=\"/Mario.Kart.Adventures/Race/Common.szs\" create=\"true\" />"
}
#
#------------------------------------------------------------------------------
# end
