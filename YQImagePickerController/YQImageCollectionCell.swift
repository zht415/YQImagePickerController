//
//  YQImageCollectionCell.swift
//  NiceLoo
//
//  Created by pushui on 2017/12/4.
//  Copyright © 2017年 张书鹏. All rights reserved.
//

import UIKit

class YQImageCollectionCell: UICollectionViewCell {

    var imageView :UIImageView?
    var selected_Image:UIImageView?
    //设置是否选中
    override var isSelected: Bool{
        didSet{
            if isSelected{
                selected_Image?.image = UIImage(named:"hg_image_selected")
            }else{
                selected_Image?.image = UIImage(named:"hg_image_not_selected")
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let widthCell = self.contentView.frame.size.width;
        let heightCell = self.contentView.frame.size.height;
        //图片
        imageView = UIImageView.init(frame: CGRect(x:0,y:0,width:widthCell,height:heightCell));
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        self.contentView.addSubview(imageView!);
        
        //按钮图片
        selected_Image = UIImageView.init(frame:CGRect(x:widthCell-30,y:0,width:30,height:30))
        self.contentView.addSubview(selected_Image!)

    }
    //动画
    public func playAnimate(){
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2,
                                                       animations: {
                                                        self.selected_Image?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4,
                                                       animations: {
                                                        self.selected_Image?.transform = CGAffineTransform.identity
                                    })
        }, completion: nil)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
