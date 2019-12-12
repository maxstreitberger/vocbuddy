//
//  WelcomeBackViewController.swift
//  vocbuddy
//
//  Created by Max Streitberger on 24.11.19.
//  Copyright © 2019 Max Streitberger. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
//import Lottie

var allWords = [Word]()
var currentTopic = ""
var currentLevel = ""

class WelcomeViewController: UIViewController, ResultDelegate, SettingsDelegate {
    
    //MARK: - Objects
    
    //Top Spacing
    let topSpacingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Bottom Spacing
    let bottomSpacingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    
    
    //Welcome Label
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-Bold", size: 29)
        label.textColor = UIColor.white
        label.text = "Hey! Willkommen\nin der App."
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    //Settings
    let settingsIconButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "settings_icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(settings), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let settingsTextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Einstellungen", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(settings), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    //Learned Words Label
    let learnedWordsLabel: UILabel = {
        let attributedText = NSMutableAttributedString(string: "Vokabeln gelernt:  ", attributes: [NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 14)!])
        
        attributedText.append(NSAttributedString(string: "0 Wörter", attributes: [NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14)!]))
        
        let label = UILabel()
        label.attributedText = attributedText
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    //Start Button
    let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Abfrage starten", for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(r: 0, g: 127, b: 255)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(start), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Feedback Button
    let feedbackButton: UIButton = {
        let button = UIButton()
        button.setTitle("Feedback geben", for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        button.setTitleColor(UIColor(r: 255, g: 114, b: 0), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.alpha = 0
        button.addTarget(self, action: #selector(feedback), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    //Advice
    let adviceLabel: UILabel = {
        let label = UILabel()
        label.text = "Hier kannst du Themen und Schwierigkeit anpassen."
        label.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tapOnSettingsIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "tap_on_settings_icon")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    //Lottie Animation
//    let lottieView: AnimationView = {
//        let lottieView = AnimationView()
//        lottieView.isHidden = true
//        lottieView.translatesAutoresizingMaskIntoConstraints = false
//        return lottieView
//    }()
    
    
    //Loading Label
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Vokabeln werden geladen"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Montserrat-Medium", size: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //Spinner Activity
    let spinnerActivity = UIActivityIndicatorView(style: .large)
    

    var firstTime = true

    var generatedWords = [Word]()
    var todaysWords = [Word]()
    var alreadyDoneWords = [Word]()
    var learnedWords = [Word]()
    
    
    var yesterdayWrongWords = [Word]()
    
    
    var learnedWordsInt = 0
    
    var numberOfWords = 0
            
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 255, g: 114, b: 0)
        
        //Spacing
        view.addSubview(topSpacingView)
        view.addSubview(bottomSpacingView)
        
        //Welcome
        view.addSubview(welcomeLabel)
        
        //Settings
        view.addSubview(settingsIconButton)
        view.addSubview(settingsTextButton)
        
        //Learned Words
        view.addSubview(learnedWordsLabel)
        
        //Start Button
        view.addSubview(startButton)
        
        //Feedback Button
        view.addSubview(feedbackButton)
        
        //Advice
        view.addSubview(adviceLabel)
        view.addSubview(tapOnSettingsIcon)
        
        //Loading
//        view.addSubview(lottieView)
        view.addSubview(loadingLabel)

        //Spinner Activity
        view.addSubview(spinnerActivity)
                
        
        if let loadFirstTime = UserDefaults.standard.object(forKey: "firstTime") as? Bool {
            firstTime = loadFirstTime
        }
        
        print(firstTime)
        
        if firstTime {
            UserDefaults.standard.setValue("2", forKey: "level")
            welcomeLabel.alpha = 0.25
            learnedWordsLabel.alpha = 0.25
            startButton.setTitle("Alles klar!", for: .normal)
        } else {
            adviceLabel.alpha = 0
            tapOnSettingsIcon.alpha = 0
        }
        
        setUpWelcomeLabel()
        setUpSettingsButtons()
        setUpLearnedWordsLabel()
        setUpButtons()
        setUpAdvice()
        
        
        
        setUpLoadingScreen()
//        setUpSpinnerActivity()
        
        
        
//        if let animationView = LOTAnimationView(name: "servishero_loading") {
//            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
//            animationView.center = self.view.center
//            animationView.contentMode = .scaleAspectFill
//
//            view.addSubview(animationView)
//
//            animationView.play()
//        }
//        self.lottieView.play()
        
        createUser()
//
//
        getSavedWords()
//        checkDate()
        
//        saveWord(level: "Beginner")
        
//        loadWords(level: "Beginner")
        
    }
    
    
    
    //MARK: - Functions
    
    func checkDate() {
        print("All Words: \(allWords)")
        
        
        let today = Date()
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        if let yesterday = UserDefaults.standard.value(forKey: "yesterday") as? String {
            print(yesterday)
            if dateFormatter.string(from: today) != yesterday {
                print("unterschied")
                
                print(allWords.count)
                print(yesterdayWrongWords.count)
                print(todaysWords.count)
                print(alreadyDoneWords.count)
                
                for word in todaysWords {
                    if word.phase == "1" {
                        yesterdayWrongWords.append(word)
                    }
                }
                
                print(allWords.count)
                print(yesterdayWrongWords.count)
                print(todaysWords.count)
                
                var counter1 = 0
                
                while counter1 < allWords.count {
                    allWords[counter1].learned = false
                    counter1 += 1
                }
                
                var counter2 = 0
                                
                while counter2 < todaysWords.count {
                    todaysWords[counter2].learned = false
                    counter2 += 1
                }
                
                todaysWords.removeAll()
                alreadyDoneWords.removeAll()
                
                UserDefaults.standard.set(dateFormatter.string(from: today), forKey: "yesterday")
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(todaysWords) {
                    UserDefaults.standard.set(encoded, forKey: "todaysWords")
                }
                
                if let encoded = try? encoder.encode(alreadyDoneWords) {
                    UserDefaults.standard.set(encoded, forKey: "alreadyUsedWords")
                }
                
                if let encoded = try? encoder.encode(yesterdayWrongWords) {
                    UserDefaults.standard.set(encoded, forKey: "yesterdayWrongWords")
                }
                
                
                if let encoded = try? encoder.encode(allWords) {
                    UserDefaults.standard.set(encoded, forKey: currentLevel)
                    
                }
                
            } else {
                print("gleich")
                print(allWords.count)
                print(yesterdayWrongWords.count)
                print(todaysWords.count)
                print(alreadyDoneWords.count)
            }
        } else {
            print("New Date")
            todaysWords.removeAll()
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(todaysWords) {
                UserDefaults.standard.set(encoded, forKey: "todaysWords")
            }
            UserDefaults.standard.set(dateFormatter.string(from: today), forKey: "yesterday")
        }
    }    
    
    
    func checkLearnedWords() {
        let loadWords = UserDefaults.standard.integer(forKey: "learnedWordsLabelText")
        learnedWordsInt += loadWords
        
        let attributedText = NSMutableAttributedString(string: "Vokabeln gelernt:  ", attributes: [NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 14)!])
               
        attributedText.append(NSAttributedString(string: "\(learnedWordsInt) Wörter", attributes: [NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14)!]))
        
        learnedWordsLabel.attributedText = attributedText

    }
    
    func createUser() {
        Auth.auth().signInAnonymously { (result, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(result!)
            }
        }
    }
    
    func checkWords(level: String) {
        print("Check")
        Database.database().reference().child("Words").child(level).child("Number").observe(.value) { (snapshot) in
            print(snapshot)
            self.numberOfWords = snapshot.value as! Int
        }
    }
    
    func getSavedWords() {
        //Check if a topic and a level is available
//        let topicOfUD = UserDefaults.standard.value(forKey: "topic") as? String
        let levelOfUD = UserDefaults.standard.value(forKey: "level") as? String
    
//        guard let topic = topicOfUD, !topic.isEmpty, let level = levelOfUD, !level.isEmpty else { return }
        
        guard let level = levelOfUD, !level.isEmpty else { return }
//        self.checkWords(level: level)

        
//        currentTopic = topic
        currentLevel = level
        
//        print("Topic: \(currentTopic)")
        print("Level: \(currentLevel)")
        
        allWords.removeAll()
        getWords(level: currentLevel)

        Database.database().reference().child("Words").child(currentLevel).child("Number").observe(.value) { (snapshot) in
//            self.numberOfWords = snapshot.value as! Int
            DispatchQueue.main.async {
                print(allWords.count)
                print(snapshot.value as! Int)
                if snapshot.value as! Int != allWords.count {
                    self.checkNewWords(level: currentLevel)
                }
            }
        }
    }
    
    func checkNewWords(level: String) {

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        Database.database().reference().child("Words").child(level).observe(.childAdded) { (snapshot) in
            self.setUpLoading(true)
            self.spinnerActivity.startAnimating()
            if let dict = snapshot.value as? [String: Any] {
                let newWord = Word(original: "\(dict["original"]!)", translated: "\(dict["translated"]!)", level: "\(dict["level"]!)", phase: "1", lastQuery: dateFormatter.string(from: date), learned: false)
                if allWords.contains(where: {$0.original == newWord.original}) == false {
                    allWords.append(newWord)
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(allWords) {
                        UserDefaults.standard.set(encoded, forKey: level)
                    }
                }
            }
            DispatchQueue.main.async {
                self.setUpLoading(false)
                self.spinnerActivity.stopAnimating()
            }
        }
    }
    
    
    
    func getWords(level: String) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

