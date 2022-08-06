local _ = import 'kct.libsonnet';

_.sdk.inOrder(['tls', 'debug', 'registry'], {
	tls: import 'tls.jsonnet',
	debug: import 'debug/main.jsonnet',
	registry: import 'registry.jsonnet',
})
