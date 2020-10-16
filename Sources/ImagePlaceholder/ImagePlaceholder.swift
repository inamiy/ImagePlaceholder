// MARK: - Image placeholder

// UIImage or NSImage
extension Image_
{
    /// - Parameter outline: Draws border and "X" mark.
    public static func placeholder(
        size: CGSize,
        theme: Theme = .gray,
        padding: CGFloat? = nil,
        alpha: CGFloat = 1,
        outline: Bool = false,
        alignment: NSTextAlignment = .center,
        font: Font_? = nil,
        text: @escaping (CGSize) -> String = { "\(Int($0.width))x\(Int($0.height))" }
    ) -> Image_
    {
        .make(size: size) { context in

            context.setAlpha(alpha)

            let rect = CGRect(origin: .zero, size: size)
            let padding = padding ?? calcPadding(imageSize: size)
            let textAreaSize = CGRect(origin: .zero, size: size).insetBy(dx: padding, dy: padding)

            theme.backgroundColor.setFill()
            context.fill(rect)

            if outline {
                // If backgroundColor is lighter
                if theme.backgroundColor.yuv.y > Color_(hex: 0x7f7f7f).yuv.y {
                    Color_(white: 0, alpha: 0.2).setStroke()
                }
                else {
                    Color_(white: 1, alpha: 0.3).setStroke()
                }
                context.setLineWidth(2)
                context.stroke(rect)

                context.setLineWidth(1)
                context.strokeLineSegments(between: [.zero, CGPoint(x: size.width, y: size.height)])
                context.strokeLineSegments(between: [CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: 0)])
            }

            let font = font
                ?? { () -> Font_? in
                    let fontSize = calcFontSize(textAreaSize: textAreaSize.size)
                    guard let fontSize_ = fontSize else {
                        return nil
                    }
                    return Font_.systemFont(ofSize: fontSize_)
                }()

            guard let font_ = font else { return } // No text if image is too small.

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .center

            let attributes = [
                NSAttributedString.Key.font: font_,
                NSAttributedString.Key.foregroundColor: theme.foregroundColor,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]

            let drawingOptions: DrawingOption = [
                .usesLineFragmentOrigin,
                .truncatesLastVisibleLine
            ]

            let string = text(size)
            var boundingRect = string.boundingRect(with: textAreaSize.size, options: drawingOptions, attributes: attributes, context: nil)

            boundingRect.origin = CGPoint(
                x: (size.width - boundingRect.size.width) / 2,
                y: (size.height - boundingRect.size.height) / 2
            )

            string.draw(with: boundingRect, options: drawingOptions, attributes: attributes, context: nil)

        }
    }

    private static func make(size: CGSize, draw: (CGContext) -> Void) -> Image_
    {
        #if os(iOS) || os(tvOS) || os(watchOS)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!

        draw(context)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image

        #elseif os(macOS)

        let image = NSImage(size: size)
        let imageRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        image.addRepresentation(imageRep)
        image.lockFocus()

        let context = NSGraphicsContext.current!.cgContext
        draw(context)

        image.unlockFocus()
        return image

        #endif
    }
}

// MARK: - Theme

public struct Theme
{
    public var backgroundColor: Color_
    public var foregroundColor: Color_

    public init(bg: Color_, fg: Color_)
    {
        self.backgroundColor = bg
        self.foregroundColor = fg
    }
}

// Built-in themes (Inspired from https://github.com/imsky/holder)
extension Theme
{
    public static let gray = Theme(bg: Color_(hex: 0xEEEEEE), fg: Color_(hex: 0xAAAAAA))
    public static let social = Theme(bg: Color_(hex: 0x3A5A97), fg: Color_(hex: 0xFFFFFF))
    public static let industrial = Theme(bg: Color_(hex: 0x434A52), fg: Color_(hex: 0xC2F200))
    public static let sky = Theme(bg: Color_(hex: 0x0D8FDB), fg: Color_(hex: 0xFFFFFF))
    public static let vine = Theme(bg: Color_(hex: 0x39DBAC), fg: Color_(hex: 0x1E292C))
    public static let lava = Theme(bg: Color_(hex: 0xF8591A), fg: Color_(hex: 0x1C2846))

    public static func random<T: RandomNumberGenerator>(using generator: inout T) -> Theme
    {
        switch Int.random(in: 0 ... 5, using: &generator) {
        case 0: return .gray
        case 1: return .social
        case 2: return .industrial
        case 3: return .sky
        case 4: return .vine
        case 5: return .lava
        default: return .gray
        }
    }

    public static func random() -> Theme
    {
        var rng = SystemRandomNumberGenerator()
        return .random(using: &rng)
    }
}

// MARK: - Private

private func calcPadding(imageSize: CGSize) -> CGFloat
{
    let minPadding: CGFloat = 10
    let maxPadding: CGFloat = 40

    let minLength = min(imageSize.width, imageSize.height)

    do {
        let padding = min(minLength / 10, maxPadding)
        if padding >= minPadding { return padding }
    }

    // If `imageSize` is too small, ignore `minPadding` and always set padding to `0`.
    return 0
}

private func calcFontSize(textAreaSize: CGSize) -> CGFloat?
{
    let minFontSize: CGFloat = 6
    let maxFontSize: CGFloat = 24

    do {
        let fontSize = min(textAreaSize.width / 5, maxFontSize)
        if fontSize >= minFontSize { return fontSize }
    }
    do {
        let fontSize = min(textAreaSize.width / 3, maxFontSize)
        if fontSize >= minFontSize { return fontSize }
    }

    // If `textAreaSize` is too small, no draw.
    return nil
}

extension Color_
{
    convenience init(hex: Int)
    {
        let mask = 0xFF
        let r = CGFloat((hex >> 16) & mask) / 255
        let g = CGFloat((hex >> 8) & mask) / 255
        let b = CGFloat((hex) & mask) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    /// RGB to YUV.
    /// - See: https://en.wikipedia.org/wiki/YUV
    var yuv: (y: CGFloat, u: CGFloat, v: CGFloat)
    {
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1

        self.getRed(&r, green: &g, blue: &b, alpha: nil)

        let y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        let u = -0.09991 * r - 0.33609 * g + 0.436 * b;
        let v = 0.615 * r - 0.55861 * g - 0.05639 * b;

        return (y, u, v)
    }
}

// MARK: - OS dependent shims

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias Color_ = UIColor
public typealias Font_ = UIFont
public typealias Image_ = UIImage
typealias DrawingOption = NSStringDrawingOptions

#elseif os(macOS)
import AppKit
public typealias Color_ = NSColor
public typealias Font_ = NSFont
public typealias Image_ = NSImage
typealias DrawingOption = NSString.DrawingOptions

extension NSFont
{
    func withSize(_ size: CGFloat) -> NSFont
    {
        NSFont(descriptor: self.fontDescriptor, size: size)!
    }
}
#endif
