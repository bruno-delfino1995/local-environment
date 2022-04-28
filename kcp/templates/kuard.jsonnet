{
	deployment: {
		apiVersion: "apps/v1",
		kind: "Deployment",
		metadata: {
			labels: {
				app: "kuard"
			},
			name: "kuard"
		},
		spec: {
			replicas: 1,
			selector: {
				matchLabels: {
					app: "kuard"
				}
			},
			template: {
				metadata: {
					labels: {
						app: "kuard"
					}
				},
				spec: {
					containers: [
						{
							image: "gcr.io/kuar-demo/kuard-amd64:1",
							name: "kuard"
						}
					]
				}
			}
		}
	},
	service: {
		apiVersion: "v1",
		kind: "Service",
		metadata: {
			labels: {
				app: "kuard"
			},
			name: "kuard"
		},
		spec: {
			ports: [
				{
					port: 80,
					protocol: "TCP",
					targetPort: 8080
				}
			],
			selector: {
				app: "kuard"
			},
			sessionAffinity: "None",
			type: "ClusterIP"
		}
	},
	proxy: {
		apiVersion: "projectcontour.io/v1",
		kind: "HTTPProxy",
		metadata: {
			name: "kuard"
		},
		spec: {
			virtualhost: {
				fqdn: "kuard.oddin.localhost",
				tls: {
					secretName: "tls-secret"
				}
			},
			routes: [
				{
					services: [
						{
							name: "kuard",
							port: 80
						}
					]
				}
			]
		}
	}
}
