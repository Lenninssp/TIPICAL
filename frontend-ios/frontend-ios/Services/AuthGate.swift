//
//  AuthGate.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import SwiftUI

    //switch b/w login and register page
struct AuthGate: View {
    @State private var showLogin = true
    var body: some View {
        VStack {
            Picker("", selection: $showLogin){
                Text("Login").tag(true) //el tag hace que si seleccionas el "login" se muestra el showlogin como true
                Text("Regiser").tag(false)  //el "login" se muestra el showlogin como false
            }.pickerStyle(.segmented) //automatico es con flechitas, .inline es como el timer de iphone
                .padding()
            if showLogin {
                LoginView()
            } else {
                RegisterView()
            }
        }
    }
}
