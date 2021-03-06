#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"

echo "========== preparing ${APP} data =========="

# paths check
${RM} -r ${INPUT_HDFS}

# generate data
START_TS=`get_start_ts`;

setup


JAR="${DIR}/target/TerasortApp-1.0-jar-with-dependencies.jar"
CLASS="src.main.scala.terasortDataGen"
OPTION=" ${NUM_OF_RECORDS} ${INOUT_SCHEME}${INPUT_HDFS}"
START_TIME=`timestamp`
Addition_jar="--jars ${DIR}/target/jars/guava-19.0-rc2.jar"
exec ${SPARK_HOME}/bin/spark-submit --class $CLASS --master ${APP_MASTER} ${YARN_OPT} ${SPARK_OPT} ${Addition_jar} $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/${APP}_gendata_${START_TS}.dat
res=$?;

END_TIME=`timestamp`
SIZE=`${DU} -s ${INPUT_HDFS} | awk '{ print $1 }'`
get_config_fields >> ${BENCH_REPORT}
print_config  ${APP}-gen ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} ${res}>> ${BENCH_REPORT};
teardown
exit 0



