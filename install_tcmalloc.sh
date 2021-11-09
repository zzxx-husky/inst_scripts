script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${script_dir}/install_gperftools.sh $@

echo "TCMalloc (i.e., GperfTools) is installed."
