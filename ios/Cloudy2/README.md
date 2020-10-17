### Mastering Model-View-Viewmodel With Swift

#### Author: Bart Jacobs

# Welcome

Welcome to **Mastering MVVM With Swift**. I'm glad to see you here. In this book, you learn the ins and outs of the **Model-View-ViewModel** pattern. The goal of this book is to provide you with the ingredients you need to implement the Model-View-ViewModel pattern in your own projects.

## Xcode 9 and Swift 4

This book uses Xcode 9 and Swift 4. Only the chapters about reactive programming stick with Xcode 9 and Swift 3. These chapters will be updated once RxSwift/RxCocoa officially support Swift 4. If you want to follow along, make sure you have Xcode 8 or 9 installed on your machine. Everything you learn in this book applies to both Swift 3 and Swift 4.

## What You'll Learn

This book covers much more than the **Model-View-ViewModel** pattern. We start with an overview of the Model-View-ViewModel pattern and we compare it with the popular **Model-View-Controller** pattern, a pattern you're probably already familiar with.

In the remainder of the book, we refactor **Cloudy**, a weather application powered by the Model-View-Controller pattern. We refactor Cloudy to use the Model-View-ViewModel pattern instead. This will show you how to apply the Model-View-ViewModel pattern in a production application. The refactoring operation will show you exactly what needs to change to move from MVC to MVVM, highlighting the benefits and challenges that go with this migration.

Along the way, you learn what view models are, how to create them, and how to use them in view controllers. We further simplify the view controllers of the project using protocol-oriented programming. Protocols and MVVM work very well together.

Later in the book, we write unit tests for the view models we created. One of the key benefits of the Model-View-ViewModel pattern is improved testability and that's something I want to show you first-hand. Writing unit tests for view models is really easy.

The Model-View-ViewModel pattern really shines with the help of bindings. I first show you how to create a custom bindings solution. This is an important step as it will show you how the Model-View-ViewModel pattern and bindings work under the hood.

Later in the book, we take it a step further by taking advantage of RxSwift and RxCocoa. You don't need to be familiar with reactive programming to understand these chapters. We primarily focus on the Model-View-ViewModel pattern and how it plays together with bindings. The Model-View-ViewModel pattern works with any bindings solution.

We end this book with a quick recap of what we gained from using the Model-View-ViewModel pattern instead of the Model-View-Controller pattern. The changes we apply to Cloudy are pretty dramatic and I'm sure you'll appreciate the benefits the Model-View-ViewModel pattern has to offer.

This book covers a lot of ground, but I'm here to guide you along the way. If you have any feedback or questions, reach out to me via email (bart@cocoacasts.com) or Twitter (@_bartjacobs). I'm here to help.

## How to Use This Book

If you'd like to follow along, I recommend downloading the source files that come with this book. The chapters that include code each have a starter project and a finished project. This makes it easy to follow along or pick a random chapter from the book. [Click here](https://goo.gl/rf8J6b) to download the source files for this book. If you're new to the Model-View-ViewModel pattern, then I recommend reading every chapter of the book.

Not everyone likes books. If you prefer video, then you may be interested in a video course in which I teach the Model-View-ViewModel pattern. The content is virtually identical. The only difference is that you can see how I refactor Notes using the Model-View-ViewModel pattern. You can find the video course on the [Cocoacasts website](https://cocoacasts.com/mastering-model-view-viewmodel-with-swift-3/).