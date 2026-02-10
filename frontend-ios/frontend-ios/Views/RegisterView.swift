//
//  RegisterView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//


import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    @StateObject private var auth =  AuthService.shared
    
    
    var body: some View {
        Form {
            Section
            {
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 4) {
                        //Email
                    Text("Email")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .font(.title3)
                    
                    TextField("Enter email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                    
                }
                .padding(.horizontal)
                .padding(.top, 15)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Password")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .font(.title3)
                    
                    SecureField("Enter Password (min 6 chars", text: $password)
                
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enter Display Name")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .font(.title3)
             
                    TextField("Enter Display Name", text: $displayName)
                    
                }
                .padding(.horizontal)
                .padding(.top, 10)
   
            }
            .scrollContentBackground(.hidden)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action:{
                print("Sign up clicked")
                
                guard Validators.isValidEmail(email) else {
                    self.errorMessage = "Invalid Email"
                    return
                }
                
                guard Validators.isValidPassword(password) else {
                    self.errorMessage = "Invalid Password"
                    return
                }
                
                guard !displayName.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty else {
                    self.errorMessage = "Please enter a display name"
                    return
                }
                auth.signUp(email: email, password: password, displayName: displayName) {
                    result in
                    switch result {
                    case .success: self.errorMessage = nil
                    case .failure(let failure): self.errorMessage = failure.localizedDescription
                        
                    }
                }
            })
            {
                Text("Register")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Marroncito"))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            }
            .disabled(email.isEmpty || password.isEmpty || displayName.isEmpty)
            
        }.scrollContentBackground(.hidden)
        
        HStack{
            Text("Have an Account?")
                .font(.footnote)
                .foregroundColor(.gray)
            NavigationLink(destination: LoginView()) {
                Text("Go to Log in")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            
        }
        Spacer(minLength: 50)
        
    }
    
}

#Preview {
    RegisterView()
}
