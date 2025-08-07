import Foundation

struct ItemDatabase {
    static let items: [Item] = [
        // MARK: - Equipment
        // Weapons
        Item(id: 1, name: "Rusty Sword", type: .equipment(.weapon), rarity: .common, effects: [.statBuff(stat: .strength, multiplier: 1.05)], value: 10),
        Item(id: 2, name: "Oak Staff", type: .equipment(.weapon), rarity: .common, effects: [.statBuff(stat: .intellect, multiplier: 1.05)], value: 10),

        // Armor
        Item(id: 3, name: "Leather Tunic", type: .equipment(.armor), rarity: .common, effects: [.statBuff(stat: .vitality, multiplier: 1.05)], value: 15),
        Item(id: 4, name: "Iron Helm", type: .equipment(.helmet), rarity: .uncommon, effects: [.statBuff(stat: .endurance, multiplier: 1.1)], value: 30),

        // Accessories
        Item(id: 5, name: "Ring of Vitality", type: .equipment(.accessory), rarity: .rare, effects: [.statBuff(stat: .vitality, multiplier: 1.15)], value: 100),

        // MARK: - Consumables
        Item(id: 6, name: "Minor Healing Potion", type: .consumable, rarity: .common, effects: [.heal(percentage: 0.2)], value: 25),
        
        // CORRECTED: Changed .mind to .intellect and removed the extra comma before 'value'.
        Item(id: 7, name: "Scroll of Minor Intellect", type: .consumable, rarity: .common, effects: [.statBuff(stat: .intellect, multiplier: 1.1)], value: 20),

        // MARK: - Crafting Materials
        Item(id: 8, name: "Iron Ore", type: .craftingMaterial, rarity: .common, value: 5),
        Item(id: 9, name: "Oak Wood", type: .craftingMaterial, rarity: .common, value: 3),
        Item(id: 10, name: "Dragon Scale", type: .craftingMaterial, rarity: .legendary, value: 1000)
    ]

    static func find(by id: Int) -> Item? {
        return items.first { $0.id == id }
    }
    
    static func find(byName name: String) -> Item? {
        return items.first { $0.name.lowercased() == name.lowercased() }
    }
}

// Example of a more complex item with multiple effects
struct ComplexItems {
    static let phoenixDown: Item = {
        let resurrectionEffect = ItemEffect.revive(healthPercentage: 0.5)
        let temporaryInvincibility = ItemEffect.timedBuff(duration: 10, buff: .init(stat: .endurance, multiplier: 999))
        
        return Item(
            id: 101,
            name: "Phoenix Down",
            type: .consumable,
            rarity: .epic,
            effects: [resurrectionEffect, temporaryInvincibility],
            value: 2500,
            description: "A feather from a mythical bird. Revives a fallen ally with 50% health and grants temporary invincibility."
        )
    }()
    
    static let philosopherStone: Item = {
        let transmuteEffect = ItemEffect.transmute(from: "Iron Ore", to: "Gold Coin", rate: 0.1)
        let statBoost = ItemEffect.statBuff(stat: .intellect, multiplier: 1.2)
        
        return Item(
            id: 102,
            name: "Philosopher's Stone",
            type: .artifact,
            rarity: .legendary,
            effects: [transmuteEffect, statBoost],
            value: 10000,
            description: "A legendary artifact that can transmute base metals into gold and greatly enhances the user's intellect."
        )
    }()
}
