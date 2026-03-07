import SwiftData
import Foundation

// MARK: - Preview Container

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Incident.self, configurations: config)

    // Sample incidents
    let samples: [(String, String, Severity, [String], Bool)] = [
        ("API de pagamento fora do ar",   "Clientes não conseguem finalizar compras.",  .p1, ["api", "pagamento"],      true),
        ("Lentidão no dashboard admin",   "Carregamento acima de 10s em produção.",      .p2, ["performance", "admin"],  false),
        ("Erro 500 ao exportar relatório","Ocorre apenas com +1000 linhas.",             .p3, ["export", "relatório"],   false),
        ("Push notifications atrasando",  "Delay de até 30min observado.",               .p3, ["push", "notificação"],   false),
        ("Falha no login SSO",            "Afeta apenas usuários do domínio corp.",      .p2, ["auth", "sso"],           true),
    ]

    for (title, body, sev, tags, resolved) in samples {
        let i = Incident(title: title, body: body, severity: sev, tags: tags)
        if resolved {
            i.resolvedAt = Date().addingTimeInterval(-Double.random(in: 300...7200))
            i.status = .resolved
        }
        container.mainContext.insert(i)
    }

    return container
}()
