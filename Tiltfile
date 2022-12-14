# Welcome to Tilt!
#   To get you started as quickly as possible, we have created a
#   starter Tiltfile for you.
#
#   Uncomment, modify, and delete any commands as needed for your
#   project's configuration.

cluster_name = 'appcloud'
project_name = 'taintmanager'

# Allow the cluster to avoid problems while having kubectl configured to talk to a remote cluster.
allow_k8s_contexts(cluster_name)

# Use custom Dockerfile for Tilt builds, which only takes locally built binary for live reloading.
dockerfile = '''
    FROM golang:1.19-alpine
    RUN go install github.com/go-delve/delve/cmd/dlv@latest
    COPY %s /usr/local/bin/%s
    ''' % (project_name, project_name)# Build Docker image

#   Tilt will automatically associate image builds with the resource(s)
#   that reference them (e.g. via Kubernetes or Docker Compose YAML).
#
#   More info: https://docs.tilt.dev/api.html#api.docker_build
#
# docker_build('registry.example.com/my-image',
#              context='.',
#              # (Optional) Use a custom Dockerfile path
#              dockerfile='./deploy/app.dockerfile',
#              # (Optional) Filter the paths used in the build
#              only=['./app'],
#              # (Recommended) Updating a running container in-place
#              # https://docs.tilt.dev/live_update_reference.html
#              live_update=[
#                 # Sync files from host to container
#                 sync('./app', '/src/'),
#                 # Execute commands inside the container when certain
#                 # paths change
#                 run('/src/codegen.sh', trigger=['./app/api'])
#              ]
# )


# Run local commands
#   Local commands can be helpful for one-time tasks like installing
#   project prerequisites. They can also manage long-lived processes
#   for non-containerized services or dependencies.
#
#   More info: https://docs.tilt.dev/local_resource.html
#
# local_resource('install-helm',
#                cmd='which helm > /dev/null || brew install helm',
#                # `cmd_bat`, when present, is used instead of `cmd` on Windows.
#                cmd_bat=[
#                    'powershell.exe',
#                    '-Noninteractive',
#                    '-Command',
#                    '& {if (!(Get-Command helm -ErrorAction SilentlyContinue)) {scoop install helm}}'
#                ]
# )

# Building binary locally.
local_resource('%s-binary' % project_name,
    'GOOS=linux GOARCH=amd64 go build -gcflags "all=-N -l" -o taintmanager taintmanager.go',
    deps=[
        './taintmanager.go',
    ],
)

# Extensions are open-source, pre-packaged functions that extend Tilt
#
#   More info: https://github.com/tilt-dev/tilt-extensions
#
load('ext://git_resource', 'git_checkout')

# Load the restart_process extension with the docker_build_with_restart func for live reloading.
load('ext://restart_process', 'docker_build_with_restart')

# Wrap a docker_build to restart the given entrypoint after a Live Update.
docker_build(
    'lthub/' + project_name,
    '.',
    dockerfile_contents=dockerfile,
    entrypoint='/go/bin/dlv --listen=0.0.0.0:50100 --api-version=2 --headless=true --only-same-user=false --accept-multiclient --check-go-version=false exec -- /usr/local/bin/taintmanager -remove jupyterhub:NoSchedule',
    live_update=[
        # Copy the binary so it gets restarted.
        sync(project_name, '/usr/local/bin/%s' % project_name),
    ],
)

# Apply Kubernetes manifests
#   Tilt will build & push any necessary images, re-deploying your
#   resources as they change.
#
#   More info: https://docs.tilt.dev/api.html#api.k8s_yaml
#
# k8s_yaml(['k8s/deployment.yaml', 'k8s/service.yaml'])
# Create the deployment from YAML file path.
k8s_yaml('deployment.yaml')

# Configure the resource.
k8s_resource(
        project_name,
        port_forwards = ["50100:50100"] # Set up the K8s port-forward to be able to connect to it locally.
)
