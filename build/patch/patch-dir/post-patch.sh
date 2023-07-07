#------------------------------------------------------------------------------
# post-patch.sh
#------------------------------------------------------------------------------
#
# Main post-patch file for Mario Kart Adventures.
# It calls patches in this order:
#	- Tracks
# 	- Music
#	- UI
#	- Items
#	- Characters
#
# written by Helix
# modified by don_bruce
#
#------------------------------------------------------------------------------

# include.fst not needed (ignore .svn entries and all other hidden files)
rm -f include.fst

#import data
if [ -f ./../config.def ]; then 
	. ./../config.def
fi

#Set fast create variable.
FAST=
[[ $WSZST_FAST = 1 || $1 == --fast ]] && FAST=--fast

#create local data
TPL_PATCH_FILES="Award Channel Event Font Globe MenuMulti MenuOther MenuSingle Present Race Title"
yes="1=yes"
no="0=no"


#------------------------------------------------------------------------------
# Do some preparations for riivolution mode. ln does not add nonexistant
# directories on a path so we add those ourselves...

if [[ $ISOMODE == "riiv" ]]
then
	echo ""
	echo "Oh, you're building a riivolution version. Let me add some stuff..."
	echo ""
	mkdir -p "./files/sound"
	mkdir -p "./files/sound/strm"
	mkdir -p "./files/thp/battle"
	mkdir -p "./files/thp/button"
	mkdir -p "./files/thp/course"
	mkdir -p "./files/thp/title"
fi


#------------------------------------------------------------------------------
#Extract all files used for icons.  These are used in multiple places in this script, and are likely used by at least one function, even if some are turned off.  We extract only once here to save from extracting and re-compiling every function call.
for fileToPatch in $TPL_PATCH_FILES; do
	wszst extract -roq "./files/Scene/UI/${fileToPatch}.szs"
done


#------------------------------------------------------------------------------
#replace tracks
if [[ $PARTIAL_PATCH_TRACKS ==  $yes  && $ADVANCE_OPTIONS == $yes ]] || [[ $ADVANCE_OPTIONS == $no ]]
then
	[[ -s ./patch-Tracks.sh ]] && bash ./patch-Tracks.sh "$@" "$1"
else
	echo ""
	echo ""
	echo "** Skipping over the tracks..."
	rm -rf "./tracks"
fi
echo ""
echo ""


#------------------------------------------------------------------------------
#replace Music
if [[ $PARTIAL_PATCH_MUSIC ==  $yes && $ADVANCE_OPTIONS == $yes ]] || [[ $ADVANCE_OPTIONS == $no ]]
then
	[[ -s ./patch-Music.sh ]] && bash ./patch-Music.sh "$@" "$1"
else
	echo ""
	echo ""
	echo "** Skipping the music. This also skips in-game sound effects and character voices..."
fi
echo ""
echo ""


#------------------------------------------------------------------------------
#replace menus
if [[ $PARTIAL_PATCH_UI ==  $yes &&  $ADVANCE_OPTIONS == $yes ]] || [[ $ADVANCE_OPTIONS == $no ]]
then
	[[ -s ./patch-UI.sh ]] && bash ./patch-UI.sh "$@" "$1"
else
	echo ""
	echo ""
	echo "** I'm skipping over the UI. This won't make things look all fancy."
	rm -rf "./ui"
fi
echo ""
echo ""


#------------------------------------------------------------------------------
#replace Items
if [[ $PARTIAL_PATCH_ITEMS ==  $yes &&  $ADVANCE_OPTIONS == $yes ]] || [[ $ADVANCE_OPTIONS == $no ]]
then
	[[ -s ./patch-Items.sh ]] && bash ./patch-Items.sh "$@" "$1"
else
	echo ""
	echo ""
	echo "** Skipping over the items..."
	rm -rf "./items"
fi
echo ""
echo ""




#------------------------------------------------------------------------------
#replace characters
if [[ $PARTIAL_PATCH_CHARACTERS ==  $yes && $ADVANCE_OPTIONS == $yes ]] || [[ $ADVANCE_OPTIONS == $no ]]
then
	[[ -s ./patch-Characters.sh ]] && bash ./patch-Characters.sh "$@" "$1"
else
	echo ""
	echo ""
	echo "** Skipping over the characters..."
	rm -rf "./characters"
fi
echo ""
echo ""



#------------------------------------------------------------------------------
#cleanup extraneous files, compile the UI files, and exit
echo "" 
echo ""
echo "I'm done! Just give me a moment to clean up..."
for fileToPatch in $TPL_PATCH_FILES; do
	wszst create -roq $FAST "./files/Scene/UI/${fileToPatch}.d"
	rm -rf "./files/Scene/UI/${fileToPatch}.d"
done

echo ""
echo ""
echo "Great! Now lets build your game..." 

true



