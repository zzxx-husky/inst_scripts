script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BOOST_VERSION=1.77.0
WITH_PYTHON= # empty to disable python
DIR="${script_dir}"

source utils.sh
checktool wget tar

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      BOOST_VERSION="${key#*=}" ;;
    "--with-python="*)
      WITH_PYTHON="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

cd ${DIR}

VER=$(echo ${BOOST_VERSION} | tr '.' '_')
if [ ! -z "${WITH_PYTHON}" ]; then
  WITH_PYTHON=" --with-python=${WITH_PYTHON} "
fi

if [ ! -d ./boost_${BOOST_VERSION}/install ]; then
  if [ ! -d ./boost_${BOOST_VERSION} ]; then
    wget http://boostorg.jfrog.io/artifactory/main/release/${BOOST_VERSION}/source/boost_${VER}.tar.gz || { exit 1; }
    tar xf boost_${VER}.tar.gz
    rm boost_${VER}.tar.gz
    mv boost_${VER} boost_${BOOST_VERSION}
  fi
  cd boost_${BOOST_VERSION}
  rm -rf $(pwd)/install/
  ./bootstrap.sh --prefix=$(pwd)/install/ ${WITH_PYTHON} || { exit 1; }
  ./b2 --clean
  ./b2 threading=multi cxxflags="-fPIC" link=shared variant=release install || { exit 1; }
  cd ..
fi

if [ -z "$(cat ~/.bashrc | grep "^export BOOST_ROOT=")" ]; then
  echo "export BOOST_ROOT=$(pwd)/boost_${BOOST_VERSION}/install" >> ~/.bashrc
  echo "export LD_LIBRARY_PATH=\${BOOST_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ~/.bashrc
  echo "export CMAKE_PREFIX_PATH=\${BOOST_ROOT}:\${CMAKE_PREFIX_PATH}" >> ~/.bashrc
fi

echo "Boost (${BOOST_VERSION}) is installed under $(pwd)/boost_${BOOST_VERSION}"
