#
# Makefile : qotd 5.1.0
#
# 1. Requires CLUSTER_HOST_URL
#    For IBM Cloud hosted deployment for ROKS and IKS, get the CLUSTER_HOST_URL using
#    kubectl get cm ibm-cloud-cluster-ingress-info -n kube-system -o 'jsonpath={.data.ingress-subdomain}'
#
# 2. Requires CLUSTER_TYPE
#    Either ROKS / IKS 
#    
# 3. Requires NAMESPACE: to be installed in.
#
# 4. Requires CLUSTER_CONTEXT as short-hand renamed-context
#    4.1 Log into the target cluster
#    4.2 Rename the current context for example as follows
#        kubectl config rename-context $(kubectl config current-context) kc-iks-dal
#
# Example use:
#
# make qotd-all CLUSTER_HOST_URL=<cluster-host-url> CLUSTER_TYPE=<ROKS/IKS> NAMESPACE=<namespace> CLUSTER_CONTEXT=<cluster-context>
#
# make qotd-backend CLUSTER_HOST_URL=<cluster-host-url> CLUSTER_TYPE=<ROKS/IKS> NAMESPACE=<namespace> CLUSTER_CONTEXT=<cluster-context>
#
# make undeploy NAMESPACE=<namespace> CLUSTER_CONTEXT=<cluster-context>
#
# Example: patching a service. 
# kubectl patch service qotd-quote --patch '{"metadata": {"labels": {"app": "qotd-quote"}}}'
#

# Check all necessary environment variables
-include env.var.app.cmd.mk

# Check if CLUSTER_HOST_URL is provided
check_var_host:
	$(call cmd_var_check,CLUSTER_HOST_URL,as make <target> CLUSTER_HOST_URL=<host-url>)
	@echo ""
	@echo "CLUSTER_HOST_URL: ${CLUSTER_HOST_URL}"

# Check if CLUSTER_TYPE is provided
check_var_type:
	$(call cmd_var_check,CLUSTER_TYPE,as make <target> CLUSTER_TYPE=<host-type>)
	@echo "    CLUSTER_TYPE: ${CLUSTER_TYPE}"

# Check if NAMESPACE is provided
check_var_namespace:
	$(call cmd_var_check,NAMESPACE,as make <target> NAMESPACE=<namespace>)
	@echo "       NAMESPACE: ${NAMESPACE}"

# Check if CLUSTER_CONTEXT is provided
check_var_cluster_context:
	$(call cmd_var_check,CLUSTER_CONTEXT,as make <target> CLUSTER_CONTEXT=<cluster-context>)
	@echo " CLUSTER_CONTEXT: ${CLUSTER_CONTEXT}"

# Deploy all services using helm chart as specified in install-qotd.sh script. -i option
qotd-all: check_var_host check_var_type check_var_namespace check_var_cluster_context
	kubectl config use-context ${CLUSTER_CONTEXT}
	./install-qotd.sh -i -c ${CLUSTER_HOST_URL} -t ${CLUSTER_TYPE} -n ${NAMESPACE}

# Deploy all services except qotd-web using helm chart as specified in install-qotd.sh script.
# After full deploy, delete QOTD_WEB service -i and -s options
qotd-beckend: check_var_host check_var_type check_var_namespace check_var_cluster_context
	kubectl config use-context ${CLUSTER_CONTEXT}
	./install-qotd.sh -i -s -c ${CLUSTER_HOST_URL} -t ${CLUSTER_TYPE} -n ${NAMESPACE}

# UnDeploy all services. -u option
undeploy: check_var_namespace check_var_cluster_context
	kubectl config use-context ${CLUSTER_CONTEXT}
	./install-qotd.sh -u -n ${NAMESPACE}

# Experimentatl. Removal of all services except qotd-web renders the qotd-web pod go into crashLoopBack
#qotd-web: check_var_host check_var_type check_var_namespace check_var_cluster_context
#	kubectl config use-context ${CLUSTER_CONTEXT}
#	./install-qotd.sh -i -w -c ${CLUSTER_HOST_URL} -t ${CLUSTER_TYPE} -n ${NAMESPACE}


