//
//  ImageKitService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.04.26.
//

import UIKit
import FirebaseAuth
import ImageKitIO

protocol ImageKitServiceProtocol {
    func fetchAuthenticationParameters(completion: @escaping (Result<ImageKitAuthResponse, Error>) -> Void)
    func uploadProfileImage(image: Data, completion: @escaping (Result<String, Error>) -> Void)
}

final class ImageKitService: ImageKitServiceProtocol{
 
    private let authEndpoint = "https://staxbackend.vercel.app/api/images/auth"
    private let publicKey = Secrets.imageKitPublicKey
    
    /// Fetches authentication parameters from the backend.
    ///
    /// This method retrieves the current user's Firebase ID token and sends it
    /// as a Bearer token to a backend endpoint hosted on Vercel. The backend
    /// validates the token and returns the necessary authentication parameters
    /// (e.g., signature, token, expire) required for secure ImageKit operations.
    ///
    /// - Parameter completion: A completion handler returning a `Result` containing
    ///   `ImageKitAuthResponse` on success or an `Error` on failure.
    func fetchAuthenticationParameters(completion: @escaping (Result<ImageKitAuthResponse, any Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth Error", code: 401, userInfo: [NSLocalizedDescriptionKey: "User do not signin"])))
            return
        }
        
        currentUser.getIDToken { token, error in
            if let error = error{
                completion(.failure(error))
                return
            }
            
            guard let idToken = token else {
                completion(.failure(NSError(domain: "Token Error", code: 500)))
                return}
            
            guard let url = URL(string: self.authEndpoint) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error{
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    do{
                        let authResponse = try JSONDecoder().decode(ImageKitAuthResponse.self, from: data)
                        completion(.success(authResponse))
                    }catch{
                        completion(.failure(error))
                    }
                }
                
            }.resume()
            
        }
    }
    
    /// Uploads an image selected from the gallery to ImageKit using
    /// authentication parameters (signature) obtained from the Vercel backend.
    /// - Returns: A `String` representing the URL of the uploaded image in the cloud if successful.
    func uploadProfileImage(image: Data, completion: @escaping (Result<String, any Error>) -> Void) {
        
        guard let uiImage = UIImage(data: image) else{
            completion(.failure(NSError(domain: "ImageKit", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Image"])))
            return
        }
        
        
        fetchAuthenticationParameters { result in
            switch result{
            case .success(let authParameters):
                
                let fileName = "profile_\(authParameters.uid ?? UUID().uuidString).jpeg"
                let folder = "/ProfileImages"
                
                ImageKit.shared.uploader().upload(
                    file: uiImage,
                    token: authParameters.token,
                    fileName: fileName,
                    folder: folder,
                    completion: { uploadResult in
                        switch uploadResult {
                        case .success(let (_, apiResponse)):
                            if let urlString = apiResponse?.url{
                                completion(.success(urlString))
                            }else{
                                let error = NSError(domain: "ImageKit", code: 500,  userInfo: [NSLocalizedDescriptionKey: "URL is missing"])
                                completion(.failure(error))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                        
                    }
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
}
