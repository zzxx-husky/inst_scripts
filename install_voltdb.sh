script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VOLTDB_VERSION=master
DIR="${script_dir}"
INSTRC="${script_dir}/instrc.sh"

source ${script_dir}/utils.sh
checktool git make

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      VOLTDB_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

${script_dir}/install_boost.sh --dir=${DIR}

cd ${DIR}

if [ ! -d ./voltdb-client-cpp-${VOLTDB_VERSION}/install ]; then
  if [ ! -d ./voltdb-client-cpp-${VOLTDB_VERSION} ]; then
    git clone --depth 1 http://github.com/VoltDB/voltdb-client-cpp --branch ${VOLTDB_VERSION} voltdb-client-cpp-${VOLTDB_VERSION}
  fi
  cd voltdb-client-cpp-${VOLTDB_VERSION}
  source ${INSTRC}
  if [ ! -z "$(cat ${INSTRC} | grep "^export BOOST_ROOT=")" ]; then
    boost_root=$(cat ${INSTRC} | grep "^export BOOST_ROOT=" | awk -F'=' '{print $2}')
    sed -i "s|BOOST_INCLUDES=.*|BOOST_INCLUDES=${boost_root}/include|" makefile || {
      echo sed -i "s|BOOST_INCLUDES=.*|BOOST_INCLUDES=${boost_root}/include|" makefile;
      exit 1;
    }
    sed -i "s|BOOST_LIBS=.*|BOOST_LIBS=${boost_root}/lib|" makefile || {
      echo sed -i "s|BOOST_LIBS=.*|BOOST_LIBS=${boost_root}/lib|" makefile;
      exit 1;
    }
  fi
  if ! make -j4; then
    sed -i 's/static const double NULL_COORDINATE /static constexpr double NULL_COORDINATE /g' include/GeographyPoint.hpp
    make -j4 || { exit 1; }
  fi
  mv $(ls -td */ | grep voltdb-client-cpp | head -n 1) install;
  mkdir install/tmp
  mv install/include install/tmp
  mv install/tmp/include install/tmp/voltdb
  mv install/tmp install/include
  mkdir install/lib
  mv install/*.a install/lib
  mv install/*.so install/lib
  cd ..
fi
if [ -z "$(cat ${INSTRC} | grep "^export VOLTDB_ROOT=")" ]; then
  echo "export VOLTDB_ROOT=$(pwd)/voltdb-client-cpp-${VOLTDB_VERSION}/install" >> ${INSTRC};
  echo "export LD_LIBRARY_PATH=\${VOLTDB_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ${INSTRC};
  echo "export CMAKE_PREFIX_PATH=\${VOLTDB_ROOT}:\${CMAKE_PREFIX_PATH}" >> ${INSTRC};
fi

echo "Voltdb Client (${VOLTDB_VERSION}) is installed under $(pwd)/voltdb-client-cpp-${VOLTDB_VERSION}"
