#!/bin/bash
#
# Deploy QOTD
#

FG_OFF="\033[0m"
FG_BLACK="\033[30m"
FG_RED="\033[31m"
FG_GREEN="\033[32m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"

FG_BBLACK="\033[1;30m"
FG_BRED="\033[1;31m"
FG_BGREEN="\033[1;32m"
FG_BYELLOW="\033[1;33m"
FG_BBLUE="\033[1;34m"

BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_YELLOW="\033[43m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

usage() {
    echo ""
    echo -e "${FG_BBLACK}Usage: $0 -h -c -i -n -t -u -w -s ${FG_OFF}"
    echo ""
    echo -e "${FG_BBLUE}Deploy and undeploy QOTD using helm on K8s cluster. ${FG_OFF}"
    echo ""
    echo "where "
    echo "   -h help "
    echo "   -c Specify cluster host url"
    echo "   -i Installs OOTD app usong helm on microk8s cluster"
    echo "   -n Namespace to install in"
    echo "   -t Cluster type ROKS/IKS atm"
    echo "   -s Backend service only. Deletes qotd-web"
    echo "   -w qotd-web only. Experimental. WIP"
    echo "   -u Undeploys QOTD app"
    echo ""
}

fn_delete_qotd_service() {
    kubectl delete deploy qotd-author
    kubectl delete deploy qotd-db
    kubectl delete deploy qotd-engraving
    kubectl delete deploy qotd-image
    kubectl delete deploy qotd-pdf
    kubectl delete deploy qotd-qrcode
    kubectl delete deploy qotd-quote 
    kubectl delete deploy qotd-rating
    kubectl delete svc qotd-author
    kubectl delete svc qotd-db
    kubectl delete svc qotd-engraving
    kubectl delete svc qotd-image
    kubectl delete svc qotd-pdf
    kubectl delete svc qotd-qrcode
    kubectl delete svc qotd-quote
    kubectl delete svc qotd-rating
}

fn_delete_qotd_web() {
    kubectl delete deploy qotd-web
    kubectl delete svc qotd-web
}

fn_setup_sec_context_roks() {
  oc new-project $1
  oc adm policy add-scc-to-user anyuid -z default

  oc new-project $1-load
  oc adm policy add-scc-to-user anyuid -z default
}

fn_deploy_roks() {
    echo -e "${FG_BBLACK}Deploying QOTD with following parameters... ${FG_OFF}"
    echo -e "Cluster HOST: $1"
    echo -e "   NAMESPACE: $2"
    echo -e "        QOTD: $3"
    read -p "Continue? (Y/N)" yn
    case $yn in
	[Yy]* ) ;;
	[Nn]* ) exit;;
    esac
    echo -e ""
    fn_setup_sec_context_roks $2
    
    helm repo list
    helm repo add qotd https://gitlab.com/api/v4/projects/26143345/packages/helm/stable
    helm repo update
    oc config set-context --current --namespace=$2
    helm install qotd-chart qotd/qotd --set host=$1 --set appNamespace=$2 --set loadNamespace=$2-load --set roksCluster=true

    if [[ "$3" = "web" ]]; then
	fn_delete_qotd_service
    elif [[ "$3" = "service" ]]; then
	fn_delete_qotd_web
    else
	echo "Running all"
    fi
}

fn_deploy_k8s() {
    echo -e "${FG_BBLACK}Deploying QOTD with following parameters... ${FG_OFF}"
    echo -e "Cluster HOST: $1"
    echo -e "   NAMESPACE: $2"
    read -p "Continue? (Y/N)" yn
    case $yn in
	[Yy]* ) ;;
	[Nn]* ) exit;;
    esac
    echo -e ""

    kubectl create ns $2
    kubectl create ns $2-load

    helm repo list
    helm repo add qotd https://gitlab.com/api/v4/projects/26143345/packages/helm/stable
    helm repo update
    kubectl config set-context --current --namespace=$2
    helm install qotd-chart qotd/qotd --set host=$1 --set appNamespace=$2 --set loadNamespace=$2-load --set useNodePort=true

    if [[ "$3" = "web" ]]; then
	fn_delete_qotd_service
    elif [[ "$3" = "service" ]]; then
	fn_delete_qotd_web
    else
	echo "Running all"
    fi
}

fn_undeploy() {
    echo ""
    echo -e "${FG_BBLACK}helm list -A ... ${FG_OFF}"
    helm list -A

    echo ""
    echo -e "${FG_BBLACK}Undeploy QOTD ... ${FG_OFF}"
    helm delete qotd-chart --namespace $1

    echo ""
    echo -e "${FG_BBLACK}Get pods -n $1 $1-load ... ${FG_OFF}"
    kubectl get pods --namespace $1
    kubectl get pods --namespace $1-load

#    echo ""
#    echo -e "${FG_BBLACK}Delete namespace $1 $1-load ... ${FG_OFF}"
#    kubectl delete namespace $1
#    kubectl delete namespace $1-load
}

QOTD=all

while getopts 'hc:in:t:uws' option; do
  case "$option" in
    h) usage
       exit 1
       ;;
    i) INSTALL=1
       ;;
    c) CLUSTER_HOST_URL=$OPTARG
       ;;
    t) CLUSTER_TYPE=$OPTARG
       ;;
    n) NAMESPACE=$OPTARG
       ;;
    w) QOTD=web
       ;;
    s) QOTD=service
       ;;
    u) UNINSTALL=1
       ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       usage
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

if [ ! -z "$INSTALL" ]; then
  if [ ! -z "$CLUSTER_HOST_URL" ]; then
    if [ ! -z "$CLUSTER_TYPE" ]; then
      if [ ! -z "$NAMESPACE" ]; then
        if [[ "$CLUSTER_TYPE" = "ROKS" ]]; then
	  fn_deploy_roks $CLUSTER_HOST_URL $NAMESPACE $QOTD
        elif [[ "$CLUSTER_TYPE" = "IKS" ]]; then
	  echo "IKS"
	  fn_deploy_k8s $CLUSTER_HOST_URL $NAMESPACE $QOTD
        else
	  echo "other k8s"
	fi
      else
        echo -e "${FG_RED}Error: Must provide NAMESPACE of the logged in cluster with -n option${FG_OFF}"
        usage
        exit 1
      fi
    else
      echo -e "${FG_RED}Error: Must provide type of cluster -t option${FG_OFF}"
      usage
      exit 1
    fi
  else
    echo -e "${FG_RED}Error: Must provide cluster HOST URL with -c option${FG_OFF}"
    usage
    exit 1
  fi
elif [ ! -z "$UNINSTALL" ]; then
    fn_undeploy $NAMESPACE
else
    echo -e "${FG_RED}Error: No valid option specified. ${FG_OFF}"
    usage
    exit 1
fi
