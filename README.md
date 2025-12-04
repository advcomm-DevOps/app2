# XDoc Workspace

A Melos monorepo workspace containing the XDoc Flutter application and the MTDS (Multi-Tenant Data Synchronization) package.

## 📁 Workspace Structure

```
app2/
├── apps/
│   └── xdoc/              # XDoc Flutter application
├── packages/
│   └── mtds/              # MTDS SDK package (git submodule)
├── pubspec.yaml           # Workspace configuration
├── melos.yaml             # Melos configuration
└── .gitmodules            # Git submodules configuration
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (>=3.7.0)
- Dart SDK (>=3.9.2)
- Git
- Melos (installed globally)

### Initial Setup

1. **Install Melos globally** (if not already installed):

   ```bash
   dart pub global activate melos
   ```

2. **Clone the repository** (if not already cloned):

   ```bash
   git clone <repository-url>
   cd app2
   ```

3. **Initialize and update git submodules**:

   ```bash
   git submodule update --init --recursive
   ```

4. **Bootstrap the workspace**:

   ```bash
   melos bootstrap
   ```

   This will:

   - Install all package dependencies
   - Set up workspace resolution
   - Link packages together

## 📦 Packages

### `apps/xdoc`

The main XDoc Flutter application. This is a Document Management System with:

- Multi-tenant support
- Real-time synchronization
- Cross-platform support (Windows, macOS, Linux, iOS, Android, Web)

### `packages/mtds`

The MTDS (Multi-Tenant Data Synchronization) SDK package. This package provides:

- Offline-first data synchronization
- Real-time sync via Server-Sent Events (SSE)
- Hybrid timestamps (client + server)
- Automatic change tracking

**Note:** This package is managed as a git submodule pointing to:

- Repository: `https://github.com/canonicalapp/mtds_dart.git`
- During development: Uses local `packages/mtds` via workspace resolution
- When publishing: Will fetch from GitHub automatically

## 🛠️ Development Workflow

### Common Melos Commands

```bash
# Get dependencies for all packages
melos get

# Run tests in all packages
melos test

# Clean all build artifacts
melos clean

# Run dart analyze in all packages
melos analyze

# Format code in all packages
melos format

# Run build_runner for mtds package
melos build_runner

# Run build_runner in watch mode
melos build_runner_watch
```

### Working with the XDoc App

```bash
# Navigate to app directory
cd apps/xdoc

# Run the app
flutter run

# Run tests
flutter test

# Build for specific platform
flutter build windows
flutter build macos
flutter build linux
flutter build web
```

### Working with MTDS Package

```bash
# Navigate to package directory
cd packages/mtds

# Run build_runner (if needed)
dart run build_runner build --delete-conflicting-outputs

# Run package tests
flutter test
```

## 🔄 Git Submodules

The `packages/mtds` directory is a git submodule. This ensures everyone uses the same version of the MTDS package.

### Updating the Submodule

To update to the latest version:

```bash
cd packages/mtds
git pull origin main  # or specific branch/tag
cd ../..
git add packages/mtds
git commit -m "Update mtds submodule to latest version"
```

### Switching to a Specific Version/Tag

```bash
cd packages/mtds
git checkout v0.0.6  # or specific commit hash
cd ../..
git add packages/mtds
git commit -m "Pin mtds submodule to v0.0.6"
```

### For New Team Members

After cloning the repository, initialize submodules:

```bash
git submodule update --init --recursive
```

## 📝 Workspace Resolution

This workspace uses **Pub Workspaces** for dependency management:

- Both `apps/xdoc` and `packages/mtds` have `resolution: workspace` in their `pubspec.yaml`
- The workspace automatically resolves dependencies between packages
- No need for explicit path dependencies or `pubspec_overrides.yaml`
- During development, `xdoc` automatically uses the local `mtds` package

## 🏗️ Building and Publishing

### Building the XDoc App

```bash
cd apps/xdoc

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux

# Web
flutter build web

# Android
flutter build apk

# iOS
flutter build ios
```

### Publishing Considerations

When publishing the `xdoc` app (outside this workspace), you'll need to:

1. **Uncomment the mtds dependency** in `apps/xdoc/pubspec.yaml`:

   ```yaml
   dependencies:
     mtds:
       git:
         url: https://github.com/canonicalapp/mtds_dart.git
         ref: main # or specific tag like 'v0.0.6'
   ```

2. **Remove `resolution: workspace`** from `apps/xdoc/pubspec.yaml` (if publishing standalone)

3. **Ensure all dependencies are properly declared**

## 🔧 Troubleshooting

### Issue: "Cannot override workspace packages"

**Solution:** Remove any `pubspec_overrides.yaml` files. Workspace resolution handles dependencies automatically.

### Issue: "Submodule not found"

**Solution:** Initialize submodules:

```bash
git submodule update --init --recursive
```

### Issue: "Melos workspace not detected"

**Solution:** Ensure you're in the workspace root (`app2/`) and that `melos.yaml` exists.

### Issue: "Package dependencies conflict"

**Solution:** Clean and re-bootstrap:

```bash
melos clean
rm -rf .dart_tool apps/*/.dart_tool packages/*/.dart_tool
melos bootstrap
```

## 📚 Additional Resources

- [Melos Documentation](https://melos.invertase.dev/)
- [Pub Workspaces Guide](https://dart.dev/go/pub-workspaces)
- [MTDS Package Repository](https://github.com/canonicalapp/mtds_dart)
- [Flutter Documentation](https://docs.flutter.dev/)

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Ensure `melos bootstrap` runs successfully
4. Run `melos test` and `melos analyze`
5. Submit a pull request

## 📄 License

[Add your license information here]

---

**Last Updated:** December 2024
