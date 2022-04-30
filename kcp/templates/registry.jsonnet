local helpers = import "helpers.libsonnet";
local _ = import "kct.io";
local labels = {"app.kubernetes.io/name": "registry"};
local configName = "config";

helpers.inOrder([
	{name: "namespace", value: {
		apiVersion: "v1",
		kind: "Namespace",
		metadata: {
			name: "registry",
		}
	}},
	{name: "config", value: {
		apiVersion: "v1",
		kind: "ConfigMap",
		metadata: {
			name: configName,
			namespace: "registry"
		},
		data: {
			"config.yml": _.files('registry.yaml'),
		},
	}},
	{name: "statefulset", value: {
		apiVersion: "apps/v1",
		kind: "StatefulSet",
		metadata: {
			name: "registry",
			namespace: "registry",
			labels: labels,
		},
		spec: {
			replicas: 1,
			serviceName: "registry-headless",
			selector: {
				matchLabels: labels,
			},
			template: {
				metadata: {
					labels: labels,
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
								name: configName,
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
	}},
	{name: "headless", value: {
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
			selector: labels,
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
	}},
	{name: "service", value: {
		kind: "Service",
		apiVersion: "v1",
		metadata: {
			name: "registry",
			namespace: "registry",
			labels: labels,
		},
		spec: {
			selector: labels,
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
	}},
	{name: "ingress", value: {
		apiVersion: "networking.k8s.io/v1",
		kind: "Ingress",
		metadata: {
			name: "registry",
			namespace: "registry",
			annotations: {
				"cert-manager.io/cluster-issuer": "ca-issuer",
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
										name: "registry",
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
	}},
])
