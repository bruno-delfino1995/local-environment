{
	apiVersion: "apps/v1",
	kind: "Deployment",
	metadata: {
		name: "shell",
		namespace: "debug",
		labels: {
			"app.kubernetes.io/name": $.metadata.name,
		},
	},
	spec: {
		replicas: 1,
		selector: {
			matchLabels: $.metadata.labels,
		},
		template: {
			metadata: {
				labels: $.metadata.labels,
			},
			spec: {
				containers: [
					{
						name: $.metadata.name,
						image: "ubuntu:20.04",
						imagePullPolicy: "IfNotPresent",
						command: [ "sh" ],
						args: [ "-c", "sleep infinity" ],
					},
				],
			},
		},
	},
}
