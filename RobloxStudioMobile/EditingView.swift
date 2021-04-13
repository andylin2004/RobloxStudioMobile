//
//  EditingView.swift
//  RobloxStudioMobile
//
//  Created by Andy Lin on 3/28/21.
//

import SwiftUI
import Drawer

struct EditingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject private var loading: LoadingFile
    @StateObject private var script = ScriptFile()
    @StateObject private var propertyList = PropertyInfoArray()
    let file: String
    let fileName: String
    let parsedArray: Array<RbxObject>
    @State private var leftOffset: Bool = false
    @State private var rightOffset: Bool = false
    @State private var controlButton = 0
    
    init(file: String, fileName: String){
        self.file = file
        self.fileName = fileName
        
        self.parsedArray = parseFile(data: file)
    }
    
    var body: some View {
        if sizeClass == .regular{
            NavigationView{
                GeometryReader{ geometry in
                    HStack{
                        mainListView(parsedArray: parsedArray, file: file)
                            .padding(.trailing, -7)
                            .frame(width: geometry.size.width*0.25)
                            .animation(.default)
                            .offset(x: leftOffset ? geometry.size.width * -0.25 - 7 : 0)
                        Divider()
                            .animation(.default)
                            .offset(x: leftOffset ? geometry.size.width * -0.25 - 7 : 0)
                        mainView(additional: (leftOffset ? geometry.size.width * 0.25 + 7 : 0) + (rightOffset ? geometry.size.width * 0.25 + 9: 0))
                            .offset(x: (leftOffset ? geometry.size.width * -0.25 - 7 : 0))
                            .animation(.default)
                        Divider()
                            .animation(.default)
                            .offset(x: (rightOffset ? geometry.size.width * 0.25 + 7 : 0))
                        PropertyView()
                            .padding(.leading, -7)
                            .frame(width: geometry.size.width*0.25)
                            .animation(.default)
                            .offset(x: (rightOffset ? geometry.size.width * 0.25 + 7 : 0))
                    }
                }.navigationBarTitle(fileName, displayMode: .inline)
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading){
                        Button(action:{presentationMode.wrappedValue.dismiss()}, label:{
                            Text("Done")
                        }).buttonStyle(PlainButtonStyle())
                        Button(action: {
                            leftOffset.toggle()
                        }, label: {
                            Image(systemName: "sidebar.left")
                        })
                        Button(action: {}, label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                        })
                        Button(action: {}, label: {
                            Image(systemName: "arrow.uturn.forward.circle")
                        })
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing){
                        Button(action: {}, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "info.circle")
                        })
                        Button(action: {
                            rightOffset.toggle()
                        }, label: {
                            Image(systemName: "sidebar.right")
                        })
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(loading)
            .environmentObject(propertyList)
            .environmentObject(script)
            .onAppear{
                loading.loading = false
            }
        }else{
            NavigationView{
                ZStack{
                    mainView(additional: 0)
                    
                    Drawer{
                        ZStack{
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color(UIColor.systemBackground))
                                .shadow(radius: 100)
                            
                            VStack{
                                Spacer().frame(height: 12)
                                Picker(selection: $controlButton, label: Text("")){
                                    Text("Explorer").tag(0)
                                    Text("Properties").tag(1)
                                }
                                .pickerStyle(SegmentedPickerStyle())

                                switch(controlButton){
                                    case 0:
                                        mainListView(parsedArray: parsedArray, file: file)
                                    default:
                                        PropertyView()
                                }
                            }
                            
                            VStack(alignment: .center) {
                                Spacer().frame(height: 4.0)
                                RoundedRectangle(cornerRadius: 3.0)
                                    .foregroundColor(.gray)
                                    .frame(width: 30.0, height: 6.0)
                                Spacer()
                            }
                        }.frame(height: 413)
                    }
                    .rest(at: .constant([100, 340]))
                }
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(fileName, displayMode: .inline)
                .toolbar{
                    ToolbarItemGroup(placement: .navigationBarLeading){
                        Button(action:{presentationMode.wrappedValue.dismiss()}, label:{
                            Text("Done")
                        }).buttonStyle(PlainButtonStyle())
                        Button(action: {}, label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                        })
                        Button(action: {}, label: {
                            Image(systemName: "arrow.uturn.forward.circle")
                        })
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing){
                        Button(action: {}, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "info.circle")
                        })
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(loading)
            .environmentObject(propertyList)
            .environmentObject(script)
            .onAppear{
                loading.loading = false
            }
            .onChange(of: propertyList.id){_ in
                controlButton = 1
            }
        }
    }
}

struct mainView: View{
    let additional: CGFloat
    
    init(additional: CGFloat){
        self.additional = additional
    }
    
    var body: some View{
        GeometryReader{ thisGeometry in
            scriptView()
                .frame(width: thisGeometry.size.width + 7 + additional)
        }
    }
}

struct scriptView: View{
    @EnvironmentObject var script: ScriptFile
    @State var scriptEditable = ""
    
    var body: some View{
        TextEditor(text: $scriptEditable)
            .onAppear(){
                scriptEditable = script.file
            }
            .onChange(of: script.file){_ in
                scriptEditable = script.file
            }
            .environmentObject(script)
    }
}

struct enviromentView: View{
    var body: some View{
        Text("Enviroment Placeholder")
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        mainView(additional: 0)
    }
}
