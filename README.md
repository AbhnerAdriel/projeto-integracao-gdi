# Projeto de Integração - Satisfação do Passageiro em Aeroportos

Este repositório contém o projeto de integração de dados sobre **indicadores de satisfação do passageiro em aeroportos**, usando as bases do 1º trimestre de **2024, 2025 e 2026**.

O objetivo do projeto é integrar os três arquivos anuais, limpar e padronizar os dados, criar um **Data Warehouse em Esquema Estrela** e comparar duas formas de processamento: **ETL** e **ELT**.

## Tema escolhido

Indicadores que avaliam a satisfação do passageiro com os processos e serviços aeroportuários a ele oferecidos, coletados nos 20 aeroportos principais durante a pesquisa.

## Tecnologias usadas

- Python
- Pandas
- OpenPyXL
- SQLite
- Google Colab
- Matplotlib
- SQL

A escolha do SQLite foi feita porque ele é simples de executar localmente ou no Colab, não exige servidor e ainda permite demonstrar bem a modelagem dimensional e as consultas analíticas.

## Estrutura do repositório

```text
.
├── data/
│   ├── raw/                  # bases originais XLSX
│   ├── processed/            # tabelas CSV geradas pelos pipelines
│   └── warehouse/            # bancos SQLite finais
├── docs/
│   ├── imagens/              # gráficos e diagramas do relatório
│   ├── metodologia_sources/   # metodologia e dicionário originais
│   ├── tabelas/              # resultados das consultas analíticas
│   └── relatorio_projeto.md   # relatório em Markdown
├── notebooks/
│   ├── 01_pipeline_etl.ipynb
│   └── 02_pipeline_elt.ipynb
├── scripts/
│   ├── run_all.py
│   └── generate_analysis_outputs.py
├── sql/
│   ├── create_schema.sql
│   ├── elt_transformations.sql
│   └── consultas_analiticas.sql
└── src/
    ├── etl/                  # código do pipeline ETL
    ├── elt/                  # código do pipeline ELT
    ├── quality/              # validações
    ├── config.py
    ├── metadata.py
    └── utils.py
```

## Como rodar localmente

1. Crie um ambiente virtual:

```bash
python -m venv .venv
```

2. Ative o ambiente virtual:

```bash
# Windows
.venv\Scripts\activate

# Linux/macOS
source .venv/bin/activate
```

3. Instale as dependências:

```bash
pip install -r requirements.txt
```

4. Rode todo o projeto:

```bash
python scripts/run_all.py
```

Esse comando executa:

- pipeline ETL;
- pipeline ELT;
- validação comparando as saídas;
- geração das tabelas e gráficos usados no relatório.

## Como rodar no Google Colab

Abra os notebooks da pasta `notebooks/` no Google Colab. Eles estão separados por processo:

- `01_pipeline_etl.ipynb`: executa extração, transformação em Python e carga no SQLite;
- `02_pipeline_elt.ipynb`: executa extração, carga em staging e transformação em SQL dentro do SQLite.

No Colab, basta manter a estrutura do repositório e executar as células em ordem.


## Resultados gerados nesta entrega

Após a execução dos pipelines, foram gerados:

- `data/warehouse/aeroportos_dw_etl.sqlite`: banco final produzido pelo ETL;
- `data/warehouse/aeroportos_dw_elt.sqlite`: banco final produzido pelo ELT;
- `docs/Relatorio_Projeto_Integracao_Aeroportos.docx`: relatório formatado seguindo a estrutura do template;
- `docs/Relatorio_Projeto_Integracao_Aeroportos.pdf`: versão em PDF do relatório;
- `docs/tabelas/*.csv`: resultados das consultas usadas nos insights;
- `docs/imagens/*.png`: gráficos e diagramas usados na documentação.

Resumo do Data Warehouse validado:

| Tabela | Linhas |
|---|---:|
| dim_tempo | 271 |
| dim_aeroporto | 20 |
| dim_cia_aerea | 39 |
| dim_operacao | 77 |
| dim_perfil_passageiro | 15.382 |
| dim_indicador | 62 |
| fato_entrevista | 77.194 |
| fato_avaliacao | 533.891 |

## Modelo dimensional

O Data Warehouse foi organizado em Esquema Estrela, com duas tabelas fato:

- `fato_entrevista`: uma linha por entrevista/respondente;
- `fato_avaliacao`: uma linha por avaliação de indicador feita em uma entrevista.

As principais dimensões são:

- `dim_tempo`;
- `dim_aeroporto`;
- `dim_cia_aerea`;
- `dim_operacao`;
- `dim_perfil_passageiro`;
- `dim_indicador`.

## Consultas principais

As consultas usadas para gerar os insights estão em `sql/consultas_analiticas.sql`.

Elas respondem perguntas como:

1. A satisfação geral melhorou ou piorou entre 2024, 2025 e 2026?
2. Quais aeroportos tiveram maior e menor média de satisfação geral?
3. Quais indicadores aparecem como pontos mais críticos?
4. Existe diferença entre voos domésticos e internacionais?

## Sugestão de mensagens de commit

Evite commits genéricos como `update`, `teste` ou `ajustes`. Sugestões:

```text
Criação da estrutura inicial do repositório
Implementação do pipeline ETL para bases de 2024 a 2026
Criação do modelo estrela no SQLite
Implementação do pipeline ELT com transformações em SQL
Geração das consultas analíticas e gráficos do relatório
Documentação do processo de integração e modelagem dimensional
```
