mint run swiftformat swiftformat sources
mint run swiftlint swiftlint --fix sources
mint run swiftlint swiftlint lint sources
mint run swiftformat swiftformat package.swift
mint run swiftlint swiftlint --fix package.swift
mint run swiftlint swiftlint lint package.swift
