import SwiftUI

struct ContentView: View {
    @StateObject private var vm = CalculatorViewModel()

    let buttons: [[CalcButton]] = [
        [.clear, .backspace, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equals]
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 10) {
                Spacer()
                Text(vm.display)
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row, id: \.self) { btn in
                            CalculatorButtonView(button: btn) { vm.tap(btn) }
                        }
                    }
                }
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 12)
        }
    }
}

struct CalculatorButtonView: View {
    let button: CalcButton
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(button.title)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(button.foreground)
                .frame(
                    width: button == .zero ? buttonWidth() * 2 + 10 : buttonWidth(),
                    height: buttonWidth()
                )
                .background(button.background)
                .clipShape(Capsule())
        }
    }

    func buttonWidth() -> CGFloat {
        (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}

enum CalcButton: String, Hashable {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case add = "+", subtract = "−", multiply = "×", divide = "÷"
    case equals = "=", clear = "C", backspace = "⌫"
    case decimal = ".", percent = "%"

    var title: String { rawValue }

    var isOperator: Bool { [.add, .subtract, .multiply, .divide, .equals].contains(self) }
    var isFunction: Bool { [.clear, .backspace, .percent].contains(self) }

    var background: Color {
        if isOperator { return .orange }
        if isFunction { return Color(.lightGray) }
        return Color(.darkGray)
    }

    var foreground: Color {
        isFunction ? .black : .white
    }
}

class CalculatorViewModel: ObservableObject {
    @Published var display = "0"
    private var operand1: Double?
    private var currentOp: CalcButton?
    private var resetNext = false

    func tap(_ btn: CalcButton) {
        switch btn {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            appendDigit(btn.rawValue)
        case .decimal:
            appendDigit(".")
        case .add, .subtract, .multiply, .divide:
            setOperator(btn)
        case .equals:
            evaluate()
        case .clear:
            display = "0"; operand1 = nil; currentOp = nil; resetNext = false
        case .backspace:
            if display.count > 1 { display.removeLast() } else { display = "0" }
        case .percent:
            if let v = Double(display) { display = format(v / 100) }
        }
    }

    private func appendDigit(_ d: String) {
        if resetNext { display = (d == "." ? "0." : d); resetNext = false; return }
        if d == "." && display.contains(".") { return }
        if display == "0" && d != "." { display = d } else { display += d }
    }

    private func setOperator(_ op: CalcButton) {
        if let _ = operand1, let _ = currentOp, !resetNext {
            evaluate()
        } else { operand1 = Double(display) }
        currentOp = op; resetNext = true
    }

    private func evaluate() {
        guard let a = operand1, let op = currentOp, let b = Double(display) else { return }
        let result: Double?
        switch op {
        case .add: result = a + b
        case .subtract: result = a - b
        case .multiply: result = a * b
        case .divide: result = b != 0 ? a / b : nil
        default: result = nil
        }
        if let r = result { display = format(r); operand1 = r }
        operand1 = nil; currentOp = nil; resetNext = true
    }

    private func format(_ v: Double) -> String {
        v == v.rounded(.towardZero) && v >= Double(Int.min) && v <= Double(Int.max)
            ? String(Int(v)) : String(v)
    }
}
