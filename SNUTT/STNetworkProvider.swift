//
//  STNetworkProvider.swift
//  SNUTT
//
//  Created by Rajin on 2018. 8. 26..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation
import Moya
import Result
import RxSwift

class STNetworkProvider: MoyaProvider<MultiTarget> {

    private struct APIKeyPlugin : PluginType {
        public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
            var request = request
            request.addValue(STConfig.sharedInstance.apiKey, forHTTPHeaderField: "x-access-apikey")
            return request
        }
    }

    private struct AccessTokenPlugin : PluginType {
        public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
            guard let token = STDefaults[.token] else {
                return request
            }
            var request = request
            request.addValue(token, forHTTPHeaderField: "x-access-token")
            return request
        }
    }

    init() {
        super.init(plugins: [APIKeyPlugin(), AccessTokenPlugin()])
    }
    func request<T: STTargetType>(
        _ target: T,
        callbackQueue: DispatchQueue? = .none,
        progress: ProgressBlock? = .none,
        completion: @escaping (_ result: Result<T.Result, MoyaError>) -> Void
        ) -> Cancellable {
        return request(.target(target), callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            switch result {
            case .success(let response):
                do {
                    #if DEBUG
                        if let request = response.request {
                            let body = request.httpBody.map { String(data: $0, encoding: .utf8) ?? "" } ?? ""
                            print("---> \(request)\n\(body)")
                        }
                        print("<--- \(String(data: response.data, encoding: .utf8) ?? "")")
                    #endif
                    let decoded = try JSONDecoder().decode(T.Result.self, from: response.data)
                    completion(.success(decoded))
                } catch let e {
                    completion(.failure(MoyaError.objectMapping(e, response)))
                }
            case .failure(let error):
                if case .underlying(_, let response) = error {
                    if let response = response {
                        #if DEBUG
                        if let request = response.request {
                            print("---> \(request)")
                        }
                        print("<--- \(String(data: response.data, encoding: .utf8) ?? "")")
                        #endif
                    }
                }
                completion(.failure(error))
            }
        })
    }

    struct STErrorDTO: Codable {
        var errcode: Int
    }

    fileprivate func translateHttpError(_ error: Error) -> STHttpError? {
        switch error {
        case MoyaError.underlying(_, let response):
            guard let data = response?.data else { return STHttpError.networkError }
            do {
                let dto = try JSONDecoder().decode(STErrorDTO.self, from: data)
                let errorCode = STErrorCode(rawValue: dto.errcode) ?? STErrorCode.SERVER_FAULT
                return STHttpError.errorCode(errorCode)
            } catch let e {
                return STHttpError.decode(e)
            }
        case MoyaError.statusCode(let response):
            let statusCode = response.statusCode
            let errorCode = STErrorCode(rawValue: statusCode) ?? STErrorCode.SERVER_FAULT
            return STHttpError.errorCode(errorCode)
        case let moya as MoyaError:
            return STHttpError.moya(moya)
        default:
            return nil
        }
    }
}

extension Reactive where Base: STNetworkProvider {

    func request<T: STTargetType>(_ target: T, callbackQueue: DispatchQueue? = nil) -> Single<T.Result> {
        return _request(target, callbackQueue: callbackQueue)
            .catchError { Single.error(self.base.translateHttpError($0) ?? $0) }
    }

    private func _request<T: STTargetType>(_ target: T, callbackQueue: DispatchQueue? = nil) -> Single<T.Result> {
        let base = self.base
        return Single.just(Void())
            .flatMap {_ in
                return Single<T.Result>.create { [weak base] single in
                    let cancellableToken = base?.request(target, callbackQueue: callbackQueue, progress: nil) { result in
                        switch result {
                        case let .success(response):
                            single(.success(response))
                        case let .failure(error):
                            single(.error(error))
                        }
                    }

                    return Disposables.create {
                        cancellableToken?.cancel()
                    }
                    }
        }
    }
}
