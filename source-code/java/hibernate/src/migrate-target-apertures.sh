#! /bin/bash
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
#
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#

# Update the PA_APERTURE table in the database. See KSOC-4218.

# configure kepler.properties and squirrel
# change default log level to WARN

# Configuration based on command line args.
PROG=${0##*/}
USAGE="Usage: ${PROG} [-dnpq] [-D <database>] <command> [<args>]

Where
	add		Add the new target table column to the PA_APERTURE table.
	alter		Alter the new column in the PA_APERTURE table
			marking it 'not null.'
	caadenceType	Either 'long' or 'short'.
	check		Check if the new column in the PA_APERTURE table
			contains any zero (null) values.
	command		One of: add, ids, tables, update, check, or alter.
	-D database	Either 'hsqldb' or 'oracle' (default is 'oracle').
	-d		Enable debugging.
	endCadence	An integer >= startCadence.
	ids [<cadenceType>]
			List of the externalIds.
	-n		No exec the commands, just display them..
	-q		Run quietly.
	startCadence	An integer >= 0.
	externalId	External id of a uplinked target table.
	tables <cadenceType> [<externalId>]
			List the externalIds and their associated cadence type,
			start cadence, and end cadence.
	update <cadenceType> { <startCadence> <endCadence> | <externalId> }
			Update the PA_APERTURE table setting the new column value
			optionally using the specified cadence-tuple [cadenceType,
			startCadence,endCadence], or pair [cadenceType,externalId]."

export TMP_PREFIX="/tmp/$(id -un)-${PROG}"

cleanup () {
    if [ "${1}" ]
    then
        if [ "${DEBUG+yes}" != yes ]
        then
            rm -f "${@}"
        fi
    elif [ "${DEBUG+yes}" != yes -a ! -z "${TMP_PREFIX}" ]
    then
        rm -f ${TMP_PREFIX}*
    fi
    unset TMP_PREFIX
}

set_cadence_type () {
    CADENCE_TYPE_STR=$(echo "${CADENCE_TYPE_STR:-${1}}" | tr '[:lower:]' '[:upper:]')
    case "${CADENCE_TYPE_STR}" in 
    LONG)
        export CADENCE_TYPE=2 
        export TARGET_TYPE=1
        export TARGET_TABLE_COLUMN=LC_TARGET_TABLE_ID
        ;;
    SHORT)
        export CADENCE_TYPE=1 
        export TARGET_TYPE=2
        export TARGET_TABLE_COLUMN=SC_TARGET_TABLE_ID
        ;;
    *)
        echo "${CADENCE_TYPE_STR}: unrecognized cadenceType, must be either 'long' or 'short'" >&2
        echo "${USAGE}" >&2
        EXITSTATUS=1 ; exit ;;
    esac
    export STATE=3 # UPLINKED
}

set_cadences_from_args () {
    export START_CADENCE=$(echo "${1}" | sed -e 's/^[^0-9]*\([0-9]*\).*$/\1/' | head -1)
    if [ ! "${START_CADENCE}" -ge 0 ]
    then
        echo "${2}: unrecognized startCadence, must be an integer greater than 0" >&2
        echo "${USAGE}" >&2
        EXITSTATUS=1 ; exit
    fi

    export END_CADENCE=$(echo "${2}" | sed -e 's/^[^0-9]*\([0-9]*\).*$/\1/' | head -1)
    if [ ! "${END_CADENCE}" -ge "${START_CADENCE}" ]
    then
        echo "${3}: unrecognized endCadence, must be an integer greater than startCadence" >&2
        echo "${USAGE}" >&2
        EXITSTATUS=1 ; exit
    fi
}

set_cadences_from_id () {
    CADENCES_SQL="SELECT MIN(CADENCE_NUMBER), MAX(CADENCE_NUMBER) FROM DR_PIXEL_LOG WHERE ${TARGET_TABLE_COLUMN} = ${1} and CADENCE_TYPE = ${CADENCE_TYPE};"

    echo "${CADENCES_SQL}" > ${CADENCES}
    ${QUIET+:} cat ${CADENCES}
    CADENCES_STR=$(echo "runjava ${LOG4J} execsql ${CADENCES}" | EXEC= QUIET= exec_cmds)
    eval $(echo "${CADENCES_STR}" \
    | awk -F, '{printf "export START_CADENCE=%d ;\nexport END_CADENCE=%d ;\n", $1, $2}')

    case "${START_CADENCE}" in
    ''|'null') unset START_CADENCE ;;
    esac

    case "${END_CADENCE}" in
    ''|'null') unset END_CADENCE ;;
    esac
}

