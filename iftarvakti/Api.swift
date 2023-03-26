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
        let url = URL(string: "https://ezanvakti.herokuapp.com/vakitler/\(ilceId)")!
        let urlSession = URLSession.shared
        var users : Vakitler
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            users = try! JSONDecoder().decode(Vakitler.self, from: data)
        }
        catch {
            print("Error loading \(url): \(String(describing: error))")
            return nil
        }

        return users
    }

}
