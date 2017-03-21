//
//  Tournament.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import Foundation

class Tournament {
    
    var baseDatos: OpaquePointer?
    
    enum privacy:String {
        case LOCAL = "LOCAL"
        case ONLINE = "ONLINE"
    }
    enum type:String {
        case SingleStage = "Single Stage"
        case TwoStage = "Two Stage"
    }
    enum tournamentFormat:String  {
        case SingleElimination = "Single Elimination"
        case DoubleElimination = "Double Elimination"
        case RoundRobin = "Round Robin"
    }
    var name: String?
    var game:String?
    var description:String?
    var type:type?
    var privacy:privacy?
    var participants = [String]()
    var firstStage:tournamentFormat?
    var secondStage:tournamentFormat?
    
    
    private func abrirBaseDatos() -> Bool {
        if let path = obtenerRuta(nombreArchivo:"baseDatos.txt") {
            if sqlite3_open(path.absoluteString, &baseDatos) == SQLITE_OK {
                return crearTabla()
            }
            // Error
            sqlite3_close(baseDatos)
        }
        return false
    }
    /*
    func consultarBaseDatos() {
        let sqlConsulta = "SELECT * FROM TORNEOS"
        var declaracion: OpaquePointer? = nil
        if sqlite3_prepare_v2(baseDatos, sqlConsulta, -1, &declaracion, nil) == SQLITE_OK {
            var arr = [String]()
            while sqlite3_step(declaracion) == SQLITE_ROW {
                let isbn = String.init(cString: sqlite3_column_text(declaracion, 0))
                arr.append(isbn)
            }
            arrLibros = arr
            self.tbVw.reloadData()
        }
    }
    */
    func crearTabla() -> Bool {
        let sqlCreaTorneos = "CREATE TABLE IF NOT EXISTS TORNEOS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NAME TEXT NOT NULL,GAME TEXT NOT NULL,DESCRIPTION TEXT NOT NULL,PRIVACY TEXT NOT NULL,TYPE TEXT NOT NULL,FIRST_STAGE TEXT NOT NULL,SECOND_STAGE TEXT)"
        let sqlCreaParticipantes = "CREATE TABLE IF NOT EXISTS PARTICIPANTS (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,TORNEO_ID INTEGER NOT NULL,NAME TEXT NOT NULL,FOREIGN KEY(TORNEO_ID) REFERENCES TORNEOS(ID))"
        var error: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(baseDatos, sqlCreaTorneos, nil, nil, &error) == SQLITE_OK {
            if sqlite3_exec(baseDatos, sqlCreaParticipantes, nil, nil, &error) == SQLITE_OK {
                return true
            }else{
                sqlite3_close(baseDatos)
                let msg = String.init(cString: error!)
                print("Error: \(msg)")
                return false
            }
        } else {
            sqlite3_close(baseDatos)
            let msg = String.init(cString: error!)
            print("Error: \(msg)")
            return false
        }
    }
    func save()->Bool{
        if self.name == nil || self.game == nil || self.description == nil || self.privacy == nil || self.type == nil || self.firstStage == nil {
            print("\(self.name),\(self.game), \(self.description),\(self.privacy?.rawValue),\(self.type?.rawValue),\(self.firstStage?.rawValue)")
        }else{
            if abrirBaseDatos() {
                if insertarDatos(){
                    return true
                }
            }else{
                return false
            }
        }
        return false
    }
    private func insertarDatos()->Bool {
        let sqlInserta = "INSERT INTO TORNEOS (NAME, GAME, DESCRIPTION, PRIVACY, TYPE, FIRST_STAGE) VALUES('\(self.name!)','\(self.game!)', '\(self.description!)','\(self.privacy!.rawValue)','\(self.type!.rawValue)', '\(self.firstStage!.rawValue)')"
        var error: UnsafeMutablePointer<Int8>? = nil                                                 
        if sqlite3_exec(baseDatos, sqlInserta, nil, nil, &error) != SQLITE_OK {
            let msg = String.init(cString: error!)
            print("Error al insertar datos \(msg)")
            return false
        }
        return true
    }
    
    private func obtenerRuta(nombreArchivo:	String)	->	URL?	{
        if let path =	FileManager.default.urls(for:	.documentDirectory,	in:	.userDomainMask).first {
            print(path.appendingPathComponent(nombreArchivo))
            return path.appendingPathComponent(nombreArchivo)
        }
        return nil
    }
    
}
