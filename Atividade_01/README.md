# Atividade 1 – Coleta e Visualização de Localizações
**Programação para Dispositivos Móveis I – Prof. Arley**
**Fatec**

---

## 👤 Integrante
* **Nome:** Nicolas Kauê Silva

---

## 📱 Sobre o Aplicativo
Aplicativo desenvolvido em **Flutter** para coleta contínua da localização do dispositivo, armazenamento local em banco **SQLite** e visualização em **lista** e em **mapa interativo** com suporte a cache local.

### Principais Funcionalidades:
1. **Gerenciamento de Permissões e GPS**:
   - Verificação de status do serviço de localização (GPS).
   - Solicitação amigável de permissões em tempo de execução com diálogo explicativo e atalho direto para as configurações do sistema caso bloqueado.
2. **Coleta Contínua via Streams**:
   - Utilização de `Stream<Position>` de alta precisão com intervalo solicitado de 20 segundos.
   - Execução em primeiro plano (*Android Foreground Service*) mantendo notificação visível no sistema, permitindo que a coleta continue mesmo com o app minimizado ou navegando entre telas.
   - Prevenção de assinaturas duplicadas e gravações concorrentes sobrepostas.
3. **Persistência Local (SQLite)**:
   - Banco `localizacoes.db` com tabela `localizacoes` tipada (`id`, `latitude`, `longitude`, `precisao`, `instante`).
   - Instante gravado estritamente em **UTC** no formato **ISO 8601** e convertido para o fuso horário local na exibição.
   - Limpeza total com diálogo de confirmação (`Cancelar` e `Limpar histórico`), alertando que se a coleta estiver ativa novos registros continuarão sendo salvos.
4. **Visualização em Lista (Histórico)**:
   - Apresenta as últimas 100 posições salvas da mais recente para a mais antiga.
   - Latitude e longitude formatadas com 6 casas decimais e precisão estimada com 1 casa decimal em metros.
   - Botão para recarregar registros sem interromper a coleta.
5. **Visualização em Mapa Interativo**:
   - Renderização da camada de ruas (OpenStreetMap) através do `flutter_map`.
   - **Cache local**: Armazenamento dos tiles em pasta privada da aplicação (`cache_mapa.dart`), otimizando requisições e respeitando as regras do provedor.
   - Marcador da localização mais recente destacado em **vermelho**.
   - Botão de auto-enquadramento (`fitCamera`) abrangendo todas as posições salvas.
   - Toque em qualquer marcador abre os detalhes com o widget reutilizável `ItemLocalizacao`.
6. **Identidade Visual**:
   - Ícone personalizado temático configurado nas densidades `drawable-nodpi`, `mipmap-*` e arquivo XML de ícone adaptativo.

---

## 📂 Arquitetura e Estrutura do Projeto

O projeto foi estruturado rigorosamente conforme especificado pelo professor:

```text
├── assets/
│   └── icons/
│       └── localizacoes.png           # Imagem original do ícone
├── android/app/src/main/
│   ├── AndroidManifest.xml           # Permissões, service e referências de ícone
│   └── res/
│       ├── drawable-nodpi/icone_localizacoes.png
│       ├── mipmap-*/ic_localizacoes.png
│       ├── mipmap-anydpi-v26/ic_localizacoes.xml
│       └── values/icone_localizacoes.xml
└── lib/
    ├── main.dart                      # Inicialização do Flutter e runApp
    ├── app.dart                       # Configuração do MaterialApp e tema
    └── features/
        └── localizacoes/
            ├── models/
            │   └── localizacao.dart   # Modelo de dados e conversão Map/UTC
            ├── data/
            │   ├── database/
            │   │   └── banco_localizacoes.dart        # Conexão e criação SQLite
            │   └── repositories/
            │       └── repositorio_localizacoes.dart  # CRUD e queries (limite 100)
            ├── services/
            │   ├── servico_localizacao.dart           # GPS, permissões e Stream
            │   └── cache_mapa.dart                    # Cache de tiles em pasta privada
            ├── presentation/
            │   ├── screens/
            │   │   ├── tela_coleta.dart               # Tela inicial de controle
            │   │   ├── tela_localizacoes.dart         # Tela de histórico de dados
            │   │   └── tela_mapa.dart                 # Tela de mapa interativo
            │   └── widgets/
            │       ├── item_localizacao.dart          # Card reutilizável de dados
            │       └── mapa_localizacoes.dart         # Mapa e marcadores com destaque
```

---

## 🚀 Como Executar o Projeto

1. Certifique-se de ter o Flutter instalado e configurado (`flutter doctor`).
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute a suíte de testes automatizados:
   ```bash
   flutter test
   ```
4. Conecte um emulador Android ou aparelho físico e execute:
   ```bash
   flutter run
   ```
