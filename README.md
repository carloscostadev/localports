# LocalPorts

A lightweight macOS menu bar app that shows all active localhost ports. Built with SwiftUI.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Auto-detect** all TCP ports listening on localhost
- **Group by project** - ports are grouped by their project directory
- **Favorites** - pin frequently used ports to the top
- **Kill process** - stop a process with one click (SIGTERM → SIGKILL fallback)
- **Restart process** - kill and relaunch with the same command
- **Open in browser** - open `localhost:<port>` in your default browser
- **Open in terminal** - open the project directory in Warp (or Terminal.app as fallback)
- **Launch at login** - start automatically when you log in
- **Polls every 3s** - always up to date

## Installation

### Download

Download the latest `LocalPorts.zip` from [Releases](../../releases), unzip, and drag `LocalPorts.app` to `/Applications/`.

On first launch: **right-click → Open** (required because the app is not signed with an Apple Developer certificate).

### Build from source

Requirements:
- macOS 14.0+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
# Install XcodeGen (if not installed)
brew install xcodegen

# Clone and build
git clone https://github.com/carloscostadev/localports.git
cd LocalPorts
xcodegen generate
xcodebuild -scheme LocalPorts -configuration Release build SYMROOT=build

# Run
open build/Release/LocalPorts.app

# Or install to Applications
cp -r build/Release/LocalPorts.app /Applications/
```

## Usage

Once running, LocalPorts appears in your menu bar with a network icon and the number of active ports.

Click the icon to see all active localhost ports grouped by project. Each port shows:

| Icon | Action |
|------|--------|
| ★ | Toggle favorite |
| ▶ Terminal | Open project in terminal (Warp or Terminal.app) |
| 🌐 Globe | Open in browser |
| ↻ Arrow | Restart process |
| ✕ X | Kill process |

### Port detection

LocalPorts uses `lsof` to detect all TCP ports in LISTEN state. It resolves the working directory of each process to show which project each port belongs to.

System processes (AirPlay, Warp, Figma, GitHub Desktop, etc.) are automatically filtered out.

### Project grouping

Ports are grouped by project root, detected by looking for `.git`, `package.json`, `Gemfile`, `composer.json`, or `go.mod` in parent directories.

## Configuration

- **Favorites** - click the star icon to pin a port to the top (persisted in UserDefaults)
- **Launch at login** - toggle in the dropdown menu
- **Quit** - click "Sair" in the dropdown

## Tech Stack

- Swift 6 + SwiftUI
- `MenuBarExtra` with `.window` style
- `lsof` for port detection
- `ServiceManagement` for launch at login
- XcodeGen for project generation

## Contributing

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Run tests: `xcodebuild -scheme LocalPorts -destination 'platform=macOS' test`
5. Submit a PR

## License

MIT - see [LICENSE](LICENSE)
