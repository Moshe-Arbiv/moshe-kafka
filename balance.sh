function check_unbalanced_partitions {
    partitions_left_to_migrate=$(/usr/local/bin/kafka-cluster-manager \
                                --cluster-type generic \
                                --cluster-name this_cluster stats 2>/dev/null| grep "Partition count imbalance" | awk 'NR==1{print $4}')
  echo $partitions_left_to_migrate

}

function rebalance_partitions {
    partitions=$1
    /usr/local/bin/kafka-cluster-manager --cluster-type generic \
                                         --cluster-name this_cluster \
                                         --apply --no-confirm rebalance \
                                         --replication-groups --brokers \
                                         --max-partition-movements $partitions 2>/dev/null
    status=$?
    return $status
}

function check_unbalanced_leaders {
    unbalanced_leaders=$(/usr/local/bin/kafka-cluster-manager \
                                --cluster-type generic \
                                --cluster-name this_cluster stats 2>/dev/null| grep "Leader count imbalance" | awk 'NR==1{print $4}')
  echo $unbalanced_leaders

}

function rebalance_leaders {
    leaders=$1
    /usr/local/bin/kafka-cluster-manager --cluster-type generic \
                                         --cluster-name this_cluster \
                                         --apply --no-confirm rebalance \
                                         --replication-groups --leaders \
                                         --max-leader-changes $leaders 2>/dev/null
    status=$?
    return $status
}

function balance_partitions {
    
    partitions=$1
    echo "Balance Kafka partitions on ${HOSTNAME}"
    if [[ "$partitions" -eq "" ]]
    then
        partitions=5
    fi
    
    echo $partitions > /tmp/max-partition-movment

    total_unbalance_partitions=$(check_unbalanced_partitions)

    unbalance_partitions=$total_unbalance_partitions

    while [ $unbalance_partitions -ne 0 ] ;do
        
        current_max_partitions=$(cat /tmp/max-partition-movment)
        progress_bar $total_unbalance_partitions $unbalance_partitions "Partition Balance"
        before=$(check_unbalanced_partitions)
        rebalance_partitions $current_max_partitions
        if [[ $status -ne 0 ]]; then
          echo "Balance Command failed, try to run the following command manually and analyze the problem:
                /usr/local/bin/kafka-cluster-manager --cluster-type generic \
                --cluster-name this_cluster \
                --apply --no-confirm rebalance \
                --replication-groups --brokers \
                --max-partition-movements $partitions"
          exit 1
        fi

        while active_task ;do
            sleep 1
        done
        sleep 1
        
        unbalance_partitions=$(check_unbalanced_partitions)

        if [[ $before = $unbalance_partitions ]]; then
            echo "Something went wrong while balancing the cluster."
            break
        fi

        rebalance_leaders 5

    done
    balance_leaders
    
    echo "Balance finished! Seems like the balance job was finished, $total_unbalance_partitions partitions and $total_unbalance_leaders leaders were balanced."
    echo "KF Tool Notification - Balance finished."
    rm -f /tmp/max-partition-movment

}

function balance_leaders {
    

    leader_changes=5
    
    total_unbalance_leaders=$(check_unbalanced_leaders)

    unbalance_leaders=$total_unbalance_leaders

    while [ $unbalance_leaders -ne 0 ] ;do

        progress_bar $total_unbalance_leaders $unbalance_leaders "Leader Balance"
        before=$(check_unbalanced_leaders)
        rebalance_leaders $leader_changes
        if [[ $status -ne 0 ]]; then
          echo "Rebalance leaders Command failed, try to run the following command manually and analyze the problem:
                /usr/local/bin/kafka-cluster-manager --cluster-type generic \
                --cluster-name this_cluster \
                --apply --no-confirm rebalance \
                --replication-groups --leaders \
                --max-leader-changes $leaders"
          exit 1
        fi
        echo "Checking active task"
        echo "leader changes $leader_changes"
        while active_task ;do
            echo "Active task is running"
            sleep 2
        done
        sleep 1

        unbalance_leaders=$(check_unbalanced_leaders)

        if [[ $before = $unbalance_leaders ]]; then
            let leader_changes=leader_changes+10
        fi
    done
}
