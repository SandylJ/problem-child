import XCTest
import SwiftData
@testable import ProjectChimera

@MainActor
final class GameStateTests: XCTestCase {
    var gameState: ChimeraGameState!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create an in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Player.self, Skill.self, TaskRecord.self, Resource.self, configurations: config)
        modelContext = ModelContext(container)
        
        gameState = ChimeraGameState()
        gameState.resetForTesting()
    }
    
    override func tearDownWithError() throws {
        gameState = nil
        modelContext = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Award XP Tests
    
    func testAwardXP_CreatesSkillIfNotExists() {
        // Given: A fresh game state
        XCTAssertEqual(gameState.skills.count, 0)
        
        // When: Award XP to a skill that doesn't exist
        gameState.awardXP(skill: .strength, amount: 50)
        
        // Then: Skill should be created and XP awarded
        XCTAssertEqual(gameState.skills.count, 1)
        let skill = gameState.skills.first
        XCTAssertEqual(skill?.skillName, .strength)
        XCTAssertEqual(skill?.xp, 50)
        XCTAssertEqual(skill?.level, 1)
    }
    
    func testAwardXP_AddsToExistingSkill() {
        // Given: A skill with existing XP
        let skill = Skill(name: .mind)
        skill.addXP(30)
        gameState.skills.append(skill)
        
        // When: Award more XP
        gameState.awardXP(skill: .mind, amount: 70)
        
        // Then: XP should be added correctly
        let updatedSkill = gameState.getSkill(by: .mind)
        XCTAssertEqual(updatedSkill?.xp, 100)
        XCTAssertEqual(updatedSkill?.level, 1) // Still level 1 since 100 XP needed for level 2
    }
    
    func testAwardXP_LevelsUpSkill() {
        // Given: A skill with 80 XP (level 1)
        let skill = Skill(name: .joy)
        skill.addXP(80)
        gameState.skills.append(skill)
        
        // When: Award 30 more XP (total 110, should level up)
        gameState.awardXP(skill: .joy, amount: 30)
        
        // Then: Skill should level up
        let updatedSkill = gameState.getSkill(by: .joy)
        XCTAssertEqual(updatedSkill?.level, 2)
        XCTAssertEqual(updatedSkill?.xp, 10) // 110 - 100 = 10 remaining
    }
    
    func testAwardXP_CreatesTaskRecord() {
        // Given: A fresh game state
        XCTAssertEqual(gameState.taskRecords.count, 0)
        
        // When: Award XP
        gameState.awardXP(skill: .vitality, amount: 25)
        
        // Then: Task record should be created
        XCTAssertEqual(gameState.taskRecords.count, 1)
        let taskRecord = gameState.taskRecords.first
        XCTAssertEqual(taskRecord?.amountXP, 25)
        XCTAssertEqual(taskRecord?.skillRef?.skillName, .vitality)
        XCTAssertEqual(taskRecord?.difficulty, "Easy")
        
        // Also verify the skill was created
        let skill = gameState.getSkill(by: .vitality)
        XCTAssertNotNil(skill)
        XCTAssertEqual(skill?.xp, 25)
    }
    
    // MARK: - Add Resource Tests
    
    func testAddResource_CreatesResourceIfNotExists() {
        // Given: A fresh game state
        XCTAssertEqual(gameState.resources.count, 0)
        
        // When: Add a resource that doesn't exist
        gameState.addResource(kind: .rations, amount: 5)
        
        // Then: Resource should be created
        XCTAssertEqual(gameState.resources.count, 1)
        let resource = gameState.resources.first
        XCTAssertEqual(resource?.resourceKind, .rations)
        XCTAssertEqual(resource?.quantity, 5)
    }
    
    func testAddResource_AddsToExistingResource() {
        // Given: An existing resource
        let resource = Resource(kind: .tools, quantity: 3)
        gameState.resources.append(resource)
        
        // When: Add more of the same resource
        gameState.addResource(kind: .tools, amount: 7)
        
        // Then: Quantity should be added
        XCTAssertEqual(resource.quantity, 10)
    }
    
    func testAddResource_HandlesNegativeAmount() {
        // Given: A resource with 10 quantity
        let resource = Resource(kind: .intel, quantity: 10)
        gameState.resources.append(resource)
        
        // When: Add negative amount
        gameState.addResource(kind: .intel, amount: -3)
        
        // Then: Quantity should be reduced but not below 0
        XCTAssertEqual(resource.quantity, 7)
    }
    
    func testAddResource_HandlesNegativeAmountBelowZero() {
        // Given: A resource with 2 quantity
        let resource = Resource(kind: .materials, quantity: 2)
        gameState.resources.append(resource)
        
        // When: Add negative amount that would go below 0
        gameState.addResource(kind: .materials, amount: -5)
        
        // Then: Quantity should be clamped to 0
        XCTAssertEqual(resource.quantity, 0)
    }
    
    // MARK: - Utility Function Tests
    
    func testGetSkill_ReturnsCorrectSkill() {
        // Given: A skill in the game state
        let skill = Skill(name: .awareness)
        gameState.skills.append(skill)
        
        // When: Get skill by name
        let foundSkill = gameState.getSkill(by: .awareness)
        
        // Then: Should return the correct skill
        XCTAssertEqual(foundSkill?.id, skill.id)
    }
    
    func testGetSkill_ReturnsNilForNonExistentSkill() {
        // Given: No skills in game state
        gameState.skills = []
        
        // When: Get non-existent skill
        let foundSkill = gameState.getSkill(by: .flow)
        
        // Then: Should return nil
        XCTAssertNil(foundSkill)
    }
    
    func testGetResource_ReturnsCorrectResource() {
        // Given: A resource in the game state
        let resource = Resource(kind: .currency, quantity: 100)
        gameState.resources.append(resource)
        
        // When: Get resource by kind
        let foundResource = gameState.getResource(by: .currency)
        
        // Then: Should return the correct resource
        XCTAssertEqual(foundResource?.id, resource.id)
    }
    
    func testGetTotalXP_ReturnsCorrectTotal() {
        // Given: Multiple skills with XP
        let skill1 = Skill(name: .strength)
        skill1.addXP(50)
        let skill2 = Skill(name: .mind)
        skill2.addXP(75)
        gameState.skills = [skill1, skill2]
        
        // When: Get total XP
        let totalXP = gameState.getTotalXP()
        
        // Then: Should return sum of all XP
        XCTAssertEqual(totalXP, 125)
    }
    
    func testGetTotalLevel_ReturnsCorrectTotal() {
        // Given: Multiple skills with different levels
        let skill1 = Skill(name: .strength)
        skill1.addXP(150) // Level 2
        let skill2 = Skill(name: .mind)
        skill2.addXP(50) // Level 1
        gameState.skills = [skill1, skill2]
        
        // When: Get total level
        let totalLevel = gameState.getTotalLevel()
        
        // Then: Should return sum of all levels
        XCTAssertEqual(totalLevel, 3)
    }
    
    // MARK: - Seed Data Tests
    
    func testSeedData_CreatesDefaultPlayer() {
        // Given: A fresh game state with seed data
        let freshGameState = ChimeraGameState()
        
        // Then: Should have a default player
        XCTAssertNotNil(freshGameState.player)
        XCTAssertEqual(freshGameState.player?.name, "Chimera Player")
        XCTAssertEqual(freshGameState.player?.level, 1)
        XCTAssertEqual(freshGameState.player?.gold, 100)
    }
    
    func testSeedData_CreatesDefaultSkills() {
        // Given: A fresh game state with seed data
        let freshGameState = ChimeraGameState()
        
        // Then: Should have all default skills
        XCTAssertEqual(freshGameState.skills.count, SkillName.allCases.count)
        
        for skillName in SkillName.allCases {
            let skill = freshGameState.skills.first { $0.skillName == skillName }
            XCTAssertNotNil(skill)
            XCTAssertEqual(skill?.level, 1)
            XCTAssertEqual(skill?.xp, 0)
        }
    }
    
    func testSeedData_CreatesDefaultResources() {
        // Given: A fresh game state with seed data
        let freshGameState = ChimeraGameState()
        
        // Then: Should have default resources
        XCTAssertEqual(freshGameState.resources.count, 6) // 6 default resource types
        
        let rations = freshGameState.getResource(by: .rations)
        XCTAssertNotNil(rations)
        XCTAssertEqual(rations?.quantity, 10)
        
        let tools = freshGameState.getResource(by: .tools)
        XCTAssertNotNil(tools)
        XCTAssertEqual(tools?.quantity, 5)
        
        let currency = freshGameState.getResource(by: .currency)
        XCTAssertNotNil(currency)
        XCTAssertEqual(currency?.quantity, 100)
    }
}
