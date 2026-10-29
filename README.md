<div align="center">

# 🏋️ ExercisesPackage

**Conta repetições de exercício pelos sensores do Apple Watch ou do iPhone.**

Swift Package que transforma os dados do acelerômetro e do giroscópio (`CMMotionManager`) em
repetições de flexão, abdominal e agachamento, com uma API reativa pronta para SwiftUI.

![Swift](https://img.shields.io/badge/Swift-6.2-F05138?logo=swift&logoColor=white)
![SPM](https://img.shields.io/badge/SPM-1.0.0-F05138?logo=swift&logoColor=white)
![Plataformas](https://img.shields.io/badge/iOS%2016%20%C2%B7%20watchOS%209%20%C2%B7%20macOS%2013-000000?logo=apple&logoColor=white)
![Core Motion](https://img.shields.io/badge/Core%20Motion-000000?logo=apple&logoColor=white)
![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-green)

</div>

> [!NOTE]
> Em uso no [**WatchSport**](https://github.com/daniellealpimenta/WatchSport), app de missões
> diárias de treino para Apple Watch.

---

## ✨ Exercícios suportados

| Exercício | Como a repetição é detectada |
|---|---|
| 🤸 **Flexão** (`.pushUp`) | Variação de *pitch* na atitude do aparelho, com *debounce* de 0,8 s para validar subida e descida completas |
| 🧘 **Abdominal** (`.sitUp`) | Vetor de gravidade mede a inclinação do tronco: 45° na subida e 20° na descida |
| 🦵 **Agachamento** (`.squat`) | Aceleração vertical contra a gravidade, com limites (*thresholds*) para subida e descida |
| 💪 **Barra** (`.pullUp`) | Manual (`increment()` / `decrement()`): o pulso não dá sinal confiável nesse movimento |

## 📦 Instalação

No Xcode: *File → Add Package Dependencies…* e cole a URL do repositório. Ou no `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/daniellealpimenta/ExercisesPackage.git", from: "1.0.0")
]
```

> [!IMPORTANT]
> Adicione `NSMotionUsageDescription` ao `Info.plist` do app, explicando por que ele usa os
> sensores de movimento.

## 💻 Como usar

O pacote foi desenhado para ser integrado de forma transparente com **SwiftUI** e **Combine**. O ponto de acesso principal é o `ExerciseTracker`, que já adota o protocolo `@ObservableObject`.

### 1. Inicializando o Rastreador

Em qualquer `View`, instancie o tracker indicando o tipo de exercício que deseja monitorar.

```swift
import SwiftUI
import ExercisesPackage

struct ContentView: View {
    // Instancia o Tracker para rastrear Agachamentos (Squat)
    @StateObject private var tracker = ExerciseTracker(type: .squat)
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Repetições")
                .font(.headline)
            
            // Variável atualizada reativamente
            Text("\(tracker.count)")
                .font(.system(size: 60, weight: .bold))
            
            // Métrica atual detalhada (Ex: velocidade, ângulo)
            Text("Métrica Atual: \(String(format: "%.2f", tracker.currentMetric))")
                .foregroundColor(.secondary)
            
            HStack {
                Button(action: { tracker.start() }) {
                    Text("Começar")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { tracker.stop() }) {
                    Text("Parar")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
    }
}
```

### 2. Trocando de Exercício Dinamicamente

Você pode alterar o tipo de exercício em tempo de execução usando o método `switchExercise(to:)`. A contagem e os sensores serão resetados automaticamente.

```swift
Button("Trocar para Abdominal") {
    tracker.switchExercise(to: .sitUp)
}
```

### 3. Usando Exercícios Manuais (Ex: Barra)

Algumas modalidades como a **Barra (`.pullUp`)** exigem interação manual devido à limitação dos sensores no pulso para este movimento. Para este tipo específico, use os métodos manuais:

```swift
// Incrementa ou decrementa a contagem de barras manualmente
Button("Fiz mais uma barra!") {
    tracker.increment() 
}

Button("Remover barra acidental") {
    tracker.decrement()
}
```

---

## 🧱 Arquitetura

**Strategy** para cada exercício, criado por uma **Factory**:

```
ExerciseTracker (ObservableObject)        ← a View observa count / currentMetric / isRecording
   │ usa
   ▼
ExerciseStrategy (protocolo)              ← start(), stop(), callbacks de repetição
   ├── PushUpStrategy   ┐
   ├── SitUpStrategy    │ cada uma lê o CMMotionManager e só avisa
   ├── SquatStrategy    │ o tracker (na main thread) quando a repetição fecha
   └── PullUpStrategy   ┘
ExerciseFactory                           ← ExerciseType → estratégia concreta
```

```
Sources/ExercisesPackage/
├── Core/         ExerciseTracker, ExerciseStrategy, ExerciseType
├── Strategies/   PushUp, SitUp, Squat, PullUp
└── Factory/      ExerciseFactory
```

Adicionar um exercício novo = um `case` em `ExerciseType`, uma estratégia nova e uma linha na
fábrica. Nada no tracker nem nas Views muda.

## 🗺️ Roadmap

- [x] Flexão, abdominal, agachamento e barra manual
- [x] Versão 1.0.0 publicada e usada no WatchSport
- [ ] Testes de unidade das estratégias com amostras de movimento gravadas
- [ ] Calibração por usuário (limites ajustáveis)
- [ ] Novos exercícios: polichinelo e burpee

## 📝 Licença

MIT. Veja [`LICENSE`](LICENSE). Contribuições com novos exercícios são bem-vindas!
