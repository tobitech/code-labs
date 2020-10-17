//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    
    let cardView = UIView()
    let videoImageView = UIImageView()
    let titleLabel = UILabel()
    let watchButton = UIButton()
    let animateButton = UIButton()
    
    var cardViewBottomConstraint: NSLayoutConstraint!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        self.view = view
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMainViewTap))
        view.addGestureRecognizer(tapGesture)
        
        setupCardView()
    }
    
    func setupCardView() {
        view.addSubview(cardView)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        
        setupCardViewConstraints()
        
        setupAnimateButton()
        setupVideoImageView()
        setupTitleLabel()
        setupWatchButton()
    }
    
    func setupCardViewConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        cardView.heightAnchor.constraint(equalToConstant: 360).isActive = true
        cardViewBottomConstraint = cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 600)
        cardViewBottomConstraint.isActive = true
    }
    
    func setupVideoImageView() {
        cardView.addSubview(videoImageView)
        videoImageView.layer.cornerRadius = 8
        videoImageView.layer.masksToBounds = true
        videoImageView.image = UIImage(named: "image.jpg")
        
        setupVideoImageViewConstraints()
    }
    
    func setupTitleLabel() {
        cardView.addSubview(titleLabel)
        titleLabel.text = "Startup Episode with Stripe Founders"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        setupTitleLabelConstraints()
    }
    
    func setupWatchButton() {
        cardView.addSubview(watchButton)
        watchButton.setTitle("Watch Now", for: .normal)
        watchButton.setTitleColor(.white, for: .normal)
        watchButton.backgroundColor = .red
        watchButton.layer.cornerRadius = 12
     
        setupWatchButtonConstraints()
    }
    
    func setupAnimateButton() {
        view.addSubview(animateButton)
        animateButton.setTitle("Animate", for: .normal)
        animateButton.setTitleColor(.white, for: .normal)
        animateButton.backgroundColor = .blue
        animateButton.layer.cornerRadius = 12
        animateButton.addTarget(self, action: #selector(handleAnimateTap), for: .touchUpInside)
        
        setupAnimateButtonConstraints()
    }
    
    func setupVideoImageViewConstraints() {
        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        videoImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 30).isActive = true
        videoImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -30).isActive = true
        videoImageView.heightAnchor.constraint(equalTo: videoImageView.widthAnchor, multiplier: 9.0/16.0).isActive = true
        videoImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 50).isActive = true
    }
    
    func setupTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
//        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.topAnchor.constraint(equalTo: videoImageView.bottomAnchor, constant: 18).isActive = true
    }
    
    func setupWatchButtonConstraints() {
        watchButton.translatesAutoresizingMaskIntoConstraints = false
        watchButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 30).isActive = true
        watchButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -30).isActive = true
        watchButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        watchButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20).isActive = true
    }
    
    func setupAnimateButtonConstraints() {
        animateButton.translatesAutoresizingMaskIntoConstraints = false
        animateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        animateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        animateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        animateButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
    }
    
    @objc func handleAnimateTap() {
        animateCard(constant: -10)
    }
    
    func animateCard(constant: CGFloat) {
        cardViewBottomConstraint.constant = constant
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleMainViewTap() {
        animateCard(constant: 600)
    }
    
}

let vc = MyViewController()
vc.preferredContentSize = CGSize(width: 320, height: 568) // iPhone X

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = vc
