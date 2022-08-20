name = example
context = example-local

.PHONY: install
install:
	@bash ./scripts/create-cluster -n ${name} -c ${context}
	@bash ./scripts/generate-root-certificate
	@bash ./scripts/setup-cluster -d "${name}.localhost" -r "registry.${name}.com" -p false

.PHONY: uninstall
uninstall:
	@k3d cluster delete ${name}
	@kubectx -u
	@kubectx -d ${context}

.PHONY: start
start:
	@k3d cluster start ${name}
	@kubectx ${context}

.PHONY: stop
stop:
	@k3d cluster stop ${name}
	@kubectx -u

.PHONY: status
status:
	@k3d cluster list ${name}
