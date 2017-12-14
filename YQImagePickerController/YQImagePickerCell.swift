//
//  YQImagePickerCell.swift
//  NiceLoo
//
//  Created by pushui on 2017/12/4.
//  Copyright © 2017年 张书鹏. All rights reserved.
//

import UIKit
import Masonry

class YQImagePickerCell: UITableViewCell {

    var titleLabel:UILabel!
    var countLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white;
        
        //标题
        titleLabel = UILabel.init(frame: CGRect(x:10,y:5,width:90,height:30));
        titleLabel.font = UIFont.systemFont(ofSize: 15);
        self.contentView .addSubview(titleLabel);
//        self.titleLabel.mas_makeConstraints { (make) in
//            make?.left.equalTo()(10);
//            make?.top.equalTo()(5);
//            make?.height.equalTo()(30);
//        }
        //countlabel
        countLabel = UILabel.init(frame: CGRect(x:120,y:5,width:60,height:30))
        countLabel.font = UIFont.systemFont(ofSize: 15);
        self.contentView.addSubview(countLabel);
        
//        self.countLabel.mas_makeConstraints { (make) in
//            make?.top.equalTo()(5);
//            make?.height.equalTo()(30);
//            make?.width.equalTo()(60);
//        }
    }
    
    //MARK:-赋值
    func setCellWithData(_ item:YQImageAlbumItem)  {
   
       self.titleLabel.text = "\(item.title ?? "") "
        let labelWidth :CGFloat = self .getStringTexWidth(textStr: item.title!, font:UIFont.systemFont(ofSize: 15.0), height: 30);
        self.titleLabel.frame = CGRect(x:10,y:5,width:labelWidth,height:30)
        //label宽
        self.titleLabel.mas_updateConstraints { (make) in
            make?.width.equalTo()(labelWidth);
        }
        self.countLabel.mas_updateConstraints { (make) in
            make?.left.equalTo()(self.titleLabel.mas_right)?.offset()(5);
        }
        self.countLabel.text = "（\(item.fetchResult.count)）"
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getStringTexWidth(textStr:String,font:UIFont,height:CGFloat) -> CGFloat {
        
        let normalText: NSString = textStr as NSString
        
        let size = CGSize(width:1000, height:height)
        
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        
//        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context:nil).size
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : Any] , context: nil).size
        
        return stringSize.width
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
