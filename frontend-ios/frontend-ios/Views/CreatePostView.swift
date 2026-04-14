//
//  CreatePostView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//
//

import SwiftUI
import PhotosUI
import MapKit

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var feedViewModel: FeedViewModel

    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var linkText: String = ""

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var uploadedImage: UploadResponseAttributes?

    @State private var showLinkField: Bool = false
    @State private var showMapPicker: Bool = false

    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedMapPosition: MapCameraPosition = .automatic

    @State private var isPublishing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.12)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar

                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            titleField
                            bodyField
                            //linkSection
                            imagePreviewSection
                            mapPreviewSection

                            if let errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                    bottomToolbar
                }
            }
            .sheet(isPresented: $showMapPicker) {
                MapPickerView(
                    selectedCoordinate: $selectedCoordinate,
                    selectedPosition: $selectedMapPosition
                )
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadSelectedPhoto(from: newItem)
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
                publishPost()
            } label: {
                Text(isPublishing ? "Publishing..." : "Publish")
                    .font(.headline)
                    .foregroundColor(canPublish ? .black : .gray)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(canPublish ? Color.white : Color(white: 0.18))
                    )
            }
            .disabled(!canPublish || isPublishing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    private var titleField: some View {
        TextField("", text: $title, prompt: Text("Title").foregroundColor(.gray))
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .textFieldStyle(.plain)
    }

    private var bodyField: some View {
        ZStack(alignment: .topLeading) {
            if bodyText.isEmpty {
                Text("Body text (optional)")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.leading, 4)
            }

            TextEditor(text: $bodyText)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .frame(minHeight: 180)
                .background(Color.clear)
        }
    }

//    private var linkSection: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            if showLinkField {
//                TextField("", text: $linkText, prompt: Text("Paste a link").foregroundColor(.gray))
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color(white: 0.14))
//                    )
//            }
//        }
//    }

    private var imagePreviewSection: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    private var mapPreviewSection: some View {
        Group {
            if let coordinate = selectedCoordinate {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Selected location")
                        .foregroundColor(.white)
                        .font(.headline)

                    Map(position: .constant(.region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    ))) {
                        Marker("Location", coordinate: coordinate)
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text("Lat: \(coordinate.latitude)\nLon: \(coordinate.longitude)")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
            }
        }
    }

    private var bottomToolbar: some View {
        HStack(spacing: 30) {
//            Button {
//                showLinkField.toggle()
//            } label: {
//                Image(systemName: "link")
//                    .font(.title2)
//                    .foregroundColor(.white)
//            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Button {
                showMapPicker = true
            } label: {
                Image(systemName: "map")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(Color.black)
    }

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadSelectedPhoto(from item: PhotosPickerItem?) async {
        guard let item else {
            selectedImage = nil
            uploadedImage = nil
            return
        }

        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
            uploadedImage = nil
        }
    }

    private func publishPost() {
        guard !isPublishing else { return }

        isPublishing = true
        errorMessage = nil
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        let coordinate = selectedCoordinate

        func submitPost(with upload: UploadResponseAttributes?) {
            PostService.shared.createPost(
                title: trimmedTitle,
                description: trimmedDescription,
                archived: false,
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude,
                imageUrl: upload?.imageUrl,
                imagePath: upload?.imagePath
            ) { result in
                DispatchQueue.main.async {
                    self.isPublishing = false

                    switch result {
                    case .success(let createdPost):
                        self.uploadedImage = upload
                        feedViewModel.prependPost(createdPost)
                        dismiss()

                    case .failure(let error):
                        print("Create post error:", error.localizedDescription)
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }

        if let uploadedImage {
            submitPost(with: uploadedImage)
            return
        }

        guard let selectedImage else {
            submitPost(with: nil)
            return
        }

        guard let imageData = selectedImage.jpegData(compressionQuality: 0.85) else {
            isPublishing = false
            errorMessage = "Failed to prepare image for upload"
            return
        }

        PostService.shared.uploadImage(imageData: imageData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let upload):
                    self.uploadedImage = upload
                    submitPost(with: upload)

                case .failure(let error):
                    self.isPublishing = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
        .environmentObject(FeedViewModel())
}

