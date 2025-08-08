import XCTest
import SwiftData
@testable import ProjectChimera

final class ModelTests: XCTestCase {
    
    // MARK: - Player Tests
    
    func testPlayer_Initialization() {
        // When: Create a player
        let player = Player(name: "Test Player")
        
        // Then: Should have correct initial values
        XCTAssertEqual(player.name, "Test Player")
        XCTAssertEqual(player.level, 1)
        XCTAssertEqual(player.essence, 0)
        XCTAssertEqual(player.gold, 100)
        XCTAssertNotNil(player.id)
    }
    
    func testPlayer_DefaultInitialization() {
        // When: Create a player with default initializer
        let player = Player()
        
        // Then: Should have default name
        XCTAssertEqual(player.name, "Player")
        XCTAssertEqual(player.level, 1)
        XCTAssertEqual(player.essence, 0)
        XCTAssertEqual(player.gold, 100)
    }
    
    // MARK: - Skill Tests
    
    func testSkill_Initialization() {
        // When: Create a skill
        let skill = Skill(name: .mind)
        
        // Then: Should have correct initial values
        XCTAssertEqual(skill.skillName, .mind)
        XCTAssertEqual(skill.level, 1)
        XCTAssertEqual(skill.xp, 0)
        XCTAssertNotNil(skill.id)
    }
    
    func testSkill_NextLevelXP() {
        // Given: A skill at level 1
        let skill = Skill(name: .joy)
        
        // When: Get next level XP
        let nextLevelXP = skill.nextLevelXP()
        
        // Then: Should return correct XP requirement
        XCTAssertEqual(nextLevelXP, 100) // level 1 * 100
    }
    
    func testSkill_AddXP_NoLevelUp() {
        // Given: A skill at level 1
        let skill = Skill(name: .strength)
        
        // When: Add XP but not enough for level up
        skill.addXP(50)
        
        // Then: Should add XP but not level up
        XCTAssertEqual(skill.xp, 50)
        XCTAssertEqual(skill.level, 1)
    }
    
    func testSkill_AddXP_LevelUp() {
        // Given: A skill at level 1
        let skill = Skill(name: .vitality)
        
        // When: Add enough XP for level up
        skill.addXP(120)
        
        // Then: Should level up and have remaining XP
        XCTAssertEqual(skill.level, 2)
        XCTAssertEqual(skill.xp, 20) // 120 - 100 = 20
    }
    
    func testSkill_AddXP_MultipleLevelUps() {
        // Given: A skill at level 1
        let skill = Skill(name: .awareness)
        
        // When: Add enough XP for multiple level ups
        skill.addXP(350) // Should level up to level 3 (100 + 200 + 50 remaining)
        
        // Then: Should level up multiple times
        XCTAssertEqual(skill.level, 3)
        XCTAssertEqual(skill.xp, 50) // 350 - 100 - 200 = 50
    }
    
    func testSkill_SkillNameProperty() {
        // Given: A skill
        let skill = Skill(name: .flow)
        
        // When: Change skill name via property
        skill.skillName = .finance
        
        // Then: Should update correctly
        XCTAssertEqual(skill.skillName, .finance)
        XCTAssertEqual(skill.name, "Finance")
    }
    
    // MARK: - TaskRecord Tests
    
    func testTaskRecord_Initialization() {
        // Given: A skill
        let skill = Skill(name: .mind)
        
        // When: Create a task record
        let taskRecord = TaskRecord(skill: skill, amountXP: 75, difficulty: "Medium")
        
        // Then: Should have correct values
        XCTAssertEqual(taskRecord.skillRef?.id, skill.id)
        XCTAssertEqual(taskRecord.amountXP, 75)
        XCTAssertEqual(taskRecord.difficulty, "Medium")
        XCTAssertNotNil(taskRecord.id)
        XCTAssertNotNil(taskRecord.date)
    }
    
    func testTaskRecord_DefaultInitialization() {
        // When: Create a task record with default initializer
        let taskRecord = TaskRecord()
        
        // Then: Should have default values
        XCTAssertNotNil(taskRecord.skillRef)
        XCTAssertEqual(taskRecord.amountXP, 10)
        XCTAssertEqual(taskRecord.difficulty, "Easy")
    }
    
