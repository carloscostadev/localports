import SwiftUI

struct PortRowView: View {
    let entry: PortEntry
    let isFavorite: Bool
    var showPath: Bool = true
    let onKill: () -> Void
    let onOpenBrowser: () -> Void
    let onRestart: () -> Void
    let onToggleFavorite: () -> Void
    let onOpenInWarp: () -> Void
    @State private var isKilling = false

    var body: some View {
        HStack(spacing: 8) {
            Text(":\(String(entry.port))")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)

            Circle()
                .fill(isKilling ? .yellow : .green)
                .frame(width: 6, height: 6)

            Text(entry.processName)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(isKilling ? .tertiary : .tertiary)

            if showPath && entry.displayPath.contains("/") {
                Text(entry.displayPath)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(isKilling ? .tertiary : .secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.borderless)
            .help("Favorito")

            Button(action: onOpenInWarp) {
                Image(systemName: "terminal")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Abrir no Warp")
            .disabled(isKilling)

            Button(action: onOpenBrowser) {
                Image(systemName: "globe")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Abrir no browser")
            .disabled(isKilling)

            Button {
                isKilling = true
                onRestart()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    isKilling = false
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Reiniciar processo")
            .disabled(isKilling)

            Button {
                isKilling = true
                onKill()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    isKilling = false
                }
            } label: {
                if isKilling {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: "xmark.circle")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .buttonStyle(.borderless)
            .help("Matar processo")
            .disabled(isKilling)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .opacity(isKilling ? 0.5 : 1)
    }
}
