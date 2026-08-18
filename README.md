# 🏋️‍♀️ ExercisesPackage

Um Swift Package poderoso e flexível para rastrear e contabilizar exercícios físicos de forma autônoma utilizando os sensores de movimento (acelerômetro, giroscópio) do Apple Watch ou iPhone. Construído seguindo o **Padrão Strategy** e os princípios **SOLID**, este pacote encapsula a lógica pesada e heurística do `CMMotionManager`, oferecendo uma interface limpa e reativa para o desenvolvedor.

---

## 🚀 Funcionalidades

O `ExercisesPackage` abstrai a captura de movimentos de exercícios complexos, reconhecendo de forma nativa e matemática quando uma repetição foi concluída. Os seguintes exercícios são suportados:

- **💪 Barra (Pull-Up):** Modo de controle manual (incremento e decremento simples).
- **🧘‍♀️ Abdominal (Sit-Up):** Usa o vetor de gravidade para analisar a inclinação do tronco, validando rotações (45° de subida e 20° de descida).
- **🦵 Agachamento (Squat):** Calcula a aceleração vertical contra a gravidade para deduzir a velocidade de impacto na subida e descida, através de limites (*thresholds*) dinâmicos.
- **🤸‍♀️ Flexão (Push-Up):** Monitora as variações de _Pitch_ no _Attitude_ do dispositivo, aplicando filtro *debounce* (0.8s) para validar subidas e descidas completas do corpo.

---

## 🛠 Instalação

Adicione o pacote ao seu projeto Xcode ou através do `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SEU_USUARIO/ExercisesPackage.git", from: "1.0.0")
]
```
> **Nota:** Certifique-se de adicionar as chaves e permissões de privacidade no arquivo `Info.plist` do seu projeto para acessar os sensores de movimento (como `NSMotionUsageDescription`).

---

## 💻 Como Usar

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

## 🏛 Arquitetura (Under the Hood)

O pacote utiliza o **Strategy Pattern** gerenciado por um **Factory Pattern**:
- **`ExerciseTracker`**: (O Contexto). Ele mantém a referência para uma estratégia em tempo real e cuida da atualização reativa para a interface (`@Published`).
- **`ExerciseStrategy`**: O protocolo base. Ele obriga que todos os exercícios possuam callbacks e as variáveis principais (`count`, `currentMetric`, `isRecording`).
- **`SitUpStrategy` / `SquatStrategy` / `PushUpStrategy` / `PullUpStrategy`**: As estratégias concretas. Elas instanciam e processam o `CMMotionManager` e avisam o tracker (Main Thread) apenas quando a repetição é computada com sucesso.

---

## 📝 Licença
Este projeto está sob licença MIT. Sinta-se livre para modificar e contribuir com novos exercícios!