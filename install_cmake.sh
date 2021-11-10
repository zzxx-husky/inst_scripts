script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CMAKE_VERSION=v3.21.4
DIR="${script_dir}"

source ${script_dir}/utils.sh
checktool git make

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      CMAKE_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

cd ${DIR}

if [ ! -d ./cmake-${CMAKE_VERSION} ]; then
  git clone --depth 1 http://github.com/Kitware/CMake --branch ${CMAKE_VERSION} cmake-${CMAKE_VERSION}
fi

cd cmake-${CMAKE_VERSION}
./bootstrap\
  --prefix=$(pwd)/install\
  && make -j4\
  && make install\
  || { exit 1; }
cd ..

echo "CMake (${CMAKE_VERSION}) is installed under $(pwd)/cmake-${CMAKE_VERSION}/install. Consider to add the followings commands to use the new CMake and remove the old one:"
echo "  export CMAKE_ROOT=$(pwd)/cmake-${CMAKE_VERSION}/install"
echo "  export PATH=\\\${CMAKE_ROOT}/bin:\\\${PATH}"
