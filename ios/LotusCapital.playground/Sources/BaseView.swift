import UIKit

public extension UIColor {
    static var themeColor: UIColor { return #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5098039216, alpha: 1)}
    static var mainColor: UIColor { return #colorLiteral(red: 0.7960784314, green: 0.4274509804, blue: 0.4156862745, alpha: 1) }
    static var primaryColor: UIColor { return #colorLiteral(red: 0.8039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1) }
    static var secondaryColorDark: UIColor { return #colorLiteral(red: 0.7333333333, green: 0.1647058824, blue: 0.1411764706, alpha: 1)}
    static var deepGrayColor: UIColor { return  #colorLiteral(red: 0.5450980392, green: 0.5450980392, blue: 0.5450980392, alpha: 1) }
    static var grayColor: UIColor {return #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)}
    static var errorColor: UIColor {return #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)}
    static var primaryColorDark: UIColor {return #colorLiteral(red: 0.5333333333, green: 0, blue: 0.003921568627, alpha: 1)}
    static var themeGreen: UIColor { return #colorLiteral(red: 0.03921568627, green: 0.662745098, blue: 0.2509803922, alpha: 1)}
    static let dimmedDarkBackground = UIColor(white: 50.0/255.0, alpha: 0.3)
    static let borderGray = UIColor(red: 235/256, green: 235/256, blue: 235/256, alpha: 1.0)
    static let darkTextColor = UIColor(red: 83/256, green: 91/256, blue: 108/256, alpha: 1.0)
    static let lightTextColor = UIColor(red: 154/256, green: 160/256, blue: 166/256, alpha: 1.0)
}

open class BaseView: UIView {
    
    open lazy var contentView: UIView = {
      let view = UIView()
        view.layer.cornerRadius = 40
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view.layoutable()
    }()

    private lazy var bottomView: UIView = {
      let view = UIView()
        view.backgroundColor = .white
        return view.layoutable()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .primaryColorDark
        configure()
        setProperties()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure() {

        addSubview(bottomView)
        addSubview(contentView)

        bottomView.leadingAnchor.align(to: leadingAnchor)
        bottomView.trailingAnchor.align(to: trailingAnchor)
        bottomView.bottomAnchor.align(to: bottomAnchor, offset: 30)
        bottomView.heightAnchor.equal(to: 100)

        contentView.topAnchor.align(to: safeAreaLayoutGuide.topAnchor)
        contentView.leadingAnchor.align(to: leadingAnchor)
        contentView.trailingAnchor.align(to: trailingAnchor)
        contentView.bottomAnchor.align(to: bottomAnchor)
    }

    public func setProperties() {
        
    }
}
