# Apache NiFi Registry - Git Flow Repository Docker Image

This docker image is a convenience image based on the official
[apache/nifi-registry](https://hub.docker.com/r/apache/nifi-registry/)
image allowing configuration of the GitFlowPersistenceProvider via environment
variables with automatic cloning of remote repositories on container startup.

The configuration applied will allow for a remote repository (and optional
branch) to be checkout out upon startup of the container which is primarily to
support the use case of running NiFi Registry as a service in docker swarm
without the need for volume mounts and specific node constraints.

The following environment variables can be provided:

| Variable                 | Description                                                                     |
| ------------------------ | ------------------------------------------------------------------------------- |
| GIT_REMOTE_REPOSITORY    | Remote Git Repository to be cloned (HTTP or HTTPS protocol)                     |
| GIT_REMOTE_BRANCH        | The branch to be checked out if different from `master`                         |
| GIT_REMOTE_TO_PUSH       | Remote name if different from `origin`                                          |
| GIT_REMOTE_ACCESS_USER   | The user account used to access the remote git repository                       |
| GIT_REMOTE_ACCESS_TOKEN  | The access token for the user defined by the `GIT_REMOTE_ACCESS_USER` variable  |

Upon container startup the `docker-entrypoint.sh` will be executed which
carries out 3 primary functions:

- Initialises the git repository within the `/conf/flow_repository` folder as
    one of the following:
    - Clones a remote repository using the `GIT_REMOTE_*` variables
    - Initialises a local git repository
- Configures the `GitFlowPersistenceProvider` within the providers using
    [dockerize](https://github.com/jwilder/dockerize)
- Launches the default NiFi Registry entrypoint (`../scripts/start.sh`)

## Usage

### Setting up a remote repository

To start the NiFi Registry with an preconfigured remote git repository the
following should be executed:

```bash
docker run --name registry -p 18080:18080 -d \
--env GIT_REMOTE_REPOSITORY=https://gitlab.com/cdavid15/nifi-registry-repo.git \
--env GIT_REMOTE_BRANCH=master \
--env GIT_REMOTE_TO_PUSH=origin \
--env GIT_REMOTE_ACCESS_USER=my-user \
--env GIT_REMOTE_ACCESS_TOKEN=my-access-token \
cdavid15/nifi-registry:latest

```

The following command is equivalent to the above:

```bash
docker run --name registry -p 18080:18080 -d \
--env GIT_REMOTE_REPOSITORY=https://gitlab.com/cdavid15/nifi-registry-repo.git \
--env GIT_REMOTE_ACCESS_USER=my-user \
--env GIT_REMOTE_ACCESS_TOKEN=my-access-token \
cdavid15/nifi-registry:latest
```

If your development workflow requires different branches to be used within
each NiFi environment the following commands shows how this can be done:

```bash
## Development Instance
docker run --name registry-dev -p 18080:18080 -d \
--env GIT_REMOTE_REPOSITORY=https://gitlab.com/cdavid15/nifi-registry-repo.git \
--env GIT_REMOTE_BRANCH=dev \
--env GIT_REMOTE_ACCESS_USER=my-user \
--env GIT_REMOTE_ACCESS_TOKEN=my-access-token \
cdavid15/nifi-registry:latest

## Test Instance
docker run --name registry-test -p 28080:18080 -d \
--env GIT_REMOTE_REPOSITORY=https://gitlab.com/cdavid15/nifi-registry-repo.git \
--env GIT_REMOTE_BRANCH=test \
--env GIT_REMOTE_ACCESS_USER=my-user \
--env GIT_REMOTE_ACCESS_TOKEN=my-access-token \
cdavid15/nifi-registry:latest

## Production Instance
docker run --name registry-production -p 38080:18080 -d \
--env GIT_REMOTE_REPOSITORY=https://gitlab.com/cdavid15/nifi-registry-repo.git \
--env GIT_REMOTE_BRANCH=master \
--env GIT_REMOTE_ACCESS_USER=my-user \
--env GIT_REMOTE_ACCESS_TOKEN=my-access-token \
cdavid15/nifi-registry:latest
```

This allows a MR / PR workflow between different environments which may be
required within the organisation.

### Setting up a empty local repository

Executing the following will result in the minimum required configuration
to use the `GitFlowPersistenceProvider` by executing `git init` in our flow
repository folder.

```bash
docker run --name registry -p 18080:18080 -d cdavid15/nifi-registry:latest
```

## Inspired By

This simplified and specific image has been inspired the approaches used in
both [michalklempa/docker-nifi-registry](https://github.com/michalklempa/docker-nifi-registry)
and [quintoandar/docker-nifi](https://github.com/quintoandar/docker-nifi)
custom images specifically in relation to using environment variables for
dynamic configuration using templates.

The [michalklempa/docker-nifi-registry](https://github.com/michalklempa/docker-nifi-registry)
image offers substantially more configuration options and is worth looking at.

## LICENSE

MIT
