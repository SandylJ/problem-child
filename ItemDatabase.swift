import Foundation

/// Simple in-memory database of items, spells, recipes and templates used by
/// various game systems. The implementation is intentionally lightweight – it
/// only exposes the members referenced by the rest of the codebase so that the
/// project can compile without needing a full data set.
final class ItemDatabase {
    static let shared = ItemDatabase()
    private init() {}

    // MARK: - Items
    private var items: [String: Item] = [:]

    func getItem(id: String) -> Item? {
        items[id]
    }

    // MARK: - Spells
    var masterSpellList: [Spell] = [
        Spell(
            id: "spell_double_xp",
            name: "Double XP",
            description: "Earn double XP for a short time",
            requiredLevel: 1,
            runeCost: 1,
            effect: .doubleXP
        ),
        Spell(
            id: "spell_double_gold",
            name: "Double Gold",
            description: "Earn double gold for a short time",
            requiredLevel: 1,
            runeCost: 1,
            effect: .doubleGold
        )
    ]

    // MARK: - Recipes
    var masterRecipeList: [Recipe] = []

    // MARK: - Quest Templates
    struct QuestTemplate {
        let id: UUID
        let title: String
        let questDescription: String
        let type: QuestType
        let rewards: [LootReward]
    }

    var masterQuestList: [QuestTemplate] = []

    // MARK: - Statue Templates
    struct StatueTemplate {
        let id: UUID
        let name: String
        let statueDescription: String
        let requiredWillpower: Int
        let reward: PermanentBonus
    }

    var masterStatueList: [StatueTemplate] = []
}

