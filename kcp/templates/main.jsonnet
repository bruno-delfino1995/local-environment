local helpers = import 'helpers.libsonnet';

helpers.inOrder([
	{name: 'tls', value: import 'tls.jsonnet'},
	{name: 'debug', value: import 'debug/main.jsonnet'},
	{name: 'registry', value: import 'registry.jsonnet'},
])
