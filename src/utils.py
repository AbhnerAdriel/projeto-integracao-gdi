"""Funções utilitárias usadas em mais de uma etapa do projeto.

A ideia é deixar o código dos pipelines mais limpo e legível. Por isso, regras
repetidas de limpeza, padronização de nomes e conversão de tipos ficam aqui.
"""

from __future__ import annotations

import re
import unicodedata
from datetime import date, datetime, time
from pathlib import Path
from typing import Iterable

import pandas as pd

MISSING_TEXT_VALUES = {"", "nan", "none", "null", "nat", "não informado", "nao informado"}


def strip_accents(value: str) -> str:
    """Remove acentos de uma string sem perder os demais caracteres."""
    normalized = unicodedata.normalize("NFKD", str(value))
    return "".join(char for char in normalized if not unicodedata.combining(char))


def to_snake_case(value: object) -> str:
    """Converte um texto para snake_case, de forma segura para nomes de colunas SQL."""
    text = strip_accents(str(value).strip().lower())
    text = text.replace("º", "").replace("ª", "")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    text = re.sub(r"_+", "_", text).strip("_")
    return text or "coluna_sem_nome"


def make_unique_column_names(columns: Iterable[object]) -> list[str]:
    """Padroniza nomes de colunas e garante que não existam duplicidades."""
    used: dict[str, int] = {}
    output: list[str] = []
    for column in columns:
        base_name = to_snake_case(column)
        count = used.get(base_name, 0)
        used[base_name] = count + 1
        output.append(base_name if count == 0 else f"{base_name}_{count + 1}")
    return output


def clean_text(value: object, default: str | None = None) -> str | None:
    """Limpa textos vindos da planilha, mantendo `None` quando o valor está ausente."""
    if pd.isna(value):
        return default
    text = str(value).strip()
    text = re.sub(r"\s+", " ", text)
    if strip_accents(text).lower() in MISSING_TEXT_VALUES:
        return default
    return text


def normalize_text_series(series: pd.Series, default: str = "Não informado") -> pd.Series:
    """Aplica limpeza básica em uma coluna textual de forma vetorizada.

    Evito um `apply` linha a linha aqui porque a base consolidada passa de 77 mil
    entrevistas e possui várias colunas textuais. A versão vetorizada é mais rápida
    e deixa o pipeline mais confortável para rodar no Colab.
    """
    original_missing = series.isna()
    cleaned = series.astype("string").str.strip().str.replace(r"\s+", " ", regex=True)
    lowered = cleaned.str.lower()
    missing = original_missing | lowered.isin(MISSING_TEXT_VALUES)
    return cleaned.mask(missing, default).astype(object)


def to_numeric_score(series: pd.Series) -> pd.Series:
    """Converte notas de satisfação para número, aceitando apenas a escala 1 a 5.

    Valores como "NS/NR" e células vazias viram NaN, pois não representam uma nota
    válida na escala Likert usada pela pesquisa.
    """
    numeric = pd.to_numeric(series, errors="coerce")
    return numeric.where(numeric.between(1, 5))


def to_numeric_nullable(series: pd.Series) -> pd.Series:
    """Converte uma coluna para número, preservando ausências como NaN."""
    return pd.to_numeric(series, errors="coerce")


def parse_date_series(series: pd.Series) -> pd.Series:
    """Converte a coluna de data para datetime, tolerando formatos diferentes.

    Algumas linhas do arquivo de 2024 vêm como número serial do Excel (ex.: 45315)
    em vez de data formatada. Por isso trato primeiro os seriais numéricos com a
    origem do Excel e depois completo com a interpretação normal de datas/textos.
    """
    numeric_serial = pd.to_numeric(series, errors="coerce")
    dates_from_serial = pd.to_datetime(numeric_serial, unit="D", origin="1899-12-30", errors="coerce")
    dates_from_text = pd.to_datetime(series.where(numeric_serial.isna()), errors="coerce", dayfirst=True)
    return dates_from_text.fillna(dates_from_serial)


def value_to_time_string(value: object) -> str | None:
    """Converte horários de Excel/Python para texto HH:MM:SS."""
    if pd.isna(value):
        return None
    if isinstance(value, time):
        return value.strftime("%H:%M:%S")
    if isinstance(value, datetime):
        return value.strftime("%H:%M:%S")
    text = str(value).strip()
    # Alguns horários podem chegar como "16:14:30" ou como "0 days 16:14:30".
    match = re.search(r"(\d{1,2}:\d{2}(?::\d{2})?)", text)
    if not match:
        return None
    parts = match.group(1).split(":")
    if len(parts) == 2:
        parts.append("00")
    return f"{int(parts[0]):02d}:{int(parts[1]):02d}:{int(parts[2]):02d}"


def save_csv(df: pd.DataFrame, path: Path) -> None:
    """Salva um DataFrame em CSV UTF-8, criando a pasta quando necessário."""
    path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(path, index=False, encoding="utf-8")


def coalesce_for_dimension(series: pd.Series) -> pd.Series:
    """Padroniza campos usados nas dimensões, evitando chaves nulas."""
    return normalize_text_series(series, default="Não informado")
