#!/bin/bash

# To add :
#	Options for nucmer
#	Update log
#	Remove sequence with no match from mummer plot

threads="10"
assembly=""
prefix="MOAR_"
references=""
mummerPath=""
outputDir="./"

function usage
{
	echo "This script will align an assembly against one or more reference using Mummer:"
	echo ""
	echo "USAGE MOAR.sh -t [NBTHREADS] -r [FASTA_LIST] -a [ASSEMBLY] -p [PREFIX] -m [MUMMER_PATH] -o [OUTPUTFOLDER]"
	echo "-h print this help message"
	echo "-t : number of threads to use (default: 10)"
	echo "-r : a text file containing the list of fasta files to use as a reference (Required)"
	echo "-a : assembly to align to the reference (Required)"
	echo "-p : output prefix (default: Mummer_)"
	echo "-m : path to Mummer (required)"
	echo "-o : output directory (default: ./)"
	echo ""
}


while getopts r:t:a:p:m:o:h opt; do
    case ${opt} in
        h)
		usage
		exit 1
        ;;
	t)
            threads=${OPTARG}
        ;;
	r)
		references=${OPTARG}
	;;
	a)
		assembly=${OPTARG}
	;;
	p)
		prefix=${OPTARG}
	;;
	m)
		mummerPath=${OPTARG}
	;;
	o)
		outputDir=${OPTARG}
	;;
	\?)
		echo "Invalid option: -${OPTARG}"
		echo ""
		usage
		exit 1
	;;
	:)
		echo "Option -${OPTARG} requires an argument"
		echo ""
		usage
		exit 1
	;;
    esac
done

# Check if the files are readable
if [ ! -r "${references}" ]; then
	echo "Cannot read ${references}... Abort"
	echo ""
	usage
	exit 1
fi

if [ ! -r "${assembly}" ]; then
	echo "Cannot read ${assembly}... Abort"
	echo ""
	usage
	exit 1
fi

if [ ! -d "${outputDir}" ]; then
	echo "Cannot access the output directory: ${outputDir} ... Abort"
	echo ""
	usage
	exit 1
fi

echo "MOAR on `date '+%Y-%m-%d %H:%M:%S'`" > ${outputDir}/MOAR.log


# Compare the assembly against each file from "references"
for ref in $(cat ${references}); do
	echo ""

	if [ ! -r ${ref} ]; then
		echo "Cannot read ${ref} !!! Skipping..."
		echo "${ref}" >> ${outputDir}/Skipped.log
	fi

	# "ref" is  a path, soing the basename allow us to create a folder named after the file only
	refname=$(basename ${ref})

	cd "${outputDir}"
	mkdir "${prefix}_${refname}";
	cd "${prefix}_${refname}";

	cmd="${mummerPath}/nucmer --mum -c 500 -t ${threads} ${ref} ${assembly}";
	echo "Running ${cmd} ...";
	eval ${cmd};

	cmd="${mummerPath}/delta-filter -1 out.delta > out.delta.filter";
	echo "Running ${cmd} ...";
        eval ${cmd};

	cmd="${mummerPath}/mummerplot -large -layout -t png out.delta.filter";
	echo "Running ${cmd} ...";
	eval ${cmd};

	# Changing styles : reducing point size and coloring forward () and reverse ()
	sed -i 's/set style line 1  lt 1 lw 3 pt 6 ps 1/set style line 1 lc "blue" lt 2 lw 1 pt 6 ps 0.4/g' out.gp
	sed -i 's/set style line 2  lt 3 lw 3 pt 6 ps 1/set style line 2 lc "red" lt 2 lw 1 pt 6 ps 0.4/g' out.gp

	# Replace out.png by out.pdf
	sed -i 's/set terminal png tiny size 1400,1400/set terminal pdf size 20,20/g' out.gp
	sed -i 's/set output "out.png"/set output "out.pdf"/g' out.gp
	# Remove the grid to avoid having scaffolds names overlapping leadingto a black box on the Y axis
	sed -i 's/set grid//g' out.gp

	# Finaly print the pdf plot and rename the files
	gnuplot out.gp

	cp out.gp ${prefix}_${ref}.gp
	mv out.png ${prefix}_${ref}.png
	mv out.pdf ${prefix}_${ref}.pdf

	cd ../;
done

echo "Done !"
echo "The list of skipped sequences (if fasta not readable) are available in ${outputDir}/Skipped.log"
exit 0
