-- Consultas analíticas usadas no relatório.

-- 1) Evolução da satisfação geral por ano.
SELECT
    dt.ano,
    COUNT(*) AS total_entrevistas,
    ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
    ROUND(100.0 * AVG(CASE WHEN fe.satisfacao_geral >= 4 THEN 1 ELSE 0 END), 2) AS percentual_avaliacoes_positivas
FROM fato_entrevista fe
JOIN dim_tempo dt ON dt.data_key = fe.data_key
GROUP BY dt.ano
ORDER BY dt.ano;

-- 2) Ranking de aeroportos por satisfação geral.
SELECT
    da.codigo_icao,
    da.nome_aeroporto,
    da.uf,
    COUNT(*) AS total_entrevistas,
    ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
    ROUND(100.0 * AVG(CASE WHEN fe.satisfacao_geral >= 4 THEN 1 ELSE 0 END), 2) AS percentual_positivo
FROM fato_entrevista fe
JOIN dim_aeroporto da ON da.aeroporto_key = fe.aeroporto_key
GROUP BY da.codigo_icao, da.nome_aeroporto, da.uf
ORDER BY media_satisfacao_geral DESC, total_entrevistas DESC;

-- 3) Indicadores com menor média de nota no período completo.
SELECT
    di.codigo_indicador,
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

-- 4) Comparativo por tipo de voo.
SELECT
    dop.tipo_de_voo,
    COUNT(*) AS total_entrevistas,
    ROUND(AVG(fe.satisfacao_geral), 3) AS media_satisfacao_geral,
    ROUND(100.0 * AVG(CASE WHEN fe.satisfacao_geral >= 4 THEN 1 ELSE 0 END), 2) AS percentual_positivo
FROM fato_entrevista fe
JOIN dim_operacao dop ON dop.operacao_key = fe.operacao_key
GROUP BY dop.tipo_de_voo
ORDER BY media_satisfacao_geral DESC;
