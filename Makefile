.PHONY: install
install:
	@bash ./scripts/create-cluster
	@bash ./scripts/generate-root-certificate
	@bash ./scripts/setup-cluster

.PHONY: uninstall
uninstall:
	@kind delete cluster --name oddin
	@kubectx -u
	@kubectx -d asgard

.PHONY: stop
stop:
	@docker container stop `kind get nodes --name oddin`
	@kubectx -u
