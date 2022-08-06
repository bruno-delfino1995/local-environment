local _ = import 'kct.libsonnet';

_.sdk.inOrder(['namespace'], {
	namespace: import 'namespace.jsonnet',
	shell: import 'shell.jsonnet',
	kuard: import 'kuard.jsonnet',
})
