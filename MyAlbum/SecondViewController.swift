//
//  SecondViewController.swift
//  MyAlbum
//
//  Created by 쭌이 on 2022/08/29.
//

import UIKit
import Photos

class SecondViewController: UIViewController,PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate {
  
   

    @IBOutlet weak var secondCollectionView: UICollectionView!
    
    @IBOutlet weak var seletToolbarItem: UIBarButtonItem!
    
   // @IBOutlet weak var cancelToolbarItem: UIBarButtonItem!
    
    @IBOutlet weak var arrangeToolbarItem: UIBarButtonItem!
    
    @IBOutlet weak var trashToolbarItem: UIBarButtonItem!
    
    
    var buttonstatus = false
    var pictures: PHFetchResult<PHAsset>!
    var albumName: String!
    var albumIndex: Int!
    
    
    let imageManager = PHCachingImageManager()
    let half: Double = Double(UIScreen.main.bounds.width / 3 - 10)
    
    
    var myrightBarButtonItem: UIBarButtonItem!
    
    var delete = [Int]() //삭제할 이미지 인덱스 저장하는곳
    
    var stop: Bool = false // 다중선택시 클릭할때 넘어가지 않도록 bool값
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: half, height: half)
        flowlayout.sectionInset = UIEdgeInsets.zero
        flowlayout.minimumLineSpacing = 20
        flowlayout.minimumInteritemSpacing = 10
        self.secondCollectionView.collectionViewLayout = flowlayout
       
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.navigationItem.title = albumName
        
        self.trashToolbarItem.isEnabled = false
        
        
        PHPhotoLibrary.shared().register(self)
        
        
    }
    
    
    
    //MARK: - 툴바기능
    //정렬
    @IBAction func ArrangeButton(_ sender: Any) {
        
        buttonstatus = !buttonstatus
        
        if buttonstatus == true {
            arrangeToolbarItem.title = "과거순"
            let reversecreationDateFet = PHFetchOptions()
            reversecreationDateFet.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            if albumName! == "Camera Roll" {
                let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                guard let userAlbum:PHAssetCollection = cameraRoll.firstObject else {
                    return
                }
                pictures = PHAsset.fetchAssets(in: userAlbum, options: reversecreationDateFet)
            }else {
                
                let listfet = PHFetchOptions()
                listfet.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
                
                let userAlbumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: listfet)
                
                let userAlbum: PHAssetCollection = userAlbumList.object(at: albumIndex-1)
                pictures = PHAsset.fetchAssets(in: userAlbum, options: reversecreationDateFet)
            }
            
            secondCollectionView.reloadData()
        } else {
            arrangeToolbarItem.title = "최신순"
            
            let creationDateFet = PHFetchOptions()
            creationDateFet.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            if albumName! == "Camera Roll"{
                let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                
                guard let userAlbum:PHAssetCollection = cameraRoll.firstObject else {
                    return
                }
                
                pictures = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
            }else {
                
                let listfet = PHFetchOptions()
                listfet.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
                
                let userAlbumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: listfet)
                
                let userAlbum: PHAssetCollection = userAlbumList.object(at: albumIndex-1)
                pictures = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
                
            }
            
            secondCollectionView.reloadData()
        }
        
        
    }
    @IBAction func selectbuttonPress(_ sender: Any) {
        self.trashToolbarItem.isEnabled = true
       
        self.arrangeToolbarItem.isEnabled = false
        self.stop = !stop
        
        
        if self.secondCollectionView.allowsMultipleSelection == false {
            self.secondCollectionView.allowsMultipleSelection = true
            seletToolbarItem.title = "취소"
        } else {
            self.secondCollectionView.allowsMultipleSelection = false
            seletToolbarItem.title = "선택"
            trashToolbarItem.isEnabled = false
            arrangeToolbarItem.isEnabled = true
            
            

        }
        
        
        
        
    }
    
   
//    @IBAction func cancelButton(_ sender: Any) {
//
//        if secondCollectionView.allowsMultipleSelection {
//            self.secondCollectionView.allowsMultipleSelection = false
//        }
//        cancelToolbarItem.isEnabled = false
//        trashToolbarItem.isEnabled = false
//
//
//
//    }
    
    @IBAction func trashButton(_ sender: Any) {
        
        guard let selectedCells = self.secondCollectionView.indexPathsForSelectedItems else {return}
        
        var asset = [PHAsset]()
        
        for indexPath in selectedCells {
            asset.append(self.pictures[indexPath.item])
        }
        

        
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(asset as NSFastEnumeration)}, completionHandler: nil)
        
        //self.secondCollectionView.reloadData()
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: PictureCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as? PictureCollectionViewCell else {
             print("error cell")
            return UICollectionViewCell()
        }
        
        let picture:PHAsset = pictures.object(at: indexPath.item)
        
        imageManager.requestImage(for: picture, targetSize: CGSize(width: half, height: half), contentMode: .aspectFill, options: nil, resultHandler: {img, _ in
            cell.imageView?.image = img
        })
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        secondCollectionView.cellForItem(at: indexPath)?.alpha = 0.7
        secondCollectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.white
       
        
        if !delete.contains(indexPath.item) {
            delete.append(indexPath.item)
        }
        print(delete)
        
        if !stop {

            guard let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") else {
                print("View controller not found")
                return
            }

            let thirdvc: ThirdViewController = vc as! ThirdViewController

            let cell:PictureCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PictureCollectionViewCell
            thirdvc.picture = cell.imageView.image

            thirdvc.asset = pictures[indexPath.item]
            self.navigationController?.pushViewController(vc, animated: true)
            self.secondCollectionView.cellForItem(at: indexPath)?.alpha = 1.0
            
            
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        secondCollectionView.cellForItem(at: indexPath)?.alpha = 1
        secondCollectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.black
        let index: Int! = delete.firstIndex(of: indexPath.item)
        delete.remove(at: index)
        print("delet: \(delete)")
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: pictures) else {
            return
        }
        
        pictures = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            
            self.secondCollectionView.reloadData()
        }
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
