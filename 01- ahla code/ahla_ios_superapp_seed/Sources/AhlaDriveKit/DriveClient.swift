import Foundation

public enum DriveUploadMethod { case tus, presign }

public final class DriveClient {
    public init() {}

    public func presignedPut(url: URL, data: Data, progress: ((Double)->Void)? = nil, completion: @escaping (Result<Void,Error>)->Void) {
        var req = URLRequest(url: url); req.httpMethod = "PUT"
        let task = URLSession.shared.uploadTask(with: req, from: data) { _, _, err in
            if let err = err { completion(.failure(err)); return }
            completion(.success(()))
        }
        task.resume()
    }
}
