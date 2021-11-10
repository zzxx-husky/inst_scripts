script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

RDKAFKA_VERSION=v1.8.2
DIR="${script_dir}"
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      RDKAFKA_VERSION="${key#*=}" ;;
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

if [ ! -d ./librdkafka-${RDKAFKA_VERSION}/install ]; then
  if [ ! -d ./librdkafka-${RDKAFKA_VERSION} ]; then
    git clone --depth 1 http://github.com/edenhill/librdkafka --branch ${RDKAFKA_VERSION} librdkafka-${RDKAFKA_VERSION}
  fi
  cd librdkafka-${RDKAFKA_VERSION}
  ./configure\
    --prefix=$(pwd)/install\
    --disable-sasl\
    --disable-ssl\
    && make -j4\
    && make install\
    || { exit 1; }
  cd ..
fi
if [ -z "$(cat ${INSTRC} | grep RDKAFKA_ROOT)" ]; then
  echo "export RDKAFKA_ROOT=$(pwd)/librdkafka-${RDKAFKA_VERSION}/install" >> ${INSTRC}
  echo "export LD_LIBRARY_PATH=\${RDKAFKA_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${RDKAFKA_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "RdKafka (${RDKAFKA_VERSION}) is installed under $(pwd)/librdkafka-${RDKAFKA_VERSION}"