EXITSTATUS=0
trap 'cleanup; exit ${EXITSTATUS}' 0
trap 'echo "${PROG}: aborting ..." 1>&2; exit' 1 2 3 15

EXEC=
unset ERRS DEBUG QUIET EXTERNAL_ID DATABASE TAD_TARGET_TABLE_ID
while getopts "D:dnq" ARG
do
    case "${ARG}" in
    D)  DATABASE=$(echo "${DATABASE:-${OPTARG}}" | tr '[:lower:]' '[:upper:]') ;;
    d)  DEBUG= ; unset QUIET ;;
    n)  unset EXEC ; unset QUIET ;;
    q)  QUIET= ;;
    \?) ERRS=  ;;
    esac
done
shift $((${OPTIND} - 1))

DATABASE=${DATABASE:-ORACLE}
case "${DATABASE}" in
HSQLDB)
    BIG_INT='BIGINT'
    NOT_DEFERRABLE='' ;;
ORACLE)
    BIG_INT='NUMBER(19,0)'
    NOT_DEFERRABLE='NOT DEFERRABLE ENABLE' ;;
*)
    echo "${DATABASE}: invalid database, must be either 'hsqldb' or 'oracle'" >&2
    echo "${USAGE}" >&2
    EXITSTATUS=1 ; exit ;;
esac

case "${#}" in
0)  echo "${USAGE}"
    EXITSTATUS=0 ; exit ;;
1)
    export COMMAND=$(echo "${COMMAND:-${1}}" | tr '[:lower:]' '[:upper:]')

    case "${COMMAND}" in
    ADD|ALTER|CHECK|IDS)
        ;;
    *)
        echo "too few command line args" >&2
        echo "${USAGE}" >&2
        EXITSTATUS=1 ; exit
        ;;
    esac
    ;;
2)
    export COMMAND=$(echo "${COMMAND:-${1}}" | tr '[:lower:]' '[:upper:]')

    set_cadence_type "${2}"
    ;;
3)  
    export COMMAND=$(echo "${COMMAND:-${1}}" | tr '[:lower:]' '[:upper:]')

    set_cadence_type "${2}"

    case "${COMMAND}" in
    UPDATE)
        if [ "${3}" = "all" ]
        then
             COMMAND=UPDATE_ALL
        else
            export EXTERNAL_ID="${EXTERNAL_ID:-${3}}"
        fi
        ;;
    TABLES)
        export EXTERNAL_ID="${EXTERNAL_ID:-${3}}"
        ;;
    *)
        echo "${3}: unrecognized command line arg" >&2
        echo "${USAGE}" >&2
        EXITSTATUS=1 ; exit
        ;;
    esac
    ;;
4)  
    export COMMAND=$(echo "${COMMAND:-${1}}" | tr '[:lower:]' '[:upper:]')

    set_cadence_type "${2}"

    set_cadences_from_args "${3}" "${4}"
    ;;
*)  echo "too many command line args" >&2
    echo "${USAGE}" >&2
    EXITSTATUS=1 ; exit ;;
esac

# Create temporary files.
TARGET_TABLE=$(mktemp ${TMP_PREFIX}.XXXXXX)
ADD=$(mktemp ${TMP_PREFIX}.XXXXXX)
EXTERNAL_IDS=$(mktemp ${TMP_PREFIX}.XXXXXX)
EXTERNAL_IDS_SORT=$(mktemp ${TMP_PREFIX}.XXXXXX)
EXTERNAL_IDS_LIST=$(mktemp ${TMP_PREFIX}.XXXXXX)
END_CADENCE_SET=$(mktemp ${TMP_PREFIX}.XXXXXX)
START_CADENCE_SET=$(mktemp ${TMP_PREFIX}.XXXXXX)
CADENCES=$(mktemp ${TMP_PREFIX}.XXXXXX)
TAD_IDS=$(mktemp ${TMP_PREFIX}.XXXXXX)
UPDATE=$(mktemp ${TMP_PREFIX}.XXXXXX)
UPDATE_ALL=$(mktemp ${TMP_PREFIX}.XXXXXX)
CHECK=$(mktemp ${TMP_PREFIX}.XXXXXX)
ALTER=$(mktemp ${TMP_PREFIX}.XXXXXX)

