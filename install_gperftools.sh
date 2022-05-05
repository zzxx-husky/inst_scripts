script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GPERF_VERSION=gperftools-2.9.1
DIR="${script_dir}"
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git make

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      GPERF_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

cd ${DIR}

if [ ! -d ./gperftools-${GPERF_VERSION}/install_dir ]; then
  if [ ! -d ./gperftools-${GPERF_VERSION} ]; then
    git clone --depth 1 http://github.com/gperftools/gperftools --branch ${GPERF_VERSION} gperftools-${GPERF_VERSION}
  fi
  cd gperftools-${GPERF_VERSION}
  ./autogen.sh\
    && ./configure --prefix=$(pwd)/install_dir --enable-frame-pointers\
    && make -j4\
    && make install\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ${INSTRC} | grep "^export GPERF_ROOT=")" ]; then
  echo "export GPERF_ROOT=$(pwd)/gperftools-${GPERF_VERSION}/install_dir" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${GPERF_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export DYLD_LIBRARY_PATH=\${GPERF_ROOT}/lib:\${DYLD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${GPERF_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
  echo "export PATH=\${GPERF_ROOT}/bin:\${PATH}" >> ${INSTRC}
fi

echo "GperfTools (${GPERF_VERSION}) is installed under $(pwd)/gperftools-${GPERF_VERSION}"
