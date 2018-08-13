//
//  ImageEditorController.swift
//  ImageCropper
//
//  Created by Dhanasekarapandian Srinivasan on 8/11/18.
//  Copyright © 2018 Dhanasekarapandian Srinivasan. All rights reserved.
//

import Foundation
import UIKit


protocol ImageEditingCompletedDelegate : class {
    func imageEditingCompleted(image : UIImage)
}

class ImageEditorController: UIViewController {
    
    weak var delegate : ImageEditingCompletedDelegate?
    
    @IBOutlet var imageView : TouchUIImageView!
    let shapeLayer : CAShapeLayer = CAShapeLayer()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shapeLayer.frame = CGRect.init(x: 25, y: imageView.layer.frame.size.height - 100 , width: imageView.layer.frame.size.width - 50, height: 100)

        let initialPath = UIBezierPath(rect: CGRect.init(x: 0  , y: 0 , width: shapeLayer.frame.size.width, height: 100))
        shapeLayer.path = initialPath.cgPath
        shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.45).cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        
        imageView.layer.addSublayer(shapeLayer)
        shapeLayer.name = "cropper"
        
    }
    
    @IBAction func find(_ sender : UIButton){
        self.imageView.image = cropImage(imageView.image!, toRect: shapeLayer.frame, viewWidth: imageView.frame.size.width, viewHeight: imageView.frame.size.height)
        shapeLayer.removeFromSuperlayer()
        delegate?.imageEditingCompleted(image: self.imageView.image!)
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}


class TouchUIImageView: UIImageView {
    
    var fromPoint : CGPoint?
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
        print(point)
        fromPoint = point
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self), let fp = fromPoint{
            print(point)
            let dx = point.x - fp.x
            let dy = point.y - fp.y
            if let movableLayer = layer.sublayers?.first(where: { (layer) -> Bool in
                return layer.name == "cropper"
            }){
                let size = movableLayer.frame.size
                let point = CGPoint.init(x: movableLayer.frame.origin.x + dx, y: movableLayer.frame.origin.y + dy)
                movableLayer.frame = CGRect.init(origin: point, size: size)
            }
            fromPoint = point
            
        }
        
        
    }
}