# Read commands from STDIN and execute them.
exec_cmds () {
    while read CMD
    do
        CMD=$(eval echo "${CMD}")
        ${QUIET+${EXEC+:}} echo "# ${CMD}"
        if ${EXEC-:} eval "${CMD}"
        then :
        else
            EXITSTATUS=$?
            printf "%s: failed, exiting\n" "${CMD}" >&2
        fi
    done
    return $EXITSTATUS
}

# Set the value of NULL_COUNT.
set_null_count () {
    CHECK_SQL="SELECT COUNT(*) FROM PA_APERTURE WHERE TAD_TARGET_TABLE_ID = 0 ;"

    echo "${CHECK_SQL}" > ${CHECK}
    ${QUIET+:} cat ${CHECK}
    export NULL_COUNT=$(echo "runjava ${LOG4J} execsql ${CHECK}" | EXEC= QUIET= exec_cmds)
    if [ $? -ne 0 ]
    then
        echo "ERROR: ${NULL_COUNT}" >&2
        EXITSTATUS=2 ; exit
    fi
    if [ -z "${NULL_COUNT}" ]
    then
        echo "ERROR: could not determmine the number of NULL target table entries in PA_APERTURE table." >&2
        EXITSTATUS=2 ; exit
    fi
}

# Set the value of EXTERNAL_ID.
set_external_id () {
    if [ ! "$ EXTERNAL_ID+yes}" = "yes" ]
    then
        TARGET_TABLE_SQL="SELECT DISTINCT(${TARGET_TABLE_COLUMN}) FROM DR_PIXEL_LOG WHERE CADENCE_NUMBER <= ${END_CADENCE} AND CADENCE_NUMBER >= ${START_CADENCE} AND CADENCE_TYPE = ${CADENCE_TYPE} ;"

        echo "${TARGET_TABLE_SQL}" > ${TARGET_TABLE}
        ${QUIET+:} cat ${TARGET_TABLE}
        export EXTERNAL_ID=$(echo "runjava ${LOG4J} execsql ${TARGET_TABLE}" | EXEC= QUIET= exec_cmds)
        if [ -z "${EXTERNAL_ID}" ]
        then
            echo "ERROR: could not determmine the external target table id from the given cadenceType(${CADENCE_TYPE}), startCadence(${START_CADENCE}), and endCadence(${END_CADENCE})." >&2
            EXITSTATUS=2 ; exit
        fi
    fi
}

# List all the EXTERNAL_IDs given a CADENCE_TYPE.
get_external_ids () {
    EXTERNAL_IDS_LIST_SQL="SELECT DISTINCT(EXTERNAL_ID) FROM TAD_TARGET_TABLE WHERE STATE = ${STATE} AND TYPE = ${TARGET_TYPE} ORDER BY EXTERNAL_ID;"

    echo "${EXTERNAL_IDS_LIST_SQL}" > ${EXTERNAL_IDS_LIST}
    ${QUIET+:} cat ${EXTERNAL_IDS_LIST}
    echo "runjava ${LOG4J} execsql ${EXTERNAL_IDS_LIST}" | EXEC= QUIET= exec_cmds
}

