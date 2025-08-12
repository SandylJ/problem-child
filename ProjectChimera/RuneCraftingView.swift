import SwiftUI
import SwiftData

struct RuneCraftingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User

    private let runeRecipes: [Recipe] = ItemDatabase.shared.masterRecipeList.filter { $0.id.hasPrefix("rune_glyph_") }
    @State private var selection: String? = nil
    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black.opacity(0.9), .purple.opacity(0.3), .cyan.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header

                    // Crafting Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Craft Glyphs").font(.title2.bold()).foregroundColor(.white)
                        Text("Transmute rare materials into luminous runes.")
                            .font(.caption).foregroundColor(.white.opacity(0.8))
                        ForEach(runeRecipes) { recipe in
                            RuneRecipeCard(recipe: recipe, user: user)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)

                    // Inscription Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Inscribe Glyphs").font(.title2.bold()).foregroundColor(.white)
                        Text("Bind a crafted glyph into your spellbook.")
                            .font(.caption).foregroundColor(.white.opacity(0.8))
                        ForEach(glyphItems(), id: \.id) { item in
                            InscribeGlyphRow(item: item, user: user)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                .padding()
            }
            .onAppear { withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) { shimmerPhase = 1 } }
        }
        .navigationTitle("Rune Atelier")
    }

    private var header: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(AngularGradient(gradient: Gradient(colors: [.cyan, .purple, .blue, .cyan]), center: .center))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                    .opacity(0.4)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .purple.opacity(0.7), radius: 12, x: 0, y: 0)
            }
            Text("Weave runes into reality")
                .font(.title).bold().foregroundColor(.white)
            HStack(spacing: 16) {
                Label("Gold: \(user.gold)", systemImage: "dollarsign.circle.fill").foregroundColor(.yellow)
                Label("Runes: \(user.runes)", systemImage: "circle.hexagonpath.fill").foregroundColor(.cyan)
            }.font(.callout).padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
    }

    private func glyphItems() -> [Item] {
        let ids = ["glyph_insight", "glyph_verdant", "glyph_midas", "glyph_rune_surge"]
        return ids.compactMap { ItemDatabase.shared.getItem(id: $0) }
    }
}

private struct RuneRecipeCard: View {
    @Environment(\.modelContext) private var modelContext
    let recipe: Recipe
    @Bindable var user: User
    @State private var craftedTrigger = false

    private var canCraft: Bool { CraftingManager.shared.canCraft(recipe, user: user) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let item = recipe.craftedItem {
                HStack { Image(systemName: item.icon).foregroundColor(color(for: item.rarity)).font(.title2); Text(item.name).font(.headline) }
                Text(item.description).font(.caption).foregroundColor(.secondary)
            }
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(recipe.requiredMaterials.keys), id: \.self) { itemID in
                    if let mat = ItemDatabase.shared.getItem(id: itemID) {
                        let need = recipe.requiredMaterials[itemID] ?? 0
                        let have = user.inventory?.first(where: { $0.itemID == itemID })?.quantity ?? 0
                        HStack { Text(mat.name).font(.caption); Spacer(); Text("\(have)/\(need)").font(.caption).foregroundColor(have >= need ? .primary : .red) }
                    }
                }
                HStack { Text("Gold").font(.caption); Spacer(); Text("\(user.gold)/\(recipe.requiredGold)").font(.caption).foregroundColor(user.gold >= recipe.requiredGold ? .primary : .red) }
            }
            Button("Craft") {
                CraftingManager.shared.craftItem(recipe, user: user, context: modelContext)
                craftedTrigger.toggle()
            }
            .buttonStyle(JuicyButtonStyle())
            .disabled(!canCraft)
            .sensoryFeedback(.success, trigger: craftedTrigger)
        }
        .padding()
        .background(Material.thin)
        .cornerRadius(14)
    }

    private func color(for rarity: Rarity) -> Color {
        switch rarity { case .common: return .green; case .rare: return .blue; case .epic: return .purple; case .legendary: return .orange }
    }
}

private struct InscribeGlyphRow: View {
    @Environment(\.modelContext) private var modelContext
    let item: Item
    @Bindable var user: User
    @State private var inscribeTrigger = false

    private var qty: Int { user.inventory?.first(where: { $0.itemID == item.id })?.quantity ?? 0 }
    private var canInscribe: Bool { qty > 0 }
    private var unlocksText: String {
        switch item.id {
        case "glyph_insight": return "Unlocks Mind Amplification"
        case "glyph_verdant": return "Unlocks Verdant Growth"
        case "glyph_midas": return "Unlocks Golden Harvest"
        case "glyph_rune_surge": return "Unlocks Rune Surge"
        default: return "Unlocks mysterious magic"
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: item.icon).foregroundColor(color(for: item.rarity)).font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.headline)
                Text(unlocksText).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text("x\(qty)").font(.caption).foregroundColor(.secondary)
            Button("Inscribe") {
                RuneCraftingManager.shared.inscribeGlyph(item.id, for: user, context: modelContext)
                inscribeTrigger.toggle()
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            .disabled(!canInscribe)
            .sensoryFeedback(.success, trigger: inscribeTrigger)
        }
        .padding(10)
        .background(Material.thin)
        .cornerRadius(12)
    }

    private func color(for rarity: Rarity) -> Color {
        switch rarity { case .common: return .green; case .rare: return .blue; case .epic: return .purple; case .legendary: return .orange }
    }
}