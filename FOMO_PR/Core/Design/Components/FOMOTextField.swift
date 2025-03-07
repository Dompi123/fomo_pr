import SwiftUI

/**
 * FOMOTextField: A standardized text input component
 * Supports various states including validation, error, and different field types
 */
public struct FOMOTextField: View {
    // MARK: - Properties
    
    /// Binding to the text value
    @Binding private var text: String
    
    /// Placeholder text to display when field is empty
    private let placeholder: String
    
    /// Title label displayed above the text field (optional)
    private let title: String?
    
    /// Icon to display in the field (optional)
    private let icon: String?
    
    /// Helper text displayed below the field (optional)
    private let helperText: String?
    
    /// Error message to display when validation fails (optional)
    private let errorMessage: String?
    
    /// Style of the text field
    private let style: FieldStyle
    
    /// Whether the field is currently active/focused
    @State private var isFocused: Bool = false
    
    /// Whether to hide the text (for password fields)
    @State private var isSecure: Bool = false
    
    /// Input type for the field
    private let inputType: InputType
    
    // MARK: - Initialization
    
    public init(
        text: Binding<String>,
        placeholder: String,
        title: String? = nil,
        icon: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        style: FieldStyle = .default,
        inputType: InputType = .text
    ) {
        self._text = text
        self.placeholder = placeholder
        self.title = title
        self.icon = icon
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.style = style
        self.inputType = inputType
        self.isSecure = inputType == .password
    }
    
    // MARK: - Computed Properties
    
    /// Whether the field is in an error state
    private var hasError: Bool {
        return errorMessage != nil && !errorMessage!.isEmpty
    }
    
    /// The border color based on the current state
    private var borderColor: Color {
        if hasError {
            return FOMOTheme.Colors.error
        } else if isFocused {
            return FOMOTheme.Colors.primary
        } else {
            return style.borderColor
        }
    }
    
    /// The text color to use
    private var textColor: Color {
        if hasError {
            return FOMOTheme.Colors.error
        } else {
            return FOMOTheme.Colors.text
        }
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title if provided
            if let title = title {
                FOMOText(title, style: .subheadline)
                    .padding(.bottom, 2)
            }
            
            // Main input field
            HStack(spacing: 12) {
                // Leading icon if provided
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(hasError ? FOMOTheme.Colors.error : FOMOTheme.Colors.textSecondary)
                        .frame(width: 20)
                }
                
                // Text input
                ZStack(alignment: .leading) {
                    // Placeholder
                    if text.isEmpty {
                        Text(placeholder)
                            .font(style.font)
                            .foregroundColor(FOMOTheme.Colors.textSecondary.opacity(0.8))
                    }
                    
                    // Actual text field
                    if isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                            .font(style.font)
                            .foregroundColor(textColor)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                            .font(style.font)
                            .foregroundColor(textColor)
                            .keyboardType(keyboardType)
                            .textContentType(textContentType)
                            .autocorrectionDisabled(inputType != .text)
                            .textInputAutocapitalization(autocapitalization)
                    }
                }
                
