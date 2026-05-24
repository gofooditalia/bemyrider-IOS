//
//  WebRequester.swift
//  APICalling
//
//  Created by Nirav Sapariya.
//  Copyright © 2018 NMS. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

#if DEBUG
let enableDebugLogs = true
#else
let enableDebugLogs = false
#endif

typealias dictionary = [String:Any]

class WebRequester {
    static let shared = WebRequester()
    var dataRequest:DataRequest!

    // Sessions keyed by timeout so ARC never deallocates them while a request is in flight.
    // A local `let session` goes out of scope immediately, cancelling the request silently.
    private var sessionCache: [TimeInterval: Session] = [:]

    private func cachedSession(timeout: TimeInterval) -> Session {
        if let existing = sessionCache[timeout] { return existing }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        let s = Session(configuration: configuration)
        sessionCache[timeout] = s
        return s
    }

    func requests(url:String, method:HTTPMethod = .post, parameter:dictionary = dictionary(), isLoader:Bool = true, timeout: TimeInterval = 30, completion:@escaping(Result<Any>)->Void){
        if isLoader {
            Modal.sharedAppdelegate.startLoader()
        }

        let session = cachedSession(timeout: timeout)
        if parameter.isEmpty{
            var parameter = Modal.addLanguageId(param: parameter)
               if let user = UserData.shared.getUser(),!user.user_id.isEmpty {
                               parameter["login_userid"] = user.user_id
               }
            if enableDebugLogs {
                print("API Request - URL:", url)
                print("API Request - Parameters:", parameter)
                print("API Request - Timeout:", timeout)
            }
            dataRequest = session.request(url, method: method, parameters: parameter, encoding: URLEncoding.default).validate().responseJSON { (respones) in
                switch respones.result{
                case .success(let value):
                    completion(Result.success(value))
                case.failure(let error):
                    completion(Result.failure(error))
                }
            }
        }else{
            var parameter = Modal.addLanguageId(param: parameter)
                    if let user = UserData.shared.getUser(),!user.user_id.isEmpty {
                       parameter["login_userid"] = user.user_id
                   }
            if enableDebugLogs {
                print("API Request - URL:", url)
                print("API Request - Parameters:", parameter)
                print("API Request - Timeout:", timeout)
            }
            dataRequest = session.request(url, method: method, parameters: parameter, encoding: URLEncoding.default).validate().responseJSON { (respones) in
                switch respones.result{
                case .success(let value):
                    completion(Result.success(value))
                case.failure(let error):
                     completion(Result.failure(error))
                }
            }
        }
    }

