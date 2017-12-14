//
//  YQViewController.swift
//  NiceLoo
//
//  Created by pushui on 2017/12/2.
//  Copyright © 2017年 张书鹏. All rights reserved.
//

/*
 * 选择图片  最多选择三张
 */

import UIKit
import Photos
import PhotosUI

/*
 *相册列表项
 */
struct YQImageAlbumItem {
    //相册名称
    var title : String?
    //相册内资源
    var fetchResult:PHFetchResult<PHAsset>
}
let CELLIDENTIFIER = "YQImagePickerCell"

//MARK:相册图片选择
class YQImagePickerViewController: UIViewController {

    var tableView:UITableView?
    var items:[YQImageAlbumItem] = []
    var maxSelected:Int = Int.max
    //选择完毕后回调
    var completeHandler:((_ assets:[PHAsset])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置标题
        title = "相簿"
        //tableView
        let tabView = UITableView.init(frame: self.view.bounds)
        tabView.delegate = self;
        tabView.dataSource = self;
        tabView.separatorStyle = .none;
        tabView.backgroundColor = UIColor.lightGray;
        //设置表格相关样式属性
        tabView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tabView.rowHeight = 55
        tabView .register(YQImagePickerCell.self, forCellReuseIdentifier: CELLIDENTIFIER);
        self.tableView = tabView;
        self.view.addSubview(tabView);
    
        //添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self,
                                           action:#selector(cancel) )
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        //MARK:-申请权限
        self.getPhotosAccess()
    }
    
    //申请权限
    func getPhotosAccess(){
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                return
            }
            //列出所有系统的智能相册
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                                                      subtype: .albumRegular,
                                                                                                        options: smartOptions);
            self.convertCollection(collection: smartAlbums)
            //列出所有用户创建的相册
            let usersCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.convertCollection(collection: usersCollections as! PHFetchResult<PHAssetCollection>)
            
            //相册按包含的照片数量排序(降序)
            self.items.sort(by: { (item1, item2) -> Bool in
                return item1.fetchResult.count > item2.fetchResult.count
            })
            //异步加载表格数据 需在主线程中调用 reloadData()方法
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                
                //首次进来后直接进入第一个相册图片展示页面（相机胶卷）
                let imageCollectionVC = YQImageCollectionViewController()
                imageCollectionVC.title = self.items.first?.title
                imageCollectionVC.assetsFetchResults = self.items.first?.fetchResult
                imageCollectionVC.completeHandler = self.completeHandler
                imageCollectionVC.maxSelected = self.maxSelected
                self.navigationController?.pushViewController(imageCollectionVC,
                                                              animated: false)
                
            }
        }
    }
    //MARK:转化处理获取到的相簿
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>){
        
        for i in 0..<collection.count{
            //获取当前相簿图片
            let resultsOptions = PHFetchOptions();
            resultsOptions.sortDescriptors = [NSSortDescriptor( key : "creationDate",
                                                                                              ascending:false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                   PHAssetMediaType.image.rawValue)
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0 {
                let title = titleOfAlbumForChinse(title: c.localizedTitle)
                items.append(YQImageAlbumItem(title: title,
                                              fetchResult: assetsFetchResult))
            }
        }
    }
    //由于系统返回的相册集名称为英文，我们需要转换为中文
    private func titleOfAlbumForChinse(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        self.dismiss(animated: true, completion: nil)
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension YQImagePickerViewController: UITableViewDelegate,UITableViewDataSource {
    
    //设置单元格内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            //同一形式的单元格重复使用，在声明时已注册
            let cell = tableView.dequeueReusableCell(withIdentifier: CELLIDENTIFIER, for: indexPath)
                as! YQImagePickerCell
            let item = self.items[indexPath.row]            
            cell.setCellWithData(item);
            return cell
    }
    
    //表格单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //表格单元格选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let imageCollectionVC = YQImageCollectionViewController()

        let cell = self.tableView?.cellForRow(at: indexPath) as! YQImagePickerCell
        //设置回调函数
        imageCollectionVC.completeHandler = completeHandler
        //设置标题
        imageCollectionVC.title = cell.titleLabel.text
        //设置最多可选图片数量
        imageCollectionVC.maxSelected = self.maxSelected
        guard  let indexPath = self.tableView?.indexPath(for: cell) else { return }
        
        //获取选中的相簿信息
        let fetchResult = self.items[indexPath.row].fetchResult
        //传递相簿内的图片资源
        imageCollectionVC.assetsFetchResults = fetchResult
        self.navigationController?.pushViewController(imageCollectionVC,
                                                      animated: false)
    }
}
extension UIViewController {
    //HGImagePicker提供给外部调用的接口，同于显示图片选择页面
    func presentHGImagePicker(maxSelected:Int = Int.max,
                              completeHandler:((_ assets:[PHAsset])->())?)
        -> YQImagePickerViewController?{
            
            //获取图片选择视图控制器
            let imagePickerVC = YQImagePickerViewController()
            //设置选择完毕后的回调
            imagePickerVC.completeHandler = completeHandler
            //设置图片最多选择的数量
            imagePickerVC.maxSelected = maxSelected
            //将图片选择视图控制器外添加个导航控制器，并显示
            let nav = UINavigationController(rootViewController: imagePickerVC)
            self.present(nav, animated: true, completion: nil)
            return imagePickerVC
     }
}










































