import XCTest

import plistTests

var tests = [XCTestCaseEntry]()
tests += plistTests.allTests()
XCTMain(tests)
