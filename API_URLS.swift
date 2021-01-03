//
//  API_URLS.swift
//  Monang Champaneri
//
//  Created by Monang Champaneri on 03/01/2021
//  Copyright © 2021 Monang Champaneri. All rights reserved.
//

import Foundation
//MARK: - ************* Header KEY **************
let HeaderXApiKey =  "X_Api_Key"
let HeaderIDKey =  "id"
let HeaderDeviceType =  "device_type"
let HeaderDeviceToken =  "device_token"
let HeaderContentType = "Content-Type"
let HeaderUserToken = "user_token"


//MARK: - ************* Header VALUE **************


let DeviceType =  "ios"
let XAPIKey =  ""
let ContentType = "application/json"

//MARK: - ************* Param **************
let kPassword =  "password"
let kEmail =  "email"
let kImage = "image"
//MARK: - ************* LOCAL API BASE URL **************

let BASE_URL = "http://google.com"

//MARK: - ********** API ************
let urlTest                     = GET_FULL_URL("")


//MARK: - ********** GET FULL URL FUNCTION ************
func GET_FULL_URL(_ endPoint: String) -> String {
    return BASE_URL + endPoint
}

//MARK: - ********** END POINT URL ************

//MARK: - ********** RESPONSE KEY  ************
struct ResponseKeys {
    static let kModelID = "id"
    static let kModleUser = "User"
}

