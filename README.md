# Projeto de Integração — Satisfação do Passageiro em Aeroportos

Projeto de integração de dados desenvolvido com as bases da **Pesquisa de Satisfação do Passageiro em Aeroportos**, referentes ao primeiro trimestre de **2024, 2025 e 2026**.

O projeto integra as três bases anuais, realiza limpeza e padronização dos dados, cria um **Data Warehouse em Esquema Estrela** e implementa dois processos completos de integração: **ETL** e **ELT**.

## Equipe 7

- **Abhner Adriel Cristóvão Silva** — aacs2@cin.ufpe.br
- **Reilson Batista da Fonseca** — rbf5@cin.ufpe.br

**Projeto da disciplina de Banco de Dados — 2026.1**

---

## Sumário

1. [Tema e objetivo](#tema-e-objetivo)
2. [Conceitos principais](#conceitos-principais)
3. [Tecnologias utilizadas](#tecnologias-utilizadas)
4. [Estrutura do repositório](#estrutura-do-repositório)
5. [Pré-requisitos](#pré-requisitos)
6. [Execução rápida](#execução-rápida)
7. [Tutorial completo para rodar localmente](#tutorial-completo-para-rodar-localmente)
8. [Execução individual dos processos](#execução-individual-dos-processos)
9. [Resultados gerados](#resultados-gerados)
10. [Modelo dimensional](#modelo-dimensional)
11. [Como fazer consultas SQL](#como-fazer-consultas-sql)
12. [Como usar o Google Colab](#como-usar-o-google-colab)
13. [Como executar os testes](#como-executar-os-testes)
14. [Relatórios DOCX e PDF](#relatórios-docx-e-pdf)
15. [Problemas comuns](#problemas-comuns)

---

## Tema e objetivo

### Tema escolhido

**Indicadores que avaliam a satisfação do passageiro com os processos e serviços aeroportuários a ele oferecidos, coletados nos 20 aeroportos principais durante a pesquisa.**

### Objetivo geral

O objetivo é integrar as bases de 2024, 2025 e 2026 em uma estrutura única e adequada para análise. O resultado é um Data Warehouse que permite responder perguntas como:

- A satisfação dos passageiros aumentou ou diminuiu ao longo dos anos?
- Quais aeroportos apresentam as maiores e menores médias?
- Quais serviços aeroportuários são mais bem ou mais mal avaliados?
- Existem diferenças entre voos domésticos e internacionais?
- Existem diferenças entre os processos de embarque e desembarque?

---

## Conceitos principais

### Data Warehouse

Um **Data Warehouse** é um banco de dados voltado para consultas analíticas. Em vez de apenas armazenar registros operacionais, ele organiza os dados para facilitar comparações, agrupamentos, indicadores e geração de insights.

### Esquema Estrela

O projeto utiliza **Esquema Estrela**, uma modelagem formada por:

- **Tabelas fato**, que armazenam os acontecimentos e medidas analisadas;
- **Tabelas dimensão**, que armazenam informações descritivas usadas para contextualizar esses fatos.

### ETL

ETL significa:

```text
Extract → Transform → Load
Extrair → Transformar → Carregar
```

No pipeline ETL deste projeto, as planilhas são lidas, tratadas com Python e Pandas e, somente depois, carregadas no banco SQLite.

### ELT

ELT significa:

```text
Extract → Load → Transform
Extrair → Carregar → Transformar
```

No pipeline ELT, os dados são primeiro carregados em uma tabela de staging no SQLite. Depois, as transformações são executadas dentro do banco por meio de SQL.

---

## Tecnologias utilizadas

- **Python** — linguagem principal;
- **Pandas** — leitura, limpeza e transformação dos dados;
- **OpenPyXL** — leitura dos arquivos XLSX;
- **SQLite** — banco de dados final;
- **SQL** — criação do modelo ELT e consultas analíticas;
- **Matplotlib** — geração dos gráficos;
- **Google Colab/Jupyter Notebook** — execução dos notebooks;
- **python-docx** — suporte à criação e manipulação de documentos DOCX;
- **nbformat** — suporte aos notebooks;
- **Git e GitHub** — versionamento e publicação do projeto.

O SQLite foi escolhido por ser simples, portátil e não exigir a instalação de um servidor. Cada banco fica armazenado em um único arquivo `.sqlite`.

---

## Estrutura do repositório

```text
.
├── data/
│   ├── raw/                         # planilhas XLSX originais
│   ├── processed/
│   │   ├── etl/                     # CSVs gerados pelo pipeline ETL
│   │   └── elt/                     # CSVs gerados pelo pipeline ELT
│   └── warehouse/                   # bancos SQLite finais
├── docs/
│   ├── imagens/                     # gráficos e diagramas
│   ├── metodologia_sources/         # metodologia e dicionário originais
│   ├── tabelas/                     # resultados das consultas analíticas
│   ├── dicionario_dw.md
│   ├── esquema_estrela.md
│   ├── fluxo_integracao.md
│   ├── relatorio_projeto.md
│   ├── Relatorio_Projeto_Integracao_Aeroportos.docx
│   └── Relatorio_Projeto_Integracao_Aeroportos.pdf
├── notebooks/
│   ├── 01_pipeline_etl.ipynb
│   └── 02_pipeline_elt.ipynb
├── scripts/
│   ├── run_all.py
│   ├── generate_analysis_outputs.py
│   └── executar_consulta.py          # consulta SQL de exemplo em Python
├── sql/
│   ├── create_schema.sql
│   ├── elt_transformations.sql
│   └── consultas_analiticas.sql
├── src/
│   ├── etl/
│   │   ├── extract.py
│   │   ├── transform.py
│   │   ├── load.py
│   │   └── run_etl.py
│   ├── elt/
│   │   └── run_elt.py
│   ├── quality/
│   │   └── validate_outputs.py
│   ├── config.py
│   ├── metadata.py
│   └── utils.py
├── tests/
│   └── test_metadata.py
├── requirements.txt
├── .gitignore
└── README.md
```

> Caso o arquivo `scripts/executar_consulta.py` ainda não tenha sido criado na sua cópia do projeto, a seção de consultas deste README também apresenta outras formas de consultar o banco.

---

## Pré-requisitos

Antes de executar o projeto, verifique se estão instalados:

- Python;
- `pip`;
- Git, caso o repositório seja clonado do GitHub;
- VS Code ou outro editor, opcional;
- DB Browser for SQLite, DBeaver ou SQLiteStudio, opcional para consultas visuais.

Para verificar o Python:

```bash
python --version
```

No Windows, também pode ser usado:

```bash
py --version
```

Para verificar o `pip`:

```bash
pip --version
```

---

## Execução rápida

Na raiz do repositório:

### Windows — PowerShell ou Prompt de Comando

```bash
python -m venv .venv
.venv\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
python scripts/run_all.py
```

Caso o comando `python` não funcione, substitua por `py`:

```bash
py -m venv .venv
.venv\Scripts\activate
py -m pip install --upgrade pip
py -m pip install -r requirements.txt
py scripts/run_all.py
```

### Linux ou macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
pip install -r requirements.txt
python3 scripts/run_all.py
```

---

## Tutorial completo para rodar localmente

### 1. Obtenha o projeto

Há duas possibilidades.

#### Clonar pelo GitHub

```bash
git clone URL_DO_REPOSITORIO
cd NOME_DA_PASTA_DO_REPOSITORIO
```

#### Usar um arquivo ZIP

Extraia o ZIP e abra a pasta principal no VS Code.

A raiz correta é aquela que contém:

```text
README.md
requirements.txt
data/
docs/
notebooks/
scripts/
sql/
src/
```

### 2. Abra o terminal na raiz do projeto

No VS Code:

```text
Terminal → New Terminal
```

No Windows, confirme a pasta atual:

```bash
dir
```

No Linux/macOS:

```bash
ls
```

### 3. Verifique as planilhas de entrada

A pasta `data/raw/` deve conter:

```text
pesquisa_satisfacao_1_tri_2024.xlsx
pesquisa_satisfacao_1_tri_2025.xlsx
pesquisa_satisfacao_1_tri_2026.xlsx
```

Esses arquivos são as fontes utilizadas pelos pipelines.

### 4. Crie o ambiente virtual

Windows:

```bash
python -m venv .venv
```

Linux/macOS:

```bash
python3 -m venv .venv
```

O ambiente virtual isola as bibliotecas do projeto das demais bibliotecas instaladas no computador.

### 5. Ative o ambiente virtual

Windows:

```bash
.venv\Scripts\activate
```

Linux/macOS:

```bash
source .venv/bin/activate
```

Após a ativação, o terminal normalmente passa a exibir `(.venv)` no início da linha.

### 6. Instale as dependências

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

As dependências declaradas são:

```text
pandas
openpyxl
matplotlib
python-docx
nbformat
```

### 7. Execute o projeto inteiro

```bash
python scripts/run_all.py
```

O script executa, nesta ordem:

1. `src/etl/run_etl.py`;
2. `src/elt/run_elt.py`;
3. `src/quality/validate_outputs.py`;
4. `scripts/generate_analysis_outputs.py`.

Durante a execução, o terminal mostra as etapas e a quantidade de linhas geradas.

> A execução pode levar algum tempo porque as três planilhas possuem dezenas de milhares de entrevistas e a tabela `fato_avaliacao` possui centenas de milhares de registros.

> Ao executar novamente os pipelines, os bancos SQLite anteriores são recriados. Portanto, alterações manuais feitas diretamente nesses bancos podem ser perdidas.

---

## Execução individual dos processos

### Executar somente o ETL

```bash
python src/etl/run_etl.py
```

Principais saídas:

```text
data/processed/etl/
data/warehouse/aeroportos_dw_etl.sqlite
```

O ETL:

1. lê os três arquivos XLSX;
2. cria o dicionário técnico das colunas;
3. limpa e padroniza os dados;
4. cria dimensões e fatos;
5. exporta as tabelas para CSV;
6. carrega o Data Warehouse no SQLite.

### Executar somente o ELT

```bash
python src/elt/run_elt.py
```

Principais saídas:

```text
data/processed/elt/
data/warehouse/aeroportos_dw_elt.sqlite
```

O ELT:

1. lê os arquivos XLSX;
2. carrega os dados em `stg_pesquisa_satisfacao`;
3. carrega as tabelas de referência;
4. executa `sql/elt_transformations.sql`;
5. cria dimensões e fatos dentro do SQLite;
6. exporta as tabelas finais para CSV.

### Validar ETL e ELT

```bash
python src/quality/validate_outputs.py
```

A validação compara as quantidades de registros das tabelas produzidas pelos dois pipelines.

O resultado também é salvo em:

```text
docs/tabelas/validacao_etl_vs_elt.csv
```

### Gerar novamente as análises e os gráficos

```bash
python scripts/generate_analysis_outputs.py
```

Esse comando consulta o banco ETL e gera:

```text
docs/tabelas/*.csv
docs/imagens/*.png
```

---

## Resultados gerados

### Bancos de dados

```text
data/warehouse/aeroportos_dw_etl.sqlite
data/warehouse/aeroportos_dw_elt.sqlite
```

### CSVs processados

```text
data/processed/etl/
data/processed/elt/
```

### Tabelas analíticas

```text
docs/tabelas/satisfacao_por_ano.csv
docs/tabelas/ranking_aeroportos_satisfacao.csv
docs/tabelas/indicadores_pontos_criticos.csv
docs/tabelas/comparativo_tipo_voo.csv
docs/tabelas/comparativo_processo.csv
docs/tabelas/validacao_etl_vs_elt.csv
```

### Gráficos

```text
docs/imagens/grafico_satisfacao_por_ano.png
docs/imagens/grafico_ranking_aeroportos.png
docs/imagens/grafico_indicadores_criticos.png
```

### Resumo validado do Data Warehouse

| Tabela | Quantidade de linhas |
|---|---:|
| `dim_tempo` | 271 |
| `dim_aeroporto` | 20 |
| `dim_cia_aerea` | 39 |
| `dim_operacao` | 77 |
| `dim_perfil_passageiro` | 15.382 |
| `dim_indicador` | 62 |
| `fato_entrevista` | 77.194 |
| `fato_avaliacao` | 533.891 |

Para verificar rapidamente as saídas no Windows:

```bash
dir data\warehouse
dir docs\tabelas
dir docs\imagens
```

No Linux/macOS:

```bash
ls data/warehouse
ls docs/tabelas
ls docs/imagens
```

---

## Modelo dimensional

O Data Warehouse possui duas tabelas fato.

### `fato_entrevista`

Grão: **uma linha para cada entrevista/respondente**.

Essa tabela contém referências para as dimensões e medidas gerais, como a satisfação geral.

### `fato_avaliacao`

Grão: **uma linha para cada indicador avaliado em uma entrevista**.

Essa tabela transforma os vários indicadores que originalmente estavam em colunas da planilha em registros organizados. Isso facilita a comparação entre indicadores.

### Dimensões

| Dimensão | Finalidade |
|---|---|
| `dim_tempo` | Datas, anos, meses, trimestres e dias da semana |
| `dim_aeroporto` | Código ICAO, nome, cidade, UF e região |
| `dim_cia_aerea` | Companhias aéreas encontradas nas pesquisas |
| `dim_operacao` | Processo, tipo de voo, conexão, check-in e terminal |
| `dim_perfil_passageiro` | Características declaradas pelos passageiros |
| `dim_indicador` | Metadados dos indicadores de satisfação |

A documentação complementar pode ser consultada em:

```text
docs/dicionario_dw.md
docs/esquema_estrela.md
docs/fluxo_integracao.md
```

---

## Como fazer consultas SQL

As consultas analíticas prontas estão em:

```text
sql/consultas_analiticas.sql
```

O banco mais indicado para consultas gerais é:

```text
data/warehouse/aeroportos_dw_etl.sqlite
```

O banco ELT possui o mesmo modelo final e também pode ser consultado.

### Opção 1 — DB Browser for SQLite

1. Instale e abra o **DB Browser for SQLite**;
2. Clique em **Open Database**;
3. Escolha `data/warehouse/aeroportos_dw_etl.sqlite`;
4. Abra a aba **Database Structure** para visualizar as tabelas;
5. Abra a aba **Execute SQL**;
6. Cole uma consulta;
7. Clique em executar.

Exemplo: satisfação por ano.

```sql
SELECT
    dt.ano,
    COUNT(*) AS total_entrevistas,
    ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN fe.satisfacao_geral >= 4 THEN 1
                ELSE 0
            END
        ),
        2
    ) AS percentual_avaliacoes_positivas
FROM fato_entrevista AS fe
JOIN dim_tempo AS dt
    ON dt.data_key = fe.data_key
GROUP BY dt.ano
ORDER BY dt.ano;
```

### Opção 2 — Script Python

Execute:

```bash
python scripts/executar_consulta.py
```

O script abre o banco SQLite, executa a consulta definida no arquivo e mostra o resultado no terminal.

Para mudar a consulta:

1. abra `scripts/executar_consulta.py`;
2. localize a variável que contém o SQL;
3. substitua a consulta;
4. salve o arquivo;
5. execute novamente.

### Opção 3 — Terminal do SQLite

Caso o programa `sqlite3` esteja instalado:

```bash
sqlite3 data/warehouse/aeroportos_dw_etl.sqlite
```

Dentro do SQLite:

```sql
.headers on
.mode column
.tables
```

Para ver a estrutura de uma tabela:

```sql
.schema fato_entrevista
```

Para executar as consultas do arquivo:

```sql
.read sql/consultas_analiticas.sql
```

Para sair:

```sql
.quit
```

### Consultas de exemplo

#### Quantidade de entrevistas

```sql
SELECT COUNT(*) AS total_entrevistas
FROM fato_entrevista;
```

#### Quantidade de avaliações

```sql
SELECT COUNT(*) AS total_avaliacoes
FROM fato_avaliacao;
```

#### Média de satisfação por aeroporto

```sql
SELECT
    da.codigo_icao,
    da.nome_aeroporto,
    da.uf,
    COUNT(*) AS total_entrevistas,
    ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao
FROM fato_entrevista AS fe
JOIN dim_aeroporto AS da
    ON da.aeroporto_key = fe.aeroporto_key
GROUP BY
    da.codigo_icao,
    da.nome_aeroporto,
    da.uf
ORDER BY media_satisfacao DESC;
```

#### Indicadores com as menores médias

```sql
SELECT
    di.codigo_indicador,
    di.campo_original AS indicador,
    di.categoria,
    COUNT(*) AS total_avaliacoes,
    ROUND(AVG(fa.nota), 3) AS media_nota
FROM fato_avaliacao AS fa
JOIN dim_indicador AS di
    ON di.indicador_key = fa.indicador_key
GROUP BY
    di.codigo_indicador,
    di.campo_original,
    di.categoria
HAVING COUNT(*) >= 500
ORDER BY media_nota ASC
LIMIT 15;
```

> Consultas `SELECT` apenas leem os dados. Comandos como `UPDATE`, `DELETE` e `DROP` alteram o banco e devem ser usados com cuidado.

---

## Como usar o Google Colab

Os notebooks são:

```text
notebooks/01_pipeline_etl.ipynb
notebooks/02_pipeline_elt.ipynb
```

### Forma recomendada

1. Suba o repositório para o GitHub;
2. Acesse o Google Colab;
3. Escolha a opção para abrir notebook pelo GitHub;
4. Informe o endereço do repositório;
5. Abra o notebook desejado;
6. Execute as células na ordem apresentada.

Também é possível enviar o notebook manualmente ao Colab, mas os demais arquivos do repositório precisam manter a mesma estrutura de pastas.

O notebook ETL executa:

```text
extração → transformação em Python → carga no SQLite
```

O notebook ELT executa:

```text
extração → carga em staging → transformação com SQL
```

---

## Como executar os testes

Os testes disponíveis verificam metadados importantes, como:

- quantidade esperada de aeroportos;
- unicidade das chaves dos indicadores;
- preenchimento dos nomes normalizados.

O `pytest` não está listado entre as dependências principais. Para executar os testes, instale-o:

```bash
pip install pytest
```

Depois:

```bash
python -m pytest
```

Para executar somente o arquivo existente:

```bash
python -m pytest tests/test_metadata.py
```

---

## Relatórios DOCX e PDF

Os arquivos:

```text
docs/Relatorio_Projeto_Integracao_Aeroportos.docx
docs/Relatorio_Projeto_Integracao_Aeroportos.pdf
```

foram preparados como documentos finais e incluídos no repositório.

---

## Problemas comuns

### `python` não é reconhecido

No Windows, tente:

```bash
py --version
py scripts/run_all.py
```

### Erro `ModuleNotFoundError`

Confirme se o ambiente virtual está ativo e reinstale as dependências:

```bash
.venv\Scripts\activate
pip install -r requirements.txt
```

### O PowerShell bloqueou a ativação do ambiente

Execute temporariamente:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Depois:

```powershell
.venv\Scripts\Activate.ps1
```

Outra opção é usar o Prompt de Comando do Windows.

### Arquivo XLSX não encontrado

Verifique se os três arquivos estão em `data/raw/` com os nomes esperados:

```text
pesquisa_satisfacao_1_tri_2024.xlsx
pesquisa_satisfacao_1_tri_2025.xlsx
pesquisa_satisfacao_1_tri_2026.xlsx
```

### Banco SQLite não encontrado

Execute primeiro:

```bash
python scripts/run_all.py
```

ou pelo menos:

```bash
python src/etl/run_etl.py
```

### `sqlite3` não é reconhecido

Use uma destas alternativas:

- DB Browser for SQLite;
- DBeaver;
- SQLiteStudio;
- `scripts/executar_consulta.py`;
- módulo `sqlite3` do próprio Python.

### O comando foi executado fora da raiz do projeto

Volte para a pasta que contém `README.md`, `requirements.txt`, `scripts/` e `src/`.

Exemplo:

```bash
cd caminho\para\projeto-integracao-gdi
```

---

## Fluxo completo do projeto

```text
Planilhas XLSX de 2024, 2025 e 2026
                    ↓
         Extração e leitura dos dados
                    ↓
       Limpeza e padronização das bases
                    ↓
      Criação das dimensões e tabelas fato
                    ↓
       Data Warehouse em Esquema Estrela
                    ↓
      Bancos SQLite produzidos por ETL e ELT
                    ↓
          Validação entre os pipelines
                    ↓
        Consultas, tabelas, gráficos e insights
```

---

## Licença e uso acadêmico

Este repositório foi desenvolvido para fins acadêmicos na disciplina de Banco de Dados, período 2026.1.
