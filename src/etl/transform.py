"""Transformações do pipeline ETL.

Neste arquivo estão as regras principais de limpeza, padronização e modelagem
dimensional. O objetivo foi deixar cada transformação explícita e comentada para que
qualquer integrante do grupo consiga entender a construção do Data Warehouse.
"""

from __future__ import annotations

import pandas as pd

from src.metadata import get_airports_df, get_indicators_df
from src.utils import (
    coalesce_for_dimension,
    parse_date_series,
    to_numeric_nullable,
    to_numeric_score,
    value_to_time_string,
)

TEXT_COLUMNS = [
    "processo",
    "aeroporto",
    "mes",
    "terminal",
    "portao",
    "tipo_de_voo",
    "cia_aerea",
    "voo",
    "conexao",
    "aquisicao_da_passagem",
    "meio_de_aquisicao_da_passagem",
    "meio_de_transporte_para_o_aeroporto",
    "possui_deficiencia",
    "utiliza_recurso_assistivo",
    "solicitou_assistencia_especial",
    "forma_de_desembarque_utilizada",
    "utilizou_o_estacionamento",
    "forma_de_check_in",
    "motivo",
    "nacionalidade",
    "genero",
    "idade",
    "escolaridade",
    "renda_familiar",
    "viajando_sozinho",
    "motivo_da_viagem",
    "quantidade_de_viagens_nos_ultimos_12_meses",
    "ja_embarcou_desembarcou_antes_no_aeroporto",
    "comentarios_adicionais",
]

PROFILE_COLUMNS = [
    "nacionalidade",
    "genero",
    "idade",
    "escolaridade",
    "renda_familiar",
    "viajando_sozinho",
    "motivo_da_viagem",
    "quantidade_de_viagens_nos_ultimos_12_meses",
    "ja_embarcou_desembarcou_antes_no_aeroporto",
    "possui_deficiencia",
    "utiliza_recurso_assistivo",
    "solicitou_assistencia_especial",
]

OPERATION_COLUMNS = [
    "processo",
    "tipo_de_voo",
    "conexao",
    "forma_de_check_in",
    "forma_de_desembarque_utilizada",
    "terminal",
]


def prepare_clean_dataframe(raw_df: pd.DataFrame) -> pd.DataFrame:
    """Limpa e padroniza a base consolidada antes de gerar dimensões e fatos."""
    df = raw_df.copy()

    # Remove linhas completamente vazias e linhas sem chave de entrevista.
    df = df.dropna(how="all")
    df = df[df["chave"].notna()].copy()
    df["chave"] = pd.to_numeric(df["chave"], errors="coerce").astype("Int64")
    df = df[df["chave"].notna()].copy()

    # Padroniza data e cria uma chave temporal numérica no formato AAAAMMDD.
    df["data"] = parse_date_series(df["data"])
    df["data_key"] = df["data"].dt.strftime("%Y%m%d").astype("Int64")

    # Horários de coleta são mantidos como texto padronizado HH:MM:SS para facilitar SQL.
    for column in ["inicio_coleta", "fim_coleta"]:
        if column in df.columns:
            df[column] = df[column].apply(value_to_time_string)

    # Limpeza de campos textuais usados nas dimensões.
    for column in TEXT_COLUMNS:
        if column in df.columns:
            df[column] = coalesce_for_dimension(df[column])

    # Conversões numéricas diretas.
    for column in ["numero_de_acompanhantes", "antecedencia", "tempo_de_espera"]:
        if column in df.columns:
            df[column] = to_numeric_nullable(df[column])

    # Converte todos os indicadores de satisfação para a escala 1 a 5.
    indicators = get_indicators_df()
    for column in indicators["coluna_normalizada"]:
        if column in df.columns:
            df[column] = to_numeric_score(df[column])

    # Remove duplicatas de entrevista por segurança. A regra mantém a primeira ocorrência.
    df = df.drop_duplicates(subset=["chave"], keep="first")
    return df.reset_index(drop=True)


def build_dim_tempo(df: pd.DataFrame) -> pd.DataFrame:
    """Monta a dimensão de datas."""
    dim = df[["data_key", "data"]].dropna().drop_duplicates().copy()
    dim["ano"] = dim["data"].dt.year
    dim["trimestre"] = dim["data"].dt.quarter
    dim["mes_numero"] = dim["data"].dt.month
    # Como o relatório é em português, uso um mapeamento simples para o nome do mês.
    month_map = {
        1: "Janeiro", 2: "Fevereiro", 3: "Março", 4: "Abril", 5: "Maio", 6: "Junho",
        7: "Julho", 8: "Agosto", 9: "Setembro", 10: "Outubro", 11: "Novembro", 12: "Dezembro",
    }
    weekday_map = {
        0: "Segunda-feira", 1: "Terça-feira", 2: "Quarta-feira", 3: "Quinta-feira",
        4: "Sexta-feira", 5: "Sábado", 6: "Domingo",
    }
    dim["mes_nome"] = dim["mes_numero"].map(month_map)
    dim["dia"] = dim["data"].dt.day
    dim["dia_semana"] = dim["data"].dt.weekday.map(weekday_map)
    dim["data"] = dim["data"].dt.date.astype(str)
    return dim.sort_values("data_key").reset_index(drop=True)


