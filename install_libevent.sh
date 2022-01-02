script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LIBEVENT_VERSION=release-2.1.12-stable
DIR="${script_dir}"
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git make cmake

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      LIBEVENT_VERSION="${key#*=}" ;;
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

if [ ! -d ./libevent-${LIBEVENT_VERSION}/install ]; then
  if [ ! -d ./libevent-${LIBEVENT_VERSION} ]; then
    git clone --depth 1 https://github.com/libevent/libevent --branch ${LIBEVENT_VERSION} libevent-${LIBEVENT_VERSION}
  fi
  cd libevent-${LIBEVENT_VERSION}
  cmake -S . -B release\
    -DCMAKE_BUILD_TYPE=Release\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    && cmake --build release --target install -j4\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ${INSTRC} | grep "^export LIBEVENT_ROOT=")" ]; then
  echo "export LIBEVENT_ROOT=$(pwd)/libevent-${LIBEVENT_VERSION}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${LIBEVENT_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${LIBEVENT_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "Libevent (${LIBEVENT_VERSION}) is installed under $(pwd)/libevent-${LIBEVENT_VERSION}"
