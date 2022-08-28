function test_cluster_connection {
    echo "VALIDATE: CLUSTER CONNECTION..."
    /usr/local/bin/kafka-cluster-manager \
    --cluster-type generic \
    --cluster-name this_cluster \
    stats >/dev/null 2>/dev/null
    trigger=$?
    
    if [[ $trigger -eq 0 ]]; then
        echo "VALIDATE: SUCCESS"
    else
        echo "VALIDATE: FAILED"
        exit 1
    fi
}

function test_kafka_utils {
    echo "VALIDATE: kafka-utils Installed..."
    FILE=/usr/local/bin/kafka-cluster-manager
    if [[ ! -f "$FILE" ]]; then
      echo "VALIDATE: FAILED"
      exit 1
    else
      echo "VALIDATE: SUCCESS"
    fi
}

function test_process_running {
    echo "VALIDATE: no other kf process running..."
    if [ $(active_task) ]; then
      echo "VALIDATE: FAILED"
      exit 1 
    else
      echo "VALIDATE: SUCCESS"
    fi
}

function validations {
  # Validate kafka-utils installed
  test_kafka_utils
  # Check there isn't a process running
  test_process_running
  # Validate Cluster connection
  test_cluster_connection
}
