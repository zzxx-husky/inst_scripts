script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GLOG_VERSION=v0.5.0
DIR="${script_dir}"
WITH_LIBUNWIND=false
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git make cmake

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      GTEST_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    "--with-libunwind")
      WITH_LIBUNWIND=true ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

if [ "${WITH_LIBUNWIND}" = true ]; then
  ${script_dir}/install_libunwind.sh --dir=${DIR}
  source ${INSTRC}
  WITH_LIBUNWIND=ON
else
  WITH_LIBUNWIND=OFF
fi

cd ${DIR}

if [ ! -d ./glog-${GLOG_VERSION}/install ]; then
  if [ ! -d ./glog-${GLOG_VERSION} ]; then
    git clone --depth 1 http://github.com/google/glog --branch ${GLOG_VERSION} glog-${GLOG_VERSION}
  fi
  cd glog-${GLOG_VERSION}
  cmake -S . -B release\
    -DWITH_UNWIND=${WITH_LIBUNWIND}\
    -DWITH_GFLAGS=OFF\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    -DCMAKE_BUILD_TYPE=Release\
    && cmake --build release --target install -j4\
    || { exit 1; }
  cd ..
fi
if [ -z "$(cat ${INSTRC} | grep "^export GLOG_ROOT=")" ]; then
  echo "export GLOG_ROOT=$(pwd)/glog-${GLOG_VERSION}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${GLOG_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${GLOG_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "GLOG (${GLOG_VERSION}) is installed under $(pwd)/glog-${GLOG_VERSION}"
