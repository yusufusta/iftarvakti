//
//  JsonModels.swift
//  iftarvakti
//
//  Created by Yusuf Usta on 25.03.2023.
//

import Foundation

struct Il: Codable, Identifiable, Hashable {
    var id: String { SehirID }
    let SehirID: String
    let SehirAdi: String
    let SehirAdiEn: String
}

typealias Iller = [Il]


struct Ilce: Codable, Identifiable,Hashable {
    var id: String { IlceID }
    let IlceID: String
    let IlceAdi: String
    let IlceAdiEn: String
}

typealias Ilceler = [Ilce]

struct Vakit: Codable,Hashable {
    let aksam : String?
    let ayinSekliURL : String?
    let greenwichOrtalamaZamani : Double?
    let gunes : String?
    let gunesBatis : String?
    let gunesDogus : String?
    let hicriTarihKisa : String?
    let hicriTarihKisaIso8601 : String?
    let hicriTarihUzun : String?
    let hicriTarihUzunIso8601 : String?
    let ikindi : String?
    let imsak : String?
    let kibleSaati : String?
    let miladiTarihKisa : String?
    let miladiTarihKisaIso8601 : String?
    let miladiTarihUzun : String?
    let miladiTarihUzunIso8601 : String?
    let ogle : String?
    let yatsi : String?

    enum CodingKeys: String, CodingKey {

        case aksam = "Aksam"
        case ayinSekliURL = "AyinSekliURL"
        case greenwichOrtalamaZamani = "GreenwichOrtalamaZamani"
        case gunes = "Gunes"
        case gunesBatis = "GunesBatis"
        case gunesDogus = "GunesDogus"
        case hicriTarihKisa = "HicriTarihKisa"
        case hicriTarihKisaIso8601 = "HicriTarihKisaIso8601"
        case hicriTarihUzun = "HicriTarihUzun"
        case hicriTarihUzunIso8601 = "HicriTarihUzunIso8601"
        case ikindi = "Ikindi"
        case imsak = "Imsak"
        case kibleSaati = "KibleSaati"
        case miladiTarihKisa = "MiladiTarihKisa"
        case miladiTarihKisaIso8601 = "MiladiTarihKisaIso8601"
        case miladiTarihUzun = "MiladiTarihUzun"
        case miladiTarihUzunIso8601 = "MiladiTarihUzunIso8601"
        case ogle = "Ogle"
        case yatsi = "Yatsi"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        aksam = try values.decodeIfPresent(String.self, forKey: .aksam)
        ayinSekliURL = try values.decodeIfPresent(String.self, forKey: .ayinSekliURL)
        greenwichOrtalamaZamani = try values.decodeIfPresent(Double.self, forKey: .greenwichOrtalamaZamani)
        gunes = try values.decodeIfPresent(String.self, forKey: .gunes)
        gunesBatis = try values.decodeIfPresent(String.self, forKey: .gunesBatis)
        gunesDogus = try values.decodeIfPresent(String.self, forKey: .gunesDogus)
        hicriTarihKisa = try values.decodeIfPresent(String.self, forKey: .hicriTarihKisa)
        hicriTarihKisaIso8601 = try values.decodeIfPresent(String.self, forKey: .hicriTarihKisaIso8601)
        hicriTarihUzun = try values.decodeIfPresent(String.self, forKey: .hicriTarihUzun)
        hicriTarihUzunIso8601 = try values.decodeIfPresent(String.self, forKey: .hicriTarihUzunIso8601)
        ikindi = try values.decodeIfPresent(String.self, forKey: .ikindi)
        imsak = try values.decodeIfPresent(String.self, forKey: .imsak)
        kibleSaati = try values.decodeIfPresent(String.self, forKey: .kibleSaati)
        miladiTarihKisa = try values.decodeIfPresent(String.self, forKey: .miladiTarihKisa)
        miladiTarihKisaIso8601 = try values.decodeIfPresent(String.self, forKey: .miladiTarihKisaIso8601)
        miladiTarihUzun = try values.decodeIfPresent(String.self, forKey: .miladiTarihUzun)
        miladiTarihUzunIso8601 = try values.decodeIfPresent(String.self, forKey: .miladiTarihUzunIso8601)
        ogle = try values.decodeIfPresent(String.self, forKey: .ogle)
        yatsi = try values.decodeIfPresent(String.self, forKey: .yatsi)
    }
}

typealias Vakitler = [Vakit]

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

