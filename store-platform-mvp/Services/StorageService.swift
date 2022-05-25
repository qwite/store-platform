import FirebaseStorage
import Kingfisher
import UIKit

// MARK: - Singleton Storage Service
class StorageService {
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
        var urls: [String] = []
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
                    urls.append(absoluteUrl)
                    counter += 1
                    
                    if counter == data.count {
                        completion(.success(urls))
                    }
                }
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
}

// MARK: - Storage Service Errors
extension StorageService {
    private enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
