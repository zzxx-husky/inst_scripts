script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PHMAP_VERSION=1.33
DIR="${script_dir}"
INSTRC=${script_dir}/instrc.sh

source ${script_dir}/utils.sh
checktool git

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      GTEST_VERSION="${key#*=}" ;;
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

if [ ! -d ./parallel-hashmap-${PHMAP_VERSION} ]; then
  git clone --depth 1 http://github.com/greg7mdp/parallel-hashmap --branch ${PHMAP_VERSION} parallel-hashmap-${PHMAP_VERSION}
fi

if [ -z "$(cat ${INSTRC} | grep "^export PHMAP_ROOT=")" ]; then
  echo "export PHMAP_ROOT=$(pwd)/parallel-hashmap-${PHMAP_VERSION}" >> ${INSTRC}
  echo "export CMAKE_PREFIX_PATH=\${PHMAP_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC}
fi

echo "parallel-hashmap (${PHMAP_VERSION}) is installed under $(pwd)/parallel-hashmap-${PHMAP_VERSION}"
