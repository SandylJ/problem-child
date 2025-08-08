import Foundation
import SwiftData
import SwiftUI

// MARK: - Backup Data Structure
struct BackupData: Codable {
    let version: String
    let timestamp: Date
    let player: PlayerData?
    let skills: [SkillData]
    let resources: [ResourceData]
    let taskRecords: [TaskRecordData]
    let buildings: [BuildingData]
    let expeditions: [PlayerExpeditionData]
    let reports: [PlayerExpeditionReportData]
    
    struct PlayerData: Codable {
        let id: String
        let name: String
        let level: Int
        let essence: Int
        let gold: Int
    }
    
    struct SkillData: Codable {
        let id: String
        let name: String
        let level: Int
        let xp: Int
    }
    
    struct ResourceData: Codable {
        let id: String
        let kind: String
        let quantity: Int
    }
    
    struct TaskRecordData: Codable {
        let id: String
        let date: Date
        let skillRef: String
        let amountXP: Int
        let difficulty: String
    }
    
    struct BuildingData: Codable {
        let id: String
        let type: String
        let level: Int
        let lastProductionTime: Date?
    }
    
    struct PlayerExpeditionData: Codable {
        let id: String
        let type: String
        let startTime: Date
        let endTime: Date
        let isActive: Bool
        let isCompleted: Bool
    }
    
    struct PlayerExpeditionReportData: Codable {
        let id: String
        let expeditionId: String
        let expeditionType: String
        let completionDate: Date
        let rewards: String
    }
}

