# MOAR
MOAR (Mummer On Assembly against a Reference)

This script will align an assembly against one or more reference using Mummer:"

USAGE MOAR.sh -t [NBTHREADS] -r [FASTA_LIST] -a [ASSEMBLY] -p [PREFIX] -m [MUMMER_PATH] -o [OUTPUTFOLDER]
	-h print this help message
	-t : number of threads to use (default: 10)
	-r : a text file containing the list of fasta files to use as a reference (Required)
	-a : assembly to align to the reference (Required)
	-p : output prefix (default: Mummer_)
	-m : path to Mummer (required)
	-o : output directory (default: ./)
