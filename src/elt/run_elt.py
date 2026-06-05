"""Pipeline ELT completo.

No ELT, os dados são primeiro extraídos e carregados em uma tabela de staging no
SQLite. Depois disso, as transformações principais são executadas em SQL dentro do
próprio banco.

Execute a partir da raiz do projeto:

    python src/elt/run_elt.py
"""

from __future__ import annotations

import sqlite3
import sys
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from src.config import ELT_DATABASE_PATH, ELT_OUTPUT_DIR, SOURCE_FILES, SQL_DIR, ensure_project_dirs
from src.etl.extract import extract_all_sources
from src.utils import parse_date_series, value_to_time_string
from src.metadata import get_airports_df, get_indicators_df
from src.utils import save_csv


def load_staging_tables(conn: sqlite3.Connection) -> None:
    """Extrai os XLSX e carrega as tabelas brutas de apoio no SQLite."""
    print("[ELT] Extraindo arquivos XLSX...")
    raw_df = extract_all_sources(SOURCE_FILES)

    # Para a carga no SQLite, faço apenas padronizações técnicas necessárias para o banco:
    # datas em ISO, chave temporal e horários em texto. As limpezas analíticas ficam no SQL.
    staging = raw_df.copy()
    staging = staging.dropna(how="all")
    staging["data"] = parse_date_series(staging["data"]).dt.strftime("%Y-%m-%d")
    staging["data_key"] = staging["data"].str.replace("-", "", regex=False)
    for column in ["inicio_coleta", "fim_coleta"]:
        if column in staging.columns:
            staging[column] = staging[column].apply(value_to_time_string)
    staging.to_sql("stg_pesquisa_satisfacao", conn, index=False, if_exists="replace")

    get_airports_df().to_sql("ref_aeroportos", conn, index=False, if_exists="replace")
    get_indicators_df().to_sql("ref_indicadores", conn, index=False, if_exists="replace")
    print(f"[ELT] Staging carregado com {len(staging):,} entrevistas.")


def export_final_tables(conn: sqlite3.Connection) -> None:
    """Exporta as tabelas finais do ELT para CSV, facilitando conferência no GitHub."""
    ELT_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    table_names = [
        "dim_tempo", "dim_aeroporto", "dim_cia_aerea", "dim_operacao", "dim_perfil_passageiro",
        "dim_indicador", "fato_entrevista", "fato_avaliacao",
    ]
    for table_name in table_names:
        df = pd.read_sql_query(f"SELECT * FROM {table_name}", conn)
        save_csv(df, ELT_OUTPUT_DIR / f"{table_name}.csv")


def main() -> None:
    ensure_project_dirs()
    if ELT_DATABASE_PATH.exists():
        ELT_DATABASE_PATH.unlink()

    with sqlite3.connect(ELT_DATABASE_PATH) as conn:
        conn.execute("PRAGMA foreign_keys = ON;")
        load_staging_tables(conn)

        print("[ELT] Executando transformações SQL dentro do banco...")
        sql_script = (SQL_DIR / "elt_transformations.sql").read_text(encoding="utf-8")
        conn.executescript(sql_script)

        print("[ELT] Exportando tabelas finais para CSV...")
        export_final_tables(conn)

    print(f"[ELT] Banco gerado em: {ELT_DATABASE_PATH}")


if __name__ == "__main__":
    main()
