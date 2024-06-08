//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Денис Петров on 17.12.2023.
//

import Foundation

struct QuizQuestion {
    let image: Data
    // строка с вопросом о рейтинге фильма
    let text: String
    // булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}

