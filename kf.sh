DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/validations.sh"
. "$DIR/drain.sh"
. "$DIR/general.sh"
. "$DIR/balance.sh"

# Redirect all output to log file


# help section
while getopts ":hl:" opt; do
  case ${opt} in
    l ) log=${OPTARG} ;;
   \? )  echo "Invalid Option: -$OPTARG" 1>&2; exit 1 ;;
    h | *)
      echo "
       Methods:
       drain <broker_number> <partition_concurrency(default:5)>   | Will decommission a broker
       balance <partition_concurrency(default:5)>                 | Will balance all partitions in the cluster

       Example balance: kf balance 2                        // Will balance the cluster with 2 paritions max moving at the same time
       Example drain: kf drain 1 10                        //   Will drain broker number 1 with 10 partitions at a time
       Example status: kf status                           // Will print the status of the cluster
       Example to direct to a log: kf -l f status         // will print to log /tmp/kf.log"

      exit 0
      ;;
  esac
done

if [[ "$log" == "y" ]]; then
  echo "Directing output to log file /tmp/kf.log"
  export LOG_FILE=/tmp/kf.log
  exec > $LOG_FILE
  exec 2>&1
fi


# Validations
validations


shift $((OPTIND -1))
# Method Section
subcommand=$1; shift

case "$subcommand" in
	drain)
    
        option=$1; shift
        broker=$option

        option=$1; shift
        partitions=$option

        validate_args $broker
        drain $broker $partitions

		;;

	balance)
		option=$1; shift
        partitions=$option

        balance_partitions $partitions
        balance_leaders
    

		;;

  status)
		option=$1; shift
        clusterStatus
    ;;

  "")
    option=$1; shift

    echo "Please specify the operation you want to do (balance|drain) - example: kf balance 5| kf drain 2 5"

    ;;

esac