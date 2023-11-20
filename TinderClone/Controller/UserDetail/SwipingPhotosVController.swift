//
//  SwipingPhotosVController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 20.11.23.
//

import UIKit

class SwipingPhotosVController: UIPageViewController, UIPageViewControllerDataSource {

    var cardViewModel: CardViewModel? {
        didSet {
            
            guard let cardViewModel = cardViewModel else { return }
            
            controllers = cardViewModel.imageUrls.map({ imageUrl in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            
            setViewControllers([controllers.first!], direction: .forward, animated: true)
        }
    }
    
    
    var controllers: [UIViewController] = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        view.backgroundColor = .white
        
        //setViewControllers([controllers.first!], direction: .forward, animated: true)
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
