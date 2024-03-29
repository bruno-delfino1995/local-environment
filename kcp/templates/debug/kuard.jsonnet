local _ = import "kct.libsonnet";
local name = "kuard";
local host = "%s.%s" % [name, _.input.host];

{
	deployment: {
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
				matchLabels: $.deployment.metadata.labels,
			},
			template: {
				metadata: {
					labels: $.deployment.metadata.labels,
				},
				spec: {
					containers: [
						{
							image: "gcr.io/kuar-demo/kuard-amd64:1",
							name: name,
						},
					],
				},
			},
		},
	},
	service: {
		apiVersion: "v1",
		kind: "Service",
		metadata: {
			name: name,
			namespace: "debug",
			labels: {
				"app.kubernetes.io/name": name,
			},
		},
		spec: {
			selector: $.deployment.metadata.labels,
			type: "ClusterIP",
			ports: [
				{
					port: 80,
					protocol: "TCP",
					targetPort: 8080,
				}
			],
		},
	},
	ingress: {
		apiVersion: "networking.k8s.io/v1",
		kind: "Ingress",
		metadata: {
			name: name,
			namespace: "debug",
			annotations: {
				"cert-manager.io/cluster-issuer": "default-issuer",
			}
		},
		spec: {
			rules: [{
				host: host,
				http: {
					paths: [
						{
							path: "/",
							pathType: "Prefix",
							backend: {
								service: {
									name: $.service.metadata.name,
									port: {
										number: 80,
									},
								},
							},
						},
					],
				},
			}],
			tls: [{
				hosts: [host],
				secretName: "%s-cert" % name,
			}],
		},
	},
}
