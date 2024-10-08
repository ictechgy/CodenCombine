//
//  ViewController.swift
//  TestApp
//
//  Created by JINHONG AN on 10/3/24.
//

import UIKit
import CodenCombine
import Combine

final class ViewController: UIViewController {

    @IBOutlet private weak var centerButton: UIButton!
    private let testText = "테스트용 텍스트"
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view
            .tapGesture
            .sink { _ in
                print("무야호")
            }
            .store(in: &cancellables)
        
        centerButton
            .onTouchUpInside
            .sink { _ in
                print("버튼 눌림")
            }
            .store(in: &cancellables)
        
        Just(1)
            .withUnretained(self)
            .sink { viewController, _ in
                print(viewController.testText)
            }
            .store(in: &cancellables)
        
        Just(1)
            .scan(100) { $0 + $1 }
            .sink { number in
                print("scan 확인 \(number)")
            }
            .store(in: &cancellables)
        
        Just(1000)
            .observe(on: DispatchQueue.main)
            .sink { _ in
                print("이거 잘 될까??")
            }
            .store(in: &cancellables)
        
        let subject = PassthroughSubject<Int, Error>()
        subject
            .sink { _ in
                print("completed")
                subject.send(completion: .failure(NSError())) // 무한 재귀를 일으키지 않음
            } receiveValue: { _ in
                print("receive value")
                subject.send(1) // 무한재귀를 일으킴
            }
            .store(in: &cancellables)

        subject.send(completion: .failure(NSError()))
        subject.send(1)
    }
    
    deinit {
        print("메모리 해제됨")
    }
}

