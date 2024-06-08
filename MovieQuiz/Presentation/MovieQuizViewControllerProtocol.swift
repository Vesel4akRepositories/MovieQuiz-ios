//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Денис Петров on 08.06.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func paintBorder(_ isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    func showFailedToLoadPosterAlert()
    
}
