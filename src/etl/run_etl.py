"""Pipeline ETL completo.

Execute a partir da raiz do projeto:

    python src/etl/run_etl.py

Saídas geradas:
- data/processed/etl/*.csv
- data/warehouse/aeroportos_dw_etl.sqlite
"""

from __future__ import annotations

import sys
from pathlib import Path

# Permite rodar o script diretamente sem instalar o pacote local.
ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from src.config import ETL_DATABASE_PATH, ETL_OUTPUT_DIR, SOURCE_FILES, ensure_project_dirs
from src.etl.extract import extract_all_sources, read_question_codes
from src.etl.load import save_tables_as_csv, save_tables_to_sqlite
from src.etl.transform import build_star_schema, prepare_clean_dataframe
from src.utils import save_csv


def main() -> None:
    """Roda extração, transformação e carga no modelo estrela."""
    ensure_project_dirs()

    print("[ETL] Extraindo arquivos XLSX...")
    raw_df = extract_all_sources(SOURCE_FILES)
    print(f"[ETL] Linhas extraídas: {len(raw_df):,}")

    print("[ETL] Gerando dicionário técnico das colunas...")
    dictionary = read_question_codes(SOURCE_FILES[2024])
    save_csv(dictionary, ETL_OUTPUT_DIR / "dicionario_colunas_origem.csv")

    print("[ETL] Limpando e padronizando dados...")
    clean_df = prepare_clean_dataframe(raw_df)
    save_csv(clean_df.head(1000), ETL_OUTPUT_DIR / "amostra_base_limpa_1000_linhas.csv")
    print(f"[ETL] Linhas após limpeza: {len(clean_df):,}")

    print("[ETL] Construindo dimensões e fatos...")
    tables = build_star_schema(clean_df)
    for name, table in tables.items():
        print(f"  - {name}: {len(table):,} linhas")

    print("[ETL] Salvando CSVs do DW...")
    save_tables_as_csv(tables, ETL_OUTPUT_DIR)

    print("[ETL] Carregando banco SQLite final...")
    save_tables_to_sqlite(tables, ETL_DATABASE_PATH)
    print(f"[ETL] Banco gerado em: {ETL_DATABASE_PATH}")


if __name__ == "__main__":
    main()
