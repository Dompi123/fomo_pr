import SwiftUI

/**
 * FOMOPicker: A standardized picker/dropdown component
 * Provides consistent selection UI with different styles and modes
 */
public struct FOMOPicker<T: Hashable>: View {
    // MARK: - Properties
    
    /// Options to display in the picker
    private let options: [PickerOption<T>]
    
    /// Currently selected option ID
    @Binding private var selectedID: T?
    
    /// Style of the picker
    private let style: PickerStyle
    
    /// Title label displayed above the picker
    private let title: String?
    
    /// Helper text displayed below the picker
    private let helperText: String?
    
    /// Error message to display when validation fails
    private let errorMessage: String?
    
    /// Placeholder text to display when no option is selected
    private let placeholder: String
    
    /// Whether the picker is enabled
    private let isEnabled: Bool
    
    /// The display mode of the picker
    private let displayMode: DisplayMode
    
    /// Action to perform when selection changes
    private let onSelectionChanged: ((T?) -> Void)?
    
    /// Selection state for multi-select mode
    @State private var multiSelection: Set<T> = []
    
    /// Track whether the picker dropdown is expanded
    @State private var isExpanded: Bool = false
    
    // MARK: - Initialization
    
    public init(
        options: [PickerOption<T>],
        selectedID: Binding<T?>,
        style: PickerStyle = .default,
        title: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        placeholder: String = "Select an option",
        isEnabled: Bool = true,
        displayMode: DisplayMode = .dropdown,
        onSelectionChanged: ((T?) -> Void)? = nil
    ) {
        self.options = options
        self._selectedID = selectedID
        self.style = style
        self.title = title
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.placeholder = placeholder
        self.isEnabled = isEnabled
        self.displayMode = displayMode
        self.onSelectionChanged = onSelectionChanged
    }
    
    // MARK: - Computed Properties
    
    /// Whether the picker is in an error state
    private var hasError: Bool {
        return errorMessage != nil && !errorMessage!.isEmpty
    }
    
    /// The border color based on current state
    private var borderColor: Color {
        if hasError {
            return FOMOTheme.Colors.error
        } else if isExpanded {
            return FOMOTheme.Colors.primary
        } else {
            return style.borderColor
        }
    }
    