# Along with the EXTERNAL_ID list the CADENCE_TYPE, START_CADENCE, and END_CADENCE.
get_table_long_format () {
    if [ -z "${CADENCE_TYPE}" ]
    then
        echo "ERROR: missing cadenceType is required." >&2
        EXITSTATUS=2 ; exit
    elif [ -z "${1}" ] 
    then
        echo "ERROR: missing externalId is required." >&2
        EXITSTATUS=2 ; exit
    fi

    START_CADENCE_SQL="SELECT MIN(CADENCE_NUMBER) FROM DR_PIXEL_LOG WHERE CADENCE_TYPE = ${CADENCE_TYPE} AND ${TARGET_TABLE_COLUMN} = ${1} ORDER BY CADENCE_NUMBER;"
    echo "${START_CADENCE_SQL}" > ${START_CADENCE_SET}
    ${QUIET+:} cat ${START_CADENCE_SET}
    export START_CADENCE=$(echo "runjava ${LOG4J} execsql ${START_CADENCE_SET}" | EXEC= QUIET= exec_cmds | head -1)

    END_CADENCE_SQL="SELECT MAX(CADENCE_NUMBER) FROM DR_PIXEL_LOG WHERE CADENCE_TYPE = ${CADENCE_TYPE} AND ${TARGET_TABLE_COLUMN} = ${1} ORDER BY CADENCE_NUMBER;"
    echo "${END_CADENCE_SQL}" > ${END_CADENCE_SET}
    ${QUIET+:} cat ${END_CADENCE_SET}
    export END_CADENCE=$(echo "runjava ${LOG4J} execsql ${END_CADENCE_SET}" | EXEC= QUIET= exec_cmds | head -1)

    case "${START_CADENCE}" in
    ''|'null') unset START_CADENCE ;;
    esac

    case "${END_CADENCE}" in
    ''|'null') unset END_CADENCE ;;
    esac
    
    if [ ! -z "${START_CADENCE}" -a ! -z "${END_CADENCE}" ]
    then
        printf "%s,%s,%s,%s\n" "${1}" "${CADENCE_TYPE}" "${START_CADENCE}" "${END_CADENCE}"
    fi
}

tables () {
    if [ "${EXTERNAL_ID+yes}" = "yes" ]
    then
        EXTERNAL_IDS="${EXTERNAL_ID}"
    else
        EXTERNAL_IDS="$(EXEC= QUIET= get_external_ids)"
    fi
    for EXTERNAL_ID in $(echo "${EXTERNAL_IDS}")
    do
        QUIET= get_table_long_format "${EXTERNAL_ID}"
    done
}

# Set the value of TAD_TARGET_TABLE_ID.
set_target_table_id () {
    TAD_TARGET_TABLE_ID_SQL="SELECT ID FROM TAD_TARGET_TABLE WHERE EXTERNAL_ID = ${1} AND STATE = ${STATE} AND TYPE = ${TARGET_TYPE} ;"

    echo "${TAD_TARGET_TABLE_ID_SQL}" > ${TAD_IDS}
    ${QUIET+:} cat ${TAD_IDS}
    export TAD_TARGET_TABLE_ID=$(echo "runjava ${LOG4J} execsql ${TAD_IDS}" | EXEC= QUIET= exec_cmds)
}

# Process the command.
case "${COMMAND}" in
ADD)
    ADD_SQL="ALTER TABLE PA_APERTURE ADD TAD_TARGET_TABLE_ID ${BIG_INT} DEFAULT 0.0 ;
ALTER TABLE PA_APERTURE ADD CONSTRAINT FKF60B121E3F3CFA1E FOREIGN KEY (TAD_TARGET_TABLE_ID) REFERENCES TAD_TARGET_TABLE (ID) ${NOT_DEFERRABLE} ;"

    echo "${ADD_SQL}" > ${ADD}
    ${QUIET+:} cat ${ADD}
    echo "runjava ${LOG4J} execsql ${ADD}" | exec_cmds
    ;;
IDS)
    if [ "${CADENCE_TYPE+yes}" = "yes" ]
    then
        get_external_ids
    elif (set_cadence_type LONG ; EXEC= QUIET= get_external_ids > ${EXTERNAL_IDS_SORT})
    then
        if (set_cadence_type SHORT ; EXEC= QUIET= get_external_ids >> ${EXTERNAL_IDS_SORT})
        then
            cat "${EXTERNAL_IDS_SORT}" | sort -n -u
        else
            echo "ERROR: cannot determine the externalIds for CandenceType.SHORT." >&2
            EXITSTATUS=2 ; exit
        fi
    else
        echo "ERROR: cannot determine the externalIds for CandenceType.LONG." >&2
        EXITSTATUS=2 ; exit
    fi
    ;;
TABLES)
    tables
    ;;
