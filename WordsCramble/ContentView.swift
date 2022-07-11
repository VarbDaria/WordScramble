//
//  ContentView.swift
//  WordsCramble
//
//  Created by Дарья Варб on 6/12/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    var body: some View {
        VStack {
            NavigationView{
                List{
                    Section{
                        TextField("Enter your word", text: $newWord)
                            .autocapitalization(.none)
                    }
                    Section{
                        ForEach(usedWords, id: \.self){ word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                    
                }
                .navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError){
                    Button("OK", role: .cancel) { }
                }message: {
                    Text(errorMessage)
                }
                .safeAreaInset(edge: .bottom) {
                    Text("Score: \(score)")
                        .frame(maxWidth: .infinity)
                               .padding()
                               .background(.blue)
                               .foregroundColor(.white)
                               .font(.title)
                }
//                .toolbar {
//                    Button("New Game", action: startGame)
//                }

            }
            Button {
                startGame()
            } label: {
                Text("RESTART")
                    .font(.body.bold())
                    .foregroundColor(.secondary)
                    .padding()
                    .background(.pink)
                    .cornerRadius(20)
                    .shadow(color: .purple, radius: 6, x: 5, y: 8)
            }
        }
    
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 else {
         wordErorr(title: "To short", message: "Words must be at least four letters long.")
            return
        }
        
        guard answer != rootWord else {
            wordErorr(title: "Nice try…", message: "You can't use your starting word!")
                return
        }
        
        guard isOriginal(word: answer) else {
            wordErorr(title: "Slovo uzhe ispolzovalos", message: "Be more original!")
            return
        }
        guard isPossible(word: answer) else {
            wordErorr(title: "Nevozmozhno", message: "Use words from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordErorr(title: "Fignya", message: "Davay dumay normalno")
            return
        }
        
        withAnimation{
        usedWords.insert(answer, at: 0)
        }
        newWord = ""
        score += answer.count
    }
    func startGame() {
        newWord = ""
        score = 0
        usedWords.removeAll()
       
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                        tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspalladRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspalladRange.location == NSNotFound
    }
    func wordErorr(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
//    func shortWord(word: String) -> Bool {
//        if word.count < 2 {
//            return false
//        }
//        return true
//    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
