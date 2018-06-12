# MOAR
MOAR (Mummer On Assembly against a Reference)

This script will align an assembly against one or more reference using Mummer

USAGE script_mummer.sh -r [file with reference fasta] -t [NBTHREADS] -p [PREFIX] -o [OUTPUTFOLDER]"

	-r : a text file containing the list of fasta files to use as a reference (Required)
	-t : number of threads to use (default: 10)
	-a : assembly to align to the reference (Required)
	-p : output prefix (default: Mummer_)
	-o : output directory (default: ./)