//        if let savedWords = UserDefaults.standard.object(forKey: "\(topic)-\(level)") as? Data {
//            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
//                allWords = loadedWords
//            }
//        } else {
//            Database.database().reference().child("Words").child(topic).child(level).observe(.childAdded) { (snapshot) in
//                self.setUpLoadingScreen(true)
//                self.spinnerActivity.startAnimating()
//                if let dict = snapshot.value as? [String: Any] {
//                    let word = Word(original: "\(dict["original"]!)", translated: "\(dict["translated"]!)", level: "\(dict["level"]!)", phase: "\(dict["phase"]!)", lastQuery: dateFormatter.string(from: testDate), learned: false)
//                    allWords.append(word)
//                }
//
//                let encoder = JSONEncoder()
//                if let encoded = try? encoder.encode(allWords) {
//                    UserDefaults.standard.set(encoded, forKey: "\(topic)-\(level)")
//                    DispatchQueue.main.async {
//                        self.setUpLoadingScreen(false)
//                        self.spinnerActivity.stopAnimating()
//                    }
//                }
//            }
//        }

        if let savedWords = UserDefaults.standard.object(forKey: level) as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                print("Load")
                allWords = loadedWords
            }
        } else {
            Database.database().reference().child("Words").child(level).observe(.childAdded) { (snapshot) in
                self.setUpLoading(true)
                self.spinnerActivity.startAnimating()
                if let dict = snapshot.value as? [String: Any] {
                    let word = Word(original: "\(dict["original"]!)", translated: "\(dict["translated"]!)", level: "\(dict["level"]!)", phase: "1", lastQuery: dateFormatter.string(from: date), learned: false)
                    allWords.append(word)
                }
        
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(allWords) {
                    UserDefaults.standard.set(encoded, forKey: level)
                    DispatchQueue.main.async {
                        self.setUpLoading(false)
                        self.spinnerActivity.stopAnimating()
                    }
                }
            }
        }
        
        
        if let savedWords = UserDefaults.standard.object(forKey: "todaysWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                todaysWords = loadedWords
            }
        }
                
        if let savedWords = UserDefaults.standard.object(forKey: "alreadyUsedWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                alreadyDoneWords = loadedWords
            }
        }
        
        if let savedWords = UserDefaults.standard.object(forKey: "yesterdayWrongWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                yesterdayWrongWords = loadedWords
            }
        }
    }
    
    
    @objc func start() {
        print(allWords)
        if firstTime {
            firstTime = false
            UserDefaults.standard.set(firstTime, forKey: "firstTime")

            UIView.animate(withDuration: 0.25) {
                //Reset
                self.welcomeLabel.alpha = 1
                self.learnedWordsLabel.alpha = 1
                self.startButton.setTitle("Abfrage starten", for: .normal)

                self.adviceLabel.alpha = 0
                self.tapOnSettingsIcon.alpha = 0
            }
        } else {
            print(todaysWords.count)
            print(alreadyDoneWords.count)
            print(allWords.count)

            selectWords()
            generateQuestions()

            let playViewController = PlayViewController()
            playViewController.modalPresentationStyle = .overFullScreen
            playViewController.resultDelegate = self
            playViewController.words = generatedWords
            playViewController.answers = allWords
            present(playViewController, animated: true, completion: nil)
        }
    }
    
    func selectWords() {
        
        if todaysWords.isEmpty && alreadyDoneWords.isEmpty {
            
            var highestPhaseWords = [Word]()
            
            print("All Words: \(allWords.count)")
            
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            let todayDate = dateFormatter.string(from: today)
                        
            for word in allWords {
                if todayDate == word.lastQuery {
                    highestPhaseWords.append(word)
                } else {
                    if dateFormatter.date(from: word.lastQuery)! < today {
                        if word.phase != "1" {
                            highestPhaseWords.append(word)
                        } else {
                            print("1")
                        }
                    }
                }
            }
            
            
            print(allWords.count)
            print(highestPhaseWords.count)
                    
            while highestPhaseWords.count < 30 {
                print("first")
                if yesterdayWrongWords.isEmpty == false {
                    for word in yesterdayWrongWords {
                        highestPhaseWords.append(word)
                        let index = yesterdayWrongWords.firstIndex(where: {$0.original == word.original})!
                        yesterdayWrongWords.remove(at: index)
                    }
                } else {
                    let randomNumber = Int(arc4random_uniform(UInt32(allWords.count)))
                    highestPhaseWords.append(allWords[randomNumber])
                }
            }
            
        
            if highestPhaseWords.count == allWords.count {
                print("second")
                while highestPhaseWords.count > 30 {
                    let randomNumber = Int(arc4random_uniform(UInt32(highestPhaseWords.count)))
                    highestPhaseWords.remove(at: randomNumber)
                }
            }
            
            print(highestPhaseWords.count)
                
            todaysWords = highestPhaseWords

            print("Todays Words: \(todaysWords)")
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(todaysWords) {
                UserDefaults.standard.set(encoded, forKey: "todaysWords")
            }
            
            if let encoded = try? encoder.encode(yesterdayWrongWords) {
                UserDefaults.standard.set(encoded, forKey: "yesterdayWrongWords")
            }
            
            if let savedWords = UserDefaults.standard.object(forKey: "yesterdayWrongWords") as? Data {
                if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                    yesterdayWrongWords = loadedWords
                }
            }
            
        } else {
            print("Already 30 words")
            print("Already used: \(alreadyDoneWords)")
            print("Todays Words: \(todaysWords)")
        }
    }
 
    
    func generateQuestions() {
        generatedWords.removeAll()
        
        var counter = 1
        
        if allWords.isEmpty == false {
            if todaysWords.count == 0 {
                print("Refill")
                print(alreadyDoneWords)
                todaysWords = alreadyDoneWords
                alreadyDoneWords.removeAll()
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(alreadyDoneWords) {
                    UserDefaults.standard.set(encoded, forKey: "alreadyUsedWords")
                }
            }
            
            while counter <= 10 {
                var randomNumber = Int(arc4random_uniform(UInt32(todaysWords.count)))
                var word = todaysWords[randomNumber]
                            
                for alreadyUsedWord in alreadyDoneWords {
                    if word.original == alreadyUsedWord.original {
                        randomNumber = Int(arc4random_uniform(UInt32(todaysWords.count)))
                        word = todaysWords[randomNumber]
                    }
                }
            
                todaysWords.remove(at: randomNumber)
                generatedWords.append(word)
                
                counter += 1
            }
            
            print("Generated words: \(generatedWords)")
        }
    }
    
    func result(rightWordsInt: Int, learnedWordsList: [Word], rightWords: [Word], wrongWords: [Word], alreadyKnownWords: [Word]) {
        
        alreadyDoneWords += rightWords
        alreadyDoneWords += wrongWords
                
//        for alreadyKnownWord in alreadyKnownWords {
//            for alreadyDoneWord in alreadyDoneWords {
//                if alreadyDoneWord.original == alreadyKnownWord.original {
//                    let index = alreadyDoneWords.firstIndex(where: {$0.original == alreadyDoneWord.original})
//                    alreadyDoneWords.remove(at: index!)
//                }
//            }
//        }
        
//        if yesterdayWrongWords.count >= alreadyKnownWords.count {
//            for _ in alreadyKnownWords {
//                let randomNumber = Int(arc4random_uniform(UInt32(yesterdayWrongWords.count)))
//                alreadyDoneWords.append(yesterdayWrongWords[randomNumber])
//            }
//        } else {
//            for _ in alreadyKnownWords {
//                let randomNumber = Int(arc4random_uniform(UInt32(allWords.count)))
//                alreadyDoneWords.append(allWords[randomNumber])
//            }
//        }
        
        for word in allWords {
            for learnedWord in learnedWordsList {
                if word.original == learnedWord.original {
                    let index = allWords.firstIndex(where: {$0.original == word.original})
                    allWords.remove(at: index!)
                    allWords.append(learnedWord)
                }
            }
        }
        
        welcomeLabel.text = "Klasse! Du hast \(rightWordsInt) von 10 Vokabeln gewusst!"
        settingsTextButton.setTitle("Themengebiete ändern", for: .normal)
        startButton.setTitle("Nächste Runde", for: .normal)
        feedbackButton.alpha = 1


        
        
        //Update learnedWords Label
        learnedWordsInt += rightWordsInt
        
        let attributedText = NSMutableAttributedString(string: "Vokabeln gelernt: ", attributes: [NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 14)!])
               
        attributedText.append(NSAttributedString(string: "\(learnedWordsInt) Wörter", attributes: [NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14)!]))
        
        learnedWordsLabel.attributedText = attributedText
        
        
        
        //Update UserDefaults
        UserDefaults.standard.set(learnedWordsInt, forKey: "learnedWordsLabelText")
        
        
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(alreadyDoneWords) {
            UserDefaults.standard.set(encoded, forKey: "alreadyUsedWords")
        }
        
        if let encoded = try? encoder.encode(todaysWords) {
            UserDefaults.standard.set(encoded, forKey: "todaysWords")
        }
        
        if let encoded = try? encoder.encode(allWords) {
            UserDefaults.standard.set(encoded, forKey: currentLevel)
        }
        
        
        if let savedWords = UserDefaults.standard.object(forKey: "todaysWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                todaysWords = loadedWords
            }
        }
        
        if let savedWords = UserDefaults.standard.object(forKey: "alreadyUsedWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                alreadyDoneWords = loadedWords
            }
        }
        
        if let savedWords = UserDefaults.standard.object(forKey: currentLevel) as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                allWords = loadedWords
            }
        }
        
        print(todaysWords.count)
        print(alreadyDoneWords.count)
        print(allWords.count)
        
    }
    
    func selectSettings(level: String) {
//        UserDefaults.standard.set(topic, forKey: "topic")
        UserDefaults.standard.set(level, forKey: "level")
        
//        currentTopic = topic
        
        todaysWords.removeAll()
        alreadyDoneWords.removeAll()
        yesterdayWrongWords.removeAll()
        
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(todaysWords) {
            UserDefaults.standard.set(encoded, forKey: "todaysWords")
        }
        
        if let encoded = try? encoder.encode(alreadyDoneWords) {
            UserDefaults.standard.set(encoded, forKey: "alreadyUsedWords")
        }
        
        if let encoded = try? encoder.encode(yesterdayWrongWords) {
            UserDefaults.standard.set(encoded, forKey: "yesterdayWrongWords")
        }
        
        
        
        if let savedWords = UserDefaults.standard.object(forKey: "todaysWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                todaysWords = loadedWords
            }
        }
                
        if let savedWords = UserDefaults.standard.object(forKey: "alreadyUsedWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                alreadyDoneWords = loadedWords
            }
        }
        
        if let savedWords = UserDefaults.standard.object(forKey: "yesterdayWrongWords") as? Data {
            if let loadedWords = try? JSONDecoder().decode([FailableDecodable<Word>].self, from: savedWords).compactMap { $0.base } {
                yesterdayWrongWords = loadedWords
            }
        }
        
        
        allWords.removeAll()

        getWords(level: level)
        print(allWords.count)
    }
    
    @objc func settings() {
        let settingsViewController = SettingsViewController()
        settingsViewController.modalPresentationStyle = .overFullScreen
        settingsViewController.settingsDelegate = self
        present(settingsViewController, animated: true, completion: nil)
    }
    
    @objc func feedback() {
        let feedbackViewController = FeedbackViewController()
        feedbackViewController.modalPresentationStyle = .overFullScreen
        present(feedbackViewController, animated: true, completion: nil)
    }
    
    
    
    //MARK: - SetUp
    
    func setUpLoading(_ loading: Bool) {
        if loading {
//            lottieView.isHidden = false
            loadingLabel.isHidden = false
            settingsIconButton.alpha = 0.0
            settingsTextButton.alpha = 0.0
            welcomeLabel.alpha = 0.0
            startButton.alpha = 0.0
            tapOnSettingsIcon.alpha = 0.0
            adviceLabel.alpha = 0.0
            learnedWordsLabel.alpha = 0.0
        } else {
//            lottieView.isHidden = true
            loadingLabel.isHidden = true
            settingsIconButton.alpha = 1.0
            settingsTextButton.alpha = 1.0
            
            if firstTime {
                welcomeLabel.alpha = 0.25
                learnedWordsLabel.alpha = 0.25
                tapOnSettingsIcon.alpha = 1.0
                adviceLabel.alpha = 1.0
            }  else {
                welcomeLabel.alpha = 1.0
                learnedWordsLabel.alpha = 1.0
                tapOnSettingsIcon.alpha = 0.0
                adviceLabel.alpha = 0.0
            }
            
            startButton.alpha = 1.0
        }
    }
    
    func setUpLoadingScreen() {
        //Spinner Activity
        spinnerActivity.color = UIColor.white
        spinnerActivity.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height / 2.0)

        
