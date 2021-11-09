script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GPERF_VERSION=gperftools-2.9.1
DIR="${script_dir}"

source utils.sh
checktool git make

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      GPERF_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

cd ${DIR}

if [ ! -d ./gperftools-${GPERF_VERSION}/install ]; then
  if [ ! -d ./gperftools-${GPERF_VERSION} ]; then
    git clone --depth 1 http://github.com/gperftools/gperftools --branch ${GPERF_VERSION} gperftools-${GPERF_VERSION}
  fi
  cd gperftools-${GPERF_VERSION}
  ./autogen.sh\
    && ./configure --prefix=$(pwd)/install --enable-frame-pointers\
    && make -j4\
    && make install\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ~/.bashrc | grep "^export GPERF_ROOT=")" ]; then
  echo "export GPERF_ROOT=$(pwd)/gperftools-${GPERF_VERSION}/install" >> ~/.bashrc
  echo "export LD_LIBRARY_PATH=\${GPERF_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ~/.bashrc
  echo "export CMAKE_PREFIX_PATH=\${GPERF_ROOT}:\${CMAKE_PREFIX_PATH}" >> ~/.bashrc
  echo "export PATH=\${GPERF_ROOT}/bin:\${PATH}" >> ~/.bashrc
fi

echo "GperfTools (${GPERF_VERSION}) is installed under $(pwd)/gperftools-${GPERF_VERSION}"
