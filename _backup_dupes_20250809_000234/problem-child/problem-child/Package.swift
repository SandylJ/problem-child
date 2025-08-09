// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProjectChimeraProblemChild",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ProjectChimeraProblemChild",
            targets: ["ProjectChimeraProblemChild"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ProjectChimeraProblemChild",
            dependencies: [],
            path: ".",
            sources: [
                "ProjectChimeraApp.swift",
                "ContentView.swift",
                "MainView.swift",
                "MainTabs.swift",
                "Models.swift",
                "Managers.swift",
                "ItemDatabase.swift",
                "OnboardingView.swift",
                "OnboardingManager.swift",
                "IdleGameManager.swift",
                "HealthKitManager.swift",
                "EquipmentManager.swift",
                "SanctuaryManager.swift",
                "GuildManager.swift",
                "ShopManager.swift",
                "QuestManager.swift",
                "AchievementManager.swift",
                "EggManager.swift",
                "TeamManager.swift",
                "CharacterView.swift",
                "CraftingView.swift",
                "EquipmentView.swift",
                "GuildMasterView.swift",
                "LairView.swift",
                "LevelUpOverlay.swift",
                "QuestsView.swift",
                "SanctuaryView.swift",
                "SanctuaryFeatureViews.swift",
                "SharedViews.swift",
                "ShopView.swift",
                "SpellbookView.swift",
                "Styles.swift",
                "TaskListView.swift",
                "ActiveBuffsView.swift",
                "AltarOfWhispersView.swift",
                "GameState.swift",
                "ChallengeBridge.swift",
                "Challenges:ChallengeManager.swift",
                "Challenges:ChallengesView.swift",
                "Challenges:DailyChallenge.swift",
                "Items:Affixes.swift",
                "Items:TemperingForge.swift",
                "Meta:AscensionManager.swift",
                "Meta:AscensionView.swift",
                "Meta:PrestigePerk.swift"
            ],
            resources: [
                .process("Assets.xcassets")
            ])
    ]
)
