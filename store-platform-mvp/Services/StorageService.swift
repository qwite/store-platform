import FirebaseStorage
import Kingfisher
import UIKit

// MARK: - Singleton Storage Service
final class StorageService {
    static let sharedInstance = StorageService()
    private init() {}
    
    /// Storage reference
    let storageReference = Storage.storage().reference()
    
    /*
     /items_images/file.png
     */
    
    /// Upload images for new item and return urls string to download
    func uploadItemImages(with data: [Data], completion: @escaping (Result<[String], Error>) -> ()) {
        let metadata: StorageMetadata = StorageMetadata()
        metadata.contentType = "png"
        var urls: [Int: String] = [:]
        var counter = 0 // Need for completion
        
        for item in data {
            let fileName = "\(UUID().uuidString).png"
            let reference = self.storageReference.child("items_images/\(fileName)")
            reference.putData(item, metadata: metadata) { metadata, error in
                guard let _ = metadata else {
                    counter += 1
                    return completion(.failure(StorageErrors.failedToUpload))
                }
                
                // Downloading url for insert in array
                reference.downloadURL { url, error in
                    guard let url = url else {
                        return completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    }
                    
                    let absoluteUrl = url.absoluteString
                    urls[counter] = absoluteUrl
                    counter += 1
                    
                    if counter == data.count {
                        debugPrint(urls)
                        completion(.success(urls.map({ $0.value })))
                    }
                }
            }
        }
    }
    
    func uploadImage(with data: Data, type: StoragePathType, completion: @escaping (Result<String, Error>) -> ()) {
        let fileName = "\(UUID().uuidString).png"
        let metadata: StorageMetadata = StorageMetadata()
        metadata.contentType = "png"
        
        let reference = self.storageReference.child("\(type.rawValue)/\(fileName)")
        reference.putData(data, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                return completion(.failure(error!))
            }
            
            reference.downloadURL { url, error in
                guard let url = url else {
                    return completion(.failure(StorageErrors.failedToGetDownloadUrl))
                }
                
                let absoluteUrl = url.absoluteString
                completion(.success(absoluteUrl))
            }
        }
    }
    
    func getImagesFromUrls(images: [String], size: CGSize,
                        completion: @escaping (Result<UIImageView, Error>) -> ()) {
        
        for value in 0..<images.count {
            let offset = CGFloat(value) * size.width
            let imageView = UIImageView(frame: CGRect(x: offset, y: 0, width: size.width, height: size.height))
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = false
            
            let url = URL(string: images[value])
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, options: [.cacheOriginalImage]) { result in
                switch result {
                case .success(_):
                    completion(.success(imageView))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getImageFromUrl(imageUrl: String, completion: @escaping (Result<Data, Error>) -> ()) {
        guard let url = URL(string: imageUrl) else {
            fatalError()
        }
        
        let options: KingfisherOptionsInfo  = [.cacheOriginalImage]
        
        KingfisherManager.shared.downloader.downloadImage(with: url, options: options) { result in
            switch result {
            case .success(let image):

                completion(.success(image.originalData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - Storage Service Errors
extension StorageService {
    private enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}

// MARK: - StoragePathType
extension StorageService {
    public enum StoragePathType: String {
        case brandLogo = "brands_images"
        case messageAttachment = "message_attachments_images"
    }
}
