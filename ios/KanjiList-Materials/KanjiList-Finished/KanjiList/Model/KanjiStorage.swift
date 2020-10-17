/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

struct KanjiCache {
  let kanjiArray: [Kanji]
  let kanjiDictionary: [String: Kanji]
}

// Provides kanji data from JSON
class KanjiStorage {
  static let kanjiURL = Bundle.main.url(forResource: "knji", withExtension: "json")!
  private let allKanjiFromJSON: KanjiCache
  
  init() {
    // Parse json and store it's data
    let data = try! Data(contentsOf: KanjiStorage.kanjiURL)
    let allKanjis = try! JSONDecoder().decode([Kanji].self, from: data)
    
    let kanjiDictionary = allKanjis.reduce([:]) { (dictionary, kanji) -> [String: Kanji] in
      var dictionary = dictionary
      dictionary[kanji.character] = kanji
      return dictionary
    }
    
    // Save new cache
    allKanjiFromJSON = KanjiCache(kanjiArray: allKanjis, kanjiDictionary: kanjiDictionary)
  }
  
  func allKanji() -> [Kanji] {
    return allKanjiFromJSON.kanjiArray
  }
  
  func kanjiForWord(_ word: String) -> [Kanji] {
    let kanjiInWord: [Kanji] = word.compactMap { (character) -> Kanji? in
      let kanjiForCharacter = allKanjiFromJSON.kanjiDictionary["\(character)"]
      return kanjiForCharacter
    }
    return kanjiInWord
  }
}
