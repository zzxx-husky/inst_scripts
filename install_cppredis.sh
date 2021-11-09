script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CPPREDIS_VERSION=4.3.1
DIR="${script_dir}"

source ${script_dir}/utils.sh
checktool git cmake make

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--version="*)
      CPPREDIS_VERSION="${key#*=}" ;;
    "--dir="*)
      DIR="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

cd ${DIR}

if [ ! -d ./cpp_redis-${CPPREDIS_VERSION}/install ]; then
  if [ ! -d ./cpp_redis-${CPPREDIS_VERSION} ]; then
    git clone --depth 1 http://github.com/cpp-redis/cpp_redis --branch ${CPPREDIS_VERSION} cpp_redis-${CPPREDIS_VERSION}
  fi
  cd cpp_redis-${CPPREDIS_VERSION}

  # Get tacopie submodule
  git submodule init && git submodule update
  # Generate the Makefile using CMake
  cmake -S . -B release\
    -DCMAKE_BUILD_TYPE=Release\
    -DCMAKE_INSTALL_PREFIX=$(pwd)/install\
    && cmake --build release --target install -j4\
    || { exit 1; }
  cd ..
fi

if [ -z "$(cat ~/.bashrc | grep "^export CPPREDIS_ROOT=")" ]; then
  echo "export CPPREDIS_ROOT=$(pwd)/cpp_redis-${CPPREDIS_VERSION}/install" >> ~/.bashrc
  echo "export LD_LIBRARY_PATH=\${CPPREDIS_ROOT}/lib:\${LD_LIBRARY_PATH}" >> ~/.bashrc
  echo "export CMAKE_PREFIX_PATH=\${CPPREDIS_ROOT}:\${CMAKE_PREFIX_PATH}" >> ~/.bashrc
  source ~/.bashrc
fi

echo "CPPRedis (${CPPREDIS_VERSION}) is installed under $(pwd)/cpp_redis-${CPPREDIS_VERSION}"
