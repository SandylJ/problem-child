import Foundation
import Combine

// This manager will handle the logic for learning, casting,
// and tracking the effects of spells.
class SpellbookManager: ObservableObject {
    // A list of all spells the player has learned.
    @Published var knownSpells: [Spell] = []
    
    // A list of all buffs/debuffs currently affecting the player.
    @Published var activeBuffs: [ActiveBuff] = []

    // A public initializer is necessary so it can be created in your app's entry point.
    public init() {
        // Here you could load saved spells or set up an initial state.
        // For now, we'll start with an empty spellbook.
    }

    /// Adds a new spell to the player's spellbook if they don't already know it.
    func addSpell(_ spell: Spell) {
        if !knownSpells.contains(where: { $0.id == spell.id }) {
            knownSpells.append(spell)
        }
    }

    /// Handles the logic for casting a spell.
    func castSpell(_ spell: Spell) {
        // This is where you would apply the spell's effects to the game state.
        // For example, if a spell is a buff, you would add it to the activeBuffs array.
        print("Casting \(spell.name)")
    }
}

/// A simple structure to represent a buff that is currently active.
struct ActiveBuff: Identifiable {
    let id = UUID()
    let spell: Spell
    let remainingDuration: TimeInterval
}
