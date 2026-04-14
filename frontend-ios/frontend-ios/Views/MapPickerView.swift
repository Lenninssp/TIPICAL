//
//  MapPickerView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-09.
//

import SwiftUI
import MapKit

struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var selectedPosition: MapCameraPosition
    
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $selectedPosition) {
                    
                   
                    if let userLocation = locationManager.userLocation {
                        Marker("You", coordinate: userLocation)
                    }
                    
            
                    if let selectedCoordinate {
                        Marker("Selected", coordinate: selectedCoordinate)
                    }
                }
                .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Use my location") {
                        if let userLocation = locationManager.userLocation {
                            selectedCoordinate = userLocation
                        }
                        dismiss()
                    }
                    .disabled(locationManager.userLocation == nil)
                }
            }
            .onAppear {
                if let userLocation = locationManager.userLocation {
                    selectedPosition = .region(
                        MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    )
                }
            }
        }
    }
}
