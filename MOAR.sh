#!/bin/bash

threads="10"
assembly=""
prefix="Mummer_"
references=""
outputDir=""


function usage
{
	echo "This script will align an assembly against one or more reference using Mummer"
        echo "USAGE script_mummer.sh -t [NBTHREADS] -p [PREFIX] -o [OUTPUTFOLDER]"
        echo "-h print this help message"
	echo "-r : a text file containing the list of fasta files to use as a reference (Required)"
        echo "-t : number of threads to use (default: 10)"
        echo "-a : assembly to align to the reference (Required)"
        echo "-p : output prefix (default: Mummer_)"
        echo "-o : output directory (default: ./)"
}


while getopts r:t:a:p:o:h opt; do
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
if [ ! -r ${assembly} ]; then
	echo "cannot read ${assembly}... Abort"
	echo ""
	usage
	exit 1
fi

if [ "${outputDir}" = "" ]; then
	echo "You must indicates a path to the output directory"
	usage
	exit 1
fi



# Compare against Solanum Lycopersicum
for ref in references; do
	cd "${outputDir}"
	mkdir "ch${chr}_${prefix}";
	cd "ch${chr}_${prefix}";
	cmd="${mummerPath}/nucmer --mum -c 500 -t 100 ${ref} ${assembly}";
	echo "${cmd}";
	eval ${cmd}
	${mummerPath}/mummer-4.0.0beta2/delta-filter -1 out.delta > out.delta.filter;
	${mummerPath}/tools/mummer-4.0.0beta2/mummerplot -large -layout out.delta.filter;
	sed -i 's/set style line 1  lt 1 lw 2 pt 6 ps 1/set style line 1 lc "blue" lt 2 lw 1 pt 6 ps 0.5/g' out.gp
	sed -i 's/set style line 2  lt 3 lw 2 pt 6 ps 1/set style line 2 lc "red" lt 2 lw 1 pt 6 ps 0.5/g' out.gp
	gnuplot out.gp
	cd ../;
done

echo "Done !"
exit 0
