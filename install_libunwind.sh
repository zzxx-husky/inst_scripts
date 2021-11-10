script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UNWIND_VERSION=v1.6-stable
DIR="${script_dir}"
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git make autoreconf

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      CMAKE_VERSION="${key#*=}" ;;
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

if [ ! -d ./libunwind-${UNWIND_VERSION}/install ]; then
  if [ ! -d ./libunwind-${UNWIND_VERSION} ]; then
    git clone --depth 1 https://github.com/libunwind/libunwind --branch ${UNWIND_VERSION} libunwind-${UNWIND_VERSION}
  fi
  cd libunwind-${UNWIND_VERSION}
  autoreconf -i\
    && ./configure --prefix=$(pwd)/install\
    && make -j4\
    && make install prefix=$(pwd)/install\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ${INSTRC} | grep "^export LIBUNWIND_ROOT=")" ]; then
  echo "export LIBUNWIND_ROOT=$(pwd)/libunwind-${UNWIND_VERSION}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${LIBUNWIND_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${LIBUNWIND_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "Libunwind (${UNWIND_VERSION}) is installed under $(pwd)/libunwind-${UNWIND_VERSION}"
