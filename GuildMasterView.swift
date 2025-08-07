
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
                    HuntsSection(user: user, modelContext: modelContext)
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

struct HuntsSection: View {
    @Bindable var user: User
    var modelContext: ModelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Start a goblin hunt quick action
            Button {
                let combatantIDs = (user.guildMembers ?? []).filter { $0.isCombatant }.map { $0.id }
                guard !combatantIDs.isEmpty else { return }
                GuildManager.shared.startHunt(enemyID: "enemy_goblin", with: combatantIDs, for: user, context: modelContext)
            } label: {
                Label("Start Goblin Hunt (auto-assign all combatants)", systemImage: "scope")
            }
            .buttonStyle(.borderedProminent)

            if (user.activeHunts ?? []).isEmpty {
                Text("No active hunts. Start one to earn passive gold and complete combat bounties.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(user.activeHunts ?? []) { hunt in
                    HuntRowView(hunt: hunt, user: user, modelContext: modelContext)
                }
            }
        }
        .padding()
        .background(Material.regular)
        .cornerRadius(10)
    }
}

struct HuntRowView: View {
    @Bindable var hunt: ActiveHunt
    @Bindable var user: User
    var modelContext: ModelContext

    private func dpsText() -> String {
        let dps = GuildManager.shared.totalPartyDPS(memberIDs: hunt.memberIDs, on: user)
        return String(format: "%.1f DPS", dps)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(hunt.enemy?.name ?? "Unknown Enemy").bold()
                Spacer()
                Text(dpsText()).font(.caption).foregroundColor(.secondary)
            }
            Text("Kills: \(hunt.killsAccumulated)").font(.caption)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(hunt.memberIDs, id: \.self) { id in
                        if let member = user.guildMembers?.first(where: { $0.id == id }) {
                            Text(member.name)
                                .font(.caption2)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            HStack {
                Button("Stop Hunt") {
                    GuildManager.shared.stopHunt(hunt, for: user, context: modelContext)
                }
                .buttonStyle(.bordered)
                Spacer()
            }
        }
        .padding()
        .background(Material.thin)
        .cornerRadius(10)
    }
}
