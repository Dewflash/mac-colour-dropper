# ColorDrop Implementation Notes

ColorDrop is a native macOS 13+ menu bar utility. It has no main window and no Dock icon.

## App Shell

The app uses SwiftUI `MenuBarExtra` instead of a manual AppKit `NSStatusItem`. `MenuBarExtra` is available on macOS 13, matches the deployment target, and lets SwiftUI own the menu content lifecycle. A manual `NSStatusItem` would also work, but it would force us to bridge more state between AppKit callbacks and SwiftUI views.

`LSUIElement` is set to `true` in `Info.plist`. This is the bundle-level way to make the app an agent-style menu bar app without a Dock icon. `NSApp.setActivationPolicy(.accessory)` is still called at launch as a runtime backstop, but the plist is the important source of truth.

Pitfalls:

- Menu bar apps should avoid hidden main windows. This app only declares a `MenuBarExtra` scene.
- `LSUIElement` is read from the app bundle at launch. Changing it requires rebuilding/relaunching the app.
- SwiftUI menu contents are short-lived views, so durable state belongs in the `ColorDropModel` object.

## Color Picking

The picker uses AppKit `NSColorSampler`. This is safer and simpler than manual Core Graphics screen capture because AppKit owns the user-mediated eyedropper interaction and returns an `NSColor` directly. A manual sampler would need to capture screen pixels, convert from global display coordinates into image pixel coordinates, handle Retina scaling, handle multi-display origins, and manage broader privacy prompts.

Pitfalls:

- The sampler is retained by `ColorDropModel`. Keeping it as a local variable risks losing the sampler while the interaction is still in progress.
- The sampler callback is marshalled back onto the main actor before updating `@Published` state or the pasteboard.
- The callback can return `nil` when the user cancels, so cancellation is not treated as an error.

## Color Formatting

`NSColor` values are converted to sRGB before formatting. This makes HEX and RGB output predictable across color spaces. The code rounds each 0...1 component to the nearest 8-bit value and clamps defensively to 0...255.

Pitfalls:

- Reading `redComponent`, `greenComponent`, or `blueComponent` from a color in an incompatible color space can fail or produce invalid assumptions. Converting through `usingColorSpace(.sRGB)` avoids that.
- HEX output intentionally ignores alpha for the first MVP because the sampled screen pixel is meant for common design/development copy-paste workflows.

## Pasteboard

The app writes to `NSPasteboard.general`. It clears existing contents first, then writes a string value with type `.string`.

Pitfalls:

- Pasteboard access should happen on the main actor for this small UI-driven tool.
- Copying happens after the model stores the last sample, so the menu reflects the same value that was copied.
