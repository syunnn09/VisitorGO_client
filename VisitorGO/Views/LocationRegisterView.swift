//
//  LocationRegisterView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import MapKit
import SwiftUI

struct LocationRegisterView: View {
    @State var position: MapCameraPosition = .automatic

    @StateObject var viewModel = MapViewHelper()
    @Binding var saveLocations: [Locate]
    @State var expandMap = false
    @State var showingSaved = false
    @State var isEditing = false
    @State var editingLocation: Locate?

    @State var alias = ""
    @State var icon = ""
    @State var color: Color = .red

    @State var showTooltip = false
    @State var showedTooltip = false

    @State var suggestion: Locate?
    @State var changeCount = 0

    func createLocate(place: MKLocalSearchCompletion, coordinate: CLLocationCoordinate2D) -> Locate {
        return Locate(name: place.title, place: place.subtitle, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func saveLocate(place: MKLocalSearchCompletion, coordinate: CLLocationCoordinate2D) {
        let locate = createLocate(place: place, coordinate: coordinate)
        self.saveLocations.append(locate)
        self.makePosition()
        self.suggestion = nil
        self.changeCount = 0
        if !showedTooltip {
            showedTooltip = true
            showTooltip = true
        }
    }

    func getSaveLocation(completion: MKLocalSearchCompletion) -> Locate? {
        for location in saveLocations {
            if location.name == completion.title && location.place == completion.subtitle {
                return location
            }
        }
        return nil
    }

    func isSaved(completion: MKLocalSearchCompletion) -> Bool {
        return getSaveLocation(completion: completion) != nil
    }

    func toggleSave(completion: MKLocalSearchCompletion) {
        let location = getSaveLocation(completion: completion)
        if location != nil {
            self.removeSave(locate: location!)
        } else {
            viewModel.searchLocation(locate: completion, completion: saveLocate)
        }
    }

    func showPosition(place: MKLocalSearchCompletion, coordinate: CLLocationCoordinate2D) {
        suggestion = createLocate(place: place, coordinate: coordinate)
        self.createPosition(coordinate: coordinate)
        self.changeCount = 0
    }

    func createPosition(coordinate: CLLocationCoordinate2D) {
        self.position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: .init(latitude: coordinate.latitude, longitude: coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    func getPosition(completion: MKLocalSearchCompletion) {
        viewModel.searchLocation(locate: completion, completion: showPosition)
    }

    func makePosition() {
        if self.saveLocations.count == 1 {
            self.createPosition(coordinate: self.saveLocations.first!.coordinate)
        } else {
            self.position = .automatic
        }
    }

    func removeSave(locate: Locate) {
        self.saveLocations.remove(at: self.saveLocations.firstIndex(of: locate)!)
        self.makePosition()
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .trailing) {
                Map(position: $position) {
                    ForEach(saveLocations) { locate in
                        Marker(locate.alias, systemImage: locate.icon, coordinate: locate.coordinate)
                            .tint(locate.color)
                    }
                    if suggestion != nil {
                        Marker(suggestion!.name, coordinate: suggestion!.coordinate)
                    }
                }.onMapCameraChange {
                    if suggestion != nil {
                        changeCount += 1
                    }
                    if changeCount > 2 && suggestion != nil {
                        changeCount = 0
                        suggestion = nil
                    }
                }

                if !expandMap {
                    TextField("場所を検索", text: $viewModel.location)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 20)
                        .onChange(of: viewModel.location) {
                            viewModel.onSearchLocation()
                            withAnimation {
                                showingSaved = false
                            }
                        }

                    Picker("", selection: $showingSaved) {
                        Text("検索結果").tag(false)
                        Text("保存済み").tag(true)
                            .popover(isPresented: $showTooltip, arrowEdge: .bottom) {
                                Text("場所を編集することができます")
                                    .font(.system(size: 15))
                                    .padding(.horizontal)
                                    .presentationCompactAdaptation(.popover)
                            }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    List {
                        if !showingSaved {
                            ForEach(viewModel.completions, id: \.self) { completion in
                                HStack {
                                    let isSaved = isSaved(completion: completion)
                                    if isSaved {
                                        Image(systemName: "bookmark.fill").foregroundStyle(.yellow)
                                    } else {
                                        Image(systemName: "bookmark")
                                    }

                                    VStack(alignment: .leading) {
                                        Text(completion.title)
                                        Text(completion.subtitle)
                                            .foregroundColor(Color.primary.opacity(0.5))
                                    }
                                    Spacer()
                                }
                                .listRowBackground(Color.gray.opacity(0.09))
                                .onTapGesture {
                                    getPosition(completion: completion)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button("保存") {
                                        toggleSave(completion: completion)
                                    }.tint(.yellow)
                                }
                            }
                        } else {
                            ForEach(saveLocations) { locate in
                                HStack {
                                    Image(systemName: "bookmark.fill").foregroundStyle(.yellow)
                                    VStack(alignment: .leading) {
                                        Text(locate.alias)
                                        Text(locate.place)
                                            .foregroundStyle(.primary.opacity(0.5))
                                    }
                                    Spacer()
                                }
                                .listRowBackground(Color.gray.opacity(0.09))
                                .onTapGesture {
                                    self.editingLocation = locate
                                    self.alias = locate.alias
                                    self.icon = locate.icon
                                    self.color = locate.color
                                    self.isEditing = true
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button("削除") {
                                        removeSave(locate: locate)
                                    }.tint(.yellow)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)

            Button {
                withAnimation(.easeInOut(duration: 0.7)) {
                    expandMap.toggle()
                }
            } label: {
                if expandMap {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                } else {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.trailing, 10)
            .padding(.top, 50)
        }
        .navigationBarBackButtonHidden(expandMap)
        .sheet(isPresented: $isEditing) {
            EditLocaleView(locate: $editingLocation, alias: $alias, icon: $icon, color: $color)
                .presentationDetents([.medium, .large])
                .onChange(of: alias) {
                    if let index = saveLocations.firstIndex(of: editingLocation!) {
                        saveLocations[index].alias = alias
                    }
                }
                .onChange(of: icon) {
                    editingLocation?.icon = icon
                }
                .onChange(of: color) {
                    editingLocation?.color = color
                }
        }
    }
}

#Preview {
    @Previewable @State var saveLocations: [Locate] = []
    LocationRegisterView(saveLocations: $saveLocations)
}
