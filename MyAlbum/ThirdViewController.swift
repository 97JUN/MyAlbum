//
//  ThirdViewController.swift
//  MyAlbum
//
//  Created by 쭌이 on 2022/08/30.
//

import UIKit
import Photos

class ThirdViewController: UIViewController,UIScrollViewDelegate{

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var picture: UIImage!
    var asset: PHAsset!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        imageView.image = picture
        
   
    }
    
    @IBAction func trashButton(_ sender: Any) {
        
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets([self.asset] as NSArray)}, completionHandler: nil)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.backgroundColor = UIColor.black
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.toolbar.isHidden = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == 1.0 {
            scrollView.backgroundColor = UIColor.white
            
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.toolbar.isHidden = false
    }
        
    @IBAction func actionButton(_ sender: Any) {
        
        let objectToShare = ["공유하기"]
        
        let activityVc = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
        
        activityVc.popoverPresentationController?.sourceView = self.view
        self.present(activityVc, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
  

}
