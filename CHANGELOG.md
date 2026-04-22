# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-21

### Added
- Register incidents with title, description, tags and automatic timestamp
- Track incident status — Open, In Progress, Resolved
- Severity levels: P1 (Critical), P2 (High), P3 (Medium), P4 (Low)
- Timeline view showing exact open and resolution times
- Automatic resolution time calculation and display
- Dashboard with two Swift Charts:
  - Average resolution time per tag
  - Incident count per tag
- Filter and search by tag, status or keyword
- Export incidents as CSV or PDF with native share sheet
- Full offline support with SwiftData persistence
- MVVM architecture for clean code organization
- SwiftUI for modern, native UI
- Support for iOS 17+
