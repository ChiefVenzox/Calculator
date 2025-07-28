import SwiftUI

// Hesap makinesi butonlarının türlerini tanımlayan bir Enum.
enum CalculatorButton: String {
    case zero, one, two, three, four, five, six, seven, eight, nine
    case equals, plus, minus, multiply, divide
    case decimal, clear, negative, percent

    // Butonların renklerini belirleyen bir özellik.
    // Tema (Light/Dark Mode) ve iOS Sürümü desteği eklendi.
    func buttonColor(forScheme scheme: ColorScheme, isLiquidGlassTheme: Bool) -> Color {
        if isLiquidGlassTheme {
            // Liquid Glass teması için buton renkleri (Daha koyu versiyon)
            // Butonların daha belirgin ve koyu görünmesi için opaklık değerleri artırıldı.
            switch self {
            case .clear, .negative, .percent:
                return Color.gray.opacity(0.6)
            case .divide, .multiply, .minus, .plus:
                return Color.blue.opacity(0.7)
            case .equals:
                return Color.blue.opacity(0.9)
            default: // Rakam butonları
                // Beyaz yerine siyah ve düşük opaklık kullanarak daha koyu bir cam efekti elde edildi.
                return Color.black.opacity(0.25)
            }
        } else {
            // iOS 18 teması için Light/Dark Mode renkleri
            switch scheme {
            case .light: // Light Mode renkleri
                switch self {
                case .clear, .negative, .percent:
                    return Color(red: 220/255, green: 220/255, blue: 220/255)
                case .divide, .multiply, .minus, .plus:
                    return Color(red: 160/255, green: 200/255, blue: 255/255)
                case .equals:
                    return Color(red: 60/255, green: 130/255, blue: 255/255)
                default: // Rakam butonları
                    return Color.white
                }
            case .dark: // Dark Mode renkleri
                switch self {
                case .clear, .negative, .percent:
                    return Color(red: 165/255, green: 165/255, blue: 165/255)
                case .divide, .multiply, .minus, .plus:
                    return Color(red: 40/255, green: 100/255, blue: 200/255)
                case .equals:
                    return Color(red: 0/255, green: 70/255, blue: 180/255)
                default: // Rakam butonları
                    return Color(red: 58/255, green: 58/255, blue: 58/255)
                }
            @unknown default:
                return .gray
            }
        }
    }

    // Butonların metin renklerini belirleyen bir özellik.
    func textColor(forScheme scheme: ColorScheme, isLiquidGlassTheme: Bool) -> Color {
        if isLiquidGlassTheme {
            // Liquid Glass teması için: Aydınlık modda siyah, karanlık modda beyaz metin.
            return scheme == .light ? .black : .white
        } else {
            // iOS 18 teması için Light/Dark Mode metin renkleri
            switch scheme {
            case .light:
                switch self {
                case .equals:
                    return .white
                default:
                    return Color(red: 50/255, green: 50/255, blue: 50/255)
                }
            case .dark:
                return .white
            @unknown default:
                return .white
            }
        }
    }

    // Butonların metin değerlerini döndüren bir özellik.
    var title: String {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .equals: return "="
        case .plus: return "+"
        case .minus: return "-"
        case .multiply: return "×"
        case .divide: return "÷"
        case .decimal: return "."
        case .clear: return "AC"
        case .negative: return "+/-"
        case .percent: return "%"
        }
    }
}

// Hesap makinesi işlemlerini tanımlayan bir Enum.
enum Operation {
    case add, subtract, multiply, divide, none
}

