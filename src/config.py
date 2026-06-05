"""Configurações de caminhos do projeto.

Este arquivo centraliza os diretórios usados pelos pipelines ETL e ELT. Assim,
se a estrutura do repositório mudar no futuro, basta ajustar os caminhos aqui.
"""

from pathlib import Path

# Raiz do repositório: dois níveis acima deste arquivo (src/config.py).
ROOT_DIR = Path(__file__).resolve().parents[1]

# Pastas principais.
DATA_DIR = ROOT_DIR / "data"
RAW_DIR = DATA_DIR / "raw"
PROCESSED_DIR = DATA_DIR / "processed"
WAREHOUSE_DIR = DATA_DIR / "warehouse"
DOCS_DIR = ROOT_DIR / "docs"
SQL_DIR = ROOT_DIR / "sql"

# Arquivos-fonte usados no projeto. As bases são do 1º trimestre de 2024, 2025 e 2026.
SOURCE_FILES = {
    2024: RAW_DIR / "pesquisa_satisfacao_1_tri_2024.xlsx",
    2025: RAW_DIR / "pesquisa_satisfacao_1_tri_2025.xlsx",
    2026: RAW_DIR / "pesquisa_satisfacao_1_tri_2026.xlsx",
}

# Bancos SQLite gerados pelos dois processos.
ETL_DATABASE_PATH = WAREHOUSE_DIR / "aeroportos_dw_etl.sqlite"
ELT_DATABASE_PATH = WAREHOUSE_DIR / "aeroportos_dw_elt.sqlite"

# Pastas de saída separadas por pipeline.
ETL_OUTPUT_DIR = PROCESSED_DIR / "etl"
ELT_OUTPUT_DIR = PROCESSED_DIR / "elt"


def ensure_project_dirs() -> None:
    """Cria as pastas principais caso elas ainda não existam."""
    for directory in [RAW_DIR, PROCESSED_DIR, WAREHOUSE_DIR, ETL_OUTPUT_DIR, ELT_OUTPUT_DIR, DOCS_DIR]:
        directory.mkdir(parents=True, exist_ok=True)