// MARK: - Game State Manager
@MainActor
class GameStateManager: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Export Backup
    func exportBackup() async throws -> Data {
        let backupData = try await createBackupData()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        return try encoder.encode(backupData)
    }
    
    private func createBackupData() async throws -> BackupData {
        // Fetch all data from SwiftData
        let playerDescriptor = FetchDescriptor<Player>()
        let skillsDescriptor = FetchDescriptor<Skill>()
        let resourcesDescriptor = FetchDescriptor<Resource>()
        let taskRecordsDescriptor = FetchDescriptor<TaskRecord>()
        let buildingsDescriptor = FetchDescriptor<Building>()
        let expeditionsDescriptor = FetchDescriptor<PlayerExpedition>()
        let reportsDescriptor = FetchDescriptor<PlayerExpeditionReport>()
        
        let players = try modelContext.fetch(playerDescriptor)
        let skills = try modelContext.fetch(skillsDescriptor)
        let resources = try modelContext.fetch(resourcesDescriptor)
        let taskRecords = try modelContext.fetch(taskRecordsDescriptor)
        let buildings = try modelContext.fetch(buildingsDescriptor)
        let expeditions = try modelContext.fetch(expeditionsDescriptor)
        let reports = try modelContext.fetch(reportsDescriptor)
        
        // Convert to backup format
        let playerData = players.first.map { player in
            BackupData.PlayerData(
                id: player.id.uuidString,
                name: player.name,
                level: player.level,
                essence: player.essence,
                gold: player.gold
            )
        }
        
        let skillsData = skills.map { skill in
            BackupData.SkillData(
                id: skill.id.uuidString,
                name: skill.name,
                level: skill.level,
                xp: skill.xp
            )
        }
        
        let resourcesData = resources.map { resource in
            BackupData.ResourceData(
                id: resource.id.uuidString,
                kind: resource.kind,
                quantity: resource.quantity
            )
        }
        
        let taskRecordsData = taskRecords.map { record in
            BackupData.TaskRecordData(
                id: record.id.uuidString,
                date: record.date,
                skillRef: record.skillRef?.name ?? "Unknown",
                amountXP: record.amountXP,
                difficulty: record.difficulty
            )
        }
        
        let buildingsData = buildings.map { building in
            BackupData.BuildingData(
                id: building.id.uuidString,
                type: building.type,
                level: building.level,
                lastProductionTime: building.lastProductionTime
            )
        }
        
        let expeditionsData = expeditions.map { expedition in
            BackupData.PlayerExpeditionData(
                id: expedition.id.uuidString,
                type: expedition.type,
                startTime: expedition.startTime ?? Date(),
                endTime: expedition.endTime ?? Date(),
                isActive: expedition.isActive,
                isCompleted: expedition.isCompleted
            )
        }
        
        let reportsData = reports.map { report in
            BackupData.PlayerExpeditionReportData(
                id: report.id.uuidString,
                expeditionId: report.expeditionId.uuidString,
                expeditionType: report.expeditionType,
                completionDate: report.completionDate,
                rewards: report.rewards.description
            )
        }
        
        return BackupData(
            version: "1.0",
            timestamp: Date(),
            player: playerData,
            skills: skillsData,
            resources: resourcesData,
            taskRecords: taskRecordsData,
            buildings: buildingsData,
            expeditions: expeditionsData,
            reports: reportsData
        )
    }
    
    // MARK: - Import Backup
    func importBackup(_ data: Data) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backupData = try decoder.decode(BackupData.self, from: data)
        
        // Validate backup version
        guard backupData.version == "1.0" else {
            throw GameStateError.incompatibleVersion(backupData.version)
        }
        
        // Clear existing data
        try await clearAllData()
        
        // Import new data
        try await importBackupData(backupData)
        
        // Save changes
        try modelContext.save()
    }
    
    private func importBackupData(_ backupData: BackupData) async throws {
        // Import player
        if let playerData = backupData.player {
            let player = Player(name: playerData.name)
            player.id = UUID(uuidString: playerData.id) ?? UUID()
            player.level = playerData.level
            player.essence = playerData.essence
            player.gold = playerData.gold
            modelContext.insert(player)
        }
        
        // Import skills
        for skillData in backupData.skills {
            let skill = Skill(name: SkillName(rawValue: skillData.name) ?? .strength)
            skill.id = UUID(uuidString: skillData.id) ?? UUID()
            skill.level = skillData.level
            skill.xp = skillData.xp
            modelContext.insert(skill)
        }
        
        // Import resources
        for resourceData in backupData.resources {
            let resource = Resource(kind: ResourceKind(rawValue: resourceData.kind) ?? .rations, quantity: resourceData.quantity)
            resource.id = UUID(uuidString: resourceData.id) ?? UUID()
            modelContext.insert(resource)
        }
        
        // Import task records
        for recordData in backupData.taskRecords {
            let skill = Skill(name: SkillName(rawValue: recordData.skillRef) ?? .strength)
            let record = TaskRecord(
                skill: skill,
                amountXP: recordData.amountXP,
                difficulty: recordData.difficulty
            )
            record.id = UUID(uuidString: recordData.id) ?? UUID()
            record.date = recordData.date
            modelContext.insert(record)
        }
        
        // Import buildings
        for buildingData in backupData.buildings {
            let building = Building(type: BuildingType(rawValue: buildingData.type) ?? .farm)
            building.id = UUID(uuidString: buildingData.id) ?? UUID()
            building.level = buildingData.level
            building.lastProductionTime = buildingData.lastProductionTime ?? Date()
            modelContext.insert(building)
        }
        
        // Import expeditions
        for expeditionData in backupData.expeditions {
            let expedition = PlayerExpedition(type: ExpeditionType(rawValue: expeditionData.type) ?? .forestScout)
            expedition.id = UUID(uuidString: expeditionData.id) ?? UUID()
            expedition.startTime = expeditionData.startTime
            expedition.endTime = expeditionData.endTime
            expedition.isActive = expeditionData.isActive
            expedition.isCompleted = expeditionData.isCompleted
            modelContext.insert(expedition)
        }
        
        // Import reports
        for reportData in backupData.reports {
            // Create a dummy expedition for the report
            let dummyExpedition = PlayerExpedition(type: ExpeditionType(rawValue: reportData.expeditionType) ?? .forestScout)
            dummyExpedition.id = UUID(uuidString: reportData.expeditionId) ?? UUID()
            
            // Parse rewards from string (simplified)
            let rewards: [ResourceKind: Int] = [.rations: 5] // Default fallback
            
            let report = PlayerExpeditionReport(expedition: dummyExpedition, rewards: rewards)
            report.id = UUID(uuidString: reportData.id) ?? UUID()
            report.completionDate = reportData.completionDate
            modelContext.insert(report)
        }
    }
    
    // MARK: - Clear Data
    func clearAllData() async throws {
        let playerDescriptor = FetchDescriptor<Player>()
        let skillsDescriptor = FetchDescriptor<Skill>()
        let resourcesDescriptor = FetchDescriptor<Resource>()
        let taskRecordsDescriptor = FetchDescriptor<TaskRecord>()
        let buildingsDescriptor = FetchDescriptor<Building>()
        let expeditionsDescriptor = FetchDescriptor<PlayerExpedition>()
        let reportsDescriptor = FetchDescriptor<PlayerExpeditionReport>()
        
        let players = try modelContext.fetch(playerDescriptor)
        let skills = try modelContext.fetch(skillsDescriptor)
        let resources = try modelContext.fetch(resourcesDescriptor)
        let taskRecords = try modelContext.fetch(taskRecordsDescriptor)
        let buildings = try modelContext.fetch(buildingsDescriptor)
        let expeditions = try modelContext.fetch(expeditionsDescriptor)
        let reports = try modelContext.fetch(reportsDescriptor)
        
        for player in players { modelContext.delete(player) }
        for skill in skills { modelContext.delete(skill) }
        for resource in resources { modelContext.delete(resource) }
        for record in taskRecords { modelContext.delete(record) }
        for building in buildings { modelContext.delete(building) }
        for expedition in expeditions { modelContext.delete(expedition) }
        for report in reports { modelContext.delete(report) }
        
        try modelContext.save()
    }
    
    // MARK: - Validation
    func validateDataIntegrity() async throws -> Bool {
        // Check that all required data exists
        let playerDescriptor = FetchDescriptor<Player>()
        let skillsDescriptor = FetchDescriptor<Skill>()
        let resourcesDescriptor = FetchDescriptor<Resource>()
        
        let players = try modelContext.fetch(playerDescriptor)
        let skills = try modelContext.fetch(skillsDescriptor)
        let resources = try modelContext.fetch(resourcesDescriptor)
        
        // Basic validation
        guard !players.isEmpty else { return false }
        guard !skills.isEmpty else { return false }
        guard !resources.isEmpty else { return false }
        
        // Check for valid skill names
        for skill in skills {
            guard SkillName(rawValue: skill.name) != nil else { return false }
        }
        
        // Check for valid resource kinds
        for resource in resources {
            guard ResourceKind(rawValue: resource.kind) != nil else { return false }
        }
        
        return true
    }
    
    func getBackupInfo(_ data: Data) async throws -> (version: String, timestamp: Date, recordCount: Int) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backupData = try decoder.decode(BackupData.self, from: data)
        let totalRecords = backupData.skills.count + backupData.resources.count + backupData.taskRecords.count + backupData.buildings.count + backupData.expeditions.count + backupData.reports.count + (backupData.player != nil ? 1 : 0)
        
        return (backupData.version, backupData.timestamp, totalRecords)
    }
}

// MARK: - Errors
enum GameStateError: LocalizedError {
    case incompatibleVersion(String)
    case invalidData
    case importFailed
    
    var errorDescription: String? {
        switch self {
        case .incompatibleVersion(let version):
            return "Backup version \(version) is not compatible with current app version"
        case .invalidData:
            return "Backup data is invalid or corrupted"
        case .importFailed:
            return "Failed to import backup data"
        }
    }
}
