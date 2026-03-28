import ServiceManagement
import SwiftUI

struct PortListView: View {
    let scanner: PortScanner
    let favoritesManager: FavoritesManager
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    private var favoritePorts: [PortEntry] {
        scanner.ports.filter { favoritesManager.isFavorite(port: $0.port) }
    }

    private var nonFavoritePorts: [PortEntry] {
        scanner.ports.filter { !favoritesManager.isFavorite(port: $0.port) }
    }

    /// Groups non-favorite ports by their project root.
    private var groupedPorts: [(projectName: String, entries: [PortEntry])] {
        let grouped = Dictionary(grouping: nonFavoritePorts) { $0.projectRoot }
        return grouped
            .map { (projectName: ($0.key as NSString).lastPathComponent, entries: $0.value.sorted { $0.port < $1.port }) }
            .sorted { $0.projectName.localizedCaseInsensitiveCompare($1.projectName) == .orderedAscending }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if scanner.ports.isEmpty {
                Text("Nenhuma porta ativa")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            } else {
                // Favorites section
                if !favoritePorts.isEmpty {
                    sectionHeader(icon: "star.fill", title: "Favoritos", color: .yellow)
                    ForEach(favoritePorts) { entry in
                        portRow(entry: entry)
                    }
                    if !nonFavoritePorts.isEmpty {
                        Divider()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                    }
                }

                // Grouped sections
                ForEach(Array(groupedPorts.enumerated()), id: \.offset) { index, group in
                    sectionHeader(icon: "folder", title: group.projectName, color: .secondary)
                    ForEach(group.entries) { entry in
                        portRow(entry: entry)
                    }
                    if index < groupedPorts.count - 1 {
                        Divider()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                    }
                }
            }

            if !scanner.ports.isEmpty {
                Divider()
                    .padding(.vertical, 2)

                Button {
                    for entry in scanner.ports {
                        ProcessManager.kill(pid: entry.pid)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        scanner.scan()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                        Text("Parar todas")
                            .font(.caption)
                    }
                    .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }

            Divider()
                .padding(.vertical, 4)

            HStack {
                Image(systemName: "arrow.clockwise")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("A cada 3s")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)

            Divider()

            Toggle("Abrir ao iniciar", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        print("Launch at login error: \(error)")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)

            Button("Sair") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
        .frame(width: 380)
    }

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private func portRow(entry: PortEntry) -> some View {
        PortRowView(
            entry: entry,
            isFavorite: favoritesManager.isFavorite(port: entry.port),
            onKill: {
                ProcessManager.kill(pid: entry.pid)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    scanner.scan()
                }
            },
            onOpenBrowser: {
                ProcessManager.openInBrowser(port: entry.port)
            },
            onRestart: {
                ProcessManager.restart(pid: entry.pid)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    scanner.scan()
                }
            },
            onToggleFavorite: {
                favoritesManager.toggle(port: entry.port)
            },
            onOpenInWarp: {
                ProcessManager.openTerminal(path: entry.projectPath)
            }
        )
    }
}
