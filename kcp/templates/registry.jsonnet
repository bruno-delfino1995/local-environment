local secretName = "registry-tls";

{
	statefulset: {
		apiVersion: "apps/v1",
		kind: "StatefulSet",
		metadata: {
			name: "registry",
			labels: {
				"app.kubernetes.io/name": "registry",
			},
		},
		spec: {
			replicas: 1,
			serviceName: "registry-headless",
			selector: {
				matchLabels: $.statefulset.metadata.labels,
			},
			template: {
				metadata: {
					labels: $.statefulset.metadata.labels,
				},
				spec: {
					containers: [
						{
							name: "registry",
							image: "registry:2",
							env: [
								{
									name: "REGISTRY_HTTP_ADDR",
									value: "0.0.0.0:80",
								},
							],
							volumeMounts: [
								{
									name: "storage",
									mountPath: "/var/lib/registry",
								},
							],
						},
					],
				},
			},
			volumeClaimTemplates: [
				{
					metadata: {
						name: "storage",
					},
					spec: {
						accessModes: [
							"ReadWriteOnce",
						],
						resources: {
							requests: {
								storage: "8Gi",
							},
						},
					},
				},
			],
		},
	},
	headless: {
		apiVersion: "v1",
		kind: "Service",
		metadata: {
			name: "registry-headless",
			labels: {
				"app.kubernetes.io/name": "registry",
			},
		},
		spec: {
			selector: $.statefulset.metadata.labels,
			type: "ClusterIP",
			clusterIP: "None",
			ports: [
				{
					name: "http",
					protocol: "TCP",
					port: 80,
				},
			],
		},
	},
	service: {
		kind: "Service",
		apiVersion: "v1",
		metadata: {
			name: "registry",
			labels: {
				"app.kubernetes.io/name": "registry",
			},
		},
		spec: {
			selector: $.statefulset.metadata.labels,
			type: "NodePort",
			ports: [
				{
					name: "http",
					protocol: "TCP",
					port: 80,
					targetPort: 80,
					nodePort: 30008,
				},
			],
		},
	},
	ingress: {
		apiVersion: "extensions/v1beta1",
		kind: "Ingress",
		metadata: {
			name: "registry",
			annotations: {
				"cert-manager.io/cluster-issuer": "ca-issuer",
				"ingress.kubernetes.io/force-ssl-redirect": "true",
			},
		},
		spec: {
			rules: [
				{
					host: _.values.registry,
					http: {
						paths: [
							{
								path: "/",
								backend: {
									serviceName: $.service.metadata.name,
									servicePort: 80,
								},
							},
						],
					},
				},
			],
			tls: [
				{
					secretName: secretName,
					hosts: [
						_.values.registry,
					],
				},
			],
		},
	},
	proxy: {
		apiVersion: "projectcontour.io/v1",
		kind: "HTTPProxy",
		metadata: {
			name: "registry",
		},
		spec: {
			virtualhost: {
				fqdn: _.values.registry,
				tls: {
					secretName: secretName,
				},
			},
			routes: [
				{
					conditions: [
						{
							prefix: "/",
						},
					],
					services: [
						{
							name: $.service.metadata.name,
							port: 80,
						},
					],
				},
			],
		},
	},
}
