script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

COLL_VERSION=master
DIR="${script_dir}"
DEPS_ONLY=false
INSTRC=${script_dir}/instrc.sh

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--deps-only")
      DEPS_ONLY=true ;;
    "--version="*)
      COLL_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

bash ${script_dir}/install_zaf.sh --dir=${DIR} --instrc=${INSTRC} || { exit 1; }
bash ${script_dir}/install_gtest.sh --dir=${DIR} --instrc=${INSTRC} || { exit 1; }

if [ "${DEPS_ONLY}" = true ]; then
  exit 0;
fi

source ${script_dir}/utils.sh
checktool git || { exit 1; }

cd ${DIR}

if [ ! -d ./coll-${COLL_VERSION}/install ]; then
  if [ ! -d ./coll-${COLL_VERSION} ]; then
    git clone --depth 1 --branch ${COLL_VERSION} http://github.com/zzxx-husky/coll coll-${COLL_VERSION}
  fi
fi

if [ -z "$(cat ${INSTRC} | grep "^export COLL_ROOT=")" ]; then
  echo "export COLL_ROOT=$(pwd)/coll-${COLL_VERSION}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${COLL_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "COLL (${COLL_VERSION}) is installed under $(pwd)/coll-${COLL_VERSION}"

