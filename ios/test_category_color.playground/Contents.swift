import UIKit

extension UIColor {
    var name: String? {
        switch self {
        case UIColor.black: return "black"
        case UIColor.darkGray: return "darkGray"
        case UIColor.lightGray: return "lightGray"
        case UIColor.white: return "white"
        case UIColor.gray: return "gray"
        case UIColor.red: return "red"
        case UIColor.green: return "green"
        case UIColor.blue: return "blue"
        case UIColor.cyan: return "cyan"
        case UIColor.yellow: return "yellow"
        case UIColor.magenta: return "magenta"
        case UIColor.orange: return "orange"
        case UIColor.purple: return "purple"
        case UIColor.brown: return "brown"
        default: return nil
        }
    }
}

let colors = [
    UIColor.red,
    UIColor.blue,
    UIColor.green,
    UIColor.orange,
    UIColor.purple,
    UIColor.black,
    UIColor.gray
]

private func getCategoryColor(index: Int) -> UIColor {
    if index > colors.count - 1 {
        return colors[index % 7]
    } else {
        return colors[index]
    }
}


for i in 0...94 {
    print(getCategoryColor(index: i).name)
}
