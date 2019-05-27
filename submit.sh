if [ -n "${MYMG5}" ]; then
    echo "MYMG5: ${MYMG5}"
else
    echo "MYMG5 Not Found"
    exit
fi

XRD_BASE="root://cms-xrdr.private.lo:2094//xrd/store/user/seyang/"
MYXRD=/xrootd/store/user/seyang//
MYQGGEN="/cms/ldap_home/slowmoyang/Projects/MG5-CMSSW_10_3_1/src/qgjets-nocr-generaation"


function submit-qgjet() {
    FINAL=${1}
    MIN_PT=${2}
    MAX_PT=${3}
    START=${4}
    END=${5}

    echo "FINAL: ${FINAL}"
    echo "MIN_PT: ${MIN_PT}"
    echo "MAX_PT: ${MAX_PT}"

    if [ "$FINAL" == "qq" -o "$FINAL" == "gg" -o "$FINAL" == 'jj' -o "${FINAL}" == "qg" ]; then
        CARD_SUFFIX="jj_${MIN_PT}_${MAX_PT}"
    elif [ "$FINAL" == "zq" -o "${FINAL}" == "zg" -o "$FINAL" == 'zj' ]; then
        CARD_SUFFIX="zj_${MIN_PT}_${MAX_PT}"
    else
        echo "Expected one of ['qq', 'qg', 'gg', 'jj', 'zq', 'zg', 'zj'], got '${FINAL}'"
        echo "Please choose one of the following: qq, gg qg gq zq zg"
        exit 1
    fi

    echo $CARD_SUFFIX

    echo "Running pp->${FINAL}"

    DELPHES_CARD=${MYQGGEN}/Cards/delphes_card_CMS.tcl
    ADDITIONAL_CARDS=${MYQGGEN}/Pythia8Cards/run_card_${CARD_SUFFIX}.dat
    if [ ! -f ${ADDITIONAL_CARDS} ]; then
        echo "${ADDITIONAL_CARDS} doesn't exist!!!"
        exit 1
    fi

    for RUN_SUFFIX in $(seq ${START} ${END}); do
        RUN="pt_${MIN_PT}_${MAX_PT}_${RUN_SUFFIX}"
        NAME="mg5_pp_${FINAL}_${RUN}"
        DESTINATION=${XRD_BASE}/qgjets-nocr/

        DEST=$(sed 's@'"${XRD_BASE}"'@'"${MYXRD}"'@' <<< "${DESTINATION}")

        if [ ! -d ${DEST} ]; then
            echo  "${DEST} not found!!!"
            exit 1
        fi

        OUTPUT_FILE=${DEST}/${NAME}.root
        if [ -f ${OUTPUT_FILE} ]; then
            echo "${OUTPUT_FILE} already exists!!!"
            continue
        fi

        submit-job -e=generate \
                   -a ${MCGEN} ${NAME} ${DESTINATION} ${FINAL} ${DELPHES_CARD} ${ADDITIONAL_CARDS} \
                   -b "${FINAL}_${MIN_PT}_${MAX_PT}" \
                   -j "job_${FINAL}_${MIN_PT}_${MAX_PT}" \
                   -s "RUN-${RUN_SUFFIX}" 
    done
}
