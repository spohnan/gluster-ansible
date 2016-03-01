#!/usr/bin/env bash
#
# Usage: gluster.sh
# 			--provider [aws|gce]
# 			--prefix [NODE_NAME_PREFIX]
# 			--action [CONFIG_STEP]
# 			--vars [variable file name]
#			--verbose                      # optionally run ansible with -vvv

# Parse arguments
declare -A ARGS
# defaults
ARGS[reboot]="true"
ARGS[provider]="gce"
while [ $# -gt 0 ]; do
    # Trim the first two chars off of the arg name ex: --foo
    case "$1" in
        *) NAME="${1:2}"; shift; ARGS[$NAME]="${1-true}" ;;
    esac
    shift
done

# Ensure we've specified the cluster name prefix
if [ -z "${ARGS[prefix]}" ] && [ "${ARGS[action]}" != "list-inventory" ]; then
	echo "No cluster name given ... exiting"
	exit
fi

# The cluster name used to prefix all instance names ex: m1-master or m1-node-065245
CLUSTER="tag_Cluster=${ARGS[prefix]}"
if [ "${ARGS[provider]}" == "aws" ]; then
	CLUSTER="ec2_${CLUSTER}" # tags are prefaced with ec2 when using AWS
fi

list_inventory() {
	case "${ARGS[provider]}" in
		"aws") hosts/aws/ec2.py --list --refresh-cache ;;
		"gce") hosts/gce/gce.py --list --pretty ;;
	esac
}

run_playbook() {
	ansible-playbook ${ARGS[verbose]//true/-vvv} \
		-i hosts/"${ARGS[provider]}" \
		-e $CLUSTER -e "cluster_prefix=${ARGS[prefix]}" \
		"${ARGS[provider]}-${1}.yml" --extra-vars="varfile=${ARGS[vars]}"
}

case "${ARGS[action]}" in
	"list-inventory") list_inventory ;;
	"build-all")
		STEPS=( "provision" "configure" "update" )
		for step in "${STEPS[@]}"; do
			run_playbook $step
			list_inventory > /dev/null 2>&1 # Update cache
		done
  		;;
  *) run_playbook "${ARGS[action]}" ;; # Anything else should be a playbook
esac
