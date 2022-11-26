# Rio's Devcontainer Features

These features are my daily drivers when developing systems that are mostly
involving containers and kubernetes. Generally they are tool installers that I
got tired of reinventing every time I move to a different project.

The features in this repository are all tested against the same set of distros
and will always have both an arm64 and amd64 variant.

# Available Features

| Name | URL | Description |
| ---  | --- | ---         |
| chezmoi   | https://chezmoi.io | *The* tool that I include in all my projects. It makes it very easy to pull in your personal dotfiles and instantly transform that last 10% of your devcontainer into the dev environment you expect on every machine! |
| skaffold  | https://skaffold.dev | A tool that helps with your development loop. It can continuously build, deploy and even sync files into already running containers whenever you make changes. Combine it with a tool like entr inside the running container and you have a killer combo. |
| kustomize | https://kustomize.io | Helps wrangling your kubernetes YAML manifests into the different shapes you need. Without templates! |
| k3d       | https://k3d.io | Gets your local kubernetes cluster up and running fast! Includes some quality of life features such as a container registry, local path provisioner, load balancer and ingress controller. |