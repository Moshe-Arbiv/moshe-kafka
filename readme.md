# kf - kafka tool
This tool utilize kafka-utils to fully automate kafka rebalance and drain tasks. 
## usage
```
Methods:
       drain <broker_number> <partition_concurrency(default:5)>   | Will decomission a broker
       balance <partition_concurrency(default:5)>                 | Will balance all partitions in the cluster

Example:
       kf balance 2                                     | Will balance the cluster with 2 paritions max moving at the same time.
```

When activating the tool it will create a file in /tmp/max-move-patitions that can be altered to run slower\quicker without breaking the script.
