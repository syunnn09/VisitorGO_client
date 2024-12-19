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

    var body: some View {
        Button("", systemImage: "questionmark.circle.fill") { showTooltip = true }
            .foregroundStyle(.black)
            .popover(isPresented: $showTooltip, arrowEdge: .bottom) {
                Text(comment)
                    .font(.system(size: 15))
                    .padding(.horizontal)
                    .presentationCompactAdaptation(.popover)
            }
        
    }
}

struct CustomDatePicker: View {
    @Binding var selection: Date
    
    var body: some View {
        DatePicker("", selection: $selection, displayedComponents: [.date])
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .pickerStyle(.inline)
            .labelsHidden()
    }
}

struct CreatePostView: View {
    @Binding var sports: Sports?
    @State var isPublic = false
    @State var from: Date = .now
    @State var to: Date = .now
    @State var stadium = ""
    @State var newStadium = ""
    @State var memo = ""
    @State var showingImage: UIImage?
    @State var isLoading = false
    @State var offset: CGFloat = 350

    @State var selection: [PhotosPickerItem] = []
    @State var uiImages: [UIImage] = []
    @State var saveLocations: [Locate] = []
    @State var payments: [Payment] = []

    @State var showTooltip = false
    @ObservedObject var postHelper: PostHelper = .init()

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
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
                                HintTip(comment: "公開すると自分以外のユーザーも\n遠征記録を閲覧可能になります")
                            }
                        }.padding(.horizontal, 2)
                        
                        HStack {
                            Text("遠征期間").bold()
                            Spacer()
                            CustomDatePicker(selection: $from)
                            Text(" ~ ")
                            CustomDatePicker(selection: $to)
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("会場").bold()
                                HintTip(comment: "試合記録を入力すると自動的に入力されます")
                            }
                            
                            HStack {
                                TextField("", text: $newStadium)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .listRowSeparator(.hidden)
                            .frame(height: CGFloat((stadium.count + 1) * 44))
                        }
                        
                        VStack(alignment: .leading) {
                            Text("試合記録").bold()
                            
                            CreateGameResultView(offset: $offset)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("メモ").bold()
                            TextEditor(text: $memo)
                                .frame(minHeight: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(.primary.opacity(0.2), lineWidth: 1)
                                )
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
                            Text("マップ").bold()
                            NavigationLink {
                                LocationRegisterView(saveLocations: $saveLocations)
                            } label: {
                                Map(interactionModes: .init()) {
                                    ForEach(saveLocations) { locate in
                                        Marker(locate.alias, systemImage: locate.icon, coordinate: locate.coordinate)
                                    }
                                }
                                .frame(height: 300)
                                .padding(.horizontal, -20)
                            }
                        }
                        
                        HStack {
                            NavigationLink {
                                PaymentManageView(payments: $payments)
                            } label: {
                                HStack {
                                    Text("出費管理")
                                    HintTip(comment: "出費管理は公開されません").foregroundStyle(.black)
                                    Spacer()
                                    Text("\(Payment.calcSum(payments))円")
                                    Image(systemName: "chevron.forward")
                                }
                            }
                        }
                        
                        LoadingButton(isLoading: $isLoading, text: "投稿する") {
                            
                        }.padding(.vertical, 16)
                    }
                }
                .padding()
                .toolbar(.hidden)

                NumberPicker(item: $postHelper.firstPoint[0], item2: $postHelper.secondPoint[0], offset: $offset)
                    .offset(y: offset)
            }
        }
    }
}

#Preview {
    CreatePostView(sports: .constant(.baseball))
}
