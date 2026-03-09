# Incident Log 🛡️

> iOS app to track, manage and analyze incidents — built with SwiftUI and SwiftData.

![Swift](https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0D96F6?style=for-the-badge&logo=swift&logoColor=white)
![SwiftData](https://img.shields.io/badge/SwiftData-F05138?style=for-the-badge&logo=apple&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17+-000000?style=for-the-badge&logo=apple&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&color=F05138&center=true&width=435&lines=Open+incidents+in+seconds;Track+every+update+in+real+time;Export+postmortems+as+Markdown" alt="Typing SVG" />
</p>

---

## 📱 About

**Incident Log** is a native iOS app for support analysts and developers who need to register, track and document incidents with precision.

Open an incident, add timeline updates as the situation evolves, fill in the postmortem — and export a structured Markdown report when it's done.

Born from a real need — built by someone who lived this pain daily as a Senior Support Analyst.

---

## ✨ Features

- **Open incidents** with title, description, affected teams and tags
- **Automatic timeline** — starts at the moment of opening, updated with each new entry
- **Add updates** to the timeline with automatic timestamp as the incident evolves
- **Status tracking** — Open → In Progress (on first update) → Resolved
- **Postmortem built-in** — root cause, lessons learned and action plan filled gradually
- **Close flow with validation** — the app requires a complete postmortem before closing
- **Action plan** with short and long term actions, responsible and deadline
- **Export postmortem as Markdown** — structured `.md` file ready to share or store
- **Dashboard** with two Swift Charts:
  - Average resolution time per tag
  - Incident count per tag
- **Filter and search** by tag, status or keyword
- **Full offline support** — all data stored locally with SwiftData

---

## 🔄 Incident Lifecycle

```
Open          →        In Progress       →       Resolved
(creation)         (first update added)      (postmortem complete)
    │                      │                        │
Timeline          Timeline updates            Markdown export
auto-starts       with timestamps             available
```

---

## 🛠 Tech Stack

| Technology | Usage |
|---|---|
| SwiftUI | All screens and UI components |
| SwiftData | Local persistence with relationships |
| Swift Charts | Dashboard graphs |
| ShareLink + PDFKit | Postmortem export |
| MVVM | Architecture pattern |

---

## 📋 Requirements

- Xcode 15.0+
- iOS 17.0+
- macOS Ventura or later (to run Xcode)

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone git@github.com:ecanalle/incident-log.git
cd incident-log
```

### 2. Open in Xcode

```bash
open "Incident Log.xcodeproj"
```

### 3. Run the app

- Select a simulator (iPhone 15 recommended) or your physical device
- Press `⌘ + R` to build and run

No external dependencies or package installation needed. ✅

---

## 📁 Project Structure

```
Incident Log App/
├── App/
│   ├── IncidentLogApp.swift        # Entry point, ModelContainer setup
│   └── ContentView.swift           # Root TabView
├── Models/
│   └── Incident.swift              # Incident, TimelineUpdate, ActionItem models
├── ViewModels/
│   └── IncidentViewModel.swift     # @Observable, filters, CRUD, close validation
├── Views/
│   ├── Home/                       # Incident list with search and tag filters
│   ├── NewIncident/                # Opening form — title, teams, tags, severity
│   ├── Detail/                     # Timeline, postmortem fields, close flow
│   ├── Dashboard/                  # Swift Charts metrics
│   └── Export/                     # CSV/PDF export and ShareSheet
└── Utilities/
    ├── PreviewData.swift            # In-memory sample data for Xcode Previews
    └── PostmortemExporter.swift     # Markdown postmortem generator
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

1. Fork the project
2. Create your feature branch (`git checkout -b feat/your-feature`)
3. Commit your changes (`git commit -m 'feat: add your feature'`)
4. Push to the branch (`git push origin feat/your-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ and Swift 🦅</p>
