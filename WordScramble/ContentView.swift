//
//  ContentView.swift
//  WordScramble
//
//  Created by Константин on 14.02.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var userScores = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    List {
                        Section {
                            TextField("Enter your word", text: $newWord)
                                .textInputAutocapitalization(.none)
                        }
                        Section {
                            ForEach(usedWords, id: \.self) { word in
                                HStack {
                                    Image(systemName: "\(word.count).circle")
                                    Text(word)
                                }
                            }
                        }
                    }
                    .navigationTitle(rootWord)
                    .onSubmit(addNewWord)
                    .onAppear(perform: {
                        startGame()
                    })
                    .alert(errorTitle, isPresented: $showingError) {
                        Button("Ok", role: .cancel) { }
                    } message: {
                        Text(errorMessage)
                    }
                }
                VStack(spacing: 30) {
                    HStack(alignment: .center) {
                        Text("Your scores:")
                            .font(.largeTitle)
                        Text("\(userScores)")
                            .font(.system(size: 50))
                    }
                    Button(action: {
                        startGame()
                        newWord = ""
                    }, label: {
                        Text("Reset")
                            .font(.largeTitle)
                    })
                }
                    
            }
        }
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "slikworm"
                return
            }
        }
        fatalError("Could not load start.txtrom bundle")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isNotRootWord(word: answer) else {
               wordError(title: "Root word detected", message: "You can't use the start word!")
               return
           }
        
        guard isLong(word: answer) else {
            wordError(title: "Word too short", message: "Word should be greater than 3 letters!")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used alredy", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cant spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "word not recognized", message: "You cant just make them up, you know")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        userScores += answer.count
        newWord = ""
    }
    
    func isNotRootWord(word: String) -> Bool {
            return word != rootWord
        }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isLong(word: String) -> Bool {
         return word.count > 3
     }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker() //класс проверки правописания
        let range = NSRange(location: 0, length: word.utf16.count)
        // проверка орфографической ошибки
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        // возвращает результат сравнения, если ошибок нет - true иначе false
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
