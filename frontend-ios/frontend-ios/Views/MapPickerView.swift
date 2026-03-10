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
    
    @State private var tappedCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $selectedPosition) {
                        if let tappedCoordinate {
                            Marker("Selected place", coordinate: tappedCoordinate)
                        }
                    }
                    .onTapGesture { screenPoint in
                        if let coordinate = proxy.convert(screenPoint, from: .local) {
                            tappedCoordinate = coordinate
                        }
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
                    Button("Done") {
                        selectedCoordinate = tappedCoordinate
                        dismiss()
                    }
                    .disabled(tappedCoordinate == nil)
                }
            }
            .onAppear {
                if let selectedCoordinate {
                    tappedCoordinate = selectedCoordinate
                    selectedPosition = .region(
                        MKCoordinateRegion(
                            center: selectedCoordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    )
                } else {
                    selectedPosition = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
                            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                        )
                    )
                }
            }
        }
    }
}
