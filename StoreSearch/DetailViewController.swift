import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }

    var downloadTask: URLSessionDownloadTask?
    enum AnimationStyle {
        case slide
        case fade
    }
    
    var dismissStyle = AnimationStyle.fade
    var isPopUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255,
            blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        if searchResult != nil {
            updateUI()
        }
        if isPopUp {
            let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                           action: #selector(close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            
            view.backgroundColor = UIColor.clear
        } else {
            view.backgroundColor = UIColor(patternImage:
                UIImage(named: "LandscapeBackground")!)
            popupView.isHidden = true
            if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
                title = displayName
            }
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    // MARK:- Actions
    @IBAction func close() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:],
                                      completionHandler: nil)
        }
    }
    
    // MARK:- Helper Methods
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artist.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "artist is unknown")
        } else {
            artistNameLabel.text = searchResult.artist
        }
        
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(
            from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        // Get image
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        popupView.isHidden = false
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailViewController:
UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?, source: UIViewController) ->
        UIPresentationController? {
            return DimmingPresentationController(
                presentedViewController: presented,
                presenting: presenting)
    }
    
    func animationController(forPresented presented:
        UIViewController, presenting: UIViewController,
                          source: UIViewController) ->
        UIViewControllerAnimatedTransitioning? {
            return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed:
        UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
    
    
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
