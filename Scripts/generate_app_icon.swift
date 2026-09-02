import AppKit

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: generate_app_icon.swift OUTPUT.png\\n", stderr)
    exit(64)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let side = 1_024
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: side,
    pixelsHigh: side,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("Unable to create bitmap")
}

guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fatalError("Unable to create graphics context")
}

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

func roundedRect(_ rect: NSRect, radius: CGFloat, fill: NSColor) {
    fill.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context

// macOS supplies the outer squircle; this inner surface remains legible at 16pt.
roundedRect(NSRect(x: 40, y: 40, width: 944, height: 944), radius: 220, fill: color(0.025, 0.025, 0.03))

// Warm, understated lift behind the calendar card.
roundedRect(NSRect(x: 112, y: 118, width: 800, height: 744), radius: 150, fill: color(0.075, 0.055, 0.065))

// Camera housing: a recessed top capsule whose curved shoulders meet the card.
roundedRect(NSRect(x: 312, y: 742, width: 400, height: 148), radius: 74, fill: color(0.01, 0.01, 0.013))

// Compact calendar surface.
roundedRect(NSRect(x: 176, y: 208, width: 672, height: 490), radius: 82, fill: color(0.055, 0.055, 0.065))
roundedRect(NSRect(x: 232, y: 618, width: 560, height: 16), radius: 8, fill: color(0.956, 0.231, 0.357))

// Calendar grid: ivory date markers with a single Alcove-red current day.
let ivory = color(0.96, 0.945, 0.94)
for row in 0..<3 {
    for column in 0..<4 {
        let x = 286 + CGFloat(column) * 150
        let y = 488 - CGFloat(row) * 105
        if row == 1 && column == 2 {
            color(0.956, 0.231, 0.357).setFill()
            NSBezierPath(ovalIn: NSRect(x: x - 22, y: y - 22, width: 44, height: 44)).fill()
            ivory.setFill()
            NSBezierPath(ovalIn: NSRect(x: x - 6, y: y - 6, width: 12, height: 12)).fill()
        } else {
            roundedRect(NSRect(x: x - 13, y: y - 13, width: 26, height: 26), radius: 7, fill: ivory)
        }
    }
}

NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode PNG")
}
try png.write(to: outputURL)
