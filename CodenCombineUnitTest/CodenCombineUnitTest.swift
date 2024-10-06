//
//  CodenCombineUnitTest.swift
//  CodenCombineUnitTest
//
//  Created by Coden on 10/5/24.
//

import XCTest
import Combine
@testable import CodenCombine

final class CodenCombineUnitTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellables.removeAll()
    }

    func test_withLatestFrom은_하나의_Publisher_Element가오면_다른_Publisher의_마지막_Element를_같이_전달한다() {
        // given
        let climberMonologue = PassthroughSubject<String, Never>()
        let numberOfProblemsSolvedNotTotal = PassthroughSubject<Int, Never>()
        
        var totalCountOfSpeech = 0
        var latestSpeechOfClimber: String?
        var totalNumberOfProblemsBroken = 0
        var lastNumberOfProlblemBroken = -1
        
        climberMonologue.withLatestFrom(numberOfProblemsSolvedNotTotal)
            .sink { liveSpeechOfClimber, liveNumberOfProblemsBroken in
                totalCountOfSpeech += 1
                latestSpeechOfClimber = liveSpeechOfClimber
                totalNumberOfProblemsBroken += liveNumberOfProblemsBroken
                lastNumberOfProlblemBroken = liveNumberOfProblemsBroken
            }
            .store(in: &cancellables)
        
        // when
        numberOfProblemsSolvedNotTotal.send(1)
        climberMonologue.send("🔴 빨강 한문제 깼다!")
        
        numberOfProblemsSolvedNotTotal.send(1)
        climberMonologue.send("🔵 파랑 한문제 깼다!")
        
        numberOfProblemsSolvedNotTotal.send(0)
        climberMonologue.send("🟣 아쉽게 보라는 못깼네 🥲")
        
        // then
        XCTAssertEqual(totalCountOfSpeech, 3)
        XCTAssertEqual(totalNumberOfProblemsBroken, 2)
        XCTAssertEqual(latestSpeechOfClimber, "🟣 아쉽게 보라는 못깼네 🥲")
        XCTAssertEqual(lastNumberOfProlblemBroken, 0)
    }
}
