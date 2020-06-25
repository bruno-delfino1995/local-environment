# Oddin Local Environment

> Development setup to mimic production as close as possible

This project supposedly helps when developing integrated stuff that needs to interact with each other. Our interactions, as of now, need a network for services to communicate along with some basic setup like databases and tls configurations for websites. By using this project, you'll be able to have a local environment configured with every service that you need integrated on a central point.

## Running

To start, you'll need a machine with [developer-tools](https://github.com/oddin-org/development-setup) installed.

Before to work on any service, you need to create the cluster:

```bash
./scripts/create-cluster
```

After we have a cluster running, which you can ensure by checking that `kind get clusters` has `oddin` on its results, you need to create the certificate to be installed.

```bash
./scripts/generate-root-certificate
```

Pay attention to the notices that this script returns regarding trusting the root certificate, otherwise, you'll have your browser yelling at you because it doesn't trust our newly certificate by default. To trust your certificate you'll need to follow the conventions held by your OS. As we encourage Arch Linux, below are the instructions for it.

```bash
sudo mv data/certs/tls.crt /etc/ca-certificates/trust-source/anchors/oddin-ca.crt
sudo trust extract-compact
```

With the new certificate generated, everything that is pending is to install it within our cluster along with the components that enable ingress traffic through `oddin.localhost` to the services itself. To accomplish that, you just need to run the following:

``` bash
./scripts/setup-cluster
```

## Cleanup

After finished with either your testing or your development - ~~you can reboot your machine and get back to normal activity~~ - you'd need to either stop or delete the cluster.

```bash
docker container stop $(kind get nodes --name oddin)
# or
kind delete cluster --name oddin
```

## Contributing

Feel free to implement any script that might speed up the daily life of our fellow contributors, only remember to have a `--help` on it.
