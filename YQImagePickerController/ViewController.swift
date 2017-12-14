//
//  ViewController.swift
//  YQImagePickerController
//
//  Created by pushui on 2017/12/8.
//  Copyright © 2017年 PuShui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var button :UIButton
        button = UIButton.init(frame: CGRect(x:50,y:100,width:100,height:50));
        button.backgroundColor = UIColor.blue
        button.setTitle("图片测试", for: .normal);
//        button.addTarget(self, action: #selector(buttonTapped:), for: )
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside);
        self.view.addSubview(button);
    }

    //“开始选择照片”按钮点击
    @objc func buttonTapped(_ sender: AnyObject) {
        //开始选择照片，最多允许选择4张
        _ = self.presentHGImagePicker(maxSelected:4) { (assets) in
            //结果处理
            print("共选择了\(assets.count)张图片，分别如下：")
            for asset in assets {
                print(asset)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

