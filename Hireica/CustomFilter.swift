////
////  CustomFilter.swift
////  Hireica
////
////  Created by HiroakiSaito on 2023/11/30.
////
//
//import Foundation
//import CoreImage
//
//class CustomFilter: CIFilter {
//    var kernel: CIKernel
//    var inputImage: CIImage?
//
//    override init() {
//        super.init()
//        self.kernel = createKernel()
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.kernel = createKernel()
//    }
//
//    func outputImage() -> CIImage? {
//        if let inputImage = self.inputImage {
//            let dod = inputImage.extent()
//            let args = [inputImage as AnyObject]
//            let dod = inputImage.extent().rectByInsetting(dx: -1, dy: -1)
//            return kernel.applyWithExtent(dod, roiCallback: {
//                   (index, rect) in
//                return rect.rectByInsetting(dx: -1, dy: -1)
//               }, arguments: args)
//        }
//        return nil
//    }
//
//    private func createKernel() -> CIKernel {
//        let kernelString =
//        "kernel vec4 RGB_to_GBR(sampler source_image)\n" +
//        "{\n" +
//            "vec4 originalColor, twistedColor;\n" +
//            "originalColor = sample(source_image, samplerCoord(source_image));\n" +
//            "twistedColor.r = originalColor.g;\n" +
//            "twistedColor.g = originalColor.b;\n" +
//            "twistedColor.b = originalColor.r ;\n" +
//            "twistedColor.a = originalColor.a;\n" +
//            "return twistedColor;\n" +
//        "}\n"
//
//        return CIKernel(string: kernelString)
//    }
//}
