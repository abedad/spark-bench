#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"

echo "========== running ${APP} benchmark =========="


# path check

SIZE=`${DU} -s ${INPUT_HDFS} | awk '{ print $1 }'`

JAR="${DIR}/target/SVDPlusPlusApp-1.0.jar"
CLASS="src.main.scala.SVDPlusPlusApp"
OPTION="${INOUT_SCHEME}${INPUT_HDFS} ${INOUT_SCHEME}${OUTPUT_HDFS} ${NUM_OF_PARTITIONS} ${NUM_ITERATION} ${RANK} ${MINVAL} ${MAXVAL} ${GAMMA1} ${GAMMA2} ${GAMMA6} ${GAMMA7} ${STORAGE_LEVEL}"

echo "opt ${OPTION}"


setup
for((i=0;i<${NUM_TRIALS};i++)); do

    ${RM} -r ${OUTPUT_HDFS}
    purge_data "${MC_LIST}"	
    START_TS=`get_start_ts`;
    START_TIME=`timestamp`
    exec ${SPARK_HOME}/bin/spark-submit --class $CLASS --master ${APP_MASTER} ${YARN_OPT} ${SPARK_OPT} ${SPARK_RUN_OPT} $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/${APP}_run_${START_TS}.dat
    res=$?;
    END_TIME=`timestamp`
    get_config_fields >> ${BENCH_REPORT}
    print_config  ${APP} ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} ${res}>> ${BENCH_REPORT};
done
teardown
exit 0


