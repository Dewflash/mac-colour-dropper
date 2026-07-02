import AppKit
import SwiftUI

@main
struct ColorDropApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = ColorDropModel()

    var body: some Scene {
        MenuBarExtra {
            ColorDropMenu(model: model)
        } label: {
            Label("ColorDrop", systemImage: "eyedropper")
        }
        .menuBarExtraStyle(.menu)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

struct ColorDropMenu: View {
    @ObservedObject var model: ColorDropModel

    var body: some View {
        Button {
            model.pickColor()
        } label: {
            Label(model.isPicking ? "Picking..." : "Pick Color", systemImage: "eyedropper")
        }
        .disabled(model.isPicking)

        if let sample = model.lastSample {
            Divider()

            Text("Last Color")

            Button {
                model.copy(sample.hex)
            } label: {
                Label(sample.hex, systemImage: "number")
            }

            Button {
                model.copy(sample.rgb)
            } label: {
                Label(sample.rgb, systemImage: "slider.horizontal.3")
            }
        }

        Divider()

        Button {
            NSApp.terminate(nil)
        } label: {
            Label("Quit ColorDrop", systemImage: "power")
        }
        .keyboardShortcut("q")
    }
}
