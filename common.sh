#!/bin/sh

usage() {
  cat << EOF

Usage: $0 -o {centos6|centos7} -v x.y.z

EOF
  exit 0


}



if [ "$#" -eq 0 ]; then
  usage;
fi

while getopts "h:o:v:" optname; do
  case "$optname" in
    "h")
      usage
      ;;
    "o")
      export OS="$OPTARG"
      ;;
    "v") 
      export HADOOP_VERSION=$OPTARG
      ;;
    "?")
      usage;
      exit 1;
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside $0"
      exit 1;
      ;;
  esac
done

[ "$OS" == "" ] && usage
[ "${HADOOP_VERSION}" == "" ] && usage
