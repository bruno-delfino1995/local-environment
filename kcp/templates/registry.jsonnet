local _ = import "kct.io";

{
	namespace: {
		apiVersion: "v1",
		kind: "Namespace",
		metadata: {
			name: "registry",
		}
	}
	,
	config: {
		apiVersion: "v1",
		kind: "ConfigMap",
		metadata: {
			name: "registry-config",
			namespace: "registry"
		},
		data: {
			"config.yml": _.files('registry.yaml'),
		},
	},
	statefulset: {
		apiVersion: "apps/v1",
		kind: "StatefulSet",
		metadata: {
			name: "registry",
			namespace: "registry",
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
							volumeMounts: [
								{
									name: "storage",
									mountPath: "/var/lib/registry",
								},
								{
									name: "config",
									mountPath: "/etc/docker/registry",
								},
							],
						},
					],
					volumes: [
						{
							name: "config",
							configMap: {
								name: $.config.metadata.name,
							},
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
			namespace: "registry",
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
			namespace: "registry",
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
		apiVersion: "networking.k8s.io/v1",
		kind: "Ingress",
		metadata: {
			name: "registry",
			namespace: "registry",
			annotations: {
				"cert-manager.io/cluster-issuer": "ca-issuer",
				"traefik.ingress.kubernetes.io/router.middlewares": "kube-system-force-https@kubernetescrd",
			},
		},
		spec: {
			rules: [
				{
					host: _.input.registry.host,
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
										}
									},
								},
							},
						],
					},
				},
			],
			tls: [
				{
					secretName: "registry-cert",
					hosts: [_.input.registry.host],
				},
			],
		},
	},
}
