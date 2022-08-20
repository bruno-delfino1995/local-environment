# Example Local Environment

> Development setup to help local development

This project supposedly helps when developing integrated stuff that needs to interact with each other. It creates a network for services to communicate, along with some basic setup like databases and TLS configurations for websites. By using this project, you'll be able to have a local environment configured with every service that you need integrated on a central point.

## Running

To start, you'll need a machine with [developer-tools](https://github.com/bruno-delfino1995/development-setup) installed.

Before you work on any service, you need to create the cluster:

```bash
./scripts/create-cluster -n <name>
```

After we have a cluster running, which you can ensure by checking that `kind get clusters` has `oddin` on its results, you need to create the certificate to be installed.

```bash
./scripts/generate-root-certificate -n <name>
```

Pay attention to the notices that this script returns regarding trusting the root certificate, otherwise, you'll have your browser yelling at you because it doesn't trust our newly certificate by default. To trust your certificate you'll need to follow the conventions held by your OS. As I prefer Arch Linux, below are the instructions for it.

```bash
sudo trust anchor --store data/certs/tls.crt
```

With the new certificate generated, everything that is pending is to install it within our cluster along with the components that enable ingress traffic through `<name>.localhost` to the services itself. To accomplish that, you just need to run the following:

``` bash
./scripts/setup-cluster -n <name>
```

Once your cluster are set up, you can access it through the port bindings that k3d provides but that wouldn't work for TLS. The remaining step is to add the domain to `/etc/hosts`:

```
127.0.0.1 <name>.localhost registry.<name>.com
::1 <name>.localhost registry.<name>.com
```

## Cleanup

After finished with either your testing or your development - ~~you can reboot your machine and get back to normal activity~~ - you'd need to either stop or delete the cluster.

```bash
docker container stop $(kind get nodes --name <name>)
# or
kind delete cluster --name <name>
```

## Commands

To make your life a little easier, I've created a `Makefile` with minimal commands - all bound to `example` as their cluster.

- `install` to create and setup a cluster and context
- `uninstall` to remove the cluster and context
- `stop` to pause your cluster for a moment
- `start` to resume your cluster after a stop

## Contributing

Feel free to implement any script that might speed up the your daily development, only remember to have a `--help` on it.