UPDATE)
    if [ "${EXTERNAL_ID+yes}" = "yes" ]
    then
        EXTERNAL_IDS="${EXTERNAL_ID}"
    elif [ "${START_CADENCE+yes}" = "yes" -a "${END_CADENCE+yes}" = "yes" ]
    then
	EXTERNAL_IDS_LIST_SQL="SELECT DISTINCT(${TARGET_TABLE_COLUMN}) FROM DR_PIXEL_LOG WHERE CADENCE_NUMBER <= ${END_CADENCE} AND CADENCE_NUMBER >= ${START_CADENCE} AND CADENCE_TYPE = ${CADENCE_TYPE} ORDER BY ${TARGET_TABLE_COLUMN} ;"

	echo "${EXTERNAL_IDS_LIST_SQL}" > ${EXTERNAL_IDS_LIST}
        ${QUIET+:} cat ${EXTERNAL_IDS_LIST}

        EXTERNAL_IDS=$(echo "runjava ${LOG4J} execsql ${EXTERNAL_IDS_LIST}" | EXEC= QUIET= exec_cmds)
    else
        echo "ERROR: either specify the startCadence and endCadence or the externalId." >&2
        echo "${USAGE}" >&2
        EXITSTATUS=2 ; exit
    fi

    for EXTERNAL_ID in $(echo "${EXTERNAL_IDS}")
    do
        set_cadences_from_id "${EXTERNAL_ID}"
        set_target_table_id "${EXTERNAL_ID}"
	if [ ! -z "${TAD_TARGET_TABLE_ID}" -a ! -z "${START_CADENCE}" -a ! -z "${END_CADENCE}" ]
	then
            UPDATE_SQL="UPDATE PA_APERTURE SET TAD_TARGET_TABLE_ID = ${TAD_TARGET_TABLE_ID} WHERE CADENCE_TYPE = ${CADENCE_TYPE} AND START_CADENCE <= ${END_CADENCE} AND END_CADENCE >= ${START_CADENCE} ;"
            echo "${UPDATE_SQL}" >> ${UPDATE}
        fi
    done
    ${QUIET+:} cat ${UPDATE}
    echo "runjava ${LOG4J} execsql ${UPDATE}" | exec_cmds
    ;;
UPDATE_ALL)
    tables  \
    | tr ',' ' ' \
    | while read EXTERNAL_ID CADENCE_TYPE START_CADENCE END_CADENCE COMMENT
    do
        export CADENCE_TYPE START_CADENCE END_CADENCE
        QUIET= set_target_table_id "${EXTERNAL_ID}"
	if [ ! -z "${TAD_TARGET_TABLE_ID}" -a ! -z "${START_CADENCE}" -a ! -z "${END_CADENCE}" ]
	then
            UPDATE_ALL_SQL="UPDATE PA_APERTURE SET TAD_TARGET_TABLE_ID = ${TAD_TARGET_TABLE_ID} WHERE CADENCE_TYPE = ${CADENCE_TYPE} AND START_CADENCE <= ${END_CADENCE} AND END_CADENCE >= ${START_CADENCE} ;"
            echo "${UPDATE_ALL_SQL}" >> ${UPDATE_ALL}
        fi
    done

    ${QUIET+:} cat ${UPDATE_ALL}
    echo "runjava ${LOG4J} execsql ${UPDATE_ALL}" | exec_cmds
    ;;
CHECK)
    set_null_count
    echo "${NULL_COUNT}: rows in PA_APERTURE table with the value zero for the TAD_TARGET_TABLE_ID column."
    ;;
ALTER)
    set_null_count
    if [ "${NULL_COUNT}" -gt 0 ]
    then
        echo "${NULL_COUNT}: rows in PA_APERTURE table with the value zero for the TAD_TARGET_TABLE_ID column."
        EXITSTATUS=2 ; exit
    fi

    ALTER_SQL="ALTER TABLE PA_APERTURE DROP COLUMN CADENCE_TYPE ;
ALTER TABLE PA_APERTURE DROP COLUMN END_CADENCE ;
ALTER TABLE PA_APERTURE DROP COLUMN START_CADENCE ;
ALTER TABLE PA_APERTURE MODIFY (TAD_TARGET_TABLE_ID NOT NULL) ;"

    echo "${ALTER_SQL}" > ${ALTER}
    ${QUIET+:} cat ${ALTER}
    echo "runjava ${LOG4J} execsql ${ALTER}" | exec_cmds
    ;;
*)
    echo "ERROR: ${COMMAND}: unrecognized command" >&2
    echo "${USAGE}" >&2
    EXITSTATUS=2 ; exit
    ;;
esac

unset DEBUG EXEC QUIET DATABASE
unset CADENCE_TYPE START_CADENCE END_CADENCE STATE TARGET_TYPE TARGET_TABLE_COLUMN
unset COMMAND NULL_COUNT EXTERNAL_ID TAD_TARGET_TABLE_ID
