if [ -n "${MYMG5}" ]; then
    echo "MYMG5: ${MYMG5}"
else
    echo "MYMG5 Not Found"
    exit
fi

function submit-qgjet() {
    FINAL=${1}
    MIN_PT=${2}
    MAX_PT=${3}
    START=${4}
    END=${5}

    echo "FINAL: ${FINAL}"
    echo "MIN_PT: ${MIN_PT}"
    echo "MAX_PT: ${MAX_PT}"

    if [ ["$FINAL" == "qq" -o "$FINAL" == "gg"] -o "$FINAL" == 'jj' ]; then
        CARD_SUFFIX="jj_${MIN_PT}_${MAX_PT}"
    elif [ ["$FINAL" == "zq" -o "${FINAL}" == "zg"] -o "$FINAL" == 'zj' ]; then
        CARD_SUFFIX="zj_${MIN_PT}_${MAX_PT}"
    else
        echo "Expected one of ['qq', 'qg', 'gg', 'jj', 'zq', 'zg', 'zj'], got '${FINAL}'"
        echo "Please choose one of the following: qq, gg qg gq zq zg"
        exit 1
    fi

    echo "Running pp->${FINAL}"

    DELPHES_CARD=${MYQGGEN}/Cards/delphes_card_CMS.tcl
    ADDITIONAL_CARDS=${MYQGGEN}/Pythia8Cards/run_card_${CARD_SUFFIX}.dat
    if [ ! -f ${ADDITIONAL_CARDS} ]; then
        echo "${ADDITIONAL_CARDS} doesn't exist!!!"
        exit 1
    fi

    for RUN_SUFFIX in $(seq ${START} ${END}); do
        RUN="pt_${MIN_PT}_${MAX_PT}_${RUN_SUFFIX}"
        NAME="mg5_pp_${FINAL}_default_${RUN}"

        OUT_DIR=${MYSTORE}/QGJets/0-Generated/${NAME}

        if [ -d ${OUT_DIR} ]; then
            echo "${OUT_DIR} already exists!!!"
            continue
        fi

        submit-job -e=generate-condor \
                   -a ${MCGEN} ${FINAL} ${OUT_DIR} ${DELPHES_CARD} ${ADDITIONAL_CARDS} \
                   -b "${FINAL}_${MIN_PT}_${MAX_PT}" \
                   -j "job_${FINAL}_${MIN_PT}_${MAX_PT}" \
                   -s "RUN-${RUN_SUFFIX}" 
    done
}

# submit-qgjet 'jj' 100 110 2 10
# submit-qgjet 'jj' 200 220 1 10
# submit-qgjet 'jj' 500 550 1 10
# submit-qgjet 'jj' 1000 1100 1 10

# submit-qgjet 'zj' 100 110 2 450
submit-qgjet 'zj' 200 220 1
# submit-qgjet 'zj' 500 550 1
# submit-qgjet 'zj' 1000 1100 1
