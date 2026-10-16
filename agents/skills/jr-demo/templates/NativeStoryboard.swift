import CryptoKit
import XCTest

@MainActor final class NativeStoryboard {
  enum Failure: Error { case invalidBrief, invalidCaption, notVisible, alreadyFinished }
  private struct Panel: Encodable {
    let caption: String
    let attachment: String
    let sha256: String
    let focus: Double
  }
  private struct Receipt: Encodable {
    let version = 1
    let test: String
    let title: String
    let brief: String
    let panels: [Panel]
  }
  private let testCase: XCTestCase
  private let app: XCUIApplication
  private let title: String
  private let brief: String
  private let token = UUID().uuidString
  private var panels: [Panel] = []
  private var finished = false

  init(testCase: XCTestCase, app: XCUIApplication, title: String, brief: String) throws {
    guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      !brief.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Failure.invalidBrief }
    self.testCase = testCase
    self.app = app
    self.title = title
    self.brief = brief
  }

  func step(_ caption: String, _ element: XCUIElement, timeout: TimeInterval = 10) throws {
    guard !finished else { throw Failure.alreadyFinished }
    guard !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw Failure.invalidCaption }
    let visible = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: element)
    guard XCTWaiter.wait(for: [visible], timeout: timeout) == .completed, element.isHittable,
      !element.frame.isEmpty, !app.frame.isEmpty else { throw Failure.notVisible }
    let data = app.screenshot().pngRepresentation
    let name = "capture-\(token)-\(panels.count + 1)"
    let image = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
    image.name = name
    image.lifetime = .keepAlways
    testCase.add(image)
    panels.append(Panel(caption: caption, attachment: name,
      sha256: SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined(),
      focus: min(100, max(0, (element.frame.midY - app.frame.minY) / app.frame.height * 100))))
  }

  func finish() throws {
    guard !finished else { throw Failure.alreadyFinished }
    guard !panels.isEmpty else { throw Failure.invalidBrief }
    let parts = testCase.name.components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).inverted).filter { !$0.isEmpty }
    let test = parts.suffix(2).joined(separator: "/")
    let receipt = Receipt(test: test, title: title, brief: brief, panels: panels)
    let attachment = XCTAttachment(data: try JSONEncoder().encode(receipt), uniformTypeIdentifier: "public.json")
    attachment.name = "native-storyboard"
    attachment.lifetime = .keepAlways
    testCase.add(attachment)
    finished = true
  }
}
