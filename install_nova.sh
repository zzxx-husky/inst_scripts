script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DIR=$(pwd)
INSTRC=${script_dir}/instrc.sh

while [[ $# -gt 0 ]]; do
  key=$1
  shift
  case "${key}" in
    "--dir="*)
      DIR="${key#*=}" ;;
    "--instrc="*)
      INSTRC="${key#*=}" ;;
    *)
      echo "Unknow argument: ${key}"
      exit 1;;
  esac
done

for i in zaf boost gperftools coll gtest; do
  ${script_dir}/install_${i}.sh\
    --dir=${DIR}\
    --instrc=${INSTRC}
done
