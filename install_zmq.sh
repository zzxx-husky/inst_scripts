script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ZMQ_VERSION=v4.3.4
CPPZMQ_VERSION=v4.8.1
DIR="${script_dir}"
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git make cmake

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--zmq_version="*)
      ZMQ_VERSION="${key#*=}" ;;
    "--cppzmq_version="*)
      CPPZMQ_VERSION="${key#*=}" ;;
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

if [ ! -d ./libzmq-${ZMQ_VERSION}/install ]; then
  if [ ! -d ./libzmq-${ZMQ_VERSION} ]; then
    git clone --depth 1 http://github.com/zeromq/libzmq --branch ${ZMQ_VERSION} libzmq-${ZMQ_VERSION}
  fi
  cd libzmq-${ZMQ_VERSION}
  cmake -S . -B release\
    -DWITH_PERF_TOOL=OFF\
    -DZMQ_BUILD_TESTS=OFF\
    -DCMAKE_BUILD_TYPE=Release\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    && cmake --build release --target install -j4\
    || { exit 1; }
  cd ..
fi
if [ ! -d ./cppzmq-${CPPZMQ_VERSION} ]; then
  git clone --depth 1 http://github.com/zeromq/cppzmq --branch ${CPPZMQ_VERSION} cppzmq-${CPPZMQ_VERSION}
  cp cppzmq-${CPPZMQ_VERSION}/zmq.hpp libzmq-${ZMQ_VERSION}/install/include
  cp cppzmq-${CPPZMQ_VERSION}/zmq_addon.hpp libzmq-${ZMQ_VERSION}/install/include
fi

if [ -z "$(cat ${INSTRC} | grep "^export ZMQ_ROOT=")" ]; then
  echo "export ZMQ_ROOT=$(pwd)/libzmq-${ZMQ_VERSION}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${ZMQ_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${ZMQ_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "Libzmq (${ZMQ_VERSION}) is installed under $(pwd)/libzmq-${ZMQ_VERSION}"
echo "Cppzmq (${CPPZMQ_VERSION}) is installed under $(pwd)/cppzmq-${CPPZMQ_VERSION}"
