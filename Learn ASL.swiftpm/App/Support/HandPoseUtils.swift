import Foundation
import CoreML
import CreateML
import Combine

extension HandPoseMLModel {
    static func loadMLModel(from url: URL, as name: String) async throws -> HandPoseMLModel? {
        let compiledModelURL = try await MLModel.compileModel(at: url)
        let model = try MLModel(contentsOf: compiledModelURL)
        return HandPoseMLModel(name: name, mlModel: model, url: url)
    }
    
    static func getDefaultMLModel() async -> HandPoseMLModel? {
        guard let rpsModel = URL.defaultMLModel else { return nil }
        do {
            return try await HandPoseMLModel.loadMLModel(from: rpsModel, as: AppModel.defaultMLModelName)
        } catch {
            print("Could not load default ML model: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func findExistingModels(exclude existingModelURLs: [URL] = []) async -> [HandPoseMLModel] {
        guard let modelDirectory = URL.modelDirectory, modelDirectory.directoryExists else { return [] }
        var models: [HandPoseMLModel] = []
        do {
            let modelURLs = modelDirectory.directoryContentsOrderedByDate
            for url in modelURLs {
                guard !existingModelURLs.contains(url) else { continue }
                guard let model = try await getMLModel(from: url) else { continue }
                models.append(model)
            }
        } catch {
            print("Error finding existing models \(error.localizedDescription)")
        }
        
        return models
    }
    
    static func getLastTrainedModel() async -> HandPoseMLModel? {
        return await HandPoseMLModel.findExistingModels().first
    }
    
    private static func getMLModel(from url: URL) async throws -> HandPoseMLModel? {
        let name = url.lastPathComponent
        guard let handposeMLModel = try await HandPoseMLModel.loadMLModel(from: url, as: name) else { return nil }
        return handposeMLModel
    }
}

extension HandPoseInput: MLFeatureProvider {
    var featureNames: Set<String> {
        get {
            return ["poses"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "poses" {
            return MLFeatureValue(multiArray: poses)
        }
        return nil
    }
    
}

extension HandPoseOutput: MLFeatureProvider {
    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }
}

extension HandPoseOutput {
    func getOutputProbabilities() -> [String : Double] {
        return self.provider.featureValue(for: "labelProbabilities")?.dictionaryValue as? [String : Double] ?? [:]
    }
    
    func getOutputLabel() -> String {
        return self.provider.featureValue(for: "label")?.stringValue ?? ""
    }
}

extension HandPoseMLModel: @unchecked Sendable {}
extension HandPoseOutput: @unchecked Sendable {}