def build_dim_cia_aerea(df: pd.DataFrame) -> pd.DataFrame:
    """Monta a dimensão de companhias aéreas."""
    dim = df[["cia_aerea"]].drop_duplicates().sort_values("cia_aerea").reset_index(drop=True)
    dim.insert(0, "cia_aerea_key", range(1, len(dim) + 1))
    return dim


def build_dim_operacao(df: pd.DataFrame) -> pd.DataFrame:
    """Monta a dimensão que descreve a operação/experiência da entrevista."""
    dim = df[OPERATION_COLUMNS].drop_duplicates().sort_values(OPERATION_COLUMNS).reset_index(drop=True)
    dim.insert(0, "operacao_key", range(1, len(dim) + 1))
    return dim


def build_dim_perfil_passageiro(df: pd.DataFrame) -> pd.DataFrame:
    """Monta a dimensão de perfil do passageiro entrevistado."""
    dim = df[PROFILE_COLUMNS].drop_duplicates().sort_values(PROFILE_COLUMNS).reset_index(drop=True)
    dim.insert(0, "perfil_key", range(1, len(dim) + 1))
    return dim


def build_dimensions(clean_df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    """Gera todas as dimensões do modelo estrela."""
    return {
        "dim_tempo": build_dim_tempo(clean_df),
        "dim_aeroporto": get_airports_df(),
        "dim_cia_aerea": build_dim_cia_aerea(clean_df),
        "dim_operacao": build_dim_operacao(clean_df),
        "dim_perfil_passageiro": build_dim_perfil_passageiro(clean_df),
        "dim_indicador": get_indicators_df(),
    }


def add_dimension_keys(clean_df: pd.DataFrame, dimensions: dict[str, pd.DataFrame]) -> pd.DataFrame:
    """Adiciona chaves substitutas das dimensões na base limpa."""
    df = clean_df.copy()
    df = df.merge(dimensions["dim_aeroporto"][["aeroporto_key", "codigo_icao"]], left_on="aeroporto", right_on="codigo_icao", how="left")
    df = df.merge(dimensions["dim_cia_aerea"], on="cia_aerea", how="left")
    df = df.merge(dimensions["dim_operacao"], on=OPERATION_COLUMNS, how="left")
    df = df.merge(dimensions["dim_perfil_passageiro"], on=PROFILE_COLUMNS, how="left")
    return df


def build_fact_entrevista(clean_df: pd.DataFrame, dimensions: dict[str, pd.DataFrame]) -> pd.DataFrame:
    """Cria a fato principal, no nível de uma entrevista por linha."""
    keyed = add_dimension_keys(clean_df, dimensions)
    fact_columns = [
        "chave", "ano_fonte", "arquivo_origem", "data_key", "aeroporto_key", "cia_aerea_key", "operacao_key", "perfil_key",
        "inicio_coleta", "fim_coleta", "voo", "aquisicao_da_passagem", "meio_de_aquisicao_da_passagem",
        "meio_de_transporte_para_o_aeroporto", "utilizou_o_estacionamento", "numero_de_acompanhantes",
        "antecedencia", "tempo_de_espera", "satisfacao_geral", "motivo", "comentarios_adicionais",
    ]
    existing = [column for column in fact_columns if column in keyed.columns]
    fact = keyed[existing].copy()
    fact.insert(0, "entrevista_key", range(1, len(fact) + 1))
    return fact


def build_fact_avaliacao(clean_df: pd.DataFrame, dimensions: dict[str, pd.DataFrame]) -> pd.DataFrame:
    """Cria a fato analítica, no nível de uma avaliação de indicador por entrevista."""
    keyed = add_dimension_keys(clean_df, dimensions)
    indicators = dimensions["dim_indicador"]
    frames: list[pd.DataFrame] = []

    for _, indicator in indicators.iterrows():
        column = indicator["coluna_normalizada"]
        if column not in keyed.columns:
            # Comentário de segurança: se uma coluna de indicador não existir, o pipeline
            # segue rodando, mas o problema fica evidente na documentação/validação.
            continue

        partial = keyed.loc[keyed[column].notna(), [
            "chave", "ano_fonte", "data_key", "aeroporto_key", "operacao_key", "perfil_key", column,
        ]].copy()
        partial = partial.rename(columns={column: "nota"})
        partial["indicador_key"] = indicator["indicador_key"]
        partial["nota_positiva"] = (partial["nota"] >= 4).astype(int)
        partial["nota_negativa_ou_neutra"] = (partial["nota"] <= 3).astype(int)
        frames.append(partial)

    fact = pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()
    fact = fact[[
        "chave", "ano_fonte", "data_key", "aeroporto_key", "operacao_key", "perfil_key",
        "indicador_key", "nota", "nota_positiva", "nota_negativa_ou_neutra",
    ]]
    fact.insert(0, "avaliacao_key", range(1, len(fact) + 1))
    return fact


def build_star_schema(clean_df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    """Monta o Data Warehouse completo em esquema estrela."""
    dimensions = build_dimensions(clean_df)
    facts = {
        "fato_entrevista": build_fact_entrevista(clean_df, dimensions),
        "fato_avaliacao": build_fact_avaliacao(clean_df, dimensions),
    }
    return {**dimensions, **facts}
