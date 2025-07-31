//
//  PhonemizerEngine.swift
//  Kokoro-tts-lib
//
import Foundation

// Custom phonemizer engine for converting text to phonemes without external dependencies
final class PhonemizerEngine {
  private var language: LanguageDialect = .none

  enum PhonemizerEngineError: Error {
    case languageNotFound
    case languageNotSet
    case couldNotPhonemize
  }

  // Available languages
  public enum LanguageDialect: String, CaseIterable {
    case none = ""
    case enUS = "en-us"
    case enGB = "en-gb"
    case jaJP = "ja"
    case znCN = "yue"
    case frFR = "fr-fr"
    case hiIN = "hi"
    case itIT = "it"
    case esES = "es"
    case ptBR = "pt-br"
  }

  init() throws {
    // No initialization needed for rule-based phonemizer
  }

  // Sets the language that will be used for phonemizing
  func setLanguage(for voice: TTSVoice) throws {
    guard let language = Constants.voice2Language[voice] else {
      throw PhonemizerEngineError.languageNotFound
    }
    self.language = language
  }

  public func languageForVoice(voice: TTSVoice) throws -> LanguageDialect {
    guard let language = Constants.voice2Language[voice] else {
      throw PhonemizerEngineError.languageNotFound
    }
    return language
  }

  // Phonemizes the text string using rule-based approaches
  func phonemize(text: String) throws -> String {
    guard language != .none else {
      throw PhonemizerEngineError.languageNotSet
    }

    guard !text.isEmpty else {
      return ""
    }

    let phonemes = try generatePhonemes(for: text.lowercased(), language: language)
    return postProcessPhonemes(phonemes)
  }

  // Generate phonemes using rule-based approaches for different languages
  private func generatePhonemes(for text: String, language: LanguageDialect) throws -> String {
    switch language {
    case .enUS, .enGB:
      return try generateEnglishPhonemes(text: text, isGB: language == .enGB)
    case .jaJP:
      return try generateJapanesePhonemes(text: text)
    case .znCN:
      return try generateChinesePhonemes(text: text)
    case .frFR:
      return try generateFrenchPhonemes(text: text)
    case .hiIN:
      return try generateHindiPhonemes(text: text)
    case .itIT:
      return try generateItalianPhonemes(text: text)
    case .esES:
      return try generateSpanishPhonemes(text: text)
    case .ptBR:
      return try generatePortuguesePhonemes(text: text)
    case .none:
      throw PhonemizerEngineError.languageNotSet
    }
  }

  // English phonemization using basic rules
  private func generateEnglishPhonemes(text: String, isGB: Bool) throws -> String {
    var result = text
    
    // Basic English phoneme mappings (simplified)
    let mappings: [(String, String)] = [
      ("th", "θ"), ("sh", "ʃ"), ("ch", "ʧ"), ("ph", "f"), ("gh", "f"),
      ("ck", "k"), ("qu", "kw"), ("x", "ks"), ("ng", "ŋ"),
      ("tion", "ʃən"), ("sion", "ʒən"), ("ough", "ʌf"),
      ("a", "æ"), ("e", "ɛ"), ("i", "ɪ"), ("o", "ɔ"), ("u", "ʌ"),
      ("ai", "eɪ"), ("ay", "eɪ"), ("ee", "iː"), ("ea", "iː"),
      ("oa", "oʊ"), ("ow", "oʊ"), ("ou", "aʊ"), ("oo", "uː"),
      ("ar", "ɑːɹ"), ("er", "ɜːɹ"), ("ir", "ɜːɹ"), ("or", "ɔːɹ"), ("ur", "ɜːɹ"),
      ("b", "b"), ("c", "k"), ("d", "d"), ("f", "f"), ("g", "g"),
      ("h", "h"), ("j", "ʤ"), ("k", "k"), ("l", "l"), ("m", "m"),
      ("n", "n"), ("p", "p"), ("r", "ɹ"), ("s", "s"), ("t", "t"),
      ("v", "v"), ("w", "w"), ("y", "j"), ("z", "z")
    ]
    
    for (pattern, phoneme) in mappings {
      result = result.replacingOccurrences(of: pattern, with: phoneme)
    }
    
    return result
  }

