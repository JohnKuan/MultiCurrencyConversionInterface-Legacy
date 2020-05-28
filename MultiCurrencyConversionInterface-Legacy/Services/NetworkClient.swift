//
//  NetworkClient.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import RxSwift

enum NetworkError: Error {
    case invalidURL
    case decodingFailed
    case unknown
}

final class NetworkClient {
    typealias Parameters = [String: String]
    var baseURL: URL?
    
    init(baseUrlString: String) {
        self.baseURL = URL(string: baseUrlString)
    }
    
    // MARK: - Generic GET
    func get<T: Decodable>(_ type: T.Type,
                           _ urlString: String,
                           parameters: Parameters = [:],
                           printURL: Bool = false)
        -> Observable<Result<T, Error>> {
            
            return Observable.create { [unowned self] observer in
                
                guard let url = URL(string: urlString,
                                    relativeTo: self.baseURL) else {
                    observer.onNext(.failure(NetworkError.invalidURL))
                    return Disposables.create()
                }
                guard var urlComponents = URLComponents(string: url.absoluteString) else {
                    observer.onNext(.failure(NetworkError.invalidURL))
                    return Disposables.create()
                }
                
                if !parameters.isEmpty {
                    urlComponents.queryItems = parameters.compactMap {
                        URLQueryItem(name: $0.key, value: $0.value)
                    }
                }
                
                var urlRequest = URLRequest(url: urlComponents.url!)
                
                urlRequest.addValue("application/json",
                                    forHTTPHeaderField: "Content-Type")
                
                print(urlRequest.url!.absoluteString)
                
                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    guard let data = data,
                        let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                            if let error = error {
                                observer.onNext(.failure(error))
                            } else {
                                observer.onNext(.failure(NetworkError.unknown))
                            }
                            return
                    }
                    
                    do {
                        let model = try JSONDecoder().decode(type, from: data)
                        observer.onNext(.success(model))
                    } catch {
                        observer.onNext(.failure(NetworkError.decodingFailed))
                    }
                    
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            }
    }
    
    // MARK: - Generic GET Array
    func getArray<T: Decodable>(_ type: [T].Type,
                                _ urlString: String,
                                parameters: Parameters = [:],
                                printURL: Bool = false)
        -> Observable<Result<[T], Error>> {
            
            return Observable.create { [unowned self] observer in
                
                guard let url = URL(string: urlString,
                                    relativeTo: self.baseURL) else {
                    observer.onNext(.failure(NetworkError.invalidURL))
                    return Disposables.create()
                }
                guard var urlComponents = URLComponents(string: url.absoluteString) else {
                    observer.onNext(.failure(NetworkError.invalidURL))
                    return Disposables.create()
                }
                
                if !parameters.isEmpty {
                    urlComponents.queryItems = parameters.compactMap {
                        URLQueryItem(name: $0.key, value: $0.value)
                    }
                }
                
                var urlRequest = URLRequest(url: urlComponents.url!)
                
                urlRequest.addValue("application/json",
                                    forHTTPHeaderField: "Content-Type")
            
                if printURL {
                    print(urlRequest.url!.absoluteString)
                }
                
                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    guard let data = data,
                        let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                            if let error = error {
                                observer.onNext(.failure(error))
                            } else {
                                observer.onNext(.failure(NetworkError.unknown))
                            }
                            return
                    }
                    
                    do {
                        let model = try JSONDecoder().decode(type, from: data)
                        observer.onNext(.success(model))
                    } catch {
                        observer.onNext(.failure(error))
                    }
                    
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            }
    }
    
    // MARK: - Basic GET Data
    /// This method does not depend on the baseURL property, so it makes sense to use it without instantiating the NetworkClient
    static func getData(_ url: URL, printURL: Bool = false) -> Observable<Result<Data, Error>> {
        return Observable.create { observer in
            
            if printURL {
                print(url.absoluteString)
            }
            
            let session = URLSession(configuration: .ephemeral)
                
            let task = session.dataTask(with: url) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                        if let error = error {
                            observer.onNext(.failure(error))
                        } else {
                            observer.onNext(.failure(NetworkError.unknown))
                        }
                        return
                }
                
                observer.onNext(.success(data))
            }
            
            task.resume()
            
            return Disposables.create {
                session.finishTasksAndInvalidate()
            }
        }
    }
}
