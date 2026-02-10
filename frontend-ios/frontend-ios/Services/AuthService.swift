//
//  AuthService.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore


class AuthService: ObservableObject {
    //Singleton pattern
    static let shared = AuthService()
    
    @Published var currentUser: AppUser?
    //dbreference
    private let db = Firestore.firestore()
    
    //signup function
    func signUp(email: String, password: String, displayName: String, completion: @escaping
                (Result<AppUser, Error>) -> Void){
        //auth 1
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if  let error = error {
                print(error.localizedDescription)
                return completion(.failure(error))
            }
            //Check for user
            guard let user = result?.user else {
                //no access to the error objc, tenemos que crear un error objct para usarlo adentro
                return completion(.failure(SimpleError("Unable to create user")))
            }
            
            //create app user
            let uid = user.uid
            let appUser = AppUser(id: uid, email: email, displayName: displayName)
            
            //push it to the firestore
            do{
                try self.db.collection("users").document(uid).setData(from: appUser) {
                    error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                    //update current user
                    
                    DispatchQueue.main.async {
                        self.currentUser = appUser //this will update the user in the main
                        
                    }
                    completion(.success(appUser))
                }
            } catch{
                print(error.localizedDescription)
                completion(.failure(error))
            }
            
        }
        
        
        
    }
    
    //login
    func login(email: String, password: String, completion: @escaping (Result<AppUser?, Error>)->Void){
        
        //login -> get uid from firebase -> then fetch appuser -> set the appuser to currentuser
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }else if let user = result?.user {
                
                let uid = user.uid
                //fetch the AppUser from the firestore
                //self.fetchUSer
                self.fetchCurrentAppUser { res in
                    switch res {
                    case.success(let appUserObj):
                        if let appUser = appUserObj {
                            completion(.success(appUser))
                        }else{
                            //either create an empty record or completion as failure
                            //opcion 1 = creamos dummy
                            let email = result?.user.email ?? "Unknown"
                            let name = result?.user.displayName ?? "Anonymous"
                            let appUser = AppUser(id: uid, email: email, displayName: name)
                            
                            // update this empty record to firestore
                            do{
                                try self.db.collection("users").document(uid).setData(from: appUser){
                                    error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                        completion(.failure(error))
                                    }
                                    DispatchQueue.main.async {
                                        self.currentUser = appUser
                                    }
                                    completion(.success(appUser))
                                }
                            }catch {
                                print(error.localizedDescription)
                                completion(.failure(error))
                            }
                        }
                    case.failure(let failure):
                        completion(.failure(failure))
                    }
                }
            }
        }
        
        
    }
    
    //fetch current app user
    func fetchCurrentAppUser(completion: @escaping (Result<AppUser?, Error>)->Void){
        //uid from firebaseAuth
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return completion(.success(nil))
        }
        db.collection("users").document(uid).getDocument { snap, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let snap = snap else {
                return completion(.success(nil))
            }
            
            do {
                let user = try snap.data(as: AppUser.self)
                
                DispatchQueue.main.async {
                    self.currentUser = user
                }
                completion(.success(user))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        
    }
    
    
    //update details
    func updateProfile(displayName: String, completion: @escaping (Result<Void, Error>)-> Void){ //ill take uid
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.success(()))
        }
        db.collection("users").document(uid).updateData(["displayName":displayName]) {
            error in
            
            if let error = error {
                return completion(.failure(error))
            } else {
                self.fetchCurrentAppUser { _ in
                    completion(.success(()))
                }
            }
        }
    }
    
    //signout
    func signOut() -> Result<Void, Error>{ //nos devuelve algo por que todos los otros metodos tambien lo hacen para seguir la misma tendencia
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return.success(())
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
}
 
