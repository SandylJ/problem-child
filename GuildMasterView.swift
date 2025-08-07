
import SwiftUI
import SwiftData

struct GuildMasterView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var user: User

    private var guild: Guild? { user.guild }
    private var activeBounties: [GuildBounty] { (user.guildBounties ?? []).filter { $0.isActive } }

    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("The Guild Master")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 5)

                Text("Welcome, \(user.username)! Our guild thrives on the dedication of its members. Take on these bounties to strengthen our ranks and earn valuable Guild Seals.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)

                if let guild = guild {
                    GuildProgressionView(guild: guild)
                }

                Section(header: Text("Hire Mercenaries").font(.title2).bold()) {
                    HireMercenariesRow(user: user, modelContext: modelContext)
                }
                .padding(.horizontal)

                Section(header: Text("Active Hunts").font(.title2).bold()) {
                    PassiveHuntsSection(user: user, modelContext: modelContext)
                }
                .padding(.horizontal)

                Section(header: Text("Guild Bounties").font(.title2).bold()) {
                    if activeBounties.isEmpty {
                        Text("No active bounties today. Check back tomorrow!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(activeBounties) { bounty in
                            GuildBountyCardView(bounty: bounty, user: user)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Guild Master")
        .onReceive(timer) { _ in
            GuildManager.shared.processHunts(for: user, deltaTime: 1.0, context: modelContext)
        }
    }
}

struct GuildProgressionView: View {
    @Bindable var guild: Guild

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Guild Level: \(guild.level)")
                .font(.headline)
            ProgressView(value: Double(guild.xp), total: Double(guild.xpToNextLevel))
                .progressViewStyle(.linear)
            Text("\(guild.xp) / \(guild.xpToNextLevel) Guild XP")
                .font(.caption)
                .foregroundColor(.secondary)

            if !guild.unlockedPerks.isEmpty {
                Text("Unlocked Perks:")
                    .font(.headline)
                ForEach(guild.unlockedPerks, id: \.self) { perk in
                    Text("• \(perk.description)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Material.regular)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct GuildBountyCardView: View {
    @Bindable var bounty: GuildBounty
    @Bindable var user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(bounty.title)
                .font(.headline)
            Text(bounty.bountyDescription)
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: Double(bounty.currentProgress), total: Double(bounty.requiredProgress))
            Text("Progress: \(bounty.currentProgress) / \(bounty.requiredProgress)")
                .font(.caption2)

            if bounty.currentProgress >= bounty.requiredProgress {
                Button("Claim Bounty") {
                    GuildManager.shared.completeBounty(bounty: bounty, for: user)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            } else {
                Text("Rewards: \(bounty.guildXpReward) Guild XP, \(bounty.guildSealReward) Guild Seals")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Material.regular)
        .cornerRadius(10)
    }
}

struct HireMercenariesRow: View {
    @Bindable var user: User
    var modelContext: ModelContext

    private let combatRoles: [GuildMember.Role] = [.knight, .archer, .wizard, .rogue, .cleric]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(combatRoles, id: \.self) { role in
                    Button("Hire \(role.rawValue)") {
                        GuildManager.shared.hireGuildMember(role: role, for: user, context: modelContext)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            Text("250 gold each. Combatants will fight in your hunts.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Material.regular)
        .cornerRadius(10)
    }
}

struct PassiveHuntsSection: View {
    @Bindable var user: User
    var modelContext: ModelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hunt Rewards ready: \(user.unclaimedHuntGold) Gold").font(.headline)
                Spacer()
                Button("Claim") {
                    GuildManager.shared.claimHuntRewards(for: user)
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
                .disabled(user.unclaimedHuntGold <= 0)
            }

            // Kill Tally
            if user.huntKillTally.isEmpty {
                Text("No kills yet. Start a hunt to begin accumulating rewards.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(user.huntKillTally.keys).sorted(), id: \.self) { enemyID in
                        if let enemy = GameData.shared.getEnemy(id: enemyID) {
                            HStack {
                                Text(enemy.name)
                                Spacer()
                                Text("\(user.huntKillTally[enemyID] ?? 0) kills")
                                    .foregroundColor(.secondary)
                            }
                            .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Divider().padding(.vertical, 4)

            // Minimal controls for starting/stopping hunts
            HStack {
                Button {
                    let combatantIDs = (user.guildMembers ?? []).filter { $0.isCombatant }.map { $0.id }
                    guard !combatantIDs.isEmpty else { return }
                    GuildManager.shared.startHunt(enemyID: "enemy_goblin", with: combatantIDs, for: user, context: modelContext)
                } label: { Label("Goblin", systemImage: "scope") }
                .buttonStyle(.bordered)

                Button {
                    let combatantIDs = (user.guildMembers ?? []).filter { $0.isCombatant }.map { $0.id }
                    guard !combatantIDs.isEmpty else { return }
                    GuildManager.shared.startHunt(enemyID: "enemy_zombie", with: combatantIDs, for: user, context: modelContext)
                } label: { Label("Zombie", systemImage: "scope") }
                .buttonStyle(.bordered)

                Button {
                    let combatantIDs = (user.guildMembers ?? []).filter { $0.isCombatant }.map { $0.id }
                    guard !combatantIDs.isEmpty else { return }
                    GuildManager.shared.startHunt(enemyID: "enemy_spider", with: combatantIDs, for: user, context: modelContext)
                } label: { Label("Spider", systemImage: "scope") }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    if let first = user.activeHunts?.first {
                        GuildManager.shared.stopHunt(first, for: user, context: modelContext)
                    }
                } label: { Label("Stop", systemImage: "xmark.circle") }
                .buttonStyle(.bordered)
                .disabled((user.activeHunts ?? []).isEmpty)
            }
        }
        .padding()
        .background(Material.regular)
        .cornerRadius(10)
    }
}
