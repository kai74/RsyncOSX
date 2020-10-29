//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

class ReadWriteJSON: NamesandPaths, FileErrors {
    var jsonstring: String?
    var decodedjson: [Any]?

    private func createJSONfromstructs<T: Codable>(records: [Any]?, decode: (Any) -> T) {
        var structscodable: [T]?
        if let records = records {
            structscodable = [T]()
            for i in 0 ..< records.count {
                structscodable?.append(decode(records[i]))
            }
        }
        self.jsonstring = self.encodedata(data: structscodable)
    }

    private func encodedata<T: Codable>(data: [T]?) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            return nil
        }
        return nil
    }

    func readJSONFromPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                // check if file exists befor reading, if not bail out
                guard try Folder(path: atpath).containsFile(named: ViewControllerReference.shared.fileconfigurationsjson) else { return }
                let jsonfile = atpath + "/" + ViewControllerReference.shared.fileconfigurationsjson
                let file = try File(path: jsonfile)
                let jsonfromstore = try file.readAsString()
                if let jsonstring = jsonfromstore.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        self.decodedjson = try decoder.decode([DecodeConfigJSON].self, from: jsonstring)
                    } catch let e {
                        let error = e as NSError
                        self.error(error: error.description, errortype: .json)
                    }
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: ViewControllerReference.shared.fileconfigurationsjson)
                if let data = self.jsonstring {
                    try file.write(data)
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    override init(whattoreadwrite: WhatToReadWrite, profile: String?) {
        super.init(whattoreadwrite: whattoreadwrite, profile: profile)
    }
}
