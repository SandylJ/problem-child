// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProjectChimera",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ProjectChimera",
            targets: ["ProjectChimera"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ProjectChimera",
            dependencies: [],
            path: ".",
            exclude: [
                "Info.plist"
            ],
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
                "ChallengeBridge.swift",
                "Challenges:ChallengeManager.swift",
                "Challenges:ChallengesView.swift",
                "Challenges:DailyChallenge.swift",
                "Items:Affixes.swift",
                "Items:TemperingForge.swift",
                "Meta:AscensionManager.swift",
                "Meta:AscensionView.swift",
                "Meta:PrestigePerk.swift",
                "GameState.swift"
            ],
            resources: [
                .process("Assets.xcassets")
            ])
    ]
)
