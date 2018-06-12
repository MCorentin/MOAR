# MOAR
MOAR (Mummer On Assembly against a Reference)

This script will align an assembly against one or more references using Mummer:

USAGE MOAR.sh -t [NBTHREADS] -r [FASTA_LIST] -a [ASSEMBLY] -p [PREFIX] -m [MUMMER_PATH] -o [OUTPUTFOLDER]

	-h : print this help message
	-t : number of threads to use (default: 10)
	-r : a text file containing the list of fasta files to use as a reference (Required)
	-a : assembly to align to the reference (Required)
	-p : output prefix (default: Mummer_)
	-m : path to Mummer (required)
	-o : output directory (default: ./)

# Output

The script will create a folder for each file available in "FASTA_LIST", this folder will contain:

	The default mummer output:

		The delta file from nucmer, containing the alignments
		A png graph with mummerplot default style
		A ".gp" file, customisable to change the style of the graph
	
	It also produce a pdf graph with a custom style (see example graph below)


# Example 
This is an output example, the reference is on the x-axis, the scaffolds on the y-axis
Forward alignments are in blue
Reverse alignments are in red

![alt text](https://raw.githubusercontent.com/MCorentin/MOAR/master/example.png)
