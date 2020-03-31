//
//  Person.swift
//  InfiniteRows
//
//  Created by Ehsan Jahromi on 3/28/20.
//  Copyright © 2020 Ehsan Jahromi. All rights reserved.
//

import Foundation

class Person: NSObject {
    @objc dynamic var name: String
    @objc dynamic var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
        super.init()
    }
}

class PersonObserver: NSObject {
    var kvoToken: NSKeyValueObservation?
    @objc var person: Person

    init(person: Person) {
        self.person = person
        super.init()
        observer(person: person)
    }

    func observer(person: Person) {
        kvoToken = observe(\.person.age, options: .new, changeHandler: { person, change in
            guard let age = change.newValue else {
                return
            }
            print("new age: \(age)")
        })
    }

    deinit {
        kvoToken?.invalidate()
    }
}
