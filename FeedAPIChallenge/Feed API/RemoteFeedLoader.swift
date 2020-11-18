//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            
            case let .success((data, response)):
                
                guard response.statusCode == 200 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                
                guard let remoteFeed = try? JSONDecoder().decode(RemoteFeed.self, from: data) else {
                    completion(.failure(Error.invalidData))
                    return 
                }
                
                let feedItems = remoteFeed.items.map { item in
                    FeedImage(
                        id: UUID(uuidString: item.image_id)!,
                        description: item.image_desc,
                        location: item.image_loc,
                        url: URL(string: item.image_url)!
                    )
                }
                                    
                completion(.success(feedItems))
                
            }
        }
    }
    
    private struct RemoteFeed: Decodable {
        struct RemoteFeedItem: Decodable {
            let image_id: String
            let image_desc: String?
            let image_loc: String?
            let image_url: String
        }
        let items: [RemoteFeedItem]
    }
}
