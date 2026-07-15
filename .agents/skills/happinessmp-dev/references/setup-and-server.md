# Setup And Server

Fetched from the official HappinessMP documentation on 2026-07-12.

## Source pages

- [Welcome to HappinessMP](https://happinessmp.net/docs/about)
- [Crash Reports and Your Privacy](https://happinessmp.net/docs/crash-reports)
- [Getting Started](https://happinessmp.net/docs/getting-started)
- [intro](https://happinessmp.net/docs/intro)
- [Console Commands](https://happinessmp.net/docs/server/commands)
- [Getting Started](https://happinessmp.net/docs/server/getting-started)
- [Settings](https://happinessmp.net/docs/server/settings)

---

# Welcome to HappinessMP

HappinessMP is an exciting multiplayer modification for Grand Theft Auto IV, bringing the thrill of multiplayer gameplay to the gritty streets of Liberty City. Our mod provides a seamless multiplayer environment, allowing players to connect to custom servers and enjoy endless possibilities for interaction, competition, and creating their own multiplayer experiences.

Image

### What is HappinessMP?

HappinessMP allows players to join custom servers and immerse themselves in a dynamic, open-world multiplayer experience set in the iconic setting of Liberty City. Whether you want to team up with friends, engage in epic battles, or embark on thrilling heists, our mod offers an engaging multiplayer environment to fulfill your gaming desires.

### How Does It Work?

Our mod leverages the power of modern C++ programming to seamlessly integrate with GTA IV, providing a stable and feature-rich multiplayer environment. Players can effortlessly join servers, interact with others, and experience a wide array of custom gameplay modes and activities. The mod ensures compatibility with the latest computer systems, enabling smooth performance and an immersive multiplayer experience.

### Key Features:

- **Seamless Multiplayer:** Dive into the world of Liberty City with a seamless multiplayer experience, where players can connect, play, and interact with each other in real-time.
- **Custom Servers:** Create and join custom servers tailored to your preferred gameplay style, offering a wide variety of game modes, custom maps, and unique features.
- **Scripting Support:** Unleash your creativity with the ability to script your own game modes, missions, and events, making each server unique and engaging.
- **Extensive Gameplay Options:** Enjoy a plethora of gameplay options, from team-based missions and races to open-world mayhem and role-playing experiences.

### What's Next?

We are continuously working on improving and expanding the mod based on the feedback and needs of the community. Our dedicated team of developers is committed to providing regular updates and support to ensure that HappinessMP remains a thrilling and ever-evolving multiplayer experience.

### How to Get Started?

Visit the front page to download the latest version of the mod and join our vibrant community. Whether you're a seasoned multiplayer enthusiast or a new player eager to explore the possibilities, HappinessMP welcomes everyone to join the action.

Thank you for choosing HappinessMP, and we look forward to seeing you in Liberty City!

Source: https://happinessmp.net/docs/about


---

# Crash Reports and Your Privacy

We value your privacy and want to ensure you are informed about the data we collect through crash reports. Here are some key points:

### Voluntary Submission

Sending a crash report is entirely voluntary. We will always ask for your permission before sending one. Your reports are invaluable in helping us improve our mod.

### Data Collected

When you agree to send a crash report, the following data is transmitted:

- The generated minidump
- The core log file
- The client version
- The address of the server you were connected to

### Personal Data in Minidumps

Minidumps may contain personal data such as:

- Memory contents at the time of the crash
- Information about the state of the app and the operating system

### Data Upload and Privacy Policy

The collected data is uploaded to Sentry. You can review their privacy policy [here](https://sentry.io/privacy/).

### Anonymity

No data that can identify you personally is transmitted. We ensure that the data collected cannot be traced back to the individual who sent it.

### Purpose of Data Collection

The data collected through crash reports is used solely to improve the mod. We do not use it for any other purpose.

Source: https://happinessmp.net/docs/crash-reports


---

# Getting Started

### Requirements

- Operating system: Windows 10 or higher.
  - Windows 11 is recommended.
  - Windows 7 SP 1 with all updates may work too, but isn't supported.
- An active internet connection for installation.
- WebView2 Runtime must be installed (Microsoft Edge).
- A legally purchased copy of Grand Theft Auto IV with the latest version (Complete Edition).

### Installation

1. Download HappinessMP from the main page .
2. Run the downloaded file "HappinessMP.exe".
3. From here, the launcher accompanies you through the installation process.
  - First select the location where HappinessMP should be installed.
  - Then select the location of your GTA IV installation (Normally this is already recognized and entered automatically).
  - Finally, you will be asked if you want to create a desktop shortcut for HappinessMP.
4. When the installation is complete, you will need to install the first update.

Image

### How to Play

If the installation was successful and you have successfully installed the first update, you will see a list of available servers to play on. Each server has its own game mode. To join, simply click on a server. And don't forget to set a nickname in the settings.

Image

Source: https://happinessmp.net/docs/getting-started


---

# intro

Source: https://happinessmp.net/docs/intro


---

# Console Commands

| Command | Syntax | Description |
| --- | --- | --- |
| help | `help` | Displays a list of commands. |
| stop | `stop <reason>` | Shows all players the specified reason (optional) and shuts down the server. |
| restart | `restart` | Restart the server and reconnect all players. |
| resstart | `resstart <resource>` | Start a resource. |
| resstop | `resstop <resource>` | Stop a resource. |
| resrestart | `resrestart <resource>` | Restart a resource. |
| kick | `kick <playerid>` | Disconnect a player with the specified serverID. |

Source: https://happinessmp.net/docs/server/commands


---

# Getting Started

## Download

Windows: [HappinessMP Server 2.0.0.1 Windows.zip](https://happinessmp.net/files/HappinessMP%20Server%202.0.0.1%20Windows.zip) (Last updated: 2026-06-28)

Linux: [HappinessMP Server 2.0.0.1 Linux.zip](https://happinessmp.net/files/HappinessMP%20Server%202.0.0.1%20Linux.zip) (Ubuntu 22.04, Last updated: 2026-06-28)

## Windows installation

1. Download server files from Download section.
2. Extract the ZIP archive.
3. Configure the settings.xml according to your needs (see Settings for more info).
4. Run `HappinessMP.Server.exe` .

Image

## Connect to my server

Either simply connect via the server list or use `127.0.0.1` on the direct connect page in the launcher.

Source: https://happinessmp.net/docs/server/getting-started


---

# Settings

| Setting | Description | Default Value |
| --- | --- | --- |
| hostaddress | The address the server will bind to.<br><br>Use `::` to listen on all local IPv4 & IPv6 adapters.<br>Use `0.0.0.0` to listen on all local IPv4 adapters. | `127.0.0.1` |
| hostname | The hostname players will see in the server list. | `HappinessMP Server` |
| listed | Whether the server should be displayed on the server list. | `true` |
| port | Port the server will listen on.<br><br>Allowed Range: 1024 - 65535 | `9999` |
| maxplayers | Maximum number of players the server will support.<br><br>Current max: 100 | `32` |
| episode | Select game episode to be used by server.<br><br>0 = IV<br>1 = TLAD<br>2 = TBOGT | `0` |
| secret | Secret used for encrypting client side resource files. | `changeme` |
| loglevel | Select log level for console and log file.<br><br>0 = Trace<br>1 = Debug<br>2 = Info<br>3 = Warn<br>4 = Error<br>5 = Critical<br>6 = Off | `2` |
| chat | Whether the standard chat provided by the client should be activated, usable with [chat functions](https://happinessmp.net/docs/scripting/functions/chat). | `true` |
| resource | List of resources to be loaded. |  |

Source: https://happinessmp.net/docs/server/settings

