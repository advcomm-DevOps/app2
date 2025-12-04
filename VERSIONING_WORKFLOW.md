# Automated Versioning Workflow

This document describes the automated semantic versioning workflow for XDoc.

---

## 🔄 **Automated Workflow Overview**

```
Developer → Commit (conventional) → Push to main → CI/CD Analyzes Commits
                                                           ↓
                                     Determines Version Type (major/minor/patch)
                                                           ↓
                                    Bumps Version → Updates CHANGELOG → Tags Release
                                                           ↓
                                              Creates GitHub Release
```

---

## 📝 **Step-by-Step Workflow**

### **1. Developer Makes Changes**

```bash
# Make your changes
git checkout -b feature/dark-mode
# ... make changes ...

# Commit with conventional commit message
git add .
git commit -m "feat: add dark mode support"

# Push to remote
git push origin feature/dark-mode
```

---

### **2. Create Pull Request**

- Create PR to `main` branch
- CI runs tests and checks
- Get code review
- Merge to `main`

---

### **3. Automated Versioning Triggers**

When code is merged to `main`:

**GitHub Actions automatically:**

1. ✅ **Analyzes commits** since last release
2. ✅ **Determines version bump type**:
   - `feat:` or `feature:` → **minor** bump
   - `fix:`, `perf:`, `refactor:`, `build:` → **patch** bump
   - `feat!:` or `fix!:` (with `!`) → **major** bump
   - `docs:`, `chore:`, `style:`, `test:` → **no bump**

3. ✅ **Runs `melos version:*`** command
4. ✅ **Updates**:
   - `apps/xdoc/pubspec.yaml` (version)
   - `apps/xdoc/CHANGELOG.md` (changelog)
   - Build number (+8 → +9)

5. ✅ **Creates git commit**:
   ```
   chore(release): bump xdoc to v1.1.0
   ```

6. ✅ **Creates git tag**:
   ```
   xdoc-v1.1.0
   ```

7. ✅ **Pushes to repository**

8. ✅ **Creates GitHub Release** with:
   - Release notes from CHANGELOG
   - Download links for builds
   - Assets (APK, AppImage, etc.)

---

## 🎯 **Commit Message Format**

### **Structure:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

### **Types:**

| Type | Version Bump | Description | Example |
|------|--------------|-------------|---------|
| `feat:` | **minor** | New feature | `feat: add user profile` |
| `fix:` | **patch** | Bug fix | `fix: resolve login issue` |
| `perf:` | **patch** | Performance | `perf: optimize queries` |
| `refactor:` | **patch** | Code refactor | `refactor: simplify auth` |
| `build:` | **patch** | Build system | `build: update gradle` |
| `docs:` | **none** | Documentation | `docs: update README` |
| `style:` | **none** | Code style | `style: format code` |
| `test:` | **none** | Tests | `test: add unit tests` |
| `chore:` | **none** | Maintenance | `chore: update deps` |
| `ci:` | **none** | CI config | `ci: update workflow` |

### **Breaking Changes:**

Add `!` after type or `BREAKING CHANGE:` in footer:

```bash
feat!: redesign authentication API

BREAKING CHANGE: Auth endpoints now require JWT tokens
```

This triggers a **major** version bump.

---

## 🚀 **Complete Example Workflow**

### **Scenario: Adding a new feature**

```bash
# 1. Create feature branch
git checkout -b feat/dark-mode

# 2. Make changes
# ... implement dark mode ...

# 3. Commit with conventional commit
git add .
git commit -m "feat: add dark mode toggle to settings

Users can now switch between light and dark themes.
Theme preference is saved to local storage."

# 4. Push and create PR
git push origin feat/dark-mode

# 5. Create PR on GitHub → Get review → Merge to main

# 6. GitHub Actions automatically:
#    - Detects "feat:" commit
#    - Bumps minor version: 1.0.0+8 → 1.1.0+9
#    - Updates pubspec.yaml and CHANGELOG.md
#    - Creates commit: "chore(release): bump xdoc to v1.1.0"
#    - Creates tag: xdoc-v1.1.0
#    - Pushes to main
#    - Creates GitHub Release

# 7. Done! New version released automatically 🎉
```

