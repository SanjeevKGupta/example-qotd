#
# Makefile : qotd 5.1.0
#
# Requires
#   NAMESPACE: to be installed in.
#   CLUSTER_CONTEXT: CL]luster where K8s resources will be created
#
# usage:
#   make apply-qotd-services NAMESPACE=sn-qotd CLUSTER_CONTEXT=kubeconfig-iks-dc
#
# You may want to modify qotd-web.yaml.tmpl if want to preserve LoadBalancer
#   make delete-qotd-services NAMESPACE=sn-qotd CLUSTER_CONTEXT=kubeconfig-iks-dc

# Check all necessary environment variables
-include env.var.app.cmd.mk

create-namespace: check_var_namespace check_var_cluster_context
	kubectl create namespace ${NAMESPACE}

# Deploy all the pods, services except qotd-db
apply-qotd-services: apply-author apply-engraving apply-image apply-pdf apply-qrcode apply-quote apply-rating apply-web
	@echo "Services DEPLOYED"

# Deletes all the pods, services except qotd-db. You may want to modify qotd-web.yaml.tmpl if want to preserve LoadBalancer
delete-qotd-services: delete-author delete-engraving delete-image delete-pdf delete-qrcode delete-quote delete-rating delete-web
	@echo "Services DELETED"

# Check if NAMESPACE is provided
check_var_namespace:
	$(call cmd_var_check,NAMESPACE,as make <target> NAMESPACE=<namespace>)
	@echo "       NAMESPACE: ${NAMESPACE}"

# Check if CLUSTER_CONTEXT is provided
check_var_cluster_context:
	$(call cmd_var_check,CLUSTER_CONTEXT,as make <target> CLUSTER_CONTEXT=<cluster-context>)
	@echo " CLUSTER_CONTEXT: ${CLUSTER_CONTEXT}"

qotd-export:
	export NAMESPACE=${NAMESPACE}

apply-author: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-author.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-author: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-author.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-engraving: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-engraving.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-engraving: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-engraving.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-image: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-image.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-image: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-image.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-pdf: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-pdf.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-pdf: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-pdf.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-qrcode: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-qrcode.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-qrcode: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-qrcode.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-quote: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-quote.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-quote: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-quote.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-rating: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-rating.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-rating: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-rating.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-web: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-web.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-web: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-web.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

apply-db: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-db.yaml.tmpl | kubectl apply -n ${NAMESPACE} -f-
delete-db: check_var_namespace check_var_cluster_context qotd-export
	envsubst < ./kube/qotd-db.yaml.tmpl | kubectl delete -n ${NAMESPACE} -f-

