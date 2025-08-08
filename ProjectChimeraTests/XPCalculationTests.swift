import XCTest
@testable import ProjectChimera

final class XPCalculationTests: XCTestCase {
    
    // MARK: - XP Calculation Tests
    
    func testXpFor_TrivialDifficulty() {
        // Given: A task with trivial difficulty
        let task = Task(
            title: "Test Task",
            difficulty: .trivial,
            associatedStat: .discipline
        )
        
        // When: Calculate XP
        let xp = xpFor(task: task)
        
        // Then: Should return correct XP
        XCTAssertEqual(xp, 10)
    }
    
    func testXpFor_EasyDifficulty() {
        // Given: A task with easy difficulty
        let task = Task(
            title: "Test Task",
            difficulty: .easy,
            associatedStat: .mindfulness
        )
        
        // When: Calculate XP
        let xp = xpFor(task: task)
        
        // Then: Should return correct XP
        XCTAssertEqual(xp, 20)
    }
    
    func testXpFor_MediumDifficulty() {
        // Given: A task with medium difficulty
        let task = Task(
            title: "Test Task",
            difficulty: .medium,
            associatedStat: .intellect
        )
        
        // When: Calculate XP
        let xp = xpFor(task: task)
        
        // Then: Should return correct XP
        XCTAssertEqual(xp, 35)
    }
    
    func testXpFor_HardDifficulty() {
        // Given: A task with hard difficulty
        let task = Task(
            title: "Test Task",
            difficulty: .hard,
            associatedStat: .creativity
        )
        
        // When: Calculate XP
        let xp = xpFor(task: task)
        
        // Then: Should return correct XP
        XCTAssertEqual(xp, 60)
    }
    
    func testXpFor_EpicDifficulty() {
        // Given: A task with epic difficulty
        let task = Task(
            title: "Test Task",
            difficulty: .epic,
            associatedStat: .resilience
        )
        
        // When: Calculate XP
        let xp = xpFor(task: task)
        
        // Then: Should return correct XP
        XCTAssertEqual(xp, 100)
    }
    
    // MARK: - Skill Mapping Tests
    
    func testSkillFromTaskType_Discipline() {
        // When: Map discipline stat
        let skill = skillFromTaskType(.discipline)
        
        // Then: Should map to strength
        XCTAssertEqual(skill, .strength)
    }
    
    func testSkillFromTaskType_Mindfulness() {
        // When: Map mindfulness stat
        let skill = skillFromTaskType(.mindfulness)
        
        // Then: Should map to mind
        XCTAssertEqual(skill, .mind)
    }
    
    func testSkillFromTaskType_Intellect() {
        // When: Map intellect stat
        let skill = skillFromTaskType(.intellect)
        
        // Then: Should map to awareness
        XCTAssertEqual(skill, .awareness)
    }
    
    func testSkillFromTaskType_Creativity() {
        // When: Map creativity stat
        let skill = skillFromTaskType(.creativity)
        
        // Then: Should map to joy
        XCTAssertEqual(skill, .joy)
    }
    
    func testSkillFromTaskType_Resilience() {
        // When: Map resilience stat
        let skill = skillFromTaskType(.resilience)
        
        // Then: Should map to vitality
        XCTAssertEqual(skill, .vitality)
    }
}