    func requestsWithImage(url:String, parameter:dictionary = dictionary(), withPostImage postImg:UIImage?, withPostImageName imgName:String?, withPostImageAry postImgsAry:[UIImage] = [UIImage](), withPostImageNameAry imgNameAry:[String] = [String](), withParamName:String, signImage:UIImage? = nil, signImageName :String = "",signParamName:String = "", completion:@escaping(Result<Any>)->Void){
        Modal.sharedAppdelegate.startLoader()
        var imgNm = "image.jpeg"
        if imgName != nil{
            imgNm = imgName!
        }
        
        var param = parameter
        if let user = UserData.shared.getUser(),!user.user_id.isEmpty {
            param["login_userid"] = user.user_id
        }
        
        if enableDebugLogs {
            print("**********************")
            print("URL: \(url)")
            print("Parameters:")
            
            for val in param.sorted(by: { $0.0 < $1.0 }){
                print("\(val.key):\(val.value)")
            }
            print("**********************")
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            if let postImg = postImg{
                let imgData:Data = WebRequester.getDataFromImage(imageName: imgNm, postImage: postImg)
                multipartFormData.append(imgData,
                                         withName: withParamName, fileName: imgNm,
                                         mimeType: WebRequester.getMimeType(imageName: imgNm))
                if enableDebugLogs {
                    print("[\(withParamName)]: \(imgNm) => \(String(describing: postImg))")
                    print("**********************")
                }
            }
            else if postImgsAry.count > 0{
                for (i,img) in postImgsAry.enumerated() {
                    multipartFormData.append(WebRequester.getDataFromImage(imageName: imgNameAry[i], postImage: img), withName: "\(withParamName)[\(i)]", fileName: imgNameAry[i], mimeType: WebRequester.getMimeType(imageName: imgNameAry[i]))
                    if enableDebugLogs {
                        print("\(withParamName)[\(i)]: \(imgNameAry[i]) => \(String(describing: img))")
                    }
                }
                if enableDebugLogs {
                    print("**********************")
                }
            }
            
            var signImg = "signImage.jpeg"
            if !signImageName.isEmpty{
                signImg = signImageName
            }
            
            if let signImage = signImage{
                let imgData:Data = WebRequester.getDataFromImage(imageName: signImg, postImage: signImage)
                multipartFormData.append(imgData,
                                         withName: signParamName, fileName: signImg,
                                         mimeType: WebRequester.getMimeType(imageName: signImg))
                if enableDebugLogs {
                    print("[\(withParamName)]: \(imgNm) => \(String(describing: postImg))")
                    print("**********************")
                }
            }
           
           for (key, value) in param {
               multipartFormData.append("\(value)".data(using: .utf8)!, withName: key as String)
           }
           
           if let str = param["avl_dat"] as? String{
               let strAry = str.components(separatedBy: ",")
               for value in strAry{
                   multipartFormData.append("\(value)".data(using: .utf8)!, withName: "avl_dat[]")
               }
           }
       },
       to: url,
       method: .post
       ).uploadProgress { _ in }.responseJSON { response in
           switch response.result {
           case .success(let value):
               completion(Result.success(value))
           case .failure(let error):
               completion(Result.failure(error))
           }
       }
    }

    func requestsWithFileData(url:String, parameter:dictionary = dictionary(), withFileData file:Data?, withFileName fileName:String, withFileAry filesAry:[Data] = [Data](), withFileNameAry fileNameAry:[String] = [String](), withParamName:String, completion:@escaping(Result<Any>)->Void){
        Modal.sharedAppdelegate.startLoader()
        
        var param = parameter
        if let user = UserData.shared.getUser(),!user.user_id.isEmpty {
            param["login_userid"] = user.user_id
        }
        
        if enableDebugLogs {
            print("**********************")
            print("URL: \(url)")
            print("Parameters:")
            
            for val in param.sorted(by: { $0.0 < $1.0 }){
                print("\(val.key):\(val.value)")
            }
            print("**********************")
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            if let postFile = file{
                multipartFormData.append(postFile,
                                         withName: withParamName, fileName: fileName,
                                         mimeType: "")
                if enableDebugLogs {
                    print("[\(withParamName)]: \(fileName) => \(String(describing: postFile))")
                    print("**********************")
                }
            }
            else if filesAry.count > 0{
                for (i,file) in filesAry.enumerated() {
                    multipartFormData.append(file, withName: "\(withParamName)[\(i)]", fileName: fileNameAry[i], mimeType: "")
                    if enableDebugLogs {
                        print("\(withParamName)[\(i)]: \(fileNameAry[i]) => \(String(describing: file))")
                    }
                }
                if enableDebugLogs {
                    print("**********************")
                }
            }
            
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key as String)
            }
        },
        to: url,
        method: .post
        ).uploadProgress { _ in }.responseJSON { response in
            switch response.result {
            case .success(let value):
                completion(Result.success(value))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
}

extension WebRequester {
    func cancelAllReuest() {
        AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    func cancelCurrentRequest() {
        dataRequest.cancel()
    }
    
    fileprivate static func getDataFromImage(imageName imgNm: String, postImage img:UIImage) -> Data {
        if (imgNm.fileExtensionOnly().caseInsensitiveCompare(string: "png")){
            return UIImagePNGRepresentation(img)!
        }
        else {
            return UIImageJPEGRepresentation(img, 1.0)!
        }
    }
    
    fileprivate static func getMimeType(imageName imgNm:String ) -> String{
        return (acceptableImageContentTypes.contains("image/\(imgNm.fileExtensionOnly())")
            ? "image/\(imgNm.fileExtensionOnly())" : "")
    }
    
    private static var acceptableImageContentTypes: Set<String> = [
        "image/tiff",
        "image/jpeg",
        "image/jpg",
        "image/gif",
        "image/png",
        "image/ico",
        "image/x-icon",
        "image/bmp",
        "image/x-bmp",
        "image/x-xbitmap",
        "image/x-ms-bmp",
        "image/x-win-bitmap"
    ]
}

extension UIImageView{
    
    func downLoadImage(url: String, placeHolderImage img: UIImage = #imageLiteral(resourceName: "small-Image-Place-Holder")) {
        let indicator:UIActivityIndicatorView = {
            let activityInd = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityInd.translatesAutoresizingMaskIntoConstraints = false
            activityInd.color = .lightGray
            activityInd.startAnimating()
            activityInd.hidesWhenStopped = true
            return activityInd
        }()
        self.image = img
        if let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let _url = URL(string: urlString){
            self.af_setImage(withURL: _url, placeholderImage: img, completion:  { (response) in
                if let image = response.value {
                    self.image = image
                    DispatchQueue.main.async {
                        indicator.stopAnimating()
                        indicator.removeFromSuperview()
                    }
                }
            })
        }else{
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}