---

## 📋 **Manual Override**

### **Trigger workflow manually:**

1. Go to GitHub → Actions → "Version and Release"
2. Click "Run workflow"
3. Select branch: `main`
4. Choose version type:
   - patch
   - minor
   - major
   - prerelease
5. Click "Run workflow"

This bypasses commit analysis and uses your selected version type.

---

## 🔧 **Local Testing (Before CI/CD)**

Test the versioning locally before pushing:

```bash
# 1. Check what would be bumped
melos list

# 2. Bump version locally (test)
melos version:minor

# 3. Review changes
git diff apps/xdoc/pubspec.yaml
git diff apps/xdoc/CHANGELOG.md

# 4. If satisfied, commit
git add .
git commit -m "chore(release): bump xdoc to v1.1.0"
git tag xdoc-v1.1.0

# 5. Push
git push origin main --tags
```

---

## 📊 **Version Bump Decision Tree**

```
Is there a BREAKING CHANGE?
├─ YES → MAJOR (x.0.0)
└─ NO
   └─ Are there new features?
      ├─ YES → MINOR (0.x.0)
      └─ NO
         └─ Are there bug fixes?
            ├─ YES → PATCH (0.0.x)
            └─ NO → NO BUMP
```

---

## 🎯 **Best Practices**

### **DO:**
✅ Write clear, descriptive commit messages  
✅ Use conventional commit format consistently  
✅ Add breaking change notes when needed  
✅ Review version changes before merging  
✅ Keep commits atomic and focused  

### **DON'T:**
❌ Commit without conventional format  
❌ Mix multiple changes in one commit  
❌ Manually edit version in pubspec.yaml  
❌ Skip commit message body for complex changes  
❌ Forget to document breaking changes  

---

## 🛠️ **Setup Checklist**

- [ ] GitHub Actions workflow created (`.github/workflows/version-and-release.yml`)
- [ ] Melos configured with version commands
- [ ] Conventional commits enforced (commitlint)
- [ ] Team trained on commit message format
- [ ] Branch protection enabled on `main`
- [ ] Release notes template created

---

## 📝 **Commit Message Examples**

### **Good Examples:**

```bash
# New feature (minor bump)
feat: add user authentication

# Bug fix (patch bump)
fix: resolve memory leak in image cache

# Performance improvement (patch bump)
perf: optimize database queries

# Breaking change (major bump)
feat!: redesign API endpoints

BREAKING CHANGE: All API endpoints now require authentication.
Migration guide: docs/migration.md

# Multiple types in one PR (use highest priority)
feat: add export feature
fix: resolve CSV parsing bug
# → Results in minor bump (feat takes priority)
```

### **Bad Examples:**

```bash
# Too vague
update stuff

# No type
added dark mode

# Wrong format
Feature: dark mode

# Multiple unrelated changes (should be separate commits)
feat: add auth and fix bug and update docs
```

---

## 🔄 **Rollback Process**

If a release needs to be rolled back:

```bash
# 1. Identify the problematic version
git tag  # List all tags

# 2. Revert the version bump commit
git revert <commit-hash>

# 3. Delete the tag locally and remotely
git tag -d xdoc-v1.1.0
git push origin :refs/tags/xdoc-v1.1.0

# 4. Delete GitHub Release
# Go to Releases → Select release → Delete

# 5. Create a fix
git checkout -b fix/critical-bug
# ... fix the issue ...
git commit -m "fix: critical bug in v1.1.0"

# 6. Push and let CI create new patch release
git push origin main
# CI will create v1.1.1 automatically
```

---

## 📚 **Additional Resources**

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Melos Documentation](https://melos.invertase.dev/)

---

## 🔍 **Monitoring & Verification**

### **Verify version was bumped:**
```bash
# Check latest tag
git describe --tags --abbrev=0

# Check current version in pubspec
grep "version:" apps/xdoc/pubspec.yaml

# View recent releases
gh release list
```

### **Check GitHub Actions status:**
```bash
# Using GitHub CLI
gh run list --workflow=version-and-release.yml

# Or visit: https://github.com/your-org/your-repo/actions
```

---

*Last Updated: December 4, 2024*

