local helpers = import 'helpers.libsonnet';

helpers.inOrder([
	{name: 'namespace', value: import 'namespace.jsonnet'},
	{name: 'shell', value: import 'shell.jsonnet'},
	{name: 'kuard', value: import 'kuard.jsonnet'},
])