                // Trailing actions based on field type
                Group {
                    switch inputType {
                    case .password:
                        // Toggle password visibility button
                        Button(action: { isSecure.toggle() }) {
                            Image(systemName: isSecure ? "eye" : "eye.slash")
                                .foregroundColor(FOMOTheme.Colors.textSecondary)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.plain)
                        
                    case .search:
                        // Clear button for search fields
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(FOMOTheme.Colors.textSecondary)
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                        }
                        
                    case .url, .email, .number, .text:
                        // Clear button when text is not empty
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(FOMOTheme.Colors.textSecondary)
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(style.backgroundColor)
            .cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
            .overlay(
                RoundedRectangle(cornerRadius: FOMOTheme.Layout.cornerRadiusRegular)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
            
            // Helper or error text
            if hasError {
                FOMOText(errorMessage!, style: .caption, color: FOMOTheme.Colors.error)
                    .padding(.top, 4)
                    .padding(.horizontal, 4)
            } else if let helperText = helperText {
                FOMOText(helperText, style: .caption, color: FOMOTheme.Colors.textSecondary)
                    .padding(.top, 4)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    /// Determine the keyboard type based on the input type
    private var keyboardType: UIKeyboardType {
        switch inputType {
        case .email:
            return .emailAddress
        case .number:
            return .decimalPad
        case .url:
            return .URL
        case .search, .password, .text:
            return .default
        }
    }
    
    /// Determine the content type based on the input type
    private var textContentType: UITextContentType? {
        switch inputType {
        case .email:
            return .emailAddress
        case .password:
            return .password
        case .url:
            return .URL
        case .text:
            return nil
        case .search:
            return nil
        case .number:
            return nil
        }
    }
    
    /// Determine the autocapitalization based on the input type
    private var autocapitalization: TextInputAutocapitalization {
        switch inputType {
        case .email, .password, .url:
            return .never
        case .text, .search:
            return .sentences
        case .number:
            return .never
        }
    }
    
    // MARK: - Field Styles
    
    public enum FieldStyle {
        case `default`
        case filled
        case minimal
        
        var backgroundColor: Color {
            switch self {
            case .default:
                return FOMOTheme.Colors.background
            case .filled:
                return FOMOTheme.Colors.surface
            case .minimal:
                return .clear
            }
        }
        
        var borderColor: Color {
            switch self {
            case .default:
                return FOMOTheme.Colors.surfaceVariant
            case .filled:
                return .clear
            case .minimal:
                return FOMOTheme.Colors.surfaceVariant.opacity(0.5)
            }
        }
        
        var font: Font {
            return FOMOTheme.Typography.body
        }
    }
    
    // MARK: - Input Types
    
    public enum InputType {
        case text
        case email
        case password
        case number
        case url
        case search
    }
}

// MARK: - Modifiers

extension FOMOTextField {
    /// Set the style of the text field
    public func fieldStyle(_ style: FieldStyle) -> FOMOTextField {
        FOMOTextField(
            text: $text,
            placeholder: placeholder,
            title: title,
            icon: icon,
            helperText: helperText,
            errorMessage: errorMessage,
            style: style,
            inputType: inputType
        )
    }
    
    /// Add a validation error message
    public func withError(_ error: String?) -> FOMOTextField {
        FOMOTextField(
            text: $text,
            placeholder: placeholder,
            title: title,
            icon: icon,
            helperText: helperText,
            errorMessage: error,
            style: style,
            inputType: inputType
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        // Text field with title and helper text
        StateWrapper(initialValue: "") { text in
            FOMOTextField(
                text: text,
                placeholder: "Enter your name",
                title: "Full Name",
                icon: "person",
                helperText: "Please enter your legal name"
            )
        }
        
        // Email field with error
        StateWrapper(initialValue: "invalid-email") { text in
            FOMOTextField(
                text: text,
                placeholder: "Enter your email",
                title: "Email Address",
                icon: "envelope",
                errorMessage: "Please enter a valid email address",
                inputType: .email
            )
        }
        
        // Password field
        StateWrapper(initialValue: "") { text in
            FOMOTextField(
                text: text,
                placeholder: "Enter your password",
                title: "Password",
                icon: "lock",
                helperText: "Must be at least 8 characters",
                inputType: .password
            )
        }
        
        // Filled style
        StateWrapper(initialValue: "") { text in
            FOMOTextField(
                text: text,
                placeholder: "Search venues",
                icon: "magnifyingglass",
                inputType: .search
            )
            .fieldStyle(.filled)
        }
        
        // Minimal style
        StateWrapper(initialValue: "") { text in
            FOMOTextField(
                text: text,
                placeholder: "Enter promo code",
                icon: "tag",
                style: .minimal
            )
        }
    }
    .padding()
    .background(FOMOTheme.Colors.background)
    .preferredColorScheme(.dark)
}

// Helper for previews
struct StateWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content
    
    init(initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
} 