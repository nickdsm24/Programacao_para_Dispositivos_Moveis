# Programação para Dispositivos Móveis I

Repositório com os projetos práticos desenvolvidos em **Flutter** para a disciplina **Programação para Dispositivos Móveis I** (Fatec — Prof. Arley).

- **Aluno:** Nicolas Kauê Silva

---

## Estrutura do Repositório

Este repositório está organizado em **duas atividades independentes**, cada uma em seu próprio diretório com código-fonte, dependências e documentação específicos:

| Pasta | Atividade | Descrição | Documentação |
| :--- | :--- | :--- | :--- |
| [`Atividade_01/`](./Atividade_01) | **Coleta e Visualização de Localizações** | Aplicativo Flutter para coleta contínua da localização via GPS (`Stream<Position>` / *Foreground Service*), armazenamento local em **SQLite** e visualização em lista e mapa interativo. | [Ver README da Atividade 1](./Atividade_01/README.md) |
| [`Atividade_02/`](./Atividade_02) | **Previsão do Tempo — CPTEC/INPE** | Aplicativo Flutter que consome o serviço público em **XML** do CPTEC/INPE para pesquisa de cidades brasileiras, previsão de 4 dias, gráfico de temperaturas (`fl_chart`) e cache local com `SharedPreferences`. | [Ver README da Atividade 2](./Atividade_02/README.md) |

---

## Como Executar

1. Clone o repositório:
   ```bash
   git clone <URL_DO_REPOSITORIO>
   ```
2. Acesse a pasta da atividade desejada (`Atividade_01` ou `Atividade_02`):
   ```bash
   cd Atividade_02
   ```
3. Instale as dependências e execute o aplicativo:
   ```bash
   flutter pub get
   flutter run
   ```

> Consulte o `README.md` interno de cada atividade para detalhes de configuração, permissões, bibliotecas e capturas de tela.
