import UIKit

@objc class SLIndicatorBlockView: UIView {
    private let indicator = UIActivityIndicatorView(style: .whiteLarge)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        clipsToBounds = true
        isHidden = true
        layer.cornerRadius = 3
        indicator.startAnimating()
        addSubview(indicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