//        lottieView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        lottieView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        lottieView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -200).isActive = true
//        lottieView.heightAnchor.constraint(equalTo: lottieView.widthAnchor).isActive = true
//
//        lottieView.animation = Animation.named("animation")
//        lottieView.loopMode = .loop
        
        //Loading Label
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.topAnchor.constraint(equalTo: spinnerActivity.bottomAnchor, constant: 30).isActive = true
        loadingLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -160).isActive = true
    }
    
    func setUpAdvice() {
        //Icon
        tapOnSettingsIcon.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -39).isActive = true
        tapOnSettingsIcon.topAnchor.constraint(equalTo: settingsTextButton.bottomAnchor, constant: 10).isActive = true
        
        //Label
        adviceLabel.rightAnchor.constraint(equalTo: tapOnSettingsIcon.leftAnchor, constant: -3).isActive = true
        adviceLabel.centerYAnchor.constraint(equalTo: tapOnSettingsIcon.bottomAnchor).isActive = true
        adviceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
    }
    
    func setUpButtons() {
        //Bottom Spacing
        bottomSpacingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomSpacingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if view.frame.height > 568 {
            bottomSpacingView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
        } else {
            bottomSpacingView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true
        }
        
        //Start
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        startButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 100).isActive = true
        startButton.bottomAnchor.constraint(equalTo: feedbackButton.topAnchor, constant: -24).isActive = true
        
        //Feedback
        feedbackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        feedbackButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        feedbackButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        feedbackButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 24).isActive = true
        feedbackButton.bottomAnchor.constraint(equalTo: bottomSpacingView.topAnchor).isActive = true
    }
    
    func setUpLearnedWordsLabel() {
        learnedWordsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        learnedWordsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        learnedWordsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24).isActive = true
    }
    
    func setUpSettingsButtons() {
        settingsIconButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        settingsIconButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        settingsIconButton.widthAnchor.constraint(equalToConstant: 17).isActive = true
        settingsIconButton.heightAnchor.constraint(equalToConstant: 17).isActive = true

        
        settingsTextButton.centerYAnchor.constraint(equalTo: settingsIconButton.centerYAnchor).isActive = true
        settingsTextButton.rightAnchor.constraint(equalTo: settingsIconButton.leftAnchor, constant: -8).isActive = true
    }
    
    func setUpWelcomeLabel() {
        //Top Spacing
        topSpacingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topSpacingView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        topSpacingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        welcomeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
//        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 229).isActive = true
        welcomeLabel.topAnchor.constraint(equalTo: topSpacingView.bottomAnchor).isActive = true
    }
}
