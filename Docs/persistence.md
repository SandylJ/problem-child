# Project Chimera - Persistence Guide

## Overview

Project Chimera uses SwiftData for persistence, providing automatic schema management and migration capabilities. This document outlines the current schema version, migration strategies, and backup/restore functionality.

## Current Schema Version

**Version: 1.0**

### Core Models

#### Player
- `id: UUID` - Unique identifier
- `name: String` - Player name
- `level: Int` - Player level
- `essence: Int` - Ascension currency
- `gold: Int` - Gold currency

#### Skill
- `id: UUID` - Unique identifier
- `name: String` - Skill name (backed by SkillName enum)
- `level: Int` - Current skill level
- `xp: Int` - Current XP points

#### TaskRecord
- `id: UUID` - Unique identifier
- `date: Date` - When the task was completed
- `skillRef: String` - Reference to skill name
- `amountXP: Int` - XP gained
- `difficulty: String` - Task difficulty

#### Resource
- `id: UUID` - Unique identifier
- `kind: String` - Resource type (backed by ResourceKind enum)
- `quantity: Int` - Current quantity

#### Building
- `id: UUID` - Unique identifier
- `type: String` - Building type (backed by BuildingType enum)
- `level: Int` - Current building level
- `lastProductionTime: Date` - Last production tick

#### PlayerExpedition
- `id: UUID` - Unique identifier
- `type: String` - Expedition type
- `startTime: Date` - When expedition started
- `endTime: Date` - When expedition ends
- `isActive: Bool` - Whether expedition is currently running
- `isCompleted: Bool` - Whether expedition has been completed

#### PlayerExpeditionReport
- `id: UUID` - Unique identifier
- `expeditionId: String` - Reference to expedition
- `expeditionType: String` - Type of expedition
- `completionDate: Date` - When report was generated
- `rewards: String` - JSON string of rewards

## Migration Strategy

### Version 1.0 → 1.1 (Planned)

**Changes:**
- Add `essence` field to Player model
- Add `lastProductionTime` to Building model
- Add `isCompleted` to PlayerExpedition model

**Migration Steps:**
1. Update model definitions
2. SwiftData will automatically handle schema migration
3. Test with existing data

### Version 1.1 → 1.2 (Planned)

**Changes:**
- Add `perkId` to TaskRecord for perk tracking
- Add `bonusMultiplier` to Skill model
- Add `unlockedAt` to Building model

**Migration Steps:**
1. Update model definitions
2. Provide default values for new fields
3. Test migration with sample data

## Backup and Restore

### Export Format

The backup system exports data in JSON format with the following structure:

```json
{
  "version": "1.0",
  "timestamp": "2024-01-01T00:00:00Z",
  "player": {
    "id": "uuid",
    "name": "Player Name",
    "level": 1,
    "essence": 0,
    "gold": 100
  },
  "skills": [
    {
      "id": "uuid",
      "name": "Strength",
      "level": 1,
      "xp": 0
    }
  ],
  "resources": [
    {
      "id": "uuid",
      "kind": "Rations",
      "quantity": 10
    }
  ],
  "taskRecords": [
    {
      "id": "uuid",
      "date": "2024-01-01T00:00:00Z",
      "skillRef": "Strength",
      "amountXP": 20,
      "difficulty": "Easy"
    }
  ],
  "buildings": [
    {
      "id": "uuid",
      "type": "Farm",
      "level": 1,
      "lastProductionTime": "2024-01-01T00:00:00Z"
    }
  ],
  "expeditions": [
    {
      "id": "uuid",
      "type": "Forest Scout",
      "startTime": "2024-01-01T00:00:00Z",
      "endTime": "2024-01-01T01:00:00Z",
      "isActive": true,
      "isCompleted": false
    }
  ],
  "reports": [
    {
      "id": "uuid",
      "expeditionId": "uuid",
      "expeditionType": "Forest Scout",
      "completionDate": "2024-01-01T01:00:00Z",
      "rewards": "{\"rations\": 5, \"tools\": 2}"
    }
  ]
}
```

### Backup Process

1. **Export Data**: Serialize all SwiftData models to JSON
2. **Validate Schema**: Ensure all required fields are present
3. **Compress**: Optionally compress the JSON data
4. **Save**: Store backup with timestamp and version

### Restore Process

1. **Validate Backup**: Check version compatibility
2. **Clear Existing**: Remove current data (optional)
3. **Import Data**: Deserialize JSON and create SwiftData objects
4. **Verify Integrity**: Ensure all relationships are maintained
5. **Save**: Commit changes to SwiftData

## Developer Commands

### Export Backup

```swift
// Export all data to JSON
let backupData = try await GameStateManager.exportBackup()
let jsonString = String(data: backupData, encoding: .utf8)
// Save to file or share
```

### Import Backup

```swift
// Import from JSON
let backupData = jsonString.data(using: .utf8)!
try await GameStateManager.importBackup(backupData)
```

### Reset Data

```swift
// Clear all data and start fresh
try await GameStateManager.resetAllData()
```

## Best Practices

### Schema Changes

1. **Always increment version** when making schema changes
2. **Test migrations** with existing data before release
3. **Provide default values** for new required fields
4. **Document changes** in this file

### Backup Strategy

1. **Regular backups**: Export data weekly
2. **Version control**: Keep backups with version info
3. **Test restores**: Verify backup integrity
4. **Multiple formats**: Consider both JSON and binary formats

### Error Handling

1. **Validation**: Always validate imported data
2. **Rollback**: Provide rollback mechanism for failed imports
3. **Logging**: Log all backup/restore operations
4. **User feedback**: Inform users of operation status

## Troubleshooting

### Common Issues

1. **Schema mismatch**: Ensure backup version matches current schema
2. **Missing relationships**: Verify all foreign keys are valid
3. **Data corruption**: Validate JSON structure before import
4. **Performance**: Large backups may take time to process

### Debug Commands

```swift
// Check current schema version
let version = try await GameStateManager.getSchemaVersion()

// Validate data integrity
let isValid = try await GameStateManager.validateDataIntegrity()

// Get backup info
let info = try await GameStateManager.getBackupInfo(backupData)
```

