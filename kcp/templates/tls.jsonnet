local _ = import "kct.io";
local certManagerNamespace = "cert-manager";

{
	cert: {
		secret: {
			apiVersion: "v1",
			kind: "Secret",
			metadata: {
				name: "ca-key-pair",
				namespace: certManagerNamespace,
			},
			type: "Opaque",
			data: {
				"tls.crt": std.base64(_.input.ca.crt),
				"tls.key": std.base64(_.input.ca.key),
			},
		},
		issuer: {
			apiVersion: "cert-manager.io/v1",
			kind: "ClusterIssuer",
			metadata: {
				name: "ca-issuer",
				namespace: certManagerNamespace,
			},
			spec: {
				ca: { secretName: $.cert.secret.metadata.name, },
			},
		},
	},
	placeholder: {
		pod: {
			kind: "Pod",
			apiVersion: "v1",
			metadata: {
				name: "http-echo",
				labels: {
					"app.kubernetes.io/name": "http-echo",
				},
			},
			spec: {
				containers: [
					{
						name: "http-echo",
						image: "hashicorp/http-echo",
						args: [ "-text='You\'re not supposed to be here'" ],
					},
				],
			},
		},
		service: {
			kind: "Service",
			apiVersion: "v1",
			metadata: {
				name: "tls-placeholder",
			},
			spec: {
				selector: $.placeholder.pod.metadata.labels,
				ports: [
					{
						port: 80,
						targetPort: 5678,
					},
				],
			},
		},
		ingress: {
			apiVersion: "networking.k8s.io/v1",
			kind: "Ingress",
			metadata: {
				name: "tls-placeholder",
				annotations: {
					"cert-manager.io/cluster-issuer": $.cert.issuer.metadata.name,
					"ingress.kubernetes.io/force-ssl-redirect": "true",
				},
			},
			spec: {
				rules: [
					{
						host: _.input.domain,
						http: {
							paths: [
								{
									path: "/",
									pathType: "Prefix",
									backend: {
										service: {
											name: $.placeholder.service.metadata.name,
											port: {
												number: 80,
											},
										},
									},
								},
							],
						},
					},
					{
						host: "*.%s" % _.input.domain,
						http: {
							paths: [
								{
									path: "/",
									pathType: "Prefix",
									backend: {
										service: {
											name: $.placeholder.service.metadata.name,
											port: {
												number: 80,
											},
										},
									},
								},
							],
						},
					},
				],
				tls: [
					{
						secretName: "domain-tls",
						hosts: [
							_.input.domain,
							"*.%s" % _.input.domain,
						],
					},
				],
			},
		},
	},
}
