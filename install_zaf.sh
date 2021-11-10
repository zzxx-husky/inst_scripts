script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ZAF_VERSION=master
DIR="${script_dir}"
DEPS_ONLY=false
WITHOUT_BOOST=false
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
    "--without-boost")
      WITHOUT_BOOST=true ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

for i in gtest glog zmq phmap; do
  if ! bash ${script_dir}/install_${i}.sh --dir=${DIR} --instrc=${INSTRC}; then
    exit 1;
  fi
done

if [ ! ${WITHOUT_BOOST} ]; then
  bash ${script_dir}/install_boost.sh\
    --dir=${DIR}\
    --with-python=$(which python3)\
    --instrc=${INSTRC}\
    || { exit 1; }
fi

if [ "${DEPS_ONLY}" = true ]; then
  exit 0;
fi

source ${script_dir}/utils.sh
checktool git cmake make || { exit 1; }

cd ${DIR}

if [ ! -d ./zaf-${ZAF_VERSION}/install ]; then
  if [ ! -d ./zaf-${ZAF_VERSION} ]; then
    git clone --depth 1 --branch ${ZAF_VERSION} http://github.com/zzxx-husky/zaf zaf-${ZAF_VERSION}
  fi
  cd zaf-${ZAF_VERSION}
  source ${INSTRC}
  cmake -S . -B release\
    -DCMAKE_BUILD_TYPE=Release\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    && cmake --build release --target install -j4\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ${INSTRC} | grep "^export ZAF_ROOT=")" ]; then
  echo "export ZAF_ROOT=$(pwd)/zaf-${ZAF_VERSION}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${ZAF_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${ZAF_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "ZAF (${ZAF_VERSION}) is installed under $(pwd)/zaf-${ZAF_VERSION}"
