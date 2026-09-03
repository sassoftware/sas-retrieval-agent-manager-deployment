# Local Documentation Server

Use these scripts to temporarily serve the RAM documentation site on your local computer. The scripts run Jekyll in a Docker container. They do not publish content or change Azure, Kubernetes, or GitHub resources.

## Requirements

- Docker Desktop, Docker Engine, or another working Docker installation.

The scripts download the `ruby:3.3` Docker image if it is not already available. They then install the Jekyll dependencies in a temporary container and start the documentation server.

## Windows PowerShell

From the repository root, run:

```powershell
.\scripts\docs\run-docs.ps1
```

To request a different starting port, run:

```powershell
.\scripts\docs\run-docs.ps1 -Port 4002
```

## Linux and macOS

From the repository root, run:

```bash
./scripts/docs/run-docs.sh
```

To request a different starting port, run:

```bash
./scripts/docs/run-docs.sh 4002
```

## Use the Site

The scripts use port `4000` by default. If that port is in use, they select the next available port and show the local address. Open the displayed `http://localhost:<port>` address in a browser.

The server watches the repository files and refreshes the browser after documentation changes. The local site does not use the GitHub Pages URL prefix, so navigation and assets work at the local address.

Press `Ctrl+C` in the terminal to stop the server. Docker removes the temporary container after it stops.
