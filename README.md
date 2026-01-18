# Self-Hosted GitHub Actions Runner (Docker)

This repository provides a simple setup to run a self-hosted GitHub Actions runner inside a Docker container.

It is useful when you:
- Want full control over the environment where your workflows run
- Need access to local resources (for example Docker, private network, etc.)
- Prefer to avoid using GitHub-hosted runners for some workloads

## Prerequisites

- Docker and Docker Compose installed
- A GitHub personal access token (PAT) with `repo` and `admin:repo_hook` permissions
- A repository on GitHub where the runner will be registered

## Configuration

### 1. Environment variables

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

Edit `.env`:

- `GH_PAT` – your GitHub Personal Access Token (PAT)
- `OWNER` – your GitHub username or organization name
- `REPO` – the repository name where the runner will be registered

Example (`.env.example`):

```env
GH_PAT=ghp_ENTER_YOUR_PAT_HERE
OWNER=your-github-username
REPO=your-repository-name
```

> Never commit your real `.env` file. It is already ignored via `.gitignore`.

### 2. Docker Compose

The service is defined in [`docker-compose.yml`](docker-compose.yml):

- Builds the Docker image from [`Dockerfile`](file:///Users/ahmadilmanfadilah/Projects/github/me/self-hosted-runner/Dockerfile)
- Loads environment variables from `.env`
- Mounts the Docker socket (`/var/run/docker.sock`) so workflows can use Docker

## Running the self-hosted runner

Build and start the container:

```bash
docker compose up -d --build
```

This will:
- Build the image
- Start a container named `gh-runner-auto`
- Register the runner to your GitHub repository using the `GH_PAT`, `OWNER`, and `REPO` values

To see logs:

```bash
docker compose logs -f
```

To stop the runner:

```bash
docker compose down
```

The `start.sh` script will automatically:
- Fetch a registration token from the GitHub API
- Register the runner in unattended mode
- Remove the runner from GitHub when the container receives a stop signal

## Using the runner in GitHub Actions

This repository includes a basic workflow that runs on the self-hosted runner:

[`self-hosted-runner-ci.yml`](file:///Users/ahmadilmanfadilah/Projects/github/me/self-hosted-runner/.github/workflows/self-hosted-runner-ci.yml):

```yaml
jobs:
  test-runner:
    runs-on: self-hosted
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Show runner information
        run: |
          echo "Runner name: $RUNNER_NAME"
          echo "Runner OS: $RUNNER_OS"
          echo "Runner architecture: $RUNNER_ARCH"

      - name: Test Docker availability
        run: |
          docker version
          docker ps
```

You can copy this workflow to any repository where:
- The runner is registered
- You want to test that the self-hosted runner and Docker are working

If you later add labels to your runner, you can target them with:

```yaml
runs-on: [self-hosted, your-label]
```

## Security notes

- Keep your `GH_PAT` secret and never commit it to the repository.
- Restrict permissions of the PAT to only what you need.
- The runner has access to the Docker socket; any workflow can start containers with the same privileges as the Docker daemon.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
