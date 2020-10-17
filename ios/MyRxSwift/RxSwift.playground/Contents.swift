import UIKit
import RxSwift

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

/*
 Subscriptions on Observables
 */

/*
exampleOf(description: "just") {
    let observable = Observable.just("Hello, world!")
    
    observable.subscribe({ (event: Event<String>) in
        print(event)
    })
}

exampleOf(description: "of") {
    let observable = Observable.of(1, 2, 3)
    
    observable.subscribe {
        print($0)
    }
}

exampleOf(description: "asObservable") {
    
    let disposeBag = DisposeBag()
    
    let array = Observable.from([1, 2, 3])
    array.asObservable()
        .subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    let array2 = Observable.from([4, 5, 6])
    array2.asObservable().subscribe(onNext: nil, onCompleted: {
        print("Completed")
    }).disposed(by: disposeBag)
    
}


exampleOf(description: "error") {
    enum Error: Swift.Error {
        case Test
    }
    
    Observable<Int>.error(Error.Test)
        .subscribe {
        print($0)
    }
}
*/



/*
 Work with Subjects
 */

/*
exampleOf(description: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    subject.subscribe {
        print($0)
    }
    
    enum Error: Swift.Error {
        case Test
    }
    
    subject.onNext("Hello")
//    subject.onCompleted()
//    subject.onError(Error.Test)
    subject.onNext("World")
    
    let newSubscription = subject.subscribe(onNext: {
        print("New Subscription:", $0)
    })
    
    subject.onNext("What's up?")
    
    newSubscription.dispose()
    subject.onNext("Still there?")
    
}


exampleOf(description: "BehaviourSubject") {
    let disposeBag = DisposeBag()
    
    let subject = BehaviorSubject(value: "a")
    
    let firstSubscription = subject.subscribe(onNext: {
        print(#line, $0)
    }).disposed(by: disposeBag)
    
    subject.onNext("b")
    
    let secondSubscription = subject.subscribe(onNext: {
        print(#line, $0)
    }).disposed(by: disposeBag)
    
}

exampleOf(description: "ReplaySubject") {
    let disposeBag = DisposeBag()
    
    let subject = ReplaySubject<Int>.create(bufferSize: 3)
    
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
    subject.onNext(4)
    
    subject.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
}

exampleOf(description: "VariableSubject") {
    let disposeBag = DisposeBag()
    
    let variable = Variable("A")
    variable.asObservable().subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    variable.value = "B"
}
 */

/*
 Transform Observable Sequences
 */

/*
exampleOf(description: "map") {
    Observable.of(1, 2, 3).map {
        $0 * $0
        }.subscribe(onNext: {
            print($0)
        }).dispose()
}

exampleOf(description: "flatMap & flatMapLatest") {
    let disposeBag = DisposeBag()
    
    struct Player {
        let score: Variable<Int>
    }
    
    let scott = Player(score: Variable(80))
    let lori = Player(score: Variable(90))
    var player = Variable(scott)
    
    player.asObservable().flatMapLatest {
        $0.score.asObservable()
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    
    player.value.score.value = 85
    scott.score.value = 88
    
    player.value = lori
    scott.score.value = 95
    
    lori.score.value = 100
    player.value.score.value = 105
    
}

exampleOf(description: "scan") {
    let disposeBag = DisposeBag()
    
    let dartScore = PublishSubject<Int>()
    
    dartScore.asObserver()
        .buffer(timeSpan: 0.0, count: 3, scheduler: MainScheduler.instance)
        .map {
            $0.reduce(0, { prev, value in
                value + 0
            })
        }
        .scan(501) { intermediate, newValue in
        let result = intermediate - newValue
        return result == 0 || result > 1 ? result : intermediate
        }
        .do(onNext: {
            if $0 == 0 {
                dartScore.onCompleted()
            }
        })
        .subscribe({
            print($0.isStopEvent ? $0 : $0.element!)
        }).disposed(by: disposeBag)
    
    dartScore.onNext(13)
    dartScore.onNext(60)
    dartScore.onNext(50)
    dartScore.onNext(0)
    dartScore.onNext(0)
    dartScore.onNext(378)
    
}
 */



