"""Gera tabelas e gráficos usados na documentação e no relatório."""

from __future__ import annotations

import sqlite3
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from src.config import DOCS_DIR, ETL_DATABASE_PATH
from src.utils import save_csv

OUT_TABLES = DOCS_DIR / "tabelas"
OUT_IMAGES = DOCS_DIR / "imagens"
OUT_TABLES.mkdir(parents=True, exist_ok=True)
OUT_IMAGES.mkdir(parents=True, exist_ok=True)

QUERIES = {
    "satisfacao_por_ano": """
        SELECT dt.ano,
               COUNT(*) AS total_entrevistas,
               ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
               ROUND(100.0 * AVG(CASE WHEN fe.satisfacao_geral >= 4 THEN 1 ELSE 0 END), 2) AS percentual_avaliacoes_positivas
        FROM fato_entrevista fe
        JOIN dim_tempo dt ON dt.data_key = fe.data_key
        GROUP BY dt.ano
        ORDER BY dt.ano;
    """,
    "ranking_aeroportos_satisfacao": """
        SELECT da.codigo_icao,
               da.nome_aeroporto,
               da.uf,
               COUNT(*) AS total_entrevistas,
               ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
               ROUND(100.0 * AVG(CASE WHEN fe.satisfacao_geral >= 4 THEN 1 ELSE 0 END), 2) AS percentual_positivo
        FROM fato_entrevista fe
        JOIN dim_aeroporto da ON da.aeroporto_key = fe.aeroporto_key
        GROUP BY da.codigo_icao, da.nome_aeroporto, da.uf
        ORDER BY media_satisfacao_geral DESC, total_entrevistas DESC;
    """,
    "indicadores_pontos_criticos": """
        SELECT di.codigo_indicador,
               di.campo_original AS indicador,
               di.categoria,
               di.tipo_indicador,
               COUNT(*) AS total_avaliacoes,
               ROUND(AVG(fa.nota), 3) AS media_nota,
               ROUND(100.0 * AVG(fa.nota_positiva), 2) AS percentual_positivo
        FROM fato_avaliacao fa
        JOIN dim_indicador di ON di.indicador_key = fa.indicador_key
        GROUP BY di.codigo_indicador, di.campo_original, di.categoria, di.tipo_indicador
        HAVING total_avaliacoes >= 500
        ORDER BY media_nota ASC
        LIMIT 15;
    """,
    "comparativo_tipo_voo": """
        SELECT dop.tipo_de_voo,
               COUNT(*) AS total_entrevistas,
               ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
               ROUND(100.0 * AVG(CASE WHEN fe.satisfacao_geral >= 4 THEN 1 ELSE 0 END), 2) AS percentual_positivo
        FROM fato_entrevista fe
        JOIN dim_operacao dop ON dop.operacao_key = fe.operacao_key
        GROUP BY dop.tipo_de_voo
        ORDER BY media_satisfacao_geral DESC;
    """,
    "comparativo_processo": """
        SELECT dop.processo,
               COUNT(*) AS total_entrevistas,
               ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
               ROUND(100.0 * AVG(CASE WHEN fe.satisfacao_geral >= 4 THEN 1 ELSE 0 END), 2) AS percentual_positivo
        FROM fato_entrevista fe
        JOIN dim_operacao dop ON dop.operacao_key = fe.operacao_key
        GROUP BY dop.processo
        ORDER BY media_satisfacao_geral DESC;
    """,
}


def save_chart_satisfaction_by_year(df: pd.DataFrame) -> None:
    plt.figure(figsize=(7, 4))
    plt.plot(df["ano"], df["media_satisfacao_geral"], marker="o")
    plt.title("Média de satisfação geral - 1º trimestre")
    plt.xlabel("Ano")
    plt.ylabel("Nota média (1 a 5)")
    plt.xticks(df["ano"])
    plt.ylim(4.0, 5.0)
    plt.grid(True, axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig(OUT_IMAGES / "grafico_satisfacao_por_ano.png", dpi=180)
    plt.close()


def save_chart_airports(df: pd.DataFrame) -> None:
    top_bottom = pd.concat([df.head(5), df.tail(5)]).sort_values("media_satisfacao_geral")
    plt.figure(figsize=(8, 5))
    plt.barh(top_bottom["codigo_icao"], top_bottom["media_satisfacao_geral"])
    plt.title("Aeroportos - maiores e menores médias de satisfação geral")
    plt.xlabel("Nota média (1 a 5)")
    plt.xlim(4.0, 5.0)
    plt.tight_layout()
    plt.savefig(OUT_IMAGES / "grafico_ranking_aeroportos.png", dpi=180)
    plt.close()


def save_chart_indicators(df: pd.DataFrame) -> None:
    chart_df = df.head(10).sort_values("media_nota")
    plt.figure(figsize=(9, 6))
    plt.barh(chart_df["codigo_indicador"], chart_df["media_nota"])
    plt.title("Indicadores com menor média de avaliação")
    plt.xlabel("Nota média (1 a 5)")
    plt.xlim(2.5, 5.0)
    plt.tight_layout()
    plt.savefig(OUT_IMAGES / "grafico_indicadores_criticos.png", dpi=180)
    plt.close()


def main() -> None:
    with sqlite3.connect(ETL_DATABASE_PATH) as conn:
        outputs = {name: pd.read_sql_query(query, conn) for name, query in QUERIES.items()}

    for name, df in outputs.items():
        save_csv(df, OUT_TABLES / f"{name}.csv")

    save_chart_satisfaction_by_year(outputs["satisfacao_por_ano"])
    save_chart_airports(outputs["ranking_aeroportos_satisfacao"])
    save_chart_indicators(outputs["indicadores_pontos_criticos"])

    print("Tabelas e gráficos analíticos gerados em docs/tabelas e docs/imagens.")


if __name__ == "__main__":
    main()
