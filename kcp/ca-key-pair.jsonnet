local values = import "./values.json";

{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'ca-key-pair',
    namespace: 'cert-manager'
  },
  type: 'Opaque',
  data: {
    'tls.crt': std.base64(values.ca.crt),
    'tls.key': std.base64(values.ca.key)
  }
}
