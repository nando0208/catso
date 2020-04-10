import Foundation

let baseURL = "https://cat-fact.herokuapp.com"

let session = URLSession.shared

let urlRequest = URL(string: baseURL + "/facts/random?animal_type=cat&amount=2")!

session.request(url: urlRequest) { (result: Result<[Fact], Error>) in

    switch result {
    case let .success(model):

        print(model)
    case let .failure(error):

        print(error.localizedDescription)
    }
}

// MARK: - Fact
struct Fact: Decodable {

    let factId: String
    let text: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {

        case factId = "_id"
        case text
        case updatedAt
    }
}

extension Data {

    func toModel<Model: Decodable>() throws -> Model {

        return try JSONDecoder().decode(Model.self, from: self)
    }
}

extension URLSession {

    func request<Model: Decodable>(url: URL,
                                   completion: @escaping (Result<Model, Error>) -> Void) {

        dataTask(with: url) { data, _, error in

            guard let data = data else {

                return completion(.failure(error ?? ApiError.noData))
            }
            do {

                let model: Model = try data.toModel()
                completion(.success(model))
            } catch let error {

                completion(.failure(error))
            }
        }.resume()
    }
}

enum ApiError: Error {

    case noData
}