    // MARK: - Resource Tests
    
    func testResource_Initialization() {
        // When: Create a resource
        let resource = Resource(kind: .tools, quantity: 5)
        
        // Then: Should have correct values
        XCTAssertEqual(resource.resourceKind, .tools)
        XCTAssertEqual(resource.quantity, 5)
        XCTAssertNotNil(resource.id)
    }
    
    func testResource_DefaultInitialization() {
        // When: Create a resource with default initializer
        let resource = Resource()
        
        // Then: Should have default values
        XCTAssertEqual(resource.resourceKind, .rations)
        XCTAssertEqual(resource.quantity, 0)
    }
    
    func testResource_Add() {
        // Given: A resource with initial quantity
        let resource = Resource(kind: .intel, quantity: 10)
        
        // When: Add quantity
        resource.add(5)
        
        // Then: Should add correctly
        XCTAssertEqual(resource.quantity, 15)
    }
    
    func testResource_Add_NegativeAmount() {
        // Given: A resource with initial quantity
        let resource = Resource(kind: .materials, quantity: 10)
        
        // When: Add negative amount
        resource.add(-3)
        
        // Then: Should subtract correctly
        XCTAssertEqual(resource.quantity, 7)
    }
    
    func testResource_Add_NegativeAmountBelowZero() {
        // Given: A resource with initial quantity
        let resource = Resource(kind: .currency, quantity: 5)
        
        // When: Add negative amount that would go below 0
        resource.add(-10)
        
        // Then: Should clamp to 0
        XCTAssertEqual(resource.quantity, 0)
    }
    
    func testResource_Remove_Success() {
        // Given: A resource with sufficient quantity
        let resource = Resource(kind: .rations, quantity: 10)
        
        // When: Remove quantity
        let success = resource.remove(3)
        
        // Then: Should remove successfully
        XCTAssertTrue(success)
        XCTAssertEqual(resource.quantity, 7)
    }
    
    func testResource_Remove_InsufficientQuantity() {
        // Given: A resource with insufficient quantity
        let resource = Resource(kind: .tools, quantity: 2)
        
        // When: Try to remove more than available
        let success = resource.remove(5)
        
        // Then: Should fail and not change quantity
        XCTAssertFalse(success)
        XCTAssertEqual(resource.quantity, 2)
    }
    
    func testResource_ResourceKindProperty() {
        // Given: A resource
        let resource = Resource(kind: .essence, quantity: 0)
        
        // When: Change resource kind via property
        resource.resourceKind = .currency
        
        // Then: Should update correctly
        XCTAssertEqual(resource.resourceKind, .currency)
        XCTAssertEqual(resource.kind, "Currency")
    }
    
    // MARK: - Enum Tests
    
    func testSkillName_AllCases() {
        // Then: Should have all expected cases
        XCTAssertEqual(SkillName.allCases.count, 8)
        XCTAssertTrue(SkillName.allCases.contains(.strength))
        XCTAssertTrue(SkillName.allCases.contains(.mind))
        XCTAssertTrue(SkillName.allCases.contains(.joy))
        XCTAssertTrue(SkillName.allCases.contains(.vitality))
        XCTAssertTrue(SkillName.allCases.contains(.awareness))
        XCTAssertTrue(SkillName.allCases.contains(.flow))
        XCTAssertTrue(SkillName.allCases.contains(.finance))
        XCTAssertTrue(SkillName.allCases.contains(.other))
    }
    

    
    func testResourceKind_AllCases() {
        // Then: Should have all expected cases
        XCTAssertEqual(ResourceKind.allCases.count, 6)
        XCTAssertTrue(ResourceKind.allCases.contains(.rations))
        XCTAssertTrue(ResourceKind.allCases.contains(.tools))
        XCTAssertTrue(ResourceKind.allCases.contains(.intel))
        XCTAssertTrue(ResourceKind.allCases.contains(.materials))
        XCTAssertTrue(ResourceKind.allCases.contains(.currency))
        XCTAssertTrue(ResourceKind.allCases.contains(.essence))
    }
}
