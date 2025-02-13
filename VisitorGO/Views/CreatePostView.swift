//
//  CreatePostView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import MapKit
import TipKit
import SwiftUI
import PhotosUI

struct HintTip: View {
    @State var showTooltip = false
    let comment: String
    var edge: Edge = .bottom

    var body: some View {
        Button("", systemImage: "questionmark.circle.fill") { showTooltip = true }
            .foregroundStyle(.black)
            .popover(isPresented: $showTooltip, arrowEdge: edge) {
                Text(comment)
                    .font(.system(size: 15))
                    .padding(.horizontal)
                    .presentationCompactAdaptation(.popover)
            }
        
    }
}

struct CustomDatePicker: View {
    @Binding var selection: Date

    var partialRangeFrom: PartialRangeFrom<Date>?
    var partialRangeThrough: PartialRangeThrough<Date>?
    var closedRange: ClosedRange<Date>?

    var body: some View {
        if partialRangeFrom != nil {
            DatePicker("", selection: $selection, in: partialRangeFrom!, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .pickerStyle(.inline)
                .labelsHidden()
        } else if partialRangeThrough != nil {
            DatePicker("", selection: $selection, in: partialRangeThrough!, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .pickerStyle(.inline)
                .labelsHidden()
        } else if closedRange != nil {
            DatePicker("", selection: $selection, in: closedRange!, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .pickerStyle(.inline)
                .labelsHidden()
        } else {
            DatePicker("", selection: $selection, displayedComponents: [.date])
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .pickerStyle(.inline)
                .labelsHidden()
        }
    }
}

enum CreatePostField: Hashable {
    case from
    case to
}

struct CreatePostView: View {
    @Binding var sports: Sports?
    @State var isPublic = true
    @State var title: String = ""
    @State var from: Date = .now
    @State var to: Date = .now
    @State var newStadium = ""
    @State var memo = ""
    @State var showingImage: UIImage?
    @State var isLoading = false
    @State var offset: CGFloat = 350

    @State var stadium: StadiumResponseBody?
    @State var teamList: [TeamResponse] = []

    @State var selection: [PhotosPickerItem] = []
    @State var uiImages: [UIImage] = []
    @State var saveLocations: [Locate] = []
    @State var payments: [Payment] = []

    @State var showTooltip = false
    @ObservedObject var postHelper: PostHelper = .init()
    @State var selectedIndex: Int = 0
    @FocusState var focus: CreatePostField?

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        HStack(alignment: .center) {
                            Image(systemName: sports!.icon)
                                .font(.title)
                                .foregroundStyle(.green)

                            Text("\(sports!.rawValue)の遠征記録作成")
                                .font(.system(size: 25))
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        }

                        Toggle(isOn: $isPublic) {
                            HStack {
                                Text("公開する").bold()
                                HintTip(comment: "公開すると自分以外のユーザーも\n遠征記録を閲覧可能になります", edge: .top)
                            }
                        }.padding(.horizontal, 2)

                        HStack {
                            Text("タイトル")
                                .bold()
                                .padding(.trailing, 20)

                            TextField("", text: $title)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Text("遠征期間").bold()
                            Spacer()
                            CustomDatePicker(selection: $from, partialRangeThrough: ...to)
                                .focused($focus, equals: .from)
                                .onChange(of: from) { focus = .to }

                            Text(" ~ ")

                            CustomDatePicker(selection: $to, partialRangeFrom: from...)
                                .focused($focus, equals: .to)
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            Text("試合記録").bold()

                            NavigationLink {
                                SelectStadiumView(stadium: $stadium)
                            } label: {
                                HStack {
                                    Text("会場").bold()
                                    Spacer()
                                    Text(stadium?.name ?? "")
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundStyle(.black)
                            }

                            if postHelper.teamList != [] {
                                ForEach(0..<postHelper.games, id: \.self) { num in
                                    CreateGameResultView(postHelper: postHelper, offset: $offset, index: num, selectedIndex: $selectedIndex, teamList: $teamList, from: $from, to: $to)
                                }
                            }

                            HStack {
                                Spacer()
                                Button("", systemImage: "plus.circle") {
                                    withAnimation {
                                        feedbackGenerator.impactOccurred()
                                        postHelper.append()
                                    }
                                }
                                Spacer()
                            }
                        }

                        VStack(alignment: .leading) {
                            Text("メモ").bold()
                            TextEditor(text: $memo)
                                .frame(minHeight: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(.primary.opacity(0.2), lineWidth: 1)
                                )
                                .padding(.horizontal, 1)
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Text("写真").bold()
                                HintTip(comment: "写真は10枚まで選択可能です")

                                Spacer()

                                PhotosPicker(selection: $selection, maxSelectionCount: 10, matching: .images) {
                                    Image(systemName: "photo.badge.plus")
                                }.padding(.trailing, 2)
                                    .onChange(of: selection) {
                                        Task {
                                            uiImages = []
                                            showingImage = nil
                                            for item in selection {
                                                guard let data = try? await item.loadTransferable(type: Data.self) else { return }
                                                guard let uiImage = UIImage(data: data) else { return }
                                                uiImages.append(uiImage)
                                                if showingImage == nil {
                                                    showingImage = uiImage
                                                }
                                            }
                                        }
                                    }
                            }
                            if showingImage != nil {
                                Image(uiImage: showingImage!)
                                    .resizable()
                                    .scaledToFit()
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(uiImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .onTapGesture { withAnimation { showingImage = image } }
                                    }
                                }
                            }.frame(height: 70)
                        }

                        VStack(alignment: .leading) {
                            NavigationLink {
                                LocationRegisterView(saveLocations: $saveLocations)
                            } label: {
                                VStack {
                                    HStack {
                                        Text("マップ").bold()
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundStyle(.black)

                                    Map(interactionModes: .init()) {
                                        ForEach(saveLocations) { locate in
                                            Marker(locate.alias, systemImage: locate.icon, coordinate: locate.coordinate)
                                        }
                                    }
                                    .frame(height: 300)
                                    .padding(.horizontal, -20)
                                }
                            }
                        }

                        HStack {
                            NavigationLink {
                                PaymentManageView(payments: $payments, from: $from, to: $to)
                            } label: {
                                HStack {
                                    Text("出費管理").bold()
                                    HintTip(comment: "出費管理は公開されません").foregroundStyle(.black)
                                    Spacer()
                                    Text("\(Payment.calcSum(payments))円")
                                    Image(systemName: "chevron.forward")
                                }
                                .foregroundStyle(.black)
                            }
                        }

                        LoadingButton(isLoading: $isLoading, text: "投稿する") {
                            isLoading = true
                            APIHelper.shared.uploadImage(self.uiImages, completion: uploadGame)
                        }.padding(.vertical, 16)
                    }
                }
                .padding()
                .toolbar(.hidden)

                NumberPicker(item: $postHelper.firstPoint[selectedIndex], item2: $postHelper.secondPoint[selectedIndex], offset: $offset)
                    .offset(y: offset)
            }
            .onChange(of: sports) {
                APIHelper.shared.getTeamList(sportsId: sports!.id) { data in
                    self.teamList = data ?? []
                    postHelper.setTeamList(self.teamList)
                }
            }
            .onAppear {
                APIHelper.shared.getTeamList(sportsId: sports!.id) { data in
                    self.teamList = data ?? []
                    postHelper.setTeamList(self.teamList)
                }
            }
        }
    }

    func uploadGame(_ result: Bool, _ urls: [String]?) {
        if let urls = urls, let stadium = stadium, result {
//            let game = Game(isPublic: isPublic, sportId: sports!.id, stadiumId: stadium.id, title: title, startDate: from.toISOString(), endDate: to.toISOString(), memo: memo, games: GamesRequest.convert(postHelper: postHelper), imageUrls: urls, payments: PaymentRequest.convert(payments: payments), visitedFacilities: VisitedFacilityRequest.convert(locates: saveLocations))
            let game = Game(isPublic: isPublic, sportId: sports!.id, stadiumId: stadium.id, title: title, startDate: from.toISOString(), endDate: to.toISOString(), memo: memo, games: [], imageUrls: urls, payments: PaymentRequest.convert(payments: payments), visitedFacilities: VisitedFacilityRequest.convert(locates: saveLocations))
            print(game)
            APIHelper.shared.createExpedition(game: game) { status in
                isLoading = false
                if status {
                    SnackBarManager.shared.show("投稿に成功しました", .success)
                }
            }
        } else {
            SnackBarManager.shared.error("投稿に失敗しました")
            isLoading = false
        }
    }
}

#Preview {
    CreatePostView(sports: .constant(.baseball))
}