    /// The currently selected option
    private var selectedOption: PickerOption<T>? {
        if let id = selectedID {
            return options.first { $0.id == id }
        }
        return nil
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title if provided
            if let title = title {
                FOMOText(title, style: .subheadline)
                    .padding(.bottom, 2)
            }
            
            // Main picker content
            Group {
                switch displayMode {
                case .dropdown:
                    dropdownPicker
                case .segmented:
                    segmentedPicker
                case .buttons:
                    buttonsPicker
                case .radio:
                    radioPicker
                }
            }
            
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
    
    // MARK: - Dropdown Picker
    
    private var dropdownPicker: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(options, id: \.id) { option in
                        Button(action: {
                            selectedID = option.id
                            onSelectionChanged?(option.id)
                            isExpanded = false
                        }) {
                            HStack {
                                // Option icon
                                if let icon = option.icon {
                                    Image(systemName: icon)
                                        .foregroundColor(option.id == selectedID ? style.accentColor : FOMOTheme.Colors.textSecondary)
                                        .frame(width: 20)
                                }
                                
                                // Option label
                                Text(option.label)
                                    .font(FOMOTheme.Typography.body)
                                    .foregroundColor(option.id == selectedID ? style.accentColor : FOMOTheme.Colors.text)
                                
                                Spacer()
                                
                                // Selection indicator
                                if option.id == selectedID {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(style.accentColor)
                                        .font(FOMOTheme.Typography.caption)
                                }
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        if option != options.last {
                            Divider()
                                .background(FOMOTheme.Colors.surfaceVariant.opacity(0.5))
                        }
                    }
                }
                .padding(.top, 8)
            },
            label: {
                HStack {
                    // Selected option icon
                    if let selectedOption = selectedOption, let icon = selectedOption.icon {
                        Image(systemName: icon)
                            .foregroundColor(isEnabled ? FOMOTheme.Colors.text : FOMOTheme.Colors.textSecondary.opacity(0.6))
                            .frame(width: 20)
                    }
                    
                    // Selected option or placeholder
                    Text(selectedOption?.label ?? placeholder)
                        .font(FOMOTheme.Typography.body)
                        .foregroundColor(
                            selectedOption == nil ?
                            FOMOTheme.Colors.textSecondary.opacity(0.8) :
                            (isEnabled ? FOMOTheme.Colors.text : FOMOTheme.Colors.textSecondary.opacity(0.6))
                        )
                    
                    Spacer()
                }
            }
        )
        .disabled(!isEnabled)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(style.backgroundColor)
        .cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
        .overlay(
            RoundedRectangle(cornerRadius: FOMOTheme.Layout.cornerRadiusRegular)
                .strokeBorder(borderColor, lineWidth: 1.5)
        )
        .accentColor(style.accentColor)
    }
    
    // MARK: - Segmented Picker
    
    private var segmentedPicker: some View {
        HStack {
            ForEach(options, id: \.id) { option in
                Button(action: {
                    selectedID = option.id
                    onSelectionChanged?(option.id)
                }) {
                    HStack(spacing: 6) {
                        if let icon = option.icon {
                            Image(systemName: icon)
                                .font(.system(size: 12))
                        }
                        
                        Text(option.label)
                            .font(FOMOTheme.Typography.caption)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        option.id == selectedID ? style.accentColor : FOMOTheme.Colors.surfaceVariant.opacity(0.5)
                    )
                    .foregroundColor(
                        option.id == selectedID ? FOMOTheme.Colors.text : FOMOTheme.Colors.textSecondary
                    )
                    .cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
                    .animation(.easeInOut(duration: 0.2), value: selectedID)
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
            }
        }
        .padding(2)
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Layout.cornerRadiusRegular + 2)
        .overlay(
            RoundedRectangle(cornerRadius: FOMOTheme.Layout.cornerRadiusRegular + 2)
                .strokeBorder(borderColor, lineWidth: 1.5)
        )
    }
    
    // MARK: - Buttons Picker
    
    private var buttonsPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(options, id: \.id) { option in
                Button(action: {
                    selectedID = option.id
                    onSelectionChanged?(option.id)
                }) {
                    HStack {
                        if let icon = option.icon {
                            Image(systemName: icon)
                                .foregroundColor(isEnabled ? style.accentColor : FOMOTheme.Colors.textSecondary.opacity(0.6))
                        }
                        
                        Text(option.label)
                            .font(FOMOTheme.Typography.body)
                            .foregroundColor(isEnabled ? FOMOTheme.Colors.text : FOMOTheme.Colors.textSecondary.opacity(0.6))
                        
                        Spacer()
                        
                        if option.id == selectedID {
                            Image(systemName: "checkmark")
                                .foregroundColor(isEnabled ? style.accentColor : style.accentColor.opacity(0.6))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(option.id == selectedID ? style.accentColor.opacity(0.1) : FOMOTheme.Colors.surface)
                    .cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
                    .overlay(
                        RoundedRectangle(cornerRadius: FOMOTheme.Layout.cornerRadiusRegular)
                            .strokeBorder(
                                option.id == selectedID ? style.accentColor : FOMOTheme.Colors.surfaceVariant.opacity(0.5),
                                lineWidth: 1.5
                            )
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
            }
        }
    }
    
    // MARK: - Radio Picker
    
    private var radioPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(options, id: \.id) { option in
                FOMOCheckbox(
                    isSelected: Binding(
                        get: { option.id == selectedID },
                        set: { _ in 
                            selectedID = option.id
                            onSelectionChanged?(option.id)
                        }
                    ),
                    label: option.label,
                    icon: option.icon,
                    style: .radio,
                    isEnabled: isEnabled
                )
            }
        }
    }
    
    // MARK: - Picker Styles
    
    public enum PickerStyle {
        case `default`
        case primary
        case premium
        case minimal
        
        var backgroundColor: Color {
            switch self {
            case .default, .primary:
                return FOMOTheme.Colors.background
            case .premium:
                return FOMOTheme.Colors.surfaceVariant.opacity(0.5)
            case .minimal:
                return .clear
            }
        }
        
        var borderColor: Color {
            switch self {
            case .default:
                return FOMOTheme.Colors.surfaceVariant
            case .primary:
                return FOMOTheme.Colors.primary.opacity(0.5)
            case .premium:
                return FOMOTheme.Colors.primary.opacity(0.5)
            case .minimal:
                return FOMOTheme.Colors.surfaceVariant.opacity(0.5)
            }
        }
        
        var accentColor: Color {
            switch self {
            case .default, .primary:
                return FOMOTheme.Colors.primary
            case .premium:
                return FOMOTheme.Colors.accent
            case .minimal:
                return FOMOTheme.Colors.textSecondary
            }
        }
    }
    
    // MARK: - Display Modes
    
    public enum DisplayMode {
        /// Traditional dropdown with expandable options
        case dropdown
        
        /// Segmented control (best for 2-5 options)
        case segmented
        
        /// Stacked buttons (best for 2-7 options)
        case buttons
        
        /// Radio button style (best for multiple options)
        case radio
    }
    
    // MARK: - Picker Option
    
    public struct PickerOption<Value: Hashable>: Identifiable, Equatable {
        public let id: Value
        public let label: String
        public let icon: String?
        
        public init(id: Value, label: String, icon: String? = nil) {
            self.id = id
            self.label = label
            self.icon = icon
        }
        
        public static func == (lhs: PickerOption, rhs: PickerOption) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

// MARK: - Modifiers

extension FOMOPicker {
    /// Set the style of the picker
    public func pickerStyle(_ style: PickerStyle) -> FOMOPicker {
        FOMOPicker(
            options: options,
            selectedID: $selectedID,
            style: style,
            title: title,
            helperText: helperText,
            errorMessage: errorMessage,
            placeholder: placeholder,
            isEnabled: isEnabled,
            displayMode: displayMode,
            onSelectionChanged: onSelectionChanged
        )
    }
    
    /// Add an error message to the picker
    public func withError(_ error: String?) -> FOMOPicker {
        FOMOPicker(
            options: options,
            selectedID: $selectedID,
            style: style,
            title: title,
            helperText: helperText,
            errorMessage: error,
            placeholder: placeholder,
            isEnabled: isEnabled,
            displayMode: displayMode,
            onSelectionChanged: onSelectionChanged
        )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 32) {
            Group {
                FOMOText("Dropdown Picker", style: .headline)
                
                StateWrapper(initialValue: "option2" as String?) { selectedID in
                    FOMOPicker(
                        options: [
                            .init(id: "option1", label: "Option 1", icon: "1.circle"),
                            .init(id: "option2", label: "Option 2", icon: "2.circle"),
                            .init(id: "option3", label: "Option 3", icon: "3.circle")
                        ],
                        selectedID: selectedID,
                        title: "Select an Option",
                        helperText: "Choose the best option for you"
                    )
                }
            }
            
            Group {
                FOMOText("Segmented Picker", style: .headline)
                
                StateWrapper(initialValue: "day" as String?) { selectedID in
                    FOMOPicker(
                        options: [
                            .init(id: "day", label: "Day", icon: "sun.max"),
                            .init(id: "week", label: "Week", icon: "calendar"),
                            .init(id: "month", label: "Month", icon: "calendar.badge.clock")
                        ],
                        selectedID: selectedID,
                        style: .primary,
                        title: "Time Period",
                        displayMode: .segmented
                    )
                }
            }
            
            Group {
                FOMOText("Button Picker", style: .headline)
                
                StateWrapper(initialValue: "standard" as String?) { selectedID in
                    FOMOPicker(
                        options: [
                            .init(id: "standard", label: "Standard Ticket - $29.99", icon: "ticket"),
                            .init(id: "vip", label: "VIP Ticket - $99.99", icon: "ticket.fill"),
                            .init(id: "group", label: "Group Package - $199.99", icon: "person.3")
                        ],
                        selectedID: selectedID,
                        style: .premium,
                        title: "Ticket Options",
                        displayMode: .buttons
                    )
                }
            }
            
            Group {
                FOMOText("Radio Picker", style: .headline)
                
                StateWrapper(initialValue: "nearby" as String?) { selectedID in
                    FOMOPicker(
                        options: [
                            .init(id: "nearby", label: "Nearby Events", icon: "location.fill"),
                            .init(id: "trending", label: "Trending Now", icon: "flame.fill"),
                            .init(id: "recommended", label: "Recommended", icon: "star.fill"),
                            .init(id: "upcoming", label: "Upcoming", icon: "calendar")
                        ],
                        selectedID: selectedID,
                        title: "Filter Events",
                        displayMode: .radio
                    )
                }
            }
            
            Group {
                FOMOText("Error State", style: .headline)
                
                StateWrapper(initialValue: nil as String?) { selectedID in
                    FOMOPicker(
                        options: [
                            .init(id: "small", label: "Small"),
                            .init(id: "medium", label: "Medium"),
                            .init(id: "large", label: "Large")
                        ],
                        selectedID: selectedID,
                        title: "Select a Size",
                        errorMessage: "Please select a size to continue"
                    )
                }
            }
        }
        .padding()
        .background(FOMOTheme.Colors.background)
    }
    .preferredColorScheme(.dark)
} 