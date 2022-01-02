script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

HIREDIS_VERSION=v1.0.2
DIR="${script_dir}"
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git make cmake

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      HIREDIS_VERSION="${key#*=}" ;;
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

if [ ! -d ./hiredis-${HIREDIS_VERSION}/install ]; then
  if [ ! -d ./hiredis-${HIREDIS_VERSION} ]; then
    git clone --depth 1 https://github.com/redis/hiredis --branch ${HIREDIS_VERSION} hiredis-${HIREDIS_VERSION}
  fi
  cd hiredis-${HIREDIS_VERSION}
  cmake -S . -B release\
    -DCMAKE_BUILD_TYPE=Release\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    -DCMAKE_INSTALL_LIBDIR=$(pwd)/install/lib/\
    && cmake --build release --target install -j4\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ${INSTRC} | grep "^export HIREDIS_ROOT=")" ]; then
  echo "export HIREDIS_ROOT=$(pwd)/hiredis-${HIREDIS_VERSION}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${HIREDIS_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${HIREDIS_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "Hiredis (${HIREDIS_VERSION}) is installed under $(pwd)/hiredis-${HIREDIS_VERSION}"
