import SwiftUI

/**
 * FOMOText: A standardized typography component for consistent text styling
 * Supports various text styles with proper font sizes, weights, and colors
 */
public struct FOMOText: View {
    // MARK: - Properties
    
    private let text: String
    private let style: TextStyle
    private let alignment: TextAlignment
    private let color: Color?
    private let lineLimit: Int?
    private let truncationMode: Text.TruncationMode
    
    // MARK: - Initialization
    
    public init(
        _ text: String,
        style: TextStyle = .body,
        alignment: TextAlignment = .leading,
        color: Color? = nil,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail
    ) {
        self.text = text
        self.style = style
        self.alignment = alignment
        self.color = color
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
    }
    
    // MARK: - Body
    
    public var body: some View {
        Text(text)
            .font(style.font)
            .fontWeight(style.weight)
            .foregroundColor(color ?? style.color)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
            .truncationMode(truncationMode)
            .lineSpacing(style.lineSpacing)
            .kerning(style.letterSpacing)
            .fixedSize(horizontal: false, vertical: false)
    }
    
    // MARK: - TextStyle Enum
    
    public enum TextStyle {
        case display
        case title1
        case title2
        case headline
        case subheadline
        case body
        case bodyLarge
        case caption
        case button
        
        // Font configuration
        var font: Font {
            switch self {
            case .display:
                return .system(size: FOMOTheme.Typography.fontSizeDisplay)
            case .title1:
                return .system(size: FOMOTheme.Typography.fontSizeTitle1)
            case .title2:
                return .system(size: FOMOTheme.Typography.fontSizeTitle2)
            case .headline:
                return .system(size: FOMOTheme.Typography.fontSizeHeadline)
            case .subheadline:
                return .system(size: FOMOTheme.Typography.fontSizeSubheadline)
            case .body:
                return .system(size: FOMOTheme.Typography.fontSizeBody)
            case .bodyLarge:
                return .system(size: FOMOTheme.Typography.fontSizeBodyLarge)
            case .caption:
                return .system(size: FOMOTheme.Typography.fontSizeCaption)
            case .button:
                return .system(size: FOMOTheme.Typography.fontSizeButton)
            }
        }
        
        // Font weight
        var weight: Font.Weight {
            switch self {
            case .display, .title1:
                return FOMOTheme.Typography.fontWeightBold
            case .title2, .headline:
                return FOMOTheme.Typography.fontWeightSemibold
            case .subheadline, .bodyLarge:
                return FOMOTheme.Typography.fontWeightMedium
            case .body, .caption:
                return FOMOTheme.Typography.fontWeightRegular
            case .button:
                return FOMOTheme.Typography.fontWeightMedium
            }
        }
        
        // Text color
        var color: Color {
            switch self {
            case .display, .title1, .title2, .headline, .bodyLarge, .button:
                return FOMOTheme.Colors.text
            case .subheadline, .body:
                return FOMOTheme.Colors.text
            case .caption:
                return FOMOTheme.Colors.textSecondary
            }
        }
        
        // Line spacing
        var lineSpacing: CGFloat {
            switch self {
            case .display, .title1, .title2:
                return 4
            case .headline, .subheadline, .body, .bodyLarge:
                return 2
            case .caption, .button:
                return 0
            }
        }
        
        // Letter spacing
        var letterSpacing: CGFloat {
            switch self {
            case .display, .title1, .title2:
                return FOMOTheme.Typography.letterSpacingTight
            case .headline, .subheadline, .body, .bodyLarge, .button:
                return FOMOTheme.Typography.letterSpacingNormal
            case .caption:
                return FOMOTheme.Typography.letterSpacingWide
            }
        }
    }
}

// MARK: - Modifiers

extension FOMOText {
    public func lineLimit(_ limit: Int?) -> FOMOText {
        FOMOText(
            text,
            style: style,
            alignment: alignment,
            color: color,
            lineLimit: limit,
            truncationMode: truncationMode
        )
    }
    
    public func foregroundColor(_ newColor: Color) -> FOMOText {
        FOMOText(
            text,
            style: style,
            alignment: alignment,
            color: newColor,
            lineLimit: lineLimit,
            truncationMode: truncationMode
        )
    }
    
    public func multilineTextAlignment(_ newAlignment: TextAlignment) -> FOMOText {
        FOMOText(
            text,
            style: style,
            alignment: newAlignment,
            color: color,
            lineLimit: lineLimit,
            truncationMode: truncationMode
        )
    }
}

// MARK: - Preview

struct FOMOText_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    FOMOText("Display Text", style: .display)
                    FOMOText("Title 1 Text", style: .title1)
                    FOMOText("Title 2 Text", style: .title2)
                    FOMOText("Headline Text", style: .headline)
                    FOMOText("Subheadline Text", style: .subheadline)
                }
                
                Group {
                    FOMOText("Body Text", style: .body)
                    FOMOText("Body Large Text", style: .bodyLarge)
                    FOMOText("Caption Text", style: .caption)
                    FOMOText("Button Text", style: .button)
                }
                
                Group {
                    FOMOText("Custom Color", style: .headline, color: FOMOTheme.Colors.primary)
                    FOMOText("Center Aligned", style: .body, alignment: .center)
                    FOMOText("Line Limited Text with very long content that should be truncated after a certain number of lines", style: .body, lineLimit: 2)
                }
            }
            .padding()
            .background(FOMOTheme.Colors.background)
        }
        .preferredColorScheme(.dark)
    }
} 