script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ZAF_VERSION=master
DIR="${script_dir}"
DEPS_ONLY=false
ENABLE_PYZAF=OFF
ENABLE_TEST=ON
ENABLE_PHMAP=ON
ENABLE_TCMALLOC=ON
MODE=Release
INSTRC=${script_dir}/instrc.sh

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--deps-only")
      DEPS_ONLY=true ;;
    "--version="*)
      ZAF_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    *"able-pyzaf")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_PYZAF=ON; else ENABLE_PYZAF=OFF; fi ;;
    *"able-test")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_TEST=ON; else ENABLE_TEST=OFF; fi ;;
    *"able-phmap")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_PHMAP=ON; else ENABLE_PHMAP=OFF; fi ;;
    *"able-tcmalloc")
      if [[ "${key}" =~ ^--en.* ]]; then ENABLE_TCMALLOC=ON; else ENABLE_TCMALLOC=OFF; fi ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    "--mode="*)
      MODE="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

for i in glog zmq; do
  if ! bash ${script_dir}/install_${i}.sh --dir=${DIR} --instrc=${INSTRC}; then
    exit 1;
  fi
done

func=(TEST PHMAP TCMALLOC)
libs=(gtest phmap gperftools)

for i in "${!func[@]}"; do
  ENABLE_FUNC=ENABLE_${func[${i}]}
  if [ "${!ENABLE_FUNC}" == ON ]; then
    bash ${script_dir}/install_${libs[${i}]}.sh --dir=${DIR} --instrc=${INSTRC} || { exit 1; }
  fi
done

if [ "${ENABLE_PYZAF}" == ON ]; then
  bash ${script_dir}/install_boost.sh --dir=${DIR} --instrc=${INSTRC}\
    --with-python=$(which python3) || { exit 1; }
fi

if [ "${DEPS_ONLY}" = true ]; then
  exit 0;
fi

source ${script_dir}/utils.sh
checktool git cmake make || { exit 1; }

cd ${DIR}

if [ "${MODE}" = "Release" ]; then
  ZAF_DIR="zaf-${ZAF_VERSION}"
else
  ZAF_DIR="zaf-${ZAF_VERSION}-${MODE}"
fi

if [ ! -d ./${ZAF_DIR}/install_dir ]; then
  if [ ! -d ./${ZAF_DIR} ]; then
    git clone --depth 1 --branch ${ZAF_VERSION} http://github.com/zzxx-husky/zaf ${ZAF_DIR}
  fi
  cd ${ZAF_DIR}
  source ${INSTRC}
  cmake -S . -B ${MODE}\
    -DCMAKE_BUILD_TYPE=${MODE}\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install_dir\
    -DENABLE_TEST=${ENABLE_TEST}\
    -DENABLE_PHMAP=${ENABLE_PHMAP}\
    -DENABLE_TCMALLOC=${ENABLE_TCMALLOC}\
    && cmake --build ${MODE} --target install -j4\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ${INSTRC} | grep "^export ZAF_ROOT=")" ]; then
  echo "export ZAF_ROOT=$(pwd)/${ZAF_DIR}/install_dir" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${ZAF_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export DYLD_LIBRARY_PATH=\${ZAF_ROOT}/lib:\${DYLD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${ZAF_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "ZAF (${ZAF_VERSION}) is installed under $(pwd)/${ZAF_DIR}."
