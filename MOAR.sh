#!/bin/bash

# To add : 
#	options for nucmer

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
    echo "USAGE MOAR.sh -r [FASTA_LIST] -t [NBTHREADS] -p [PREFIX] -o [OUTPUTFOLDER]"
    echo "-h print this help message"
	echo "-r : a text file containing the list of fasta files to use as a reference (Required)"
    echo "-t : number of threads to use (default: 10)"
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
		r)
			references=${OPTARG}
		;;
        t)
            threads=${OPTARG}
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

echo "MOAR on `date '+%Y-%m-%d %H:%M:%S'`" > ${outputDir}/Skipped.log

# Compare the assembly against each file from "references"
for ref in $(cat ${references}); do

	if [ ! -r ${ref} ]; then
		echo "Cannot read ${ref} !!! Skipping..."
		echo "${ref}" >> ${outputDir}/Skipped.log
	fi

	cd "${outputDir}"
	mkdir "${prefix}_${ref}";
	cd "${prefix}_${ref}";
	
	cmd="${mummerPath}/nucmer --mum -c 500 -t ${threads} ${ref} ${assembly}";
	echo "Running ${cmd} ...";
	eval ${cmd}
	${mummerPath}/delta-filter -1 out.delta > out.delta.filter;
	${mummerPath}/mummerplot -large -layout --terminal png --prefix ${prefix}_${ref} out.delta.filter;
	
	# Changing styles : reducing point size and coloring forward () and reverse ()
	sed -i 's/set style line 1  lt 1 lw 2 pt 6 ps 1/set style line 1 lc "blue" lt 2 lw 1 pt 6 ps 0.5/g' out.gp
	sed -i 's/set style line 2  lt 3 lw 2 pt 6 ps 1/set style line 2 lc "red" lt 2 lw 1 pt 6 ps 0.5/g' out.gp
	
	# Replace x11 output by pdf 
	sed -i 's/set terminal x11 font "Courier,8"//g' out.gp
	sed -i -e '1iset terminal pdf size 200,100\' out.gp
	sed -i -e '2iset output \'out.pdf\'\' out.gp

	# Remove plot interactivity since we plot it as a pdf 
	head -n -8 out.gp
	
	# Finaly print the plot
	gnuplot out.gp
	
	cd ../;
done

echo "Done !"
echo "The list of skipped sequences (if fasta not readable) are available in ${outputDir}/Skipped.log"
exit 0