/*
 Filter Observable Sequences
 */

/*
exampleOf(description: "filter") {
    let disposeBag = DisposeBag()
    let numbers = Observable.generate(initialState: 1, condition: { $0 < 101 }, iterate: { $0 + 1 })
    
    numbers.filter { number in
        guard number > 1 else { return false }
        var isPrime = true
        
        (2..<number).forEach {
            if number % $0 == 0 {
                isPrime = false
            }
        }
        
        return isPrime
        }
        .toArray()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
}

exampleOf(description: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    let searchString = Variable("")
    searchString.asObservable()
        .map { $0.lowercased() }
        .distinctUntilChanged().subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    searchString.value = "APPLE"
    searchString.value = "apple"
    searchString.value = "Banana"
    searchString.value = "APPLE"
    
}

exampleOf(description: "takeWhile") {
    let disposeBag = DisposeBag()
    
    let numbers = Observable.from([1, 2, 3, 4, 3, 2, 1])
    numbers.takeWhile {
        $0 < 4
        }.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    
}
 */


/*
 Combine Observable Sequences
 */

/*
exampleOf(description: "startWith") {
    let disposeBag = DisposeBag()
    
    Observable.of("1", "2", "3")
        .startWith("A")
        .startWith("B")
        .startWith("C", "D")
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    
}

exampleOf(description: "merge") {
    let disposeBag = DisposeBag()
    
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()
    
    Observable.of(subject1, subject2)
        .merge().subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    
    subject1.onNext("A")
    subject1.onNext("B")
    
    subject2.onNext("1")
    subject2.onNext("2")
    
    subject1.onNext("C")
    subject2.onNext("3")
    
}

exampleOf(description: "zip") {
    let disposeBag = DisposeBag()
    
    let stringSubject = PublishSubject<String>()
    let intSubject = PublishSubject<Int>()
    
    Observable.zip(stringSubject, intSubject) { stringElement, intElement in
        "\(stringElement) \(intElement)"
    }.subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
    stringSubject.onNext("A")
    stringSubject.onNext("B")
    
    intSubject.onNext(1)
    intSubject.onNext(2)
    
    intSubject.onNext(3)
    stringSubject.onNext("C")
    
}
 */


/*
 Combine Observable Sequences
 */

/*
exampleOf(description: "doOnNext") {
    let disposeBag = DisposeBag()
    
    let fahrenheitTemps = Observable.from([-40, 0, 32, 70, 212])
    fahrenheitTemps
        .do(onNext: {
            $0 * $0
        }).do(onNext:{
            print("\($0)℉ = ", terminator: "")
        }).map { Double($0 - 32) * 5/9.0 }
        .subscribe(onNext: {
            print(String(format: "%.1f℃", $0))
    }).disposed(by: disposeBag)
    
}
 */


/*
 Use Schedulers
 */

let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 128.0, height: 128.0))
PlaygroundPage.current.liveView = imageView

let swift = UIImage(named: "Swift")
let swiftImageData = swift!.pngData()!
let rx = UIImage(named: "Rx")
let rxImageData = rx!.pngData()!

let disposeBag = DisposeBag()

let imageDataSubject = PublishSubject<Data>()

let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

let myQueue = DispatchQueue(label: "com.scotteg.myConcurrentQueue")
let scheduler2 = SerialDispatchQueueScheduler(queue: myQueue, internalSerialQueueName: "com.scotteg.mySerialQueue")

let operationQueue = OperationQueue()
operationQueue.qualityOfService = .background
let scheduler3 = OperationQueueScheduler(operationQueue: operationQueue)

imageDataSubject
    .observeOn(scheduler3)
    .map { UIImage(data: $0) }
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: {
        imageView.image = $0
    }).disposed(by: disposeBag)

imageDataSubject.onNext(swiftImageData)
imageDataSubject.onNext(rxImageData)


playgroundTimeLimit(seconds: 10)

