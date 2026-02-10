//
//  LoginView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//
import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    @StateObject private var auth =  AuthService.shared
    
    
    var body: some View {
        
        ZStack{
            
            VStack(spacing: 20){
                Spacer()
                Text("TIPICAL")
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(.primary)
                    .padding(.bottom, 20)
                
                Form {
                    Section
                    {
                        Text("Log In")
                            .font(.largeTitle)
                            .bold()
                            .padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 4) {
                                //Email
                            Text("Email")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .font(.title3)
                            
                            TextField("Enter Email", text: $email)
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
                        
                            // Password
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .font(.title3)
                            
                            SecureField("Enter Password (Min 6 charactes)", text: $password)
                            
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
 
                    
                    Button(action:{
                        print("Login clicked")
                        
                        guard Validators.isValidEmail(email) else {
                            self.errorMessage = "Invalid Email"
                            return
                        }
                        
                        guard Validators.isValidPassword(password) else {
                            self.errorMessage = "Invalid Password"
                            return
                        }
                        
                        auth.login(email: email, password: password) {
                            result in
                            switch result {
                                case .success:
                                self.errorMessage = nil
                            case .failure(let failure):
                                self.errorMessage = failure.localizedDescription
                            }
                        }
                        
                    }) {
                        Text("Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Azulito"))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    
                    
                    
                }.scrollContentBackground(.hidden)
                
                HStack{
                    Text("Don’t have an account?")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    NavigationLink(destination: RegisterView()) {
                        Text("Go to register")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                //.frame(maxWidth: .infinity, alignment: .center)
                //.padding(.top, 10)
               
                Spacer(minLength: 50)

            }
                
        }
    }
}

#Preview {
    LoginView()
}
