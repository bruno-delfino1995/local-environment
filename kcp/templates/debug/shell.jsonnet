local name = "shell";
{
	apiVersion: "apps/v1",
	kind: "Deployment",
	metadata: {
		name: name,
		namespace: "debug",
		labels: {
			"app.kubernetes.io/name": name,
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
						name: name,
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
