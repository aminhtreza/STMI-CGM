//
//  AuthorizePage.swift
//  STMI-CGM
//
//  Created by iMac on 10/22/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct AuthorizePage: View {
    var clientId = "db636f69725917997f569137b6d36b2e2f1862317766a.ambrosiasys.com"
    var clientSecret = "fD2U8619VI7fdN73W3J7667X6H26eEFQAd6OM3ZBKGLRCS6Y692T1776P3"
    var redirectUri = "com.AminHamiditabar.STMI-CGM"
    
    @State var email = "aminreza3000@gmail"
    @State var password = "Aminht560942!"
    @State var showPassword = false
    
    @State var accessToken: String = ""
    @State var access_token: String = ""
    @State var userSignature: String = ""
    
    @State var authenticated = false
    @State var authorized = false
    
    @State var glucoseReading = "Nothing changed"
    
    @State var begin_date = 1608167127000
    @State var end_date = 1608253527000
    
    var body: some View {
        VStack {
            if !authenticated {
                Text("Please sign in below")
                TextField("Email", text: $email)
                HStack {
                    if !showPassword {SecureField("Password", text: $password)}
                    else {TextField("Password", text: $password)}
                    Button(action: {self.showPassword.toggle()}, label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                    })
                }
                
                Button("Log in") {
                    self.authenticate()
                }
            }
            
            if !authorized && authenticated {
                Text("Please sign your initials below")
                TextField("Signature", text: $userSignature)
                Button("Submit") {
                    self.authorize()
                }
            }
            if authorized && authenticated {
                Text("\(self.glucoseReading)")
                /*
                DatePicker("Start date", selection: $startDate)
                DatePicker("End date", selection: $endDate)
                */
                Button("Get readings") {
                    self.getReadings()
                }
            }
            
        }
    }
}

extension AuthorizePage {
    func authenticate() {
        let headers = ["cache-control": "no-cache"]
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.ambrosiasys.com/app/authentication?client_id=\(clientId)&client_secret=\(clientSecret)&response_type=code&redirect_uri=\(redirectUri)&email=\(email).com&password=\(password)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(AuthenticateResponse.self, from: data) {
                    print("\(decodedResponse)")
                    self.accessToken = decodedResponse.access_token
                    return
                }
            }
            
            if (error != nil) {
                print(error?.localizedDescription ?? "Unknown error")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "No idea")
            }
        }.resume()
        withAnimation{self.authenticated = true}
    }
    
    func authorize() {
        let headers = ["cache-control": "no-cache"]
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.ambrosiasys.com/app/user_authorization?grant_type=access_token&code=\(accessToken)&signature=\(userSignature)")! as URL,
        cachePolicy: .useProtocolCachePolicy,
        timeoutInterval: 10.0)

        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(AuthorizeResponse.self, from: data) {
                    print("\(decodedResponse)")
                    self.access_token = decodedResponse.access_token
                    return
                }
            }

            if (error != nil) {
                print(error?.localizedDescription ?? "Unknown error")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "No idea")
            }
        }.resume()
        withAnimation{self.authorized = true}
        
    }
    
    func getReadings2() {
        print("Getting readigns")
        let headers = [
        "authorization": access_token,
        "cache-control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.ambrosiasys.com/app/readings?begin_date=\(self.begin_date)&end_date=\(self.end_date)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])

            if let decodedResponse = json as? [String: Any] {
                print(decodedResponse)
            }
            if (error != nil) {
                print(error?.localizedDescription ?? "Unknown error")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "No idea")
            }
        }
        print("End of function")
    }
    
    func getReadings() {
        let headers = [
            "authorization": access_token,
            "cache-control": "no-cache",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.ambrosiasys.com/app/readings?begin_date=\(self.begin_date)&end_date=\(self.end_date)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            print(json ?? "swag")

            if let decodedResponse = json as? [String: Any] {
                print(decodedResponse)
            }
            
            let json2 = try? JSONDecoder().decode(Readings.self, from: data!)
            print(json2)
            
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Readings.self, from: data) {
                    print(decodedResponse)
                    return
                }
            }
            if (error != nil) {
                print(error?.localizedDescription ?? "Unknown error")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "No idea")
            }
             
        }.resume()
        withAnimation{self.authorized = true}
    }
}

struct AuthorizePage_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizePage()
    }
}

struct Readings: Codable {
    var readings: [Reading]
    var count: Int
}

struct Reading: Codable {
    var reading: String
    var reading_time: String
}

struct AuthenticateResponse: Codable {
    var response_type: String
    var scope: String
    var access_token: String
}

struct AuthorizeResponse: Codable {
    var access_token: String
    var token_type: String
    var expires_in: Int
    var grant_type: String
}
