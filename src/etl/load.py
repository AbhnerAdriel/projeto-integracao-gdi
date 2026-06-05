"""Carga dos dados transformados para arquivos CSV e banco SQLite."""

from __future__ import annotations

import sqlite3
from pathlib import Path

import pandas as pd

from src.utils import save_csv


def save_tables_as_csv(tables: dict[str, pd.DataFrame], output_dir: Path) -> None:
    """Salva cada tabela do modelo estrela em um CSV separado."""
    output_dir.mkdir(parents=True, exist_ok=True)
    for table_name, df in tables.items():
        save_csv(df, output_dir / f"{table_name}.csv")


def save_tables_to_sqlite(tables: dict[str, pd.DataFrame], database_path: Path) -> None:
    """Grava as tabelas no SQLite, que foi o banco final escolhido para o projeto."""
    database_path.parent.mkdir(parents=True, exist_ok=True)
    if database_path.exists():
        database_path.unlink()

    with sqlite3.connect(database_path) as conn:
        # Habilito chaves estrangeiras para deixar explícito que estamos montando um DW relacional.
        conn.execute("PRAGMA foreign_keys = ON;")
        for table_name, df in tables.items():
            df.to_sql(table_name, conn, index=False, if_exists="replace")

        # Índices simples para acelerar as consultas analíticas mais comuns.
        conn.execute("CREATE INDEX IF NOT EXISTS idx_fato_entrevista_chave ON fato_entrevista(chave);")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_fato_entrevista_data ON fato_entrevista(data_key);")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_fato_avaliacao_chave ON fato_avaliacao(chave);")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_fato_avaliacao_indicador ON fato_avaliacao(indicador_key);")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_fato_avaliacao_aeroporto ON fato_avaliacao(aeroporto_key);")
