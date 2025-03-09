import Testing

@testable import SLLabyrinthGenerator

@Test func example() async throws {
    let field = generateLabyrinth()
    print(SquareFieldPrinter().print(field))
}
