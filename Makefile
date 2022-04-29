name = oddin
context = oddin-local

.PHONY: install
install:
	@bash ./scripts/create-cluster -n ${name} -c ${context}
	@bash ./scripts/generate-root-certificate
	@bash ./scripts/setup-cluster -n ${name} -t "org"

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
