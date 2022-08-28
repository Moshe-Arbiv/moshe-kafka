function active_task {
    /usr/local/bin/kafka-cluster-manager \
    --cluster-type generic \
    --cluster-name this_cluster \
    stats >/dev/null 2>/dev/null
    trigger=$?

    if [[ $trigger -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

function validate_args {
    if [ ! "$1" = "" ] 
    then
      return
    else
      echo "Missing argument, Broker_ID, Exiting."
      exit 1
    fi
}


function progress_bar {
    total=$1 
    current=$2 
    process=$3
    meta="$process: $1 / $2"
    precent=$(expr $current \* 100 / $total)
    hashes=$(expr $precent / 2)
    spaces=$(expr 50 - $hashes)
    hashtag=""
    space=""
    for i in $(seq 1 $hashes)
    do
        hashtag="#$hashtag"
    done

    for i in $(seq 1 $spaces)
    do
        space=" $space"
    done

    if [ $precent -eq 100 ]
    then
        space=""
    fi

    echo -ne "$meta |$hashtag$space|($precent%)\r"
}


function checkStatus {
  expect=250
  if [ $# -eq 3 ] ; then
    expect="${3}"
  fi
  if [ $1 -ne $expect ] ; then
    echo "Error: ${2}"
    exit
  fi
}

function clusterStatus {
      /usr/local/bin/kafka-cluster-manager \
      --cluster-type generic \
      --cluster-name this_cluster \
      stats
}
