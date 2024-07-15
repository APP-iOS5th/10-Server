@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
    }
    
    override func tearDown() async throws { 
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testHelloWorld() async throws {
        try await self.app.test(.GET, "hello", afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
    
    func testStudentRoute() async throws {
        // Arrange
        let studentRecords = ["Peter": 3.42, "Thomas": 2.98, "Jane": 3.91, "Ryan": 4.00, "Kyle": 4.00]

        for (studentName, gpa) in studentRecords {
            // Act
            try await app.test(.GET, "student/\(studentName)") { res async in
                // Assert
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqual(res.body.string, "The student \(studentName)'s GPA is \(gpa)")
            }
        }
    }
    
    
}
