# Oddin Local Environment

> Development setup to mimic production as close as possible

This project supposedly helps when developing integrated stuff that needs to interact with each other. Our interactions, as of now, typically, need a shared network and a shared configuration, exactly what we provide here. By using this project, you'll be able to have a local environment configured with every service that you need integrated and already configured on a central point.

## Installation

To start, you'll need [Docker](https://www.docker.com/) and [Docker-Compose](https://docs.docker.com/compose/), which are the basis for every one of our services once they're all containerized. Apart from the engine to run everything, be sure to have every component that you want to interact on the same parent as this folder. For example, if this is on `~/Oddin` and you want to integrate api with web, be sure to have both, respectively, at `~/Oddin/api` and `~/Oddin/web`.

For each service that you'll start and integrate, we call it a target. Given the previous example, we had two targets, being api and web. Based on this, some scripts would interact with targets, while others would interact with your machine to set up the environment so everything can run smoothly. In essence, `./scripts/targets` run on targets (duh??), while `./scripts/network` set up a docker network on your machine. ~~PS.: Don't be picky by telling me that both interact with the machine itself because a target is a local container.~~

## Running

Before starting any target, you need to create a shared network with:

```bash
./scripts/network up
```

Once the oddin-network created (`docker network ls | grep 'oddin-network'`), you need to list your projects/services, henceforth called targets, separated by a line break on `targets.cfg`. With the network up and targets configured, you can start using the scripts, e.g:

```bash
# Shared config
echo -e 'api\nweb' > targets.cfg
./scripts/targets up
```

I suggest you take a look at every script to see what we implemented and which are the options. Nevertheless, every script within `./scripts` should accept a `-h --help` argument, otherwise it won't even be considered a script.

## Cleanup

After finished with either your testing or your development, ~~you can reboot your machine and get back to normal activity~~; you'd need to either stop or remove your targets and your network by running:

```bash
./scripts/targets stop # or `./scripts/targets down`
./scripts/network down # Run this only if you've ran `./scripts/targets down`, otherwise it'll miserably fail
```

## Contributing

Feel free to implement any script that might speed up the daily life of our fellow contributors, only remember to have a `--help` on it.
