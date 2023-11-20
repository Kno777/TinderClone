//
//  SwipingPhotosVController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 20.11.23.
//

import UIKit

class SwipingPhotosVController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var cardViewModel: CardViewModel? {
        didSet {
            
            guard let cardViewModel = cardViewModel else { return }
            
            controllers = cardViewModel.imageUrls.map({ imageUrl in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            
            setViewControllers([controllers.first!], direction: .forward, animated: true)
            
            setupBarViews()
        }
    }
    
    
    var controllers: [UIViewController] = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        view.backgroundColor = .white
        
        //setViewControllers([controllers.first!], direction: .forward, animated: true)
    }
    
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate func setupBarViews() {
        
        barsStackView.distribution = .fillEqually
        barsStackView.spacing = 4
        
        cardViewModel?.imageUrls.forEach({ _ in
            let barView = UIView()
            barView.layer.cornerRadius = 2
            barView.backgroundColor = deselectedBarColor
            
            barsStackView.addArrangedSubview(barView)
        })
        
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
        
        view.addSubview(barsStackView)
        barsStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: { $0 == currentPhotoController }) {
            barsStackView.arrangedSubviews.forEach { view in
                view.backgroundColor = deselectedBarColor
            }
            
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex { controller in
            return controller == viewController
        } ?? 0
        
        if index == self.controllers.count - 1 { return nil}
        
        return self.controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = self.controllers.firstIndex { controller in
            return controller == viewController
        } ?? 0
        
        if index == 0 { return nil}
        
        return self.controllers[index - 1]
    }

}

class PhotoController: UIViewController {
    
    let imageView = UIImageView(image: UIImage(named: "jane1"))
    
    init(imageUrl: String) {
        
        if let url = URL(string: imageUrl) {
            self.imageView.sd_setImage(with: url)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.fillSuperview()
    }
}
