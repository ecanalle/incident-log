# IncidentLog 🛡️

App iOS para registro e acompanhamento de incidentes — primeiro app de portfólio.

## Stack

- **SwiftUI** — todas as telas
- **SwiftData** — persistência local
- **Swift Charts** — gráficos no Dashboard
- **PDFKit** — exportação em PDF

## Estrutura

```
IncidentLog/
├── App/
│   ├── IncidentLogApp.swift      # entry point, ModelContainer
│   └── ContentView.swift         # TabView raiz
│
├── Models/
│   └── Incident.swift            # @Model, Severity, IncidentStatus
│
├── ViewModels/
│   └── IncidentViewModel.swift   # @Observable, filtros, CRUD, form state
│
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift        # lista + filtros + search
│   │   └── IncidentRowView.swift # célula da lista
│   ├── NewIncident/
│   │   └── NewIncidentView.swift # sheet de criação
│   ├── Detail/
│   │   ├── IncidentDetailView.swift  # detalhe + timeline + ações
│   │   └── EditIncidentView.swift    # sheet de edição
│   ├── Dashboard/
│   │   └── DashboardView.swift   # cards + Swift Charts
│   └── Export/
│       └── ExportView.swift      # CSV + PDF + ShareSheet
│
└── Utilities/
    └── PreviewData.swift         # container in-memory p/ Previews
```

## Como abrir no Xcode

1. Crie um novo projeto Xcode → **App** → SwiftUI + SwiftData
2. Copie os arquivos acima para as pastas correspondentes
3. Delete o `Item.swift` gerado pelo template
4. Build & Run ✅

## Próximos passos sugeridos

- [ ] Filtro por período (semana, mês)
- [ ] Notificações locais para incidentes abertos há muito tempo
- [ ] Sincronização via CloudKit
- [ ] Widget de incidentes abertos na home screen
- [ ] Testes com Swift Testing
