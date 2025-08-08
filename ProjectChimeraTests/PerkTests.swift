import XCTest
@testable import ProjectChimera

@MainActor
final class PerkTests: XCTestCase {
    
    var gameState: ChimeraGameState!
    var perkManager: PerkManager!
    
    override func setUpWithError() throws {
        gameState = ChimeraGameState()
        gameState.resetForTesting()
        perkManager = PerkManager(gameState: gameState)
    }
    
    override func tearDownWithError() throws {
        gameState = nil
        perkManager = nil
    }
    
    // MARK: - Perk Creation Tests
    
    func testPerk_Initialization() {
        // Given: A perk is created
        let perk = Perk(type: .expeditionSuccessRate, value: 0.05)
        
        // Then: It should have correct initial values
        XCTAssertEqual(perk.perkType, .expeditionSuccessRate)
        XCTAssertEqual(perk.value, 0.05)
        XCTAssertFalse(perk.isActive)
        XCTAssertNil(perk.unlockedAt)
    }
    
    func testPerk_Activation() {
        // Given: A perk
        let perk = Perk(type: .studyProduction, value: 0.10)
        
        // When: Perk is activated
        perk.activate()
        
        // Then: Perk should be active and have unlock time
        XCTAssertTrue(perk.isActive)
        XCTAssertNotNil(perk.unlockedAt)
    }
    
    // MARK: - Perk Manager Tests
    
    func testPerkManager_StrengthLevel5_UnlocksExpeditionSuccessRate() {
        // Given: A strength skill at level 4
        let skill = Skill(name: .strength)
        skill.level = 4
        skill.xp = 400 // Just below level 5 threshold
        
        // When: Skill levels up to 5
        skill.addXP(100) // Should reach level 5
        
        // Then: Perk should be unlocked
        perkManager.checkForNewPerks(skill: skill)
        XCTAssertEqual(perkManager.activePerks.count, 1)
        XCTAssertEqual(perkManager.activePerks.first?.perkType, .expeditionSuccessRate)
        XCTAssertEqual(perkManager.activePerks.first?.value, 0.05)
    }
    
    func testPerkManager_MindLevel5_UnlocksStudyProduction() {
        // Given: A mind skill at level 5
        let skill = Skill(name: .mind)
        skill.level = 5
        
        // When: Checking for perks
        perkManager.checkForNewPerks(skill: skill)
        
        // Then: Study production perk should be unlocked
        XCTAssertEqual(perkManager.activePerks.count, 1)
        XCTAssertEqual(perkManager.activePerks.first?.perkType, .studyProduction)
        XCTAssertEqual(perkManager.activePerks.first?.value, 0.10)
    }
    
    func testPerkManager_JoyLevel3_UnlocksDailyFocusSlots() {
        // Given: A joy skill at level 3
        let skill = Skill(name: .joy)
        skill.level = 3
        
        // When: Checking for perks
        perkManager.checkForNewPerks(skill: skill)
        
        // Then: Daily focus slots perk should be unlocked
        XCTAssertEqual(perkManager.activePerks.count, 1)
        XCTAssertEqual(perkManager.activePerks.first?.perkType, .dailyFocusSlots)
        XCTAssertEqual(perkManager.activePerks.first?.value, 1.0)
    }
    
    func testPerkManager_MultiplePerks_AccumulateCorrectly() {
        // Given: Multiple perks of the same type
        let perk1 = Perk(type: .expeditionSuccessRate, value: 0.05)
        let perk2 = Perk(type: .expeditionSuccessRate, value: 0.03)
        perkManager.activePerks = [perk1, perk2]
        
        // When: Getting expedition success rate bonus
        let bonus = perkManager.getExpeditionSuccessRateBonus()
        
        // Then: Bonuses should be added together
        XCTAssertEqual(bonus, 0.08) // 0.05 + 0.03
    }
    
    func testPerkManager_NoPerks_ReturnZeroBonus() {
        // Given: No active perks
        perkManager.activePerks = []
        
        // When: Getting various bonuses
        let expeditionBonus = perkManager.getExpeditionSuccessRateBonus()
        let studyBonus = perkManager.getStudyProductionBonus()
        let focusSlots = perkManager.getDailyFocusSlotsBonus()
        
        // Then: All bonuses should be zero
        XCTAssertEqual(expeditionBonus, 0.0)
        XCTAssertEqual(studyBonus, 0.0)
        XCTAssertEqual(focusSlots, 0)
    }
    
    func testPerkManager_DuplicatePerkCheck_DoesNotAddTwice() {
        // Given: A skill that would unlock a perk
        let skill = Skill(name: .strength)
        skill.level = 5
        
        // When: Checking for perks multiple times
        perkManager.checkForNewPerks(skill: skill)
        perkManager.checkForNewPerks(skill: skill)
        perkManager.checkForNewPerks(skill: skill)
        
        // Then: Only one perk should be added
        XCTAssertEqual(perkManager.activePerks.count, 1)
    }
    
    // MARK: - Perk Type Tests
    
    func testPerkType_AllCases_HaveValidProperties() {
        // Then: All perk types should have valid properties
        for perkType in PerkType.allCases {
            XCTAssertFalse(perkType.rawValue.isEmpty)
            XCTAssertFalse(perkType.description.isEmpty)
            XCTAssertFalse(perkType.icon.isEmpty)
        }
    }
    
    func testPerkType_Descriptions_AreInformative() {
        // Then: Perk descriptions should be informative
        XCTAssertTrue(PerkType.expeditionSuccessRate.description.contains("success rate"))
        XCTAssertTrue(PerkType.studyProduction.description.contains("production"))
        XCTAssertTrue(PerkType.dailyFocusSlots.description.contains("focus slots"))
        XCTAssertTrue(PerkType.resourceGathering.description.contains("resource"))
        XCTAssertTrue(PerkType.skillXpBonus.description.contains("XP"))
        XCTAssertTrue(PerkType.buildingEfficiency.description.contains("efficiency"))
        XCTAssertTrue(PerkType.homesteadCapacity.description.contains("capacity"))
    }
    
    // MARK: - Integration Tests
    
    func testGameState_AwardXP_TriggersPerkCheck() {
        // Given: A skill that will level up
        let skill = Skill(name: .strength)
        skill.level = 4
        skill.xp = 400
        gameState.skills.append(skill)
        
        // When: Awarding XP that will cause level up
        gameState.awardXP(skill: .strength, amount: 100)
        
        // Then: Perk should be unlocked
        XCTAssertEqual(gameState.perkManager.activePerks.count, 1)
        XCTAssertEqual(gameState.perkManager.activePerks.first?.perkType, .expeditionSuccessRate)
    }
    
    func testGameState_AwardXP_NoLevelUp_NoPerkUnlock() {
        // Given: A skill that won't level up
        let skill = Skill(name: .mind)
        skill.level = 5
        skill.xp = 100
        gameState.skills.append(skill)
        
        // When: Awarding small amount of XP
        gameState.awardXP(skill: .mind, amount: 10)
        
        // Then: No new perks should be unlocked
        XCTAssertEqual(gameState.perkManager.activePerks.count, 0)
    }
}

