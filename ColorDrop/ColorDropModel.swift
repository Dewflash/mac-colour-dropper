import AppKit
import SwiftUI

@MainActor
final class ColorDropModel: ObservableObject {
    @Published private(set) var isPicking = false
    @Published private(set) var lastSample: ColorSample?
    @Published private(set) var lastCopiedValue: String?

    private let sampler = NSColorSampler()
    private let pasteboard: NSPasteboard

    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    func pickColor() {
        guard !isPicking else {
            return
        }

        isPicking = true

        sampler.show { [weak self] color in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.isPicking = false

                guard let color else {
                    return
                }

                guard let sample = ColorSample(color: color) else {
                    NSSound.beep()
                    return
                }

                self.lastSample = sample
                self.copy(sample.hex)
            }
        }
    }

    func copy(_ value: String) {
        pasteboard.clearContents()
        guard pasteboard.setString(value, forType: .string) else {
            NSSound.beep()
            return
        }

        lastCopiedValue = value
    }
}
