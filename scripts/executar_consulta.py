"""Executa uma consulta SQL no Data Warehouse do projeto."""

from pathlib import Path
import sqlite3

import pandas as pd

# Localiza a raiz do projeto.
ROOT = Path(__file__).resolve().parents[1]

# Define qual banco será consultado.
DATABASE_PATH = ROOT / "data" / "warehouse" / "aeroportos_dw_etl.sqlite"


def main() -> None:
    """Consulta a média de satisfação por ano."""

    query = """
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
    """

    if not DATABASE_PATH.exists():
        raise FileNotFoundError(
            f"Banco não encontrado: {DATABASE_PATH}\n"
            "Execute primeiro: python scripts/run_all.py"
        )

    with sqlite3.connect(DATABASE_PATH) as connection:
        resultado = pd.read_sql_query(query, connection)

    print("\nResultado da consulta:\n")
    print(resultado.to_string(index=False))


if __name__ == "__main__":
    main()