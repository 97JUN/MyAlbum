//
//  ViewController.swift
//  MyAlbum
//
//  Created by 쭌이 on 2022/08/28.
//

import UIKit
import Photos

class ViewController: UIViewController,UICollectionViewDataSource {

   
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    var userAsset = [PHFetchResult<PHAsset>]() //앨범별 분류된 사진저장하는곳
    var albumName = [String]() //앨범별 이름
    var assetCount = [Int]() //앨범 내부의 갯수
    
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    let half: Double = Double(UIScreen.main.bounds.width/2 - 20)
    
    override func viewWillAppear(_ animated: Bool) {
        //돌아올때마다 다시 적용시키기 위해서
        //큰글씨에서 스크롤시 작은글씨로 타이틀바 표시
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let heightSize: Double = half + 40
        
        self.navigationItem.title = "앨범"
        
        //layOut 설정
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: half, height: heightSize + 20)
        
        flowlayout.sectionInset = UIEdgeInsets.zero //여백을 0으로 만듦
        flowlayout.minimumInteritemSpacing = 20 //행 내에서의 간격
        flowlayout.minimumLineSpacing = 50 //줄 간 간격
        self.collectionView.collectionViewLayout = flowlayout
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가")
            self.requestCollection()
            OperationQueue.main.addOperation {
                self.collectionView.reloadData()
            }
        case.denied:
            print("접근 불가")
        case .notDetermined:
            print("아직 응답 없음")
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    print("사용자가 허가함")
                    self.requestCollection()
                    
                    OperationQueue.main.addOperation {
                        self.collectionView.reloadData()
                    }
                    
                case .denied:
                    print("사용자가 불허함")
                default :
                    break
                }
            })
        case .restricted:
            print("접근제한")
        case .limited:
        print("오류")
        @unknown default:
            print("오류2")
        }
       
    }
    
    
 
    //cell의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userAsset.count
    }
    
    //cell 구성 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else {
            print("error")
            return UICollectionViewCell()
            
        }
        
        //MARK: - 앨범리스트별 셀 만드는 부분
        // ex) let asset: PHasset = fetchResult.objecet(at: indexPath.item)
        
        let img: PHAsset = userAsset[indexPath.item].object(at: 0) //앨범별 처음사진 가져오기
        
        cell.albumTitle.text = albumName[indexPath.item] //셀의 albumTitle에 앨범의 이름할당
        cell.albumCount.text = "\(assetCount[indexPath.item])"
        
        imageManager.requestImage(for: img, targetSize: CGSize(width: half, height: half), contentMode: .aspectFill, options: nil, resultHandler: {img, _ in cell.imageView?.image = img
            
        })
        return cell
    }
    
    //사진가져오기
    func requestCollection() {
        
        let fetchOptions = PHFetchOptions()
        
        //최신순으로 정렬
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let listfet = PHFetchOptions()
        listfet.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
        
        
        //전체 엘범(Camera Roll)
        
        let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        guard let cameraRollCollection = cameraRoll.firstObject else {
            print("사진이 없어요")
            return
        }
        
        userAsset.append(PHAsset.fetchAssets(in: cameraRollCollection, options: fetchOptions))
        albumName.append("Camera Roll")
        assetCount.append(userAsset[0].count)
        
       
        
        
        //앨범 리스트
        
        //앨범 리스트 받기
        
        let userAlbumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: listfet)
        let albumCount = userAlbumList.count
        let userAlbum: [PHAssetCollection] = userAlbumList.objects(at: IndexSet(0..<albumCount))
        
        
        for i in 0..<albumCount{
            userAsset.append(PHAsset.fetchAssets(in: userAlbum[i], options: fetchOptions))
            print("\(i)번째 배열 \(userAlbum[i].localizedTitle!)의 사진갯수 \(userAsset[i+1].count)")
            //앨범마다 사진저장
            assetCount.append(userAsset[i+1].count) //앨범마다 사진갯수 저장
            albumName.append(userAlbum[i].localizedTitle!) //앨범마다 이름저장
        }
       
        
       
//        func photoLibraryDidChange(_ changeInstance: PHChange) {
//            guard let changes = changeInstance.changeDetails(for: userAsset) else {
//                return
//            }
//
//            userAsset = changes.fetchResultAfterChanges
//
//            OperationQueue.main.addOperation {
//
//                self.collectionView.reloadData()
//            }
//        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let nextView:SecondViewController = segue.destination as? SecondViewController else {
            return
        }
        
        guard let cell:CollectionViewCell = sender as? CollectionViewCell else {
            return
        }
        
        guard let index: IndexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        
        nextView.albumIndex = index.item
        nextView.pictures = userAsset[index.item]
        nextView.albumName = albumName[index.item]
        
        
        
    }
    
    
    
    

}

