 #!/usr/bin/env bash

# Sweep over dataset and file sizes to test BeeGFS scaling:
# test datasets in the range of 10 MB to 1 GB
# with mean filesize in the range of 10 KB to 10 MB

if [ $# != 1 ]; then
    echo "Usage: ${0} output_directory"
elif [[ ! -d ${1} ]]; then
    echo "Error: ${1} is not a directory."
    echo "Usage: ${0} output_directory"
else
    DIR=$(pwd)
    BIN=${DIR}/./data-generator     # absolute path to binary file
    TYM=$(date +%s)                 # UNIX epoch timestamp
    LOG="${DIR}/${TYM}_FS-march.log" # absolute path to log file

    cd $1

    # CLI options
    DM=1000000                      # data-size multiplier
    RP=3                            # number of repetitions

    # Real Values
    LGA=( 1 2 4 6 8 )
    NFA=( 10 100 1000 10000 )

    # Total number of jobs
    LGN=${#LGA[@]}
    NFN=${#NFA[@]}
    NJ=$(( LGN*NFN ))

    # Write log file column headers
    echo "Writing summary to ${LOG}"
    echo -ne "data         file            " > "${LOG}"
    for ((i=0; i<RP; i++))
    do
        echo -ne "time         " >> "${LOG}"
    done
    echo -e "write        stdev        remove" >> "${LOG}"

    n=1
    for j in "${NFA[@]}"
    do
        datasize=$(( j*DM ))
        for i in "${LGA[@]}"
        do
            filesize=$(( datasize/(i*j) ))
            printf "%2d/${NJ} " ${n}
            /usr/bin/time -f'     (%E wall, %U user, %S sys)' \
                          ${BIN} -t ${datasize} -m ${filesize} -r ${RP} -d >> "${LOG}"
            n=$(( n+1 ))
        done
    done
    echo "Wrote summary to ${LOG}"
fi
