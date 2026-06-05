"""Validação simples para comparar os resultados do ETL e do ELT."""

from __future__ import annotations

import sqlite3
import sys
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from src.config import DOCS_DIR, ELT_DATABASE_PATH, ETL_DATABASE_PATH
from src.utils import save_csv

TABLES = [
    "dim_tempo", "dim_aeroporto", "dim_cia_aerea", "dim_operacao", "dim_perfil_passageiro",
    "dim_indicador", "fato_entrevista", "fato_avaliacao",
]


def count_rows(db_path: Path) -> dict[str, int]:
    """Conta linhas de cada tabela em um banco SQLite."""
    with sqlite3.connect(db_path) as conn:
        return {table: conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0] for table in TABLES}


def main() -> None:
    etl_counts = count_rows(ETL_DATABASE_PATH)
    elt_counts = count_rows(ELT_DATABASE_PATH)
    rows = []
    for table in TABLES:
        rows.append(
            {
                "tabela": table,
                "linhas_etl": etl_counts[table],
                "linhas_elt": elt_counts[table],
                "diferenca": etl_counts[table] - elt_counts[table],
            }
        )
    result = pd.DataFrame(rows)
    save_csv(result, DOCS_DIR / "tabelas" / "validacao_etl_vs_elt.csv")
    print(result.to_string(index=False))


if __name__ == "__main__":
    main()
