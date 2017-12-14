//
//  YQImageCollectionViewController.swift
//  NiceLoo
//
//  Created by pushui on 2017/12/4.
//  Copyright © 2017年 张书鹏. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


let CELLINDENTIFIER = "YQImageCollectionCell"
class YQImageCollectionViewController: UIViewController {

    var collectionView:UICollectionView!
    var toolBar:UIToolbar!
    var bottomView:UIView!
    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>?
    
    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    //缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    //每次最多可选择的照片数量
    var maxSelected:Int = Int.max
    
    //照片选择完毕后的回调
    var completeHandler:((_ assets:[PHAsset])->())?
    
    //完成按钮
    var completeButton:YQImageCompletedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //layout
        let flowlayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView.init(frame: CGRect(x:0,y:0,width:screen_width,height:self.view.frame.height - 44), collectionViewLayout: flowlayout)
        collectionView.collectionViewLayout = flowlayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.lightGray
        collectionView .register(YQImageCollectionCell.self, forCellWithReuseIdentifier:CELLINDENTIFIER )
        //允许多选
        collectionView.allowsMultipleSelection = true
        self.collectionView = collectionView
        self.view.addSubview(collectionView)
        
   
        //toolbar
        toolBar = UIToolbar.init(frame: CGRect(x:0,y:collectionView.frame.maxY,width:screen_width,height:44));
        toolBar.backgroundColor = UIColor.white
//        self.view.addSubview(toolBar);
        
        bottomView = UIView.init(frame: CGRect(x:0,y:collectionView.frame.maxY,width:screen_width,height:44));
        bottomView.backgroundColor =  UIColor.white
        self.view.addSubview(bottomView)
        
        //初始化各重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
     
        //添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain,
                                           target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        //添加下方工具栏的完成按钮
        completeButton = YQImageCompletedButton.init()
        completeButton.addTarget(target: self, action: #selector(finishSelect))
        completeButton.center  = CGPoint(x: UIScreen.main.bounds.width - 50, y: 22)
        completeButton.isEnabled = false
        bottomView.addSubview(completeButton)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //根据单元格的尺寸计算需要的缩略图大小
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width:cellSize.width*scale,
                                                              height:cellSize.height*scale)
    }
    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //获取已选择个数
    func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems?.count ?? 0
    }
    //完成按钮点击
    @objc func finishSelect(){
        //取出已选择的图片资源
        var assets:[PHAsset] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths{
                assets.append(assetsFetchResults![indexPath.row] )
            }
        }
        //调用回调函数
        self.navigationController?.dismiss(animated: true, completion: {
            self.completeHandler?(assets)
        })
    }
    
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension YQImageCollectionViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
     //MARK:-numberOfSections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    //MARK:-numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.assetsFetchResults?.count)!
    }
    //返回自定义cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELLINDENTIFIER, for: indexPath) as! YQImageCollectionCell
        
        let asset = self.assetsFetchResults![indexPath.row]
        //获取缩略图
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: .aspectFill, options: nil) { (image, nfo) in
            cell.imageView?.image = image;
        }
        return cell
    }
    //返回cell 上下左右的间距
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero;
    }
    //didselected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? YQImageCollectionCell{
            //获取选中数量
            let count = self.selectedCount()
            //如果选择的个数大于最大选择数
            if count > self.maxSelected{
                //设置为不选中状态
                collectionView.deselectItem(at: indexPath, animated: false)
                //弹出提示
                let title = "你最多只能选择\(self.maxSelected)张照片"
                let alertController = UIAlertController.init(title: title, message: nil, preferredStyle: .alert);
                let cancelAction = UIAlertAction.init(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil);
            }else{//不超过最大数
                //改变完成按钮数字  播放动画
                completeButton.num = count;
                if count > 0 && !self.completeButton.isEnabled{
                    completeButton.isEnabled = true;
                }
                cell.playAnimate();
            }
            
        }
    }
    //单元格取消选中响应
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? YQImageCollectionCell{
            //获取选中数量
            let count = self.selectedCount()
            completeButton.num = count
            //改变完成按钮数字  并播放动画
            if count == 0 {
                completeButton.isEnabled = false;
            }
            cell.playAnimate();
        }
    }
    //MARK: - flowlayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 1;
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:screen_width/4-1,height:screen_width/4-1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0,0 );
    }
    
}

































