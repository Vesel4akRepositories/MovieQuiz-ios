//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Денис Петров on 17.12.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
    func didFailLoadPosterImage() // ошибка загрузки постера 
}
