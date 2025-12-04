# Changelog

All notable changes to XDoc will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- MTDS (Multi-Tenant Data Sync) integration
- Drift ORM for type-safe database operations
- Cross-platform support (Android, iOS, Linux, Windows, macOS)
- Automated semantic versioning with Melos

### Changed
- Migrated from sqflite to Drift ORM
- Replaced tenant_replication with mtds_dart package
- Updated database schema with MTDS columns

### Fixed
- Android MainActivity.kt missing file issue
- Linux WindowListener implementation
- Platform-specific authentication handling

## [1.0.0+8] - 2024-12-04

### Initial Release
- Document management system
- Multi-channel communication
- XDoc workflow management
- SSO authentication

