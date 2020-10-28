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
				"tls.crt": std.base64(_.values.ca.crt),
				"tls.key": std.base64(_.values.ca.key),
			},
		},
		issuer: {
			apiVersion: "cert-manager.io/v1alpha2",
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
			apiVersion: "extensions/v1beta1",
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
						host: _.values.domain,
						http: {
							paths: [
								{
									path: "/",
									backend: {
										serviceName: $.placeholder.service.metadata.name,
										servicePort: 80,
									},
								},
							],
						},
					},
					{
						host: "*.%s" % _.values.domain,
						http: {
							paths: [
								{
									path: "/",
									backend: {
										serviceName: $.placeholder.service.metadata.name,
										servicePort: 80,
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
							_.values.domain,
							"*.%s" % _.values.domain,
						],
					},
				],
			},
		},
	},
}
