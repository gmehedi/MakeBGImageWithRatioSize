//
//  ViewController.swift
//  MakeImageWithRatio
//
//  Created by Mehedi Hasan on 24/3/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var count: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedOnMakeImage(_ sender: Any) {
        count += 1
        let size = CGSize(width: 1080 * count, height: 540 * count)
        
        let topImage = UIImage(named: "topImage")!
        self.imageView.image = topImage
        let topCIImg = CIImage(image: topImage)!
        
        if let bg = topImage.getTransparentImage(1, size: size) {
            let bgCIImage = CIImage(image: bg)!
            let output = self.makeRatoImage(size: size, bGImage: bgCIImage, topImage: topCIImg)
            
            let oImg = UIImage(ciImage: output)
            
            self.imageView.image = oImg
            
        }
    }
    
    
    func makeRatoImage(size: CGSize, bGImage: CIImage, topImage: CIImage) -> CIImage {
        
        let topExtent = topImage.extent
        let bgExtent = bGImage.extent
       
        var drawImages = [CIImage]()
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        autoreleasepool() {
            while x < bgExtent.width {
                
                y = 0
                while y < bgExtent.height {
                    print("Exxtent  ", x,"    ", y,"    ", bgExtent.size)
                    var tImage = topImage.copy() as! CIImage
                    
                    let transX = x
                    let transY = bgExtent.height - y - topExtent.height
                    
                    tImage = tImage.transformed(by: CGAffineTransform(translationX: transX, y: transY))
                    drawImages.append(tImage)
                    y += topExtent.height
                }
                x += topExtent.width
            }
        }

        let filter = CIFilter(name: "CISourceOverCompositing")!
        
        var finalImage: CIImage = bGImage
        
        for ciImage in drawImages {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(finalImage, forKey: kCIInputBackgroundImageKey)
            
            if let outPut = filter.outputImage?.cropped(to: bgExtent) {

                finalImage = outPut
            }
        }
        
        return finalImage
        
    }


}




extension UIImage {
    
    func getTransparentImage(_ a: CGFloat, size: CGSize) -> UIImage? {
        
        
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { (ctx) in
            draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: a)
            
        }
    }
    
    func getColorImage(_ a: CGFloat, size: CGSize, color: CGColor) -> UIImage? {
        
        
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { (ctx) in
            let rectangle = CGRect(origin: .zero, size: size)
            ctx.cgContext.setFillColor(color)
            ctx.cgContext.setStrokeColor(UIColor.clear.cgColor)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: a)
            
        }
    }
}

extension CIImage {
    
    var correctedExtent: CIImage {
        let toTransform = CGAffineTransform(translationX: -self.extent.origin.x, y: -self.extent.origin.y)
        return self.transformed(by: toTransform)
    }
    
    func rotate(_ angle: CGFloat) -> CIImage {
        let transform = CGAffineTransform(translationX: extent.midX, y: extent.midY) .rotated(by: angle) .translatedBy(x: -extent.midX, y: -extent.midY)
        return applyingFilter("CIAffineTransform", parameters: [kCIInputTransformKey: transform])
    }
    
    func convertCIToUI() -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(self, from: self.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
