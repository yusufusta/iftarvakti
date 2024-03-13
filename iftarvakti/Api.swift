//
//  Api.swift
//  iftarvakti
//
//  Created by Yusuf Usta on 24.03.2023.
//

import Foundation

class Api {
    
    init () {}

    func getIller(completion:@escaping (Iller) -> ()) {
        guard let url = URL(string: "https://ezanvakti.herokuapp.com/sehirler/2") else { return  }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let users = try! JSONDecoder().decode(Iller.self, from: data!)
            DispatchQueue.main.async {
                completion(users)
            }
        }
        .resume()
    }
    
    func getIlceler(ilId : String, completion:@escaping (Ilceler) -> ()) {
        guard let url = URL(string: "https://ezanvakti.herokuapp.com/ilceler/\(ilId)") else { return  }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let users = try! JSONDecoder().decode(Ilceler.self, from: data!)
            DispatchQueue.main.async {
                completion(users)
            }
        }
        .resume()
    }

    func getVakitler(ilceId : String, completion:@escaping (Vakitler) -> ()) {
        guard let url = URL(string: "https://ezanvakti.herokuapp.com/vakitler/\(ilceId)") else { return  }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            let users = try! JSONDecoder().decode(Vakitler.self, from: data!)
            DispatchQueue.main.async {
                completion(users)
            }
        }
        .resume()
    }
    
    func getVakitlerAsync(ilceId : String) async -> Vakitler? {
        print("ilce",ilceId)
        let url = URL(string: "https://ezanvakti.herokuapp.com/vakitler/\(ilceId)")!
        
        let cache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "vakitlerCache")
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        let urlSession = URLSession(configuration: configuration)
        var users : Vakitler
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            // Önbellekten yüklenip yüklenmediğini kontrol et
            if let httpResponse = response as? HTTPURLResponse, let cachedResponse = urlSession.configuration.urlCache?.cachedResponse(for: URLRequest(url: url)) {
            }
            
            users = try JSONDecoder().decode(Vakitler.self, from: data)
        }
        catch {
            print("Error loading \(url): \(error)")
            return nil
        }

        return users
    }
}
