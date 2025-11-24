# Android Fastlane Setup for XDoc

## Overview
Automated Android deployment to Google Play Store using Fastlane and GitHub Actions.

## Setup Status
- ✅ Fastlane configured in `android/fastlane/`
- ✅ CI/CD workflow ready in DevOps repo
- ✅ Metadata files prepared

## Quick Start

### Local Testing
```bash
cd android
bundle install
bundle exec fastlane internal  # Deploy to internal testing
bundle exec fastlane beta      # Deploy to beta
bundle exec fastlane build_apk # Build APK only
```

### CI/CD Deployment
- **Push to main (no tag)** → Internal Testing (3 testers)
- **Push with tag `v1.0.1`** → Beta Testing (Closed Testing)

## File Structure
```
android/
├── fastlane/
│   ├── Appfile              # Package name and credentials config
│   ├── Fastfile             # Deployment automation lanes
│   └── metadata/android/en-US/
│       ├── title.txt
│       ├── short_description.txt
│       ├── full_description.txt
│       └── changelogs/default.txt
└── Gemfile                  # Ruby dependencies
```

## Deployment Lanes

### 1. Internal Testing (`fastlane internal`)
- Auto-increments version code
- Builds release AAB
- Uploads to Internal Testing track
- Available instantly to 3 internal testers

### 2. Beta Testing (`fastlane beta`)
- Auto-increments version code  
- Builds release AAB
- Uploads to Beta (Closed Testing) track
- Triggered by version tags (v*)

### 3. Build APK (`fastlane build_apk`)
- Builds APK for direct installation
- Used for CI artifacts

## Version Management

Format: `version: 1.0.0+8` in `pubspec.yaml`
- `1.0.0` = Version name
- `+8` = Version code (auto-incremented by Fastlane)

## Required Secrets (GitHub)

Must be configured in `advcomm-DevOps/app2` repository:

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64 encoded keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON_BASE64` | Google Play API credentials (base64) |

## Google Play Setup

1. **Service Account Created:**
   - Project: `xdoc-deployment`
   - Account: `xdoc-github-actions@xdoc-deployment.iam.gserviceaccount.com`
   - Has Play Console API access

2. **Testing Tracks:**
   - Internal: 3 testers configured
   - Beta (Closed Testing): Ready for tester list

## Workflow Triggers

**In DevOps repo (after merge):**
- **On push to main/master (no tag):** Deploys to Internal Testing
- **On push with version tag (v*):** Deploys to Beta Testing
- **Manual trigger:** Available via Actions tab

## Screenshots and Promotional Media

### Why We're Not Using Screenshots/Videos Currently

We have disabled screenshot and image uploads in our Fastfile:
```ruby
skip_upload_images: true
skip_upload_screenshots: true
```

Reasons:

1. **Internal Testing Focus:** We're currently deploying to Internal Testing track (3 testers only). Google Play doesn't require or display screenshots for internal testing - testers get direct app access without needing store listing.
2. **Not Required for Testing Tracks:** Screenshots are only mandatory when publishing to Production. They're optional for Internal and Beta (Closed Testing) tracks.
3. **Marketing Responsibility:** Screenshots and promotional graphics require professional design, marketing copy, and stakeholder approval - not suitable for automated deployment.
4. **One-Time Setup:** Unlike app binaries that change with every release, screenshots are created once and updated only when major UI changes occur.

### When Screenshots Become Necessary

Screenshots will be needed when:
- **Publishing to Production** - Required by Google Play Store
- **Open Beta Testing** - Helps attract external beta testers
- **Public Release** - When app is discoverable in Play Store

### How to Add Screenshots (For Production)

When ready to publish to Production, add screenshots to:
```
android/fastlane/metadata/android/en-US/images/
├── phoneScreenshots/     # Required: 2-8 screenshots (16:9 or 9:16)
├── featureGraphic.png    # Required: 1024x500px banner
└── icon.png              # Required: 512x512px app icon

android/fastlane/metadata/android/en-US/
└── video.txt             # Optional: YouTube promo video URL
```

Then update Fastfile to enable uploads:
```ruby
skip_upload_images: false
skip_upload_screenshots: false
```

### Automated Screenshot Generation (Future)

Fastlane includes a screenshots lane for future use:
```ruby
lane :screenshots do
  # Can be configured with screengrab tool
  # Generates screenshots automatically across devices
end
```

This can use https://docs.fastlane.tools/actions/screengrab/ for automated screenshot capture across different devices and locales.

## Troubleshooting

### JSON Parse Error
- Ensure base64 secret has no newlines
- Workflow strips newlines automatically with `tr -d '\n\r '`

### Version Code Conflict
- Fastlane auto-increments from current version in Play Console
- If conflict, manually bump version code in `pubspec.yaml`

### Service Account Permissions
- Verify service account has "Release manager" role in Play Console
- Check API access is enabled

## Current Status

### What's Done ✅
- Fastlane files configured
- Metadata prepared  
- Workflow file created in DevOps repo
- Service account JSON obtained
- GitHub secrets configured

### What's Pending ⏳
- Merge to main branch
- Test deployment via CI/CD
- Verify testers can download app

## Next Steps

1. **Review this branch** - Check all Fastlane files
2. **Apply improvements** - Make any requested changes
3. **Merge to main** - Merge `feature/android-fastlane` → `main`
4. **Auto-sync** - Mirror workflow will sync to DevOps repo
5. **Test deployment** - Push a commit to trigger workflow
6. **Verify** - Check Play Console for uploaded app

## Files in This Branch

- `android/fastlane/Appfile` - App configuration
- `android/fastlane/Fastfile` - Deployment lanes
- `android/fastlane/metadata/` - Play Store listing
- `android/Gemfile` - Ruby dependencies
- `FASTLANE.md` - This documentation

## Workflow File Location

**After merge**, workflow will be at:
`advcomm-DevOps/app2/.github/workflows/android-beta-deploy.yml`

## Testing Checklist

- [ ] Fastlane files reviewed
- [ ] Metadata content approved
- [ ] Secrets configured correctly
- [ ] Service account permissions verified
- [ ] Internal testers added (3 users)
- [ ] Workflow tested successfully
- [ ] App uploaded to Play Console
- [ ] Testers confirmed they can download

---
