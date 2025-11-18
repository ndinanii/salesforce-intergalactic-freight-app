# Scratch Org Development Workflow

## Overview
This project follows SFDX best practices with scratch org-based development.

## Available Orgs

### 1. **IntergalacticFreight** (Production/Dev Org)
- **Alias:** IntergalacticFreight
- **Username:** wn.myendeki959@agentforce.com
- **Purpose:** Main development org with permission sets preserved
- **Status:** Dev Hub enabled

### 2. **IFTC-Dev** (Scratch Org) 🍁 DEFAULT
- **Alias:** IFTC-Dev
- **Username:** admin@iftc-scratch.org
- **Purpose:** Isolated testing environment for development
- **Expires:** 30 days from creation
- **Features Enabled:**
  - Lightning Experience
  - Communities
  - Multi-Currency
  - Chatter
  - Translation Workbench

## Development Workflow

### 1. Create/Modify Metadata in Scratch Org
```powershell
# Open scratch org
sf org open --target-org IFTC-Dev

# Make changes in UI or use CLI
```

### 2. Pull Changes to Local
```powershell
# Pull metadata from scratch org to local project
sf project retrieve start --source-org IFTC-Dev --manifest manifest/package.xml

# Or pull all tracked changes
sf project retrieve start --source-org IFTC-Dev
```

### 3. Commit to Version Control
```powershell
git add force-app/
git commit -m "feat: Add new metadata"
git push
```

### 4. Deploy to Production/Other Orgs
```powershell
# Deploy to IntergalacticFreight org
sf project deploy start --target-org IntergalacticFreight --manifest manifest/package.xml

# Or validate before deploy
sf project deploy validate --target-org IntergalacticFreight --manifest manifest/package.xml
```

### 5. Push Changes FROM Local TO Scratch Org
```powershell
# Push all local metadata to scratch org
sf project deploy start --target-org IFTC-Dev

# Or use source tracking
sf project deploy start --source-org IFTC-Dev
```

## Org Management Commands

### Switch Default Org
```powershell
# Set scratch org as default (already set)
sf config set target-org=IFTC-Dev

# Switch back to production org
sf config set target-org=IntergalacticFreight
```

### View Org Status
```powershell
# List all orgs
sf org list --all

# Display org details
sf org display --target-org IFTC-Dev
```

### Refresh Scratch Org (if expired or corrupted)
```powershell
# Delete existing scratch org
sf org delete scratch --target-org IFTC-Dev --no-prompt

# Create new scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias IFTC-Dev --duration-days 30 --set-default
```

### Generate Password for Scratch Org User
```powershell
sf org generate password --target-org IFTC-Dev
```

## Best Practices

### ✅ DO:
- Use scratch org for all development and testing
- Pull changes frequently to keep local in sync
- Commit changes to Git regularly
- Test in scratch org before deploying to production
- Delete and recreate scratch org when starting new features

### ❌ DON'T:
- Develop directly in production (IntergalacticFreight) org
- Store sensitive data in scratch org definitions
- Let scratch orgs expire without pulling changes
- Deploy untested metadata to production

## Scratch Org Configuration

The scratch org is defined in `config/project-scratch-def.json`:
```json
{
  "orgName": "IFTC Development Scratch Org",
  "edition": "Developer",
  "features": ["EnableSetPasswordInApi", "Communities", "MultiCurrency"],
  "hasSampleData": false,
  "username": "admin@iftc-scratch.org"
}
```

## Troubleshooting

### Scratch org won't open
```powershell
sf org display --target-org IFTC-Dev
sf org open --target-org IFTC-Dev --url-only
```

### View scratch org limits
```powershell
sf org list limits --target-org IFTC-Dev
```

### Check remaining days
```powershell
sf org list --all
# Look at "Expires" column
```

## Next Steps

1. ✅ Scratch org created and set as default
2. Begin Phase 1: Build data model in scratch org
3. Pull metadata to local after each phase
4. Deploy to IntergalacticFreight only when fully tested
