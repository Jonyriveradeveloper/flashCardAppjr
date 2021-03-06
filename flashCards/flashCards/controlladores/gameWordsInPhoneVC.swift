//
//  gameWordsInPhoneVC.swift
//  flashCards
//
//  Created by Misael Rivera on 12/18/18.
//  Copyright © 2018 misael rivera. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class gameWordsInPhoneVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var wordLbl: UILabel!
    @IBOutlet weak var answertxt: UITextField!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var checkAnswerBtn: vistaBotones!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var progresssView: UIView!
    @IBOutlet weak var viewWord: sombraVista!
    @IBOutlet weak var viewAnuncios: GADBannerView!
    @IBOutlet weak var correctAnswerTxt: UILabel!
    //agregamos esto
    @IBOutlet weak var viewPrin: UIView!
    @IBOutlet weak var card: sombraVista!
    @IBOutlet weak var wordShow: UILabel!
    
    
    var wordsForLearn:WordsBankStruck?
    
    var numberWord:Int = 0
    var lado:Bool!
    var switchOn:Bool = false
    var correctAnswer = 0
    var skipWord = 0
    var incorrectanswer = 0
    var puntos = 0
    
    var ejemplo:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answertxt.delegate = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //anuncios
        viewAnuncios.adUnitID = "ca-app-pub-5222742314105921/6585214830"
        viewAnuncios.rootViewController = self
        viewAnuncios.load(GADRequest())
        
        
        //agregamos esto
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        card.addGestureRecognizer(tap)
    }
        //agregamos esto
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        setWordAndTranslateWithAnimation(view: card)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        updateVaribles()
        updateViews()
        nextWord()
        answertxt.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    //funcion para actualizar las variables a cero y los lbl despues de jugar
    func updateVaribles(){
        numberWord = 0
        correctAnswer = 0
        incorrectanswer = 0
        puntos = 0
        wordLbl.text = ""
    }
    //por medio de esta funcion le decimos al txt que si el txt esta vacio el boton se ponga no disponible
    //pero si el usuario ya ingreso datos que se ponga disponible
    @objc func textFieldDidChange(textField: UITextField) {
        if (answertxt.text?.isEmpty)!{
            checkAnswerBtn.isEnabled = false
            checkAnswerBtn.alpha = 0.5
        }else{
            checkAnswerBtn.isEnabled = true
            checkAnswerBtn.alpha = 1
        }
    }
    
    //funcion para iniciar a jugar
    //preguntamos si el numero de palabras es menor que la cantidad de palabras
    //si es menor entonces introducimos en el lbl word la palabra que tiene el array words en la posicion numerWord
    func nextWord() {
        if numberWord < wordsForLearn!.wordsArrayPhone.count {
            switchOn = getProbability()
            
            if switchOn == false {
                wordLbl.text = wordsForLearn!.wordsArrayPhone[numberWord].word
            }
            else if switchOn {
                wordLbl.text = wordsForLearn!.wordsArrayPhone[numberWord].translate
            }
        }
        else {
            performSegue(withIdentifier: "showScore2", sender: self)
        }
    }
    
    func getProbability() -> Bool{
        let randomInt = Int(arc4random_uniform(10) + 1)
        print("el numero que obtengo -> \(randomInt)")
        if randomInt < 8 {
            return false
        }
        else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let myScoreVC = segue.destination as? scoreVC {
            myScoreVC.getData(correct: correctAnswer, incorrect: incorrectanswer, learned: 0, myPts: puntos, skipWord: skipWord)
        }
    }
    
    func transitionLeft() {
        UIView.transition(with: viewWord, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    func transitionRight() {
        UIView.transition(with: viewWord, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
     //funcion para actualizar vistas, txt y botones cuando se pasa a la siguiente palabra
    func updateLbl() {
        answertxt.text = ""
        correctAnswerTxt.isHidden = true
        checkAnswerBtn.isEnabled = false
        checkAnswerBtn.alpha = 0.5
    }
    //funcion para ir cambiando la barra de estado
    func updateViews() {
        //buscamos en cada una de las constrains de la abrra de progresos
        //si el identificador del constrainr es igual a barWidht
        //entonces cambio el valor
        for constraint in self.progresssView.constraints {
            if constraint.identifier == "barWidhtGame" {
                constraint.constant = (self.view.frame.size.width * 0.70)/CGFloat(self.wordsForLearn!.wordsArrayPhone.count) * CGFloat(numberWord)
            }
        }
    }
    
    //creamos funcion para convertir texto a audio y le pasamos por parametro la palabra que queremos escuchar
    func convertTextToSpeech(forText text:String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    //funcion para checar respuesta
    //creamos una constante para obtener la respuesta correcta
    //verificamos que el txt no este vacio
    //preguntamos si la respuesta es igual a la respuesta del array
    //si es correcta giramos la carta hacia la izquierda y cambiamos color de texto y fondo y escribimos un mensaje
    //cambiamos valor de lado
    func checkAnswer() {
        var correctAnswer = ""
        
        if switchOn == false {
            correctAnswer = wordsForLearn!.wordsArrayPhone[numberWord].translate!
        }
            
        else if switchOn {
            correctAnswer = wordsForLearn!.wordsArrayPhone[numberWord].word!
        }
        
        if answertxt.text != "" {
            
            var correctAnswerC = correctAnswer.replacingOccurrences(of: " ", with: "")
            var answerC = answertxt.text!.replacingOccurrences(of: " ", with: "")
            correctAnswerC = correctAnswerC.folding(options: .diacriticInsensitive, locale: .current)
            answerC = answerC.folding(options: .diacriticInsensitive, locale: .current)
            
            if correctAnswerC.lowercased() == answerC.lowercased()
            {
                self.voiceBtn.isHidden = true
                self.correctAnswer += 1
                self.transitionLeft()
                print("correct")
                wordLbl.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                viewWord.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
                wordLbl.text = "correcto🥳!"
                lado = true
                puntos += 1
            }
            else {
                self.voiceBtn.isHidden = true
                self.incorrectanswer += 1
                print("incorrect")
                transitionRight()
                wordLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                viewWord.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                correctAnswerTxt.isHidden = false
                wordLbl.text = "incorrecto😞!"
                correctAnswerTxt.text = correctAnswer
                lado = false
            }
        }
    }
    
    //boton de aceptar fue presionado y verificamos la respuesta y al numero de palabra de sumamos 1
    //despues de checar la respuesta
    //actualizamos los lbl txt botones
    //actualizamos la barra de progreso
    //iniciamos el juego de neuvo
    //le damos color al texto y fondo
    //si el lado es true lo giramos a la derecha y si no a al izquierda
    @IBAction func checkBtnWasPressed(_ sender: Any) {
        checkAnswer()
        numberWord += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.updateLbl()
            self.updateViews()
            self.nextWord()
            self.wordLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.viewWord.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            if self.lado {
                self.transitionRight()
            } else {
                self.transitionLeft()
            }
            self.voiceBtn.isHidden = false
        }
    }
    @IBAction func skipBtnWasPressed(_ sender: Any) {
        skipWord += 1
        numberWord += 1
        if puntos > 0 {
            puntos -= 1
        }
        updateViews()
        updateLbl()
        nextWord()
    }
    @IBAction func voiceBtnWasPressed(_ sender: Any) {
        convertTextToSpeech(forText:  wordsForLearn!.wordsArrayPhone[numberWord].word!)
    }
    
    @IBAction func exitBtnWasPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Estas seguro?", message: "Si tu te sales perderas todo tu progreso.😰", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let alertAction2 = UIAlertAction(title: "Ok", style: .default) { (alertAction2) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(alertAction)
        alert.addAction(alertAction2)
        present(alert, animated: true, completion: nil)
    }
    //agregamos esto
    @IBAction func panGestureCard(_ sender: UIPanGestureRecognizer) {
        let card  = sender.view!
        let point = sender.translation(in: view)
        card.center = CGPoint(x: view.center.x + point.x, y: (view.center.y-60) + point.y)
        
        if sender.state == UIGestureRecognizer.State.ended {
            
            if card.center.x < 75 {
                //move off to the left side
                UIView.animate(withDuration: 0.3) {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 25)
                    card.alpha = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                        self.resetCard()
                    })
                }
                return
            }else if card.center.x > (view.frame.width - 75) {
                //move off to the right side
                UIView.animate(withDuration: 0.3) {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 25)
                    card.alpha = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                        self.resetCard()
                    })
                }
                return
            }
            resetCard()
        }
    }
    func resetCard() {
        UIView.animate(withDuration: 0.2) {
            self.card.center = CGPoint(x: self.view.center.x, y: self.view.center.y-60)
            self.card.alpha = 1
        }
    }
    func transitionLeft(view:UIView) {
        UIView.transition(with: view, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    func transitionRight(view:UIView) {
        UIView.transition(with: view, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
    func setWordAndTranslateWithAnimation(view :UIView){
        
        if ejemplo
        {
            wordShow.text = "Principal 1"
            transitionRight(view: view)
            ejemplo = false
        }else{
            wordShow.text = "Principal 2"
            transitionLeft(view: view)
            ejemplo = true
        }
    }
}
