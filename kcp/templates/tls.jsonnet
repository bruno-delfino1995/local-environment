local _ = import "kct.io";

{
	secret: {
		apiVersion: "v1",
		kind: "Secret",
		metadata: {
			name: "ca-key-pair",
			namespace: "cert-manager",
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
			name: "default-issuer",
			namespace: "cert-manager",
		},
		spec: {
			ca: { secretName: $.secret.metadata.name, },
		},
	},
	middleware: {
		apiVersion: "traefik.containo.us/v1alpha1",
		kind: "Middleware",
		metadata: {
			name: "force-https",
			namespace: "kube-system"
		},
		spec: {
			redirectScheme: {
				scheme: "https",
				permanent: true,
			},
		},
	},
}
