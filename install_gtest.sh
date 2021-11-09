script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GTEST_VERSION=release-1.11.0
DIR="${script_dir}"

source utils.sh
checktool git cmake make 

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      GTEST_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

cd ${DIR}

if [ ! -d ./googletest-${GTEST_VERSION}/release ]; then
  if [ ! -d ./googletest-${GTEST_VERSION} ]; then
    git clone --depth 1 http://github.com/google/googletest --branch ${GTEST_VERSION} googletest-${GTEST_VERSION} || { exit 1; }
  fi
  cd googletest-${GTEST_VERSION}
  cmake -S . -B release\
    -DBUILD_GMOCK=OFF\
    -DCMAKE_BUILD_TYPE=Release\
    -DCMAKE_CXX_STANDARD=11\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    && cmake --build release --target install\
    || { exit 1; }
  cd ..
fi
if [ -z "$(cat ~/.bashrc | grep "^export GTEST_ROOT=")" ]; then
  echo "export GTEST_ROOT=$(pwd)/googletest-${GTEST_VERSION}/install/" >> ~/.bashrc
  echo "export LD_LIBRARY_PATH=\${GTEST_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ~/.bashrc
  echo "export CMAKE_PREFIX_PATH=\${GTEST_ROOT}:\${CMAKE_PREFIX_PATH}" >> ~/.bashrc
fi

echo "GoogleTest (${GTEST_VERSION}) is installed under $(pwd)/googletest-${GTEST_VERSION}"
