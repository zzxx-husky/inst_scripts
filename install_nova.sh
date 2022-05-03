script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NOVA_VERSION=nova+
DIR=$(pwd)
INSTRC=${script_dir}/instrc.sh
DEPS_ONLY=false
ENABLE_REDIS=OFF
ENABLE_KAFKA=OFF
ENABLE_TESTS=ON
ENABLE_PROFILER=OFF
ENABLE_HEAP_PROFILER=OFF
ENABLE_FAULT_TOLERANCE=OFF
ENABLE_SQL=OFF
MODE=Release

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--deps-only")
      DEPS_ONLY=true ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    *"able-test")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_TESTS=ON; else ENABLE_TESTS=OFF; fi ;;
    *"able-redis")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_REDIS=ON; else ENABLE_REDIS=OFF; fi ;;
    *"able-kafka")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_KAFKA=ON; else ENABLE_KAFKA=OFF; fi ;;
    *"able-profiler")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_PROFILER=ON; else ENABLE_PROFILER=OFF; fi ;;
    *"able-heap-profiler")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_HEAP_PROFILER=ON; else ENABLE_HEAP_PROFILER=OFF; fi ;;
    *"able-fault-tolerance")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_FAULT_TOLERANCE=ON; else ENABLE_FAULT_TOLERANCE=OFF; fi ;;
    *"able-sql")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_SQL=ON; else ENABLE_SQL=OFF; fi ;;
    "--mode="*)
      MODE="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

for i in zaf boost gperftools coll gtest glog; do
  ${script_dir}/install_${i}.sh\
    --dir=${DIR}\
    --instrc=${INSTRC}
done

if [ "${ENABLE_REDIS}" = "ON" ]; then
  ${script_dir}/install_libevent.sh\
    --dir=${DIR}\
    --instrc=${INSTRC}

  ${script_dir}/install_hiredis.sh\
    --dir=${DIR}\
    --instrc=${INSTRC}
fi

if [ "${ENABLE_KAFKA}" = "ON" ]; then
  ${script_dir}/install_rdkafka.sh\
    --dir=${DIR}\
    --instrc=${INSTRC}
fi


if [ "${DEPS_ONLY}" = true ]; then
  exit 0;
fi

source ${script_dir}/utils.sh
checktool git cmake make || { exit 1; }

cd ${DIR}

if [ "${MODE}" = "Release" ]; then
  NOVA_DIR="nova-${NOVA_VERSION}"
else
  NOVA_DIR="nova-${NOVA_VERSION}-${MODE}"
fi

if [ ! -d ./${NOVA_DIR}/install ]; then
  if [ ! -d ./${NOVA_DIR} ]; then
    git clone --depth 1 --branch ${NOVA_VERSION} http://github.com/zzxx-husky/novax ${NOVA_DIR}
  fi
  cd ${NOVA_DIR}
  source ${INSTRC}
  cmake -S . -B ${MODE}\
    -DCMAKE_BUILD_TYPE=${MODE}\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    -DENABLE_TESTS=${ENABLE_TESTS}\
    -DENABLE_REDIS=${ENABLE_REDIS}\
    -DENABLE_KAFKA=${ENABLE_KAFKA}\
    -DENABLE_PROFILER=${ENABLE_PROFILER}\
    -DENABLE_HEAP_PROFILER=${ENABLE_HEAP_PROFILER}\
    -DENABLE_FAULT_TOLERANCE=${ENABLE_FAULT_TOLERANCE}\
    -DENABLE_SQL=${ENABLE_SQL}\
    && cmake --build ${MODE} --target install -j4\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ${INSTRC} | grep "^export NOVA_ROOT=")" ]; then
  echo "export NOVA_ROOT=$(pwd)/${NOVA_DIR}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${NOVA_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${NOVA_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "NOVA (${NOVA_VERSION}) is installed under $(pwd)/${NOVA_DIR}."
