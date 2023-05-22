//
//  OpenAISettingsModal.swift
//  QuickMarkD
//
//  Created by 徐嗣苗 on 2023/5/15.
//

import SwiftUI
import OpenAIStreamingCompletions

struct OpenAISettings: Identifiable {
    let id = UUID()
    var key: String
    var host: String
    
    init() {
        self.key = ""
        self.host = "api.openai.com"
    }
}

struct OpenAISettingsModal: View {
    
    @AppStorage("APIKey") private var aiApiKey: String = ""
    @AppStorage("APIHost") private var aiApiHost: String = ""
    
    @Binding var isPresented: Bool
    @State private var currentSettings = OpenAISettings()
    
    var body: some View {
        NavigationStack {
            List {
                
                HStack {
                    
                    VStack(alignment: .center, spacing: 8) {
                        
#if os(macOS)
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                                .background(.clear)
                            Text("OpenAI API Key")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
#else
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 50))
                                    .background(.clear)
                                Text("OpenAI API Key")
                                    .font(.title3)
                                    .bold()
                            }
                            Spacer()
                        }
#endif
                    }
                }
                
#if os(macOS)
                Divider()
#endif
                
                Section("OpenAI API Key") {
                    SecureField("sk-...", text: $aiApiKey)
                }
                
                Section("Customized API Domain") {
                    TextField("example.com", text: $aiApiHost)
                }
                
            }
#if os(macOS)
            .textFieldStyle(.roundedBorder)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        UserDefaults.standard.set(true, forKey: "isInitialLaunch")
                        aiApiKey = UserDefaults.standard.string(forKey: "APIKey") ?? ""
                        aiApiHost = UserDefaults.standard.string(forKey: "APIHost") ?? "api.openai.com"
                        isPresented = false
                    } label: {
                        Text("Confirm")
                    }
                    
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        UserDefaults.standard.set(true, forKey: "isInitialLaunch")
                        aiApiKey = currentSettings.key
                        aiApiHost = currentSettings.host
                        isPresented = false
                    } label: {
                        Text("Cancel")
                    }
                    
                }
            }
            .navigationTitle("AI Settings")
            
            .task {
                
                if aiApiHost == "" {
                    aiApiKey = ""
                    aiApiHost = "api.openai.com"
                }
                
                currentSettings.key = aiApiKey
                currentSettings.host = aiApiHost
            }
        }
#if os(macOS)
        .frame(minWidth: 300, maxWidth: 500, minHeight: 400, maxHeight: 600)
#endif
    }
}

struct OpenAISettingsModal_Previews: PreviewProvider {
    static var previews: some View {
        OpenAISettingsModal(isPresented: .constant(true))
    }
}
