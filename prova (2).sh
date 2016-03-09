while [[ $# > 1 ]] ; do
    case $1 in
        -p | --protocol)
            protocol=$2
            shift
        ;;
        --pull-repo)
            pull_repo="yes"
        ;;
        *)
            echo "Unknown option: $1"
            exit 1
        ;;
    esac
    shift
done

until [[ ${protocol,,} = "ssh" ]] || [[ ${protocol,,} = "https" ]] ; do
        echo -n "You want to use ssh or https to clone the repository? (https or ssh): "
        read protocol
done

protocol=${protocol,,}
echo "You are using $protocol"

if [[ -d "$WTL_REPO_DIR" && pull_repo != "yes" ]] ; then
    echo "You have '"$WTL_REPO_DIR"' directory in your directory."
    echo "If you are trying to re-create the config file move the directory way and re-execute this script"
fi