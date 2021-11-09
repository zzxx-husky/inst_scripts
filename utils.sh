function checktool {
  while [[ $# -gt 0 ]]; do
    if [ -z "$(which $1)" ]; then
      echo "Tool $1 not found. Please check if $1 is installed."
      exit 1
    else
      shift
    fi
  done
}
