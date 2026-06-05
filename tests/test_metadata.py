from src.metadata import get_airports_df, get_indicators_df


def test_airports_count():
    assert len(get_airports_df()) == 20


def test_indicators_have_keys():
    indicators = get_indicators_df()
    assert indicators["indicador_key"].is_unique
    assert indicators["coluna_normalizada"].notna().all()
