import SwiftData
import SwiftUI
import WidgetKit

/// What the widget shows: a random kudo, like pulling a note out of the jar.
struct KudoEntry: TimelineEntry {
    struct Kudo {
        let text: String
        let date: Date
        let colorName: String
    }

    let date: Date
    let kudo: Kudo?

    static let sample = KudoEntry(
        date: .now,
        kudo: Kudo(text: String(localized: "widget_sample_text"), date: .now, colorName: "yellow")
    )
}

struct KudoProvider: TimelineProvider {
    /// How long each kudo stays on screen before the next random one.
    private static let interval: TimeInterval = 4 * 60 * 60
    private static let entriesPerTimeline = 6

    func placeholder(in context: Context) -> KudoEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (KudoEntry) -> Void) {
        if context.isPreview {
            completion(.sample)
        } else {
            completion(KudoEntry(date: .now, kudo: Self.loadKudos().randomElement()))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KudoEntry>) -> Void) {
        let kudos = Self.loadKudos()
        let now = Date.now
        let entries = (0..<Self.entriesPerTimeline).map { index in
            KudoEntry(
                date: now.addingTimeInterval(Double(index) * Self.interval),
                kudo: kudos.randomElement()
            )
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    /// Kudos with text, read straight from the app's store (photo-only kudos
    /// would be an empty note here). Empty when the app hasn't run yet.
    private static func loadKudos() -> [KudoEntry.Kudo] {
        do {
            guard let container = try KudosStore.makeReadOnlyContainer() else { return [] }
            var descriptor = FetchDescriptor<AccomplishmentEntity>(
                predicate: #Predicate { $0.text != "" }
            )
            descriptor.propertiesToFetch = [\.text, \.date, \.colorHex]
            return try ModelContext(container).fetch(descriptor).map {
                KudoEntry.Kudo(text: $0.text, date: $0.date, colorName: $0.colorHex)
            }
        } catch {
            print("Widget could not read kudos: \(error)")
            return []
        }
    }
}

struct KudoWidgetView: View {
    let entry: KudoEntry
    @Environment(\.widgetFamily) private var family

    /// Sticky notes stay pastel in dark mode, so the ink stays dark too.
    private let ink = Color(red: 0.15, green: 0.13, blue: 0.1)

    var body: some View {
        Group {
            if let kudo = entry.kudo {
                VStack(alignment: .leading, spacing: 6) {
                    Text(kudo.text)
                        .font(family == .systemSmall ? .callout : .title3)
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    Text(kudo.date, format: .dateTime.day().month().year())
                        .font(.caption2)
                        .opacity(0.7)
                }
                .accessibilityElement(children: .combine)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("widget_empty_title")
                        .font(.headline)
                    Text("widget_empty_message")
                        .font(.caption)
                        .opacity(0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .foregroundStyle(ink)
        .containerBackground(for: .widget) {
            Self.noteColor(entry.kudo?.colorName ?? "yellow")
        }
    }

    private static func noteColor(_ name: String) -> Color {
        let rgb = (AccomplishmentColor(rawValue: name.lowercased()) ?? .yellow).rgbValues
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}

struct KudoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KudoWidget", provider: KudoProvider()) { entry in
            KudoWidgetView(entry: entry)
        }
        .configurationDisplayName("widget_display_name")
        .description("widget_description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct KudosWidgetBundle: WidgetBundle {
    var body: some Widget {
        KudoWidget()
    }
}

#Preview(as: .systemSmall) {
    KudoWidget()
} timeline: {
    KudoEntry.sample
    KudoEntry(date: .now, kudo: nil)
}
