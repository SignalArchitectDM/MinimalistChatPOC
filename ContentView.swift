import SwiftUI

struct ContentView: View {
    @StateObject private var manager = MessageManager()
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(manager.messages) { msg in
                        HStack {
                            if msg.isFromUser {
                                Spacer()
                                Text(msg.content)
                                    .padding(14)
                                    .background(Color.blue.opacity(0.85))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            } else {
                                Text(msg.content)
                                    .padding(14)
                                    .background(Color.gray.opacity(0.25))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
            }
            
            HStack {
                TextField("Message", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                
                Button {
                    manager.sendMessage(inputText)
                    inputText = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}