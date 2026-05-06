import Foundation
import Testing
@testable import Networking

@Suite(.serialized)
struct TransferNetworkTests {
    @Test
    func dataNetwork_downloadFile_writesResponseDataToDestination() async throws {
        let originalHandler = DataNetwork.requestData
        defer { DataNetwork.requestData = originalHandler }

        let fileName = "data-network-\(UUID().uuidString).pdf"
        let destination = DownloadApi.destinationPath(fileName)
        try? FileManager.default.removeItem(at: destination)

        DataNetwork.requestData = { _, _, completion in
            completion(.success(Data("demo-pdf".utf8)))
        }

        let url = try await withCheckedThrowingContinuation { continuation in
            DataNetwork.downloadFile(from: .batchPrint(["1"], fileName), fileName: fileName) { result in
                continuation.resume(with: result)
            }
        }

        let written = try Data(contentsOf: url)
        #expect(url == destination)
        #expect(String(data: written, encoding: .utf8) == "demo-pdf")
        try? FileManager.default.removeItem(at: destination)
    }

    @Test
    func downloadNetwork_downloadFile_returnsCachedFileWithoutInvokingTransfer() async throws {
        let originalHandler = DownloadNetwork.downloadFileRequest
        defer { DownloadNetwork.downloadFileRequest = originalHandler }

        let fileName = "download-network-\(UUID().uuidString).txt"
        let destination = DownloadApi.destinationPath(fileName)
        try? FileManager.default.removeItem(at: destination)
        try Data("cached".utf8).write(to: destination)

        var invoked = false
        DownloadNetwork.downloadFileRequest = { _, _, _, _ in
            invoked = true
        }

        let url = try await withCheckedThrowingContinuation { continuation in
            DownloadNetwork.downloadFile(
                from: .file(URL(string: "https://example.com/file.txt")!, fileName),
                fileName: fileName
            ) { result in
                continuation.resume(with: result)
            }
        }

        #expect(url == destination)
        #expect(invoked == false)
        try? FileManager.default.removeItem(at: destination)
    }
}
