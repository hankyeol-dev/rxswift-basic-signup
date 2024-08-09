//
//  ItunesModel.swift
//  SeSACRxThreads
//
//  Created by 강한결 on 8/8/24.
//

import Foundation

struct ItunesSearchResult: Codable {
    let results: [ItunesSearch]
}

struct ItunesSearch: Codable {
    let appIcon: String
    let screenshotUrls: [String]
    let rating: Double
    let developer: String
    let version: String
    let releaseNotes: String
    let appName: String
    let appId: Int
    let genres: [String]
    
    enum CodingKeys: String, CodingKey {
        case appIcon = "artworkUrl512"
        case screenshotUrls
        case rating = "averageUserRating"
        case developer = "artistName"
        case version
        case releaseNotes
        case appName = "trackName"
        case appId = "trackId"
        case genres
    }
    
    var getGenre: String {
        return genres.first ?? "없음"
    }
    
    var getComputedRating: String {
        return String(round(rating * 10.0) / 10.0)
    }
}
