# Semantic Versioning for XDoc

This document explains how to use automated semantic versioning with Melos for the XDoc app.

---

## 📚 **Semantic Versioning Basics**

### **Format:** MAJOR.MINOR.PATCH+BUILD

- **MAJOR** (1.x.x): Breaking changes, incompatible API changes
- **MINOR** (x.1.x): New features, backwards-compatible
- **PATCH** (x.x.1): Bug fixes, backwards-compatible
- **BUILD** (+8): Internal build number

**Example:** `1.2.3+10`

- Version: 1.2.3
- Build number: 10

---

## 🔄 **Automated Versioning with Melos**

### **Important:**

All versioning commands are scoped to the **xdoc app only**. Packages in `packages/` folder are not versioned automatically.

### **Prerequisites:**

1. **Use Conventional Commits** for your commit messages:

   ```bash
   feat: add new feature       # Bumps MINOR version
   fix: fix a bug              # Bumps PATCH version
   feat!: breaking change      # Bumps MAJOR version
   docs: update documentation  # No version bump
   ```

2. **Commit Types:**

   - `feat:` - New feature (minor bump)
   - `fix:` - Bug fix (patch bump)
   - `perf:` - Performance improvement (patch bump)
   - `refactor:` - Code refactoring (patch bump)
   - `docs:` - Documentation only (no bump)
   - `style:` - Code style changes (no bump)
   - `test:` - Tests only (no bump)
   - `chore:` - Maintenance (no bump)
   - `build:` - Build system changes (patch bump)

   **Breaking Change:** Add `!` after type: `feat!:`, `fix!:`

---

## 🚀 **Versioning Commands**

### **1. Check What Would Be Updated (Interactive)**

```bash
melos version:check

# Or manually:
melos version
```

This shows what versions would be bumped and prompts for confirmation before making changes.
You can review and say 'no' to cancel without making any changes.

---

### **2. Bump Patch Version (0.0.x)**

```bash
melos version:patch

# Manual:
melos version --yes
```

**Use for:**

- Bug fixes
- Small improvements
- Performance tweaks

**Example:** `1.0.0` → `1.0.1`

---

### **3. Bump Minor Version (0.x.0)**

```bash
melos version:minor

# Manual:
melos version --yes --scope='minor'
```

**Use for:**

- New features
- New functionality
- Backwards-compatible changes

**Example:** `1.0.1` → `1.1.0`

---

### **4. Bump Major Version (x.0.0)**

```bash
melos version:major

# Manual:
melos version --yes --scope='major'
```

**Use for:**

- Breaking changes
- API changes
- Major refactors

**Example:** `1.1.0` → `2.0.0`

---

### **5. Create Prerelease Version**

```bash
melos version:prerelease

# Manual:
melos version --prerelease --yes --preid=beta
```

**Creates:** `1.0.0-beta.1`, `1.0.0-beta.2`, etc.

**Use for:**

- Beta releases
- Testing versions
- Preview builds

---

### **6. Graduate Prerelease to Stable**

```bash
melos version:graduate

# Manual:
melos version --graduate --yes
```

**Converts:** `1.0.0-beta.1` → `1.0.0`

---

## 📝 **Complete Versioning Workflow**

### **Scenario 1: Bug Fix Release**

```bash
# 1. Make your changes
git checkout -b fix/user-login-bug

# 2. Commit with conventional commit
git add .
git commit -m "fix: resolve login timeout issue"

# 3. Merge to main
git checkout main
git merge fix/user-login-bug

# 4. Bump version (patch)
melos version:patch

# 5. Verify changes
cat apps/xdoc/pubspec.yaml  # Check version
cat apps/xdoc/CHANGELOG.md  # Check changelog

# 6. Commit and tag
git add .
git commit -m "chore(release): bump version to 1.0.1"
git tag v1.0.1
git push origin main --tags
```

**Result:** `1.0.0+8` → `1.0.1+9`

---

### **Scenario 2: Feature Release**

```bash
# 1. Make your changes
git checkout -b feat/dark-mode

# 2. Commit with conventional commit
git add .
git commit -m "feat: add dark mode support"

# 3. Merge to main
git checkout main
git merge feat/dark-mode

# 4. Bump version (minor)
melos version:minor

# 5. Commit and tag
git add .
git commit -m "chore(release): bump version to 1.1.0"
git tag v1.1.0
git push origin main --tags
```

**Result:** `1.0.1+9` → `1.1.0+10`

---

### **Scenario 3: Beta Release**

```bash
# 1. Create prerelease
melos version:prerelease

# 2. Verify
cat apps/xdoc/pubspec.yaml  # Shows: 1.1.0-beta.1+11

# 3. Test the beta build
cd apps/xdoc
flutter build apk

# 4. When ready for stable
melos version:graduate

# 5. Verify
cat apps/xdoc/pubspec.yaml  # Shows: 1.1.0+12
```

---

## 🔍 **What Melos Does Automatically**

When you run `melos version`:

1. ✅ Analyzes conventional commits since last version
2. ✅ Determines version bump (major/minor/patch)
3. ✅ Updates `pubspec.yaml` version
4. ✅ Updates `CHANGELOG.md` with changes
5. ✅ Increments build number automatically
6. ✅ Creates git tag (optional)
7. ✅ Commits changes (optional)

---

## 📊 **Version in Different Platforms**

After version bump, the version appears as:

### **Android** (`build.gradle.kts`)

```kotlin
versionName = "1.1.0"    // From version: 1.1.0+10
versionCode = 10          // From build: +10
```

### **iOS** (`Info.plist`)

```xml
<key>CFBundleShortVersionString</key>
<string>1.1.0</string>
<key>CFBundleVersion</key>
<string>10</string>
```

### **Linux/Windows**

- Shown in About dialog
- Used for update checks

---

## 🎯 **Best Practices**

### **DO:**

✅ Use conventional commits consistently  
✅ Run `melos version:check` before actual version bump  
✅ Update CHANGELOG.md manually if needed  
✅ Tag releases in git  
✅ Keep build numbers sequential

### **DON'T:**

❌ Manually edit version in pubspec.yaml  
❌ Skip version bumps for releases  
❌ Use non-conventional commit messages  
❌ Forget to push tags after release

---

## 🛠️ **Manual Version Override**

If you need to set a specific version:

```bash
# Edit pubspec.yaml manually
nano apps/xdoc/pubspec.yaml

# Change:
version: 2.0.0+15

# Then commit
git add apps/xdoc/pubspec.yaml
git commit -m "chore: bump version to 2.0.0"
git tag v2.0.0
```

---

## 📚 **Resources**

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Melos Versioning](https://melos.invertase.dev/~melos-latest/commands/version)
- [Keep a Changelog](https://keepachangelog.com/)

---

## 🔗 **Quick Reference**

| Command                    | Version Change           | Use Case         |
| -------------------------- | ------------------------ | ---------------- |
| `melos version:check`      | None (dry run)           | Preview changes  |
| `melos version:patch`      | `1.0.0` → `1.0.1`        | Bug fixes        |
| `melos version:minor`      | `1.0.1` → `1.1.0`        | New features     |
| `melos version:major`      | `1.1.0` → `2.0.0`        | Breaking changes |
| `melos version:prerelease` | `1.0.0` → `1.0.0-beta.1` | Beta versions    |
| `melos version:graduate`   | `1.0.0-beta.1` → `1.0.0` | Stable release   |

---

## ✅ **Current Version**

Check current version:

```bash
grep "version:" apps/xdoc/pubspec.yaml
```

Current: **1.0.0+8**

---

_Last Updated: December 4, 2024_
