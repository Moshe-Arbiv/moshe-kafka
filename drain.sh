function drain_broker_cycle {
    broker_id="$1"
    max_partition_movment="$2"
    /usr/local/bin/kafka-cluster-manager \
    --cluster-type generic \
    --cluster-name this_cluster \
    --apply --no-confirm decommission $broker_id \
    --max-partition-movements $max_partition_movment 2>/dev/null

    status=$?
    return $status
}

function check_remaining_partitions {
    broker_id="$1"
    partitions_left_to_migrate=$(/usr/local/bin/kafka-cluster-manager \
                                --cluster-type generic \
                                --cluster-name this_cluster stats 2>/dev/null| sed -n '/ Partition Count/,/^$/p' |awk "/^$broker_id /" | awk '{print $3}')

  echo $partitions_left_to_migrate

}

function drain {
    broker=$1
    partitions=$2
    echo "Drain Kafka partitions from ${HOSTNAME} on ${broker}"
    if [[ "$partitions" -eq "" ]]
    then
      partitions=5
    fi

    echo $partitions > /tmp/max-partition-movment

    total_partitions=$(check_remaining_partitions $broker)
    partitions_left_to_migrate=$(check_remaining_partitions $broker)
    
    COUNTER=0
    echo $partitions_left_to_migrate
    while [ $partitions_left_to_migrate -ne 0 ] ;do
            progress_bar $total_partitions $partitions_left_to_migrate "Drain"
            while active_task ;do
                sleep 1
            done

            # Check if max partition movement changed
            current_max_partitions=$(cat /tmp/max-partition-movment)
            drain_broker_cycle $broker $current_max_partitions
            if [[ $status -ne 0 ]]; then
              echo "Drain Command failed, try to run the following command manually and analyze the problem:
                          /usr/local/bin/kafka-cluster-manager \
                          --cluster-type generic \
                          --cluster-name this_cluster \
                          --apply --no-confirm decommission $broker_id \
                          --max-partition-movements $max_partition_movment "
              exit 1
            fi
            
            while active_task ;do
                sleep 2
            done

            partitions_left_to_migrate=$(check_remaining_partitions $broker)


        done
    #clear
    echo "There are 0 partitions on $broker ! Seemes like the Drain job for $broker was finished, $total_partitions partitions were drained"
    rm -f /tmp/max-partition-movment
}