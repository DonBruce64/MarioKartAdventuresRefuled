__author__ = "don_bruce"
__version__ = "1.0.0"

from BrawlCrate.API import BrawlAPI
from BrawlLib.SSBB.ResourceNodes import *
import os.path


def canEditVO(fileName):
	#Exclude Dry Bowser (BK), Koopa Troopa (NK), King Boo (KT), and miis from processing.
	#The former as they are MIDI files and not individually editable.
	return "VO/" in fileName and "VO/BK/" not in fileName and "VO/NK/" not in fileName and "VO/KT/" not in fileName and "VO/M1/" not in fileName and "VO/M2/" not in fileName and "VO/M3/" not in fileName and "VO/M4/" not in fileName and "VO/F1/" not in fileName and "VO/F2/" not in fileName and "VO/F3/" not in fileName and "VO/F4/" not in fileName

def genStreamPrefix(filePrefix, bankEntry):
	return filePrefix + "_" + str(bankEntry + 1) + ".wav"

#Populate the kart select dict using prefixes and rules.
kartSelectData = {
	"BDS": (85,90),
	"BLG": (69,76),
	"BMR": (61,68),
	"BPC": (77,84),
	"CA": (50,52),
	"DS": (42,49),
	"DD": (58,60),
	"DK": (126,128),
	"FK": (132,137),
	"KK": (91,95),
	"KO": (96,100),
	"KP": (121,125),
	"JR": (53,57),
	"LG": (24,31),
	"MR": (16,23),
	"PC": (38,41),
	"RS": (141,143),
	"WL": (113,120),
	"WR": (105,112),
	"YS": (32,37)
}

def genKartSelectPrefix(filePrefix, bankEntry):
	for prefix, range in kartSelectData.items():
		if bankEntry >= range[0] and bankEntry <= range[1]:
			return filePrefix + prefix + "_SELECT_" + str(bankEntry - range[0] + 1) + ".wav"
	return None			

def importRBNK(bankNode, filePrefix, filePrefixFunction):
	bankEntry = 0
	count = 0
	for soundChild in bankNode.Children:
		if type(soundChild) == RWARNode:
			for soundChildNode in soundChild.Children:
				if type(soundChildNode) == RWAVNode:
					fileName = filePrefixFunction(filePrefix, bankEntry)
					if fileName is not None and os.path.isfile(fileName):
						soundChildNode.Replace(fileName)
						count += 1
					bankEntry += 1
	return count

# Main function
if BrawlAPI.RootNode != None: # If there is a valid open file
	root = BrawlAPI.RootNode
	folder = BrawlAPI.OpenFolderDialog()
	if folder:
		count = 0 # Set the count
		
		#First import the main VO sounds that we can replace from the tree.
		soundNodes = BrawlAPI.NodeListOfType[RSARSoundNode]()
		for soundNode in soundNodes:
			if soundNode.CreateStreams()[0] is not None:
				soundName = soundNode.TreePath.replace("/", "_")
				soundFile = folder + "/" + soundName + ".wav"
				if os.path.isfile(soundFile):
					#Get sound as WAV and replace sound data.
					soundObj = soundNode._waveDataNode.Sound
					soundObj.Replace(soundFile)
					count += 1
					
		#Search though files not on the tree.
		for soundFile in BrawlAPI.RootNode.Files:
			if type(soundFile) == RBNKNode and canEditVO(soundFile.Name):
				#Import a VO bank.  These will be the STRM (slipstream) files.
				#Strip off the index prefix, and the GRP_ prefix to align with the normal VO files.
				filePrefix = folder + "/" + soundFile.Name[soundFile.Name.index(" ")+5:].replace("/", "_") + "_STRM"
				count += importRBNK(soundFile, filePrefix, genStreamPrefix)
			if soundFile.FileNodeIndex == 637:
				#Import the GRP char select voices.  These reference an external list for common import/export operations.
				count += importRBNK(soundFile, folder + "/VO_", genKartSelectPrefix)
					
		if count: # If any sounds are found, show the user a success message
			BrawlAPI.ShowMessage(str(count) + " sounds were successfully imported from " + folder, "Success")
		else: # If no sounds are found, show an error message
			BrawlAPI.ShowError('No sounds were found in the open file?  This isn\'t right...  Are you sure you opened RevoKart.brsar?','Error')
else: # Show an error message if there is no valid file open
    BrawlAPI.ShowError('Cannot find Root Node (is a file open?)','Error')