  // Japanese phonemization (Hiragana/Katakana to romanized phonemes)
  private func generateJapanesePhonemes(text: String) throws -> String {
    let mappings: [(String, String)] = [
      ("あ", "a"), ("い", "i"), ("う", "u"), ("え", "e"), ("お", "o"),
      ("か", "ka"), ("き", "ki"), ("く", "ku"), ("け", "ke"), ("こ", "ko"),
      ("が", "ga"), ("ぎ", "gi"), ("ぐ", "gu"), ("げ", "ge"), ("ご", "go"),
      ("さ", "sa"), ("し", "ʃi"), ("す", "su"), ("せ", "se"), ("そ", "so"),
      ("ざ", "za"), ("じ", "ʤi"), ("ず", "zu"), ("ぜ", "ze"), ("ぞ", "zo"),
      ("た", "ta"), ("ち", "ʧi"), ("つ", "tsu"), ("て", "te"), ("と", "to"),
      ("だ", "da"), ("ぢ", "ʤi"), ("づ", "zu"), ("で", "de"), ("ど", "do"),
      ("な", "na"), ("に", "ni"), ("ぬ", "nu"), ("ね", "ne"), ("の", "no"),
      ("は", "ha"), ("ひ", "hi"), ("ふ", "ɸu"), ("へ", "he"), ("ほ", "ho"),
      ("ば", "ba"), ("び", "bi"), ("ぶ", "bu"), ("べ", "be"), ("ぼ", "bo"),
      ("ぱ", "pa"), ("ぴ", "pi"), ("ぷ", "pu"), ("ぺ", "pe"), ("ぽ", "po"),
      ("ま", "ma"), ("み", "mi"), ("む", "mu"), ("め", "me"), ("も", "mo"),
      ("や", "ja"), ("ゆ", "ju"), ("よ", "jo"),
      ("ら", "ɹa"), ("り", "ɹi"), ("る", "ɹu"), ("れ", "ɹe"), ("ろ", "ɹo"),
      ("わ", "wa"), ("ゐ", "wi"), ("ゑ", "we"), ("を", "wo"), ("ん", "n")
    ]
    
    var result = text
    for (char, phoneme) in mappings {
      result = result.replacingOccurrences(of: char, with: phoneme)
    }
    
    // Handle ASCII characters that might be mixed in
    return result.replacingOccurrences(of: #"[a-zA-Z]"#, with: "", options: .regularExpression)
  }

  // Chinese phonemization (basic Pinyin approximation)
  private func generateChinesePhonemes(text: String) throws -> String {
    // Very basic Chinese phonemization (would need a proper dictionary in production)
    let basicMappings: [(String, String)] = [
      ("a", "a"), ("o", "o"), ("e", "ə"), ("i", "i"), ("u", "u"), ("ü", "y"),
      ("ai", "aɪ"), ("ei", "eɪ"), ("ao", "aʊ"), ("ou", "oʊ"),
      ("an", "an"), ("en", "ən"), ("ang", "aŋ"), ("eng", "əŋ"),
      ("er", "əɹ"), ("zh", "ʤ"), ("ch", "ʧ"), ("sh", "ʃ"), ("r", "ɹ"),
      ("z", "ts"), ("c", "tsʰ"), ("s", "s"),
      ("b", "p"), ("p", "pʰ"), ("m", "m"), ("f", "f"),
      ("d", "t"), ("t", "tʰ"), ("n", "n"), ("l", "l"),
      ("g", "k"), ("k", "kʰ"), ("h", "x"),
      ("j", "ʤ"), ("q", "ʧʰ"), ("x", "ʃ")
    ]
    
    var result = text
    for (pinyin, phoneme) in basicMappings {
      result = result.replacingOccurrences(of: pinyin, with: phoneme)
    }
    
    return result
  }

  // French phonemization
  private func generateFrenchPhonemes(text: String) throws -> String {
    let mappings: [(String, String)] = [
      ("ch", "ʃ"), ("j", "ʒ"), ("gn", "ɲ"), ("ll", "j"), ("qu", "k"),
      ("ph", "f"), ("th", "t"), ("x", "ks"),
      ("a", "a"), ("à", "a"), ("â", "a"), ("ä", "a"),
      ("e", "ə"), ("é", "e"), ("è", "ɛ"), ("ê", "ɛ"), ("ë", "ɛ"),
      ("i", "i"), ("î", "i"), ("ï", "i"),
      ("o", "o"), ("ô", "o"), ("ö", "o"),
      ("u", "u"), ("ù", "u"), ("û", "u"), ("ü", "y"),
      ("y", "i"), ("ÿ", "i"),
      ("ai", "ɛ"), ("au", "o"), ("eau", "o"), ("ei", "ɛ"), ("eu", "ø"), ("ou", "u"),
      ("oi", "wa"), ("oin", "wɛ̃"), ("on", "ɔ̃"), ("an", "ɑ̃"), ("en", "ɑ̃"), ("in", "ɛ̃"), ("un", "œ̃"),
      ("b", "b"), ("c", "k"), ("ç", "s"), ("d", "d"), ("f", "f"), ("g", "g"),
      ("h", ""), ("k", "k"), ("l", "l"), ("m", "m"), ("n", "n"), ("p", "p"),
      ("r", "ʁ"), ("s", "s"), ("t", "t"), ("v", "v"), ("w", "w"), ("z", "z")
    ]
    
    var result = text
    for (pattern, phoneme) in mappings {
      result = result.replacingOccurrences(of: pattern, with: phoneme)
    }
    
    return result
  }

  // Hindi phonemization (Devanagari to IPA approximation)
  private func generateHindiPhonemes(text: String) throws -> String {
    let mappings: [(String, String)] = [
      ("अ", "ə"), ("आ", "aː"), ("इ", "ɪ"), ("ई", "iː"), ("उ", "ʊ"), ("ऊ", "uː"),
      ("ऋ", "ɾɪ"), ("ए", "eː"), ("ऐ", "æː"), ("ओ", "oː"), ("औ", "ɔː"),
      ("क", "k"), ("ख", "kʰ"), ("ग", "g"), ("घ", "gʱ"), ("ङ", "ŋ"),
      ("च", "ʧ"), ("छ", "ʧʰ"), ("ज", "ʤ"), ("झ", "ʤʱ"), ("ञ", "ɲ"),
      ("ट", "ʈ"), ("ठ", "ʈʰ"), ("ड", "ɖ"), ("ढ", "ɖʱ"), ("ण", "ɳ"),
      ("त", "t̪"), ("थ", "t̪ʰ"), ("द", "d̪"), ("ध", "d̪ʱ"), ("न", "n"),
      ("प", "p"), ("फ", "pʰ"), ("ब", "b"), ("भ", "bʱ"), ("म", "m"),
      ("य", "j"), ("र", "ɾ"), ("ल", "l"), ("व", "ʋ"),
      ("श", "ʃ"), ("ष", "ʂ"), ("स", "s"), ("ह", "ɦ")
    ]
    
    var result = text
    for (char, phoneme) in mappings {
      result = result.replacingOccurrences(of: char, with: phoneme)
    }
    
    return result
  }

  // Italian phonemization
  private func generateItalianPhonemes(text: String) throws -> String {
    let mappings: [(String, String)] = [
      ("ch", "k"), ("gh", "g"), ("gli", "ʎ"), ("gn", "ɲ"), ("sc", "ʃ"),
      ("a", "a"), ("e", "e"), ("i", "i"), ("o", "o"), ("u", "u"),
      ("b", "b"), ("c", "ʧ"), ("d", "d"), ("f", "f"), ("g", "ʤ"),
      ("h", ""), ("l", "l"), ("m", "m"), ("n", "n"), ("p", "p"),
      ("q", "kw"), ("r", "r"), ("s", "s"), ("t", "t"), ("v", "v"),
      ("z", "ts")
    ]
    
    var result = text
    for (pattern, phoneme) in mappings {
      result = result.replacingOccurrences(of: pattern, with: phoneme)
    }
    
    return result
  }

  // Spanish phonemization
  private func generateSpanishPhonemes(text: String) throws -> String {
    let mappings: [(String, String)] = [
      ("ch", "ʧ"), ("ll", "ʎ"), ("ñ", "ɲ"), ("rr", "r"), ("qu", "k"),
      ("a", "a"), ("e", "e"), ("i", "i"), ("o", "o"), ("u", "u"),
      ("b", "b"), ("c", "k"), ("d", "d"), ("f", "f"), ("g", "g"),
      ("h", ""), ("j", "x"), ("k", "k"), ("l", "l"), ("m", "m"),
      ("n", "n"), ("p", "p"), ("r", "ɾ"), ("s", "s"), ("t", "t"),
      ("v", "b"), ("w", "w"), ("x", "ks"), ("y", "j"), ("z", "θ")
    ]
    
    var result = text
    for (pattern, phoneme) in mappings {
      result = result.replacingOccurrences(of: pattern, with: phoneme)
    }
    
    return result
  }

  // Portuguese phonemization
  private func generatePortuguesePhonemes(text: String) throws -> String {
    let mappings: [(String, String)] = [
      ("ch", "ʃ"), ("lh", "ʎ"), ("nh", "ɲ"), ("qu", "k"), ("rr", "x"),
      ("a", "a"), ("ã", "ɐ̃"), ("e", "e"), ("ê", "e"), ("é", "ɛ"),
      ("i", "i"), ("o", "o"), ("ô", "o"), ("ó", "ɔ"), ("u", "u"),
      ("ç", "s"), ("b", "b"), ("c", "k"), ("d", "d"), ("f", "f"),
      ("g", "g"), ("h", ""), ("j", "ʒ"), ("k", "k"), ("l", "l"),
      ("m", "m"), ("n", "n"), ("p", "p"), ("r", "ɾ"), ("s", "s"),
      ("t", "t"), ("v", "v"), ("w", "w"), ("x", "ʃ"), ("y", "j"), ("z", "z")
    ]
    
    var result = text
    for (pattern, phoneme) in mappings {
      result = result.replacingOccurrences(of: pattern, with: phoneme)
    }
    
    return result
  }

  // Post processes manually phonemes before returning them
  // NOTE: This is currently only for English, handling other langauges requires different kind of postproccessing
  private func postProcessPhonemes(_ phonemes: String) -> String {
    var result = phonemes.trimmingCharacters(in: .whitespacesAndNewlines)
    for (old, new) in Constants.E2M {
      result = result.replacingOccurrences(of: old, with: new)
    }

    result = result.replacingOccurrences(of: "(\\S)\u{0329}", with: "ᵊ$1", options: .regularExpression)
    result = result.replacingOccurrences(of: "\u{0329}", with: "")

    if language == .enGB {
      result = result.replacingOccurrences(of: "e^ə", with: "ɛː")
      result = result.replacingOccurrences(of: "iə", with: "ɪə")
      result = result.replacingOccurrences(of: "ə^ʊ", with: "Q")
    } else {
      result = result.replacingOccurrences(of: "o^ʊ", with: "O")
      result = result.replacingOccurrences(of: "ɜːɹ", with: "ɜɹ")
      result = result.replacingOccurrences(of: "ɜː", with: "ɜɹ")
      result = result.replacingOccurrences(of: "ɪə", with: "iə")
      result = result.replacingOccurrences(of: "ː", with: "")
    }

    result = result.replacingOccurrences(of: "o", with: "ɔ")
    return result.replacingOccurrences(of: "^", with: "")
  }

  private enum Constants {
    static let E2M: [(String, String)] = [
      ("ʔˌn\u{0329}", "tn"), ("ʔn\u{0329}", "tn"), ("ʔn", "tn"), ("ʔ", "t"),
      ("a^ɪ", "I"), ("a^ʊ", "W"),
      ("d^ʒ", "ʤ"),
      ("e^ɪ", "A"), ("e", "A"),
      ("t^ʃ", "ʧ"),
      ("ɔ^ɪ", "Y"),
      ("ə^l", "ᵊl"),
      ("ʲo", "jo"), ("ʲə", "jə"), ("ʲ", ""),
      ("ɚ", "əɹ"),
      ("r", "ɹ"),
      ("x", "k"), ("ç", "k"),
      ("ɐ", "ə"),
      ("ɬ", "l"),
      ("\u{0303}", ""),
    ].sorted(by: { $0.0.count > $1.0.count })
    static let voice2Language: [TTSVoice: LanguageDialect] = [
      .afAlloy: .enUS,
      .afAoede: .enUS,
      .afBella: .enUS,
      .afHeart: .enUS,
      .afJessica: .enUS,
      .afKore: .enUS,
      .afNicole: .enUS,
      .afNova: .enUS,
      .afRiver: .enUS,
      .afSarah: .enUS,
      .afSky: .enUS,
      .amAdam: .enUS,
      .amEcho: .enUS,
      .amEric: .enUS,
      .amFenrir: .enUS,
      .amLiam: .enUS,
      .amMichael: .enUS,
      .amOnyx: .enUS,
      .amPuck: .enUS,
      .amSanta: .enUS,
      .bfAlice: .enGB,
      .bfEmma: .enGB,
      .bfIsabella: .enGB,
      .bfLily: .enGB,
      .bmDaniel: .enGB,
      .bmFable: .enGB,
      .bmGeorge: .enGB,
      .bmLewis: .enGB,
      .efDora: .esES,
      .emAlex: .esES,
      .ffSiwis: .frFR,
      .hfAlpha: .hiIN,
      .hfBeta: .hiIN,
      .hfOmega: .hiIN,
      .hmPsi: .hiIN,
      .ifSara: .itIT,
      .imNicola: .itIT,
      .jfAlpha: .jaJP,
      .jfGongitsune: .jaJP,
      .jfNezumi: .jaJP,
      .jfTebukuro: .jaJP,
      .jmKumo: .jaJP,
      .pfDora: .ptBR,
      .pmSanta: .ptBR,
      .zfZiaobei: .znCN,
      .zfXiaoni: .znCN,
      .zfXiaoxiao: .znCN,
      .zfZiaoyi: .znCN,
      .zmYunjian: .znCN,
      .zmYunxi: .znCN,
      .zmYunxia: .znCN,
      .zmYunyang: .znCN
    ]
  }
}
