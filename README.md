# Oddin Local Environment

> Development setup to mimic production as close as possible

This project supposedly helps when developing integrated stuff that needs to interact with each other. Our interactions, as of now, need a network for services to communicate along with some basic setup like databases and tls configurations for websites. By using this project, you'll be able to have a local environment configured with every service that you need integrated on a central point.

## Running

To start, you'll need a machine with [developer-tools](https://github.com/oddin-org/development-setup) installed.

Before to work on any service, you need to create the cluster:

```bash
./scripts/create-cluster
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
