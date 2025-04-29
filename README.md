<div align="center">
  <img align="center" src=".github/media/logo.png?raw=true" alt="Logo" width="200">
</div>

<h1 align="center">upml</h1>

<p align="center">Always Up. Always Clean. Always Secure.</p>

<div align="center">

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]

</div>

## Table of Contents <!-- omit in toc -->

- [About](#about)
- [Features](#features)
- [Installation](#installation)
  - [1. Create the Discord Webhook (Optional)](#1-create-the-discord-webhook-optional)
  - [2.1. Install Using the `.deb` Package (Recommended)](#21-install-using-the-deb-package-recommended)
  - [2.2. Install Manually Using the Installer Script (Alternative)](#22-install-manually-using-the-installer-script-alternative)
  - [3. Scheduled Maintenance (Optional)](#3-scheduled-maintenance-optional)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Examples](#examples)
- [Uninstallation](#uninstallation)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

## About

`upml` (Update My Linux) is a powerful, elegant, and flexible Bash script designed to automate the maintenance and optimization of Ubuntu servers.

It handles system updates, upgrades, package cleanup, health checks, detailed logging, configuration management, and real-time Discord notifications — including full log file uploads for complete monitoring.

With a clean and professional console output, smart tab completion for all commands, robust error handling, and easily customizable settings, `upml` is the all-in-one solution to keep your servers secure, updated, efficient, and fully under control — with minimal manual effort.

<p align="right">(<a href="#top">back to top</a>)</p>

## Features

- **Automated System Maintenance**:
  - Fix broken packages
  - Update package lists
  - Upgrade and fully upgrade packages
  - Clean unnecessary and orphaned packages

- **System Health Checks**:
  - Display Disk Usage, Memory Usage, and Top Processes

- **Discord Notifications**:
  - Real-time notifications for:
    - Update start and completion
    - Errors and issues
    - Reboot status
    - Full log file uploads as attachment

- **Flexible Logging**:
  - Logs saved separately by date: `/var/log/upml/upml-YYYY-MM-DD-HHMMSS.log`
  - Automatic log rotation (deletes logs older than 30 days)
  - Option to specify a custom log file

- **Configuration File**:
  - Global settings stored at `/etc/upml.conf`
  - Easy editing without modifying the script

- **Command-Line Options**:
  - Dry-run mode to simulate without executing
  - Option to disable Discord notifications
  - Ability to set or view configuration easily

- **Tab Completion Support**:
  - Smart autocompletion for all available command-line options

- **Enhanced Console Output**:
  - Beautiful, centered, boxed headers
  - Professional, clean design

- **Advanced Error Handling**:
  - Exits on first error
  - Captures line and command that caused errors
  - Sends error alerts via Discord

<p align="right">(<a href="#top">back to top</a>)</p>

## Installation

### 1. Create the Discord Webhook (Optional)

> **Note:** Configuring a Discord Webhook is optional.
> If not configured, Discord notifications will be disabled, but system maintenance will still work normally.

To create a webhook:

1. Open your Discord server settings.
2. Navigate to **Integrations > Webhooks**.
3. Click **New Webhook**.
4. Name your webhook and select the **channel** where messages will be sent.
5. Click **Copy Webhook URL** to copy the generated URL.

You can set your webhook in two ways:

- During manual installation (when running `installer.sh`).
- After installation, using: `sudo upml --set-webhook`

### 2.1. Install Using the `.deb` Package (Recommended)

**Step 1: Download the latest `.deb` package from Releases.**
> [Go to Releases](https://github.com/demartini/upml/releases)

**Step 2: Install the package:**

```console
sudo dpkg -i upml_X.X.X.deb
```

**Step 3: (Optional) Fix missing dependencies:**

```console
sudo apt-get install -f
```

This will:

- Install necessary dependencies (`curl`, `deborphan`)
- Install `upml` into `/usr/local/bin/`
- Create `/etc/upml.conf`
- Create `/var/log/upml/`

### 2.2. Install Manually Using the Installer Script (Alternative)

**Step 1: Install dependencies:**

```console
sudo apt update
sudo apt install deborphan curl -y
```

**Step 2: Download the project:**

Clone or download the `upml` project files:

```console
git clone https://github.com/demartini/upml.git
cd upml
```

> (Or manually copy the files.)

**Step 3: Make the installer executable:**

```console
chmod +x scripts/installer.sh
```

**Step 4: Run the installer:**

```console
sudo ./scripts/installer.sh
```

This will:

- Install `upml` into `/usr/local/bin/`
- Ask for your Discord Webhook URL
- Create `/etc/upml.conf` with settings
- Create `/var/log/upml/`

### 3. Scheduled Maintenance (Optional)

Automate maintenance with cron. For example, every Sunday at 2:00 AM:

```console
sudo crontab -e
```

Add:

```console
0 2 * * SUN /usr/local/bin/upml
```

<p align="right">(<a href="#top">back to top</a>)</p>

## Configuration

`upml` uses a configuration file located at `/etc/upml.conf`.

You can manually edit this file to change settings:

| Variable          | Description                                |
| ----------------- | ------------------------------------------ |
| `DISCORD_WEBHOOK` | (Optional) Discord Webhook URL for alerts. |
| `LOG_DIR`         | Directory where log files will be saved.   |

Example of `/etc/upml.conf`:

```console
DISCORD_WEBHOOK="https://discord.com/api/webhooks/your_webhook_here"
LOG_DIR="/var/log/upml"
```

> If no webhook is configured, `upml` will still run but will not send Discord notifications.

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage

| Command                     | Description                                                                      |
| --------------------------- | -------------------------------------------------------------------------------- |
| `upml -d, --dry-run`        | Simulate all operations without making any changes.                              |
| `upml -n, --no-discord`     | Disable all Discord notifications.                                               |
| `upml -l, --logfile <path>` | Save log output to a custom file instead of `/var/log/upml/upml-YYYY-MM-DD.log`. |
| `upml -s, --set-webhook`    | Set or update your Discord Webhook URL in `/etc/upml.conf`.                      |
| `upml -c, --show-config`    | Display the current configuration (Webhook and Log Directory).                   |
| `upml -h, --help`           | Show help information for available options.                                     |
| `upml -v, --version`        | Display the current version of upml.                                             |

### Examples

Run normally:

```console
sudo upml
```

Simulate operations (no changes):

```console
sudo upml --dry-run
```

Run without sending Discord notifications:

```console
sudo upml --no-discord
```

Save logs to a custom location:

```console
sudo upml --logfile /tmp/upml-test.log
```

Combine multiple options:

```console
sudo upml --dry-run --no-discord --logfile /tmp/test.log
```

<p align="right">(<a href="#top">back to top</a>)</p>

## Uninstallation

To completely remove `upml`:

If you installed using the .deb package:

```console
sudo apt remove upml
```

If you installed manually, run:

**Step 1: Make the uninstaller executable:**

```console
chmod +x scripts/uninstaller.sh
```

**Step 2: Run the uninstaller:**

```console
sudo ./scripts/uninstaller.sh
```

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing

If you are interested in helping contribute, please take a look at our [contribution guidelines][contributing-url] and open an [issue][issues-url] or [pull request][pull-request-url].

<p align="right">(<a href="#top">back to top</a>)</p>

## Changelog

See [CHANGELOG][changelog-url] for a human-readable history of changes.

<p align="right">(<a href="#top">back to top</a>)</p>

## License

Distributed under the MIT License. See [LICENSE][license-url] for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

[changelog-url]: https://github.com/demartini/upml/blob/main/CHANGELOG.md
[contributing-url]: https://github.com/demartini/.github/blob/main/CONTRIBUTING.md
[pull-request-url]: https://github.com/demartini/upml/pulls

[contributors-shield]: https://img.shields.io/github/contributors/demartini/upml.svg?style=for-the-badge&color=8bd5ca&labelColor=181926
[contributors-url]: https://github.com/demartini/upml/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/demartini/upml.svg?style=for-the-badge&color=8bd5ca&labelColor=181926
[forks-url]: https://github.com/demartini/upml/network/members
[issues-shield]: https://img.shields.io/github/issues/demartini/upml.svg?style=for-the-badge&color=8bd5ca&labelColor=181926
[issues-url]: https://github.com/demartini/upml/issues
[license-shield]: https://img.shields.io/github/license/demartini/upml.svg?style=for-the-badge&color=8bd5ca&labelColor=181926
[license-url]: https://github.com/demartini/upml/blob/main/LICENSE
[stars-shield]: https://img.shields.io/github/stars/demartini/upml.svg?style=for-the-badge&color=8bd5ca&labelColor=181926
[stars-url]: https://github.com/demartini/upml/stargazers
