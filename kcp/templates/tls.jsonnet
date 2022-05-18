local _ = import "kct.libsonnet";

{
	traefik: {
		apiVersion: "helm.cattle.io/v1",
		kind: "HelmChartConfig",
		metadata: {
			name: "traefik",
			namespace: "kube-system"
		},
		spec: {
			valuesContent: _.files("traefik.yaml"),
		},
	},
	secret: {
		apiVersion: "v1",
		kind: "Secret",
		metadata: {
			name: "ca-key-pair",
			namespace: "cert-manager",
		},
		type: "Opaque",
		data: {
			"tls.crt": std.base64(_.input.cert.crt),
			"tls.key": std.base64(_.input.cert.key),
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
}