// Ana görünüm (View) yapısı.
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var value = "0"
    @State private var currentOperation: Operation = .none
    @State private var runningNumber = 0.0
    @State private var shouldClearDisplay = false
    @State private var currentOperatorSymbol: String = ""

    // iOS sürümünü kontrol etmek için bir değişken
    // Gerçek bir uygulamada bu, ProcessInfo.processInfo.operatingSystemVersion.majorVersion olurdu.
    // Demo için 20 ve üzeri "iOS 26" varsayalım.
    private var isLiquidGlassThemeActive: Bool {
        // Simülasyon için: Eğer major version 20 veya üzeriyse Liquid Glass temasını kullan.
        // Gerçekte: ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
        // Test için bu değeri `true` yapabilirsiniz: `return true`
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 20
    }

    let buttons: [[CalculatorButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .decimal, .equals]
    ]

    var body: some View {
        ZStack {
            // Arka plan rengi veya materyali - Tema ve iOS Sürümü destekli
            if isLiquidGlassThemeActive {
                // Liquid Glass teması için arka plan materyali
                Rectangle()
                    .fill(Material.ultraThinMaterial) // Ultra ince materyal efekti
                    .edgesIgnoringSafeArea(.all)
            } else {
                // iOS 18 teması için Light/Dark Mode arka plan renkleri
                (colorScheme == .light ? Color(red: 240/255, green: 240/255, blue: 240/255) : Color.black)
                    .edgesIgnoringSafeArea(.all)
            }

            VStack(spacing: 12) {
                Spacer()

                HStack {
                    Spacer()
                    Text(currentOperatorSymbol.isEmpty ? value : "\(formatResult(runningNumber)) \(currentOperatorSymbol)")
                        .bold()
                        .font(.system(size: 90))
                        // Ekran metin rengi - Tema ve iOS Sürümü destekli
                        .foregroundColor(isLiquidGlassThemeActive ? (colorScheme == .light ? .black : .white) : (colorScheme == .light ? Color(red: 50/255, green: 50/255, blue: 50/255) : .white))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 5)

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                self.didTap(button: item)
                            }, label: {
                                Text(item.title)
                                    .font(.system(size: 32))
                                    .fontWeight(.medium)
                                    .frame(
                                        width: self.buttonWidth(item: item),
                                        height: self.buttonHeight()
                                    )
                                    // Buton arka plan rengi - Tema ve iOS Sürümü destekli
                                    .background(item.buttonColor(forScheme: colorScheme, isLiquidGlassTheme: isLiquidGlassThemeActive))
                                    // Buton metin rengi - Tema ve iOS Sürümü destekli
                                    .foregroundColor(item.textColor(forScheme: colorScheme, isLiquidGlassTheme: isLiquidGlassThemeActive))
                                    .cornerRadius(self.buttonWidth(item: item) / 2)
                                    // Gölge efekti - Her iki temada da benzer hafif gölge
                                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 3)
                            })
                        }
                    }
                }
            }
            .padding(.bottom)
        }
    }

    // MARK: - Hesap Makinesi Mantığı (Değişiklik yok)

    func didTap(button: CalculatorButton) {
        if value == "Hata" && button != .clear {
            return
        }

        switch button {
        case .plus, .minus, .multiply, .divide:
            if currentOperation != .none && !shouldClearDisplay {
                performCalculation()
                runningNumber = Double(value) ?? 0.0
            } else {
                runningNumber = Double(value) ?? 0.0
            }
            
            self.currentOperation = {
                switch button {
                case .plus: return .add
                case .minus: return .subtract
                case .multiply: return .multiply
                case .divide: return .divide
                default: return .none
                }
            }()
            self.currentOperatorSymbol = button.title
            self.shouldClearDisplay = true

        case .equals:
            performCalculation()
            self.currentOperation = .none
            self.runningNumber = 0.0
            self.shouldClearDisplay = true
            self.currentOperatorSymbol = ""

        case .clear:
            self.value = "0"
            self.runningNumber = 0.0
            self.currentOperation = .none
            self.shouldClearDisplay = false
            self.currentOperatorSymbol = ""
        case .decimal:
            if shouldClearDisplay {
                self.value = "0."
                self.shouldClearDisplay = false
                self.currentOperatorSymbol = ""
            } else if !value.contains(".") {
                self.value += "."
            }
        case .negative:
            if let doubleValue = Double(value) {
                self.value = formatResult(-doubleValue)
            }
            self.currentOperatorSymbol = ""
            
        case .percent:
            if currentOperation != .none {
                if let currentNumber = Double(value) {
                    self.value = formatResult(runningNumber * (currentNumber / 100.0))
                    self.runningNumber = 0.0
                    self.currentOperation = .none
                    self.shouldClearDisplay = true
                    self.currentOperatorSymbol = ""
                }
            } else {
                if let doubleValue = Double(value) {
                    self.value = formatResult(doubleValue / 100.0)
                }
                self.shouldClearDisplay = true
                self.currentOperatorSymbol = ""
            }

        default:
            if shouldClearDisplay {
                self.value = button.title
                self.shouldClearDisplay = false
                self.currentOperatorSymbol = ""
            } else if self.value == "0" {
                self.value = button.title
            } else {
                self.value += button.title
            }
        }
    }
    
    private func performCalculation() {
        let currentNumber = Double(value) ?? 0.0
        var result: Double = 0.0

        switch self.currentOperation {
        case .add:
            result = runningNumber + currentNumber
        case .subtract:
            result = runningNumber - currentNumber
        case .multiply:
            result = runningNumber * currentNumber
        case .divide:
            if currentNumber != 0 {
                result = runningNumber / currentNumber
            } else {
                self.value = "Hata"
                return
            }
        case .none:
            break
        }
        self.value = formatResult(result)
    }

    // MARK: - Yardımcı Fonksiyonlar (Değişiklik yok)

    func buttonWidth(item: CalculatorButton) -> CGFloat {
        let spacing: CGFloat = 12
        let totalHorizontalPadding: CGFloat = 2 * spacing
        let numberOfButtonsInRow: CGFloat = 4
        let buttonSpacing = (numberOfButtonsInRow - 1) * spacing

        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - totalHorizontalPadding - buttonSpacing

        let normalButtonWidth = availableWidth / numberOfButtonsInRow

        if item == .zero {
            return (normalButtonWidth * 2) + spacing
        }
        return normalButtonWidth
    }

    func buttonHeight() -> CGFloat {
        let spacing: CGFloat = 12
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - (5 * spacing)) / 4
    }

    func formatResult(_ result: Double) -> String {
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", result)
        } else {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 9
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false

            return formatter.string(from: NSNumber(value: result)) ?? String(result)
        }
    }
}

// MARK: - Preview (Önizleme)

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("iOS 26 Liquid Glass (Light)")
                .environment(\.colorScheme, .light)

            ContentView()
                .previewDisplayName("iOS 26 Liquid Glass (Dark)")
                .environment(\.colorScheme, .dark)
        }
    }
}
