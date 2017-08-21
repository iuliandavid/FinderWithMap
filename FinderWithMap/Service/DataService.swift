//
//  DataService.swift
//  FinderWithMap
//
//  Created by iulian david on 8/19/17.
//  Copyright © 2017 iulian david. All rights reserved.
//

import Foundation

struct DataService {
    static let sharedInstance = DataService()
    
    private var myData = [MyModel]()
    
    private init(){
        parseCSV()
    }
    
    
    private mutating func parseCSV(){
        if let path = Bundle.main.path(forResource: "data", ofType: "csv") {
            do {
                let csv = try CSVParser.init(contentsOfURL: path)
                let rows = csv.rows
                for row in rows {
                    if let pokeId = Int(row["id"]!), let name = row["identifier"] {
                        let model = MyModel(name: name, id: pokeId)
                        myData.append(model)
                    }
                }
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
        
    }
    
    var photos : [MyModel] {
        return myData
    }
}
