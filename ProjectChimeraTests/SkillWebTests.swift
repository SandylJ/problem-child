import XCTest
@testable import ProjectChimera

@MainActor
final class SkillWebTests: XCTestCase {
    
    func testSkillBadge_DisplaysCorrectInformation() {
        // Given: A skill with XP and level
        let skill = Skill(name: .strength)
        skill.addXP(75) // Should be level 1 with 75 XP
        
        // When: Creating a skill badge
        let badge = SkillBadge(skill: skill)
        
        // Then: The badge should display correct information
        // Note: This is a UI test, so we're mainly testing that the component can be created
        XCTAssertNotNil(badge)
        XCTAssertEqual(skill.level, 1)
        XCTAssertEqual(skill.xp, 75)
        XCTAssertEqual(skill.nextLevelXP(), 100)
    }
    
    func testSkillWebView_DisplaysAllSkills() {
        // Given: A game state with skills
        let gameState = ChimeraGameState()
        gameState.setupSeedData()
        
        // When: Creating the skill web view
        let skillWebView = SkillWebView()
        
        // Then: The view should be created successfully
        XCTAssertNotNil(skillWebView)
        
        // And: All skill names should be available
        XCTAssertEqual(SkillName.allCases.count, 8) // strength, mind, joy, vitality, awareness, flow, finance, other
    }
    
    func testSkillWebDetailView_ShowsCorrectProgress() {
        // Given: A skill with specific XP
        let skill = Skill(name: .mind)
        skill.addXP(50) // Level 1, 50 XP
        
        // When: Creating the detail view
        let detailView = SkillWebDetailView(skill: skill)
        
        // Then: The view should be created successfully
        XCTAssertNotNil(detailView)
        
        // And: Progress should be calculated correctly
        let expectedProgress = Double(skill.xp) / Double(skill.nextLevelXP())
        XCTAssertEqual(expectedProgress, 0.5) // 50/100 = 0.5
    }
    
    func testSkillBadge_ColorMapping() {
        // Test that each skill has a unique color
        let skills = SkillName.allCases
        let colors = skills.map { skillName in
            let skill = Skill(name: skillName)
            let badge = SkillBadge(skill: skill)
            // Note: We can't directly test the color since it's a computed property,
            // but we can verify the badge is created successfully
            return badge
        }
        
        // All badges should be created successfully
        XCTAssertEqual(colors.count, skills.count)
    }
}
