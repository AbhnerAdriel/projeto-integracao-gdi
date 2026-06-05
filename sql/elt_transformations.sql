-- Transformações ELT do projeto de satisfação em aeroportos.
-- Este script é executado dentro do SQLite após a carga das tabelas de staging.

DROP TABLE IF EXISTS dim_tempo;
CREATE TABLE dim_tempo AS
SELECT DISTINCT
    data_key,
    DATE(data) AS data,
    CAST(STRFTIME('%Y', data) AS INTEGER) AS ano,
    1 AS trimestre,
    CAST(STRFTIME('%m', data) AS INTEGER) AS mes_numero,
    CASE CAST(STRFTIME('%m', data) AS INTEGER)
        WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
    END AS mes_nome,
    CAST(STRFTIME('%d', data) AS INTEGER) AS dia,
    CASE STRFTIME('%w', data)
        WHEN '0' THEN 'Domingo' WHEN '1' THEN 'Segunda-feira' WHEN '2' THEN 'Terça-feira'
        WHEN '3' THEN 'Quarta-feira' WHEN '4' THEN 'Quinta-feira' WHEN '5' THEN 'Sexta-feira'
        WHEN '6' THEN 'Sábado'
    END AS dia_semana
FROM stg_pesquisa_satisfacao
WHERE data IS NOT NULL;

DROP TABLE IF EXISTS dim_aeroporto;
CREATE TABLE dim_aeroporto AS
SELECT * FROM ref_aeroportos;

DROP TABLE IF EXISTS dim_cia_aerea;
CREATE TABLE dim_cia_aerea AS
SELECT
    ROW_NUMBER() OVER (ORDER BY COALESCE(NULLIF(TRIM(cia_aerea), ''), 'Não informado')) AS cia_aerea_key,
    COALESCE(NULLIF(TRIM(cia_aerea), ''), 'Não informado') AS cia_aerea
FROM stg_pesquisa_satisfacao
GROUP BY COALESCE(NULLIF(TRIM(cia_aerea), ''), 'Não informado');

DROP TABLE IF EXISTS dim_operacao;
CREATE TABLE dim_operacao AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY COALESCE(NULLIF(TRIM(processo), ''), 'Não informado'), COALESCE(NULLIF(TRIM(tipo_de_voo), ''), 'Não informado'), COALESCE(NULLIF(TRIM(conexao), ''), 'Não informado'),
                 COALESCE(NULLIF(TRIM(forma_de_check_in), ''), 'Não informado'), COALESCE(NULLIF(TRIM(forma_de_desembarque_utilizada), ''), 'Não informado'), COALESCE(NULLIF(TRIM(terminal), ''), 'Não informado')
    ) AS operacao_key,
    COALESCE(NULLIF(TRIM(processo), ''), 'Não informado') AS processo,
    COALESCE(NULLIF(TRIM(tipo_de_voo), ''), 'Não informado') AS tipo_de_voo,
    COALESCE(NULLIF(TRIM(conexao), ''), 'Não informado') AS conexao,
    COALESCE(NULLIF(TRIM(forma_de_check_in), ''), 'Não informado') AS forma_de_check_in,
    COALESCE(NULLIF(TRIM(forma_de_desembarque_utilizada), ''), 'Não informado') AS forma_de_desembarque_utilizada,
    COALESCE(NULLIF(TRIM(terminal), ''), 'Não informado') AS terminal
FROM stg_pesquisa_satisfacao
GROUP BY 2,3,4,5,6,7;

DROP TABLE IF EXISTS dim_perfil_passageiro;
CREATE TABLE dim_perfil_passageiro AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY COALESCE(NULLIF(TRIM(nacionalidade), ''), 'Não informado'), COALESCE(NULLIF(TRIM(genero), ''), 'Não informado'), COALESCE(NULLIF(TRIM(idade), ''), 'Não informado'), COALESCE(NULLIF(TRIM(escolaridade), ''), 'Não informado'),
                 COALESCE(NULLIF(TRIM(renda_familiar), ''), 'Não informado'), COALESCE(NULLIF(TRIM(viajando_sozinho), ''), 'Não informado'), COALESCE(NULLIF(TRIM(motivo_da_viagem), ''), 'Não informado'),
                 COALESCE(NULLIF(TRIM(quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado'), COALESCE(NULLIF(TRIM(ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado'),
                 COALESCE(NULLIF(TRIM(possui_deficiencia), ''), 'Não informado'), COALESCE(NULLIF(TRIM(utiliza_recurso_assistivo), ''), 'Não informado'), COALESCE(NULLIF(TRIM(solicitou_assistencia_especial), ''), 'Não informado')
    ) AS perfil_key,
    COALESCE(NULLIF(TRIM(nacionalidade), ''), 'Não informado') AS nacionalidade,
    COALESCE(NULLIF(TRIM(genero), ''), 'Não informado') AS genero,
    COALESCE(NULLIF(TRIM(idade), ''), 'Não informado') AS idade,
    COALESCE(NULLIF(TRIM(escolaridade), ''), 'Não informado') AS escolaridade,
    COALESCE(NULLIF(TRIM(renda_familiar), ''), 'Não informado') AS renda_familiar,
    COALESCE(NULLIF(TRIM(viajando_sozinho), ''), 'Não informado') AS viajando_sozinho,
    COALESCE(NULLIF(TRIM(motivo_da_viagem), ''), 'Não informado') AS motivo_da_viagem,
    COALESCE(NULLIF(TRIM(quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado') AS quantidade_de_viagens_nos_ultimos_12_meses,
    COALESCE(NULLIF(TRIM(ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado') AS ja_embarcou_desembarcou_antes_no_aeroporto,
    COALESCE(NULLIF(TRIM(possui_deficiencia), ''), 'Não informado') AS possui_deficiencia,
    COALESCE(NULLIF(TRIM(utiliza_recurso_assistivo), ''), 'Não informado') AS utiliza_recurso_assistivo,
    COALESCE(NULLIF(TRIM(solicitou_assistencia_especial), ''), 'Não informado') AS solicitou_assistencia_especial
FROM stg_pesquisa_satisfacao
GROUP BY 2,3,4,5,6,7,8,9,10,11,12,13;

DROP TABLE IF EXISTS dim_indicador;
CREATE TABLE dim_indicador AS
SELECT * FROM ref_indicadores;

DROP TABLE IF EXISTS fato_entrevista;
CREATE TABLE fato_entrevista AS
SELECT
    ROW_NUMBER() OVER (ORDER BY s.chave) AS entrevista_key,
    s.chave,
    s.ano_fonte,
    s.arquivo_origem,
    s.data_key,
    da.aeroporto_key,
    dca.cia_aerea_key,
    dop.operacao_key,
    dpp.perfil_key,
    s.inicio_coleta,
    s.fim_coleta,
    COALESCE(NULLIF(TRIM(s.voo), ''), 'Não informado') AS voo,
    COALESCE(NULLIF(TRIM(s.aquisicao_da_passagem), ''), 'Não informado') AS aquisicao_da_passagem,
    COALESCE(NULLIF(TRIM(s.meio_de_aquisicao_da_passagem), ''), 'Não informado') AS meio_de_aquisicao_da_passagem,
    COALESCE(NULLIF(TRIM(s.meio_de_transporte_para_o_aeroporto), ''), 'Não informado') AS meio_de_transporte_para_o_aeroporto,
    COALESCE(NULLIF(TRIM(s.utilizou_o_estacionamento), ''), 'Não informado') AS utilizou_o_estacionamento,
    CAST(s.numero_de_acompanhantes AS REAL) AS numero_de_acompanhantes,
    CAST(s.antecedencia AS REAL) AS antecedencia,
    CAST(s.tempo_de_espera AS REAL) AS tempo_de_espera,
    CASE WHEN CAST(s.satisfacao_geral AS REAL) BETWEEN 1 AND 5 THEN CAST(s.satisfacao_geral AS REAL) ELSE NULL END AS satisfacao_geral,
    COALESCE(NULLIF(TRIM(s.motivo), ''), 'Não informado') AS motivo,
    COALESCE(NULLIF(TRIM(s.comentarios_adicionais), ''), 'Não informado') AS comentarios_adicionais
FROM stg_pesquisa_satisfacao s
LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
LEFT JOIN dim_cia_aerea dca ON dca.cia_aerea = COALESCE(NULLIF(TRIM(s.cia_aerea), ''), 'Não informado')
LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado');

DROP TABLE IF EXISTS fato_avaliacao;
CREATE TABLE fato_avaliacao AS
SELECT
    ROW_NUMBER() OVER (ORDER BY chave, indicador_key) AS avaliacao_key,
    *
FROM (

SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.facilidade_de_desembarque_no_meio_fio AS REAL) AS nota,
        CASE WHEN CAST(s.facilidade_de_desembarque_no_meio_fio AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.facilidade_de_desembarque_no_meio_fio AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'facilidade_de_desembarque_no_meio_fio'
    WHERE CAST(s.facilidade_de_desembarque_no_meio_fio AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.opcoes_de_transporte_ate_o_aeroporto AS REAL) AS nota,
        CASE WHEN CAST(s.opcoes_de_transporte_ate_o_aeroporto AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.opcoes_de_transporte_ate_o_aeroporto AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'opcoes_de_transporte_ate_o_aeroporto'
    WHERE CAST(s.opcoes_de_transporte_ate_o_aeroporto AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.avaliacao_do_metodo_de_desembarque AS REAL) AS nota,
        CASE WHEN CAST(s.avaliacao_do_metodo_de_desembarque AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.avaliacao_do_metodo_de_desembarque AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'avaliacao_do_metodo_de_desembarque'
    WHERE CAST(s.avaliacao_do_metodo_de_desembarque AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.processo_de_restituicao_de_bagagens AS REAL) AS nota,
        CASE WHEN CAST(s.processo_de_restituicao_de_bagagens AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.processo_de_restituicao_de_bagagens AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'processo_de_restituicao_de_bagagens'
    WHERE CAST(s.processo_de_restituicao_de_bagagens AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.facilidade_de_identificacao_da_esteira_de_restituicao AS REAL) AS nota,
        CASE WHEN CAST(s.facilidade_de_identificacao_da_esteira_de_restituicao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.facilidade_de_identificacao_da_esteira_de_restituicao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'facilidade_de_identificacao_da_esteira_de_restituicao'
    WHERE CAST(s.facilidade_de_identificacao_da_esteira_de_restituicao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.tempo_de_restituicao AS REAL) AS nota,
        CASE WHEN CAST(s.tempo_de_restituicao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.tempo_de_restituicao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'tempo_de_restituicao'
    WHERE CAST(s.tempo_de_restituicao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.integridade_da_bagagem AS REAL) AS nota,
        CASE WHEN CAST(s.integridade_da_bagagem AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.integridade_da_bagagem AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'integridade_da_bagagem'
    WHERE CAST(s.integridade_da_bagagem AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.atendimento_da_cia_aerea2 AS REAL) AS nota,
        CASE WHEN CAST(s.atendimento_da_cia_aerea2 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.atendimento_da_cia_aerea2 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'atendimento_da_cia_aerea2'
    WHERE CAST(s.atendimento_da_cia_aerea2 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.processo_de_check_in AS REAL) AS nota,
        CASE WHEN CAST(s.processo_de_check_in AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.processo_de_check_in AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'processo_de_check_in'
    WHERE CAST(s.processo_de_check_in AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.tempo_de_espera_na_fila AS REAL) AS nota,
        CASE WHEN CAST(s.tempo_de_espera_na_fila AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.tempo_de_espera_na_fila AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'tempo_de_espera_na_fila'
    WHERE CAST(s.tempo_de_espera_na_fila AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.organizacao_das_filas AS REAL) AS nota,
        CASE WHEN CAST(s.organizacao_das_filas AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.organizacao_das_filas AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'organizacao_das_filas'
    WHERE CAST(s.organizacao_das_filas AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.quantidade_de_totens_aa AS REAL) AS nota,
        CASE WHEN CAST(s.quantidade_de_totens_aa AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.quantidade_de_totens_aa AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'quantidade_de_totens_aa'
    WHERE CAST(s.quantidade_de_totens_aa AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.quantidade_de_balcoes AS REAL) AS nota,
        CASE WHEN CAST(s.quantidade_de_balcoes AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.quantidade_de_balcoes AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'quantidade_de_balcoes'
    WHERE CAST(s.quantidade_de_balcoes AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.cordialidade_dos_funcionarios AS REAL) AS nota,
        CASE WHEN CAST(s.cordialidade_dos_funcionarios AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.cordialidade_dos_funcionarios AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'cordialidade_dos_funcionarios'
    WHERE CAST(s.cordialidade_dos_funcionarios AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.tempo_de_atendimento AS REAL) AS nota,
        CASE WHEN CAST(s.tempo_de_atendimento AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.tempo_de_atendimento AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'tempo_de_atendimento'
    WHERE CAST(s.tempo_de_atendimento AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.processo_de_aquisicao_da_passagem AS REAL) AS nota,
        CASE WHEN CAST(s.processo_de_aquisicao_da_passagem AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.processo_de_aquisicao_da_passagem AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'processo_de_aquisicao_da_passagem'
    WHERE CAST(s.processo_de_aquisicao_da_passagem AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.atendimento_da_cia_aerea AS REAL) AS nota,
        CASE WHEN CAST(s.atendimento_da_cia_aerea AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.atendimento_da_cia_aerea AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'atendimento_da_cia_aerea'
    WHERE CAST(s.atendimento_da_cia_aerea AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.satisfacao_geral AS REAL) AS nota,
        CASE WHEN CAST(s.satisfacao_geral AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.satisfacao_geral AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'satisfacao_geral'
    WHERE CAST(s.satisfacao_geral AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.estabelecimentos_de_alimentacao AS REAL) AS nota,
        CASE WHEN CAST(s.estabelecimentos_de_alimentacao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.estabelecimentos_de_alimentacao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'estabelecimentos_de_alimentacao'
    WHERE CAST(s.estabelecimentos_de_alimentacao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.quantidade_de_estabelecimentos_de_alimentacao AS REAL) AS nota,
        CASE WHEN CAST(s.quantidade_de_estabelecimentos_de_alimentacao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.quantidade_de_estabelecimentos_de_alimentacao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'quantidade_de_estabelecimentos_de_alimentacao'
    WHERE CAST(s.quantidade_de_estabelecimentos_de_alimentacao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_de_alimentacao AS REAL) AS nota,
        CASE WHEN CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_de_alimentacao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_de_alimentacao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'qualidade_e_variedade_de_opcoes_de_estabelecimentos_de_alimentacao'
    WHERE CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_de_alimentacao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_de_alimentacao AS REAL) AS nota,
        CASE WHEN CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_de_alimentacao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_de_alimentacao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'relacao_preco_x_qualidade_dos_estabelecimentos_de_alimentacao'
    WHERE CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_de_alimentacao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.estabelecimentos_comerciais AS REAL) AS nota,
        CASE WHEN CAST(s.estabelecimentos_comerciais AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.estabelecimentos_comerciais AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'estabelecimentos_comerciais'
    WHERE CAST(s.estabelecimentos_comerciais AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.quantidade_de_estabelecimentos_comerciais AS REAL) AS nota,
        CASE WHEN CAST(s.quantidade_de_estabelecimentos_comerciais AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.quantidade_de_estabelecimentos_comerciais AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'quantidade_de_estabelecimentos_comerciais'
    WHERE CAST(s.quantidade_de_estabelecimentos_comerciais AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_comerciais AS REAL) AS nota,
        CASE WHEN CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_comerciais AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_comerciais AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'qualidade_e_variedade_de_opcoes_de_estabelecimentos_comerciais'
    WHERE CAST(s.qualidade_e_variedade_de_opcoes_de_estabelecimentos_comerciais AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_comerciais AS REAL) AS nota,
        CASE WHEN CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_comerciais AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_comerciais AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'relacao_preco_x_qualidade_dos_estabelecimentos_comerciais'
    WHERE CAST(s.relacao_preco_x_qualidade_dos_estabelecimentos_comerciais AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.estacionamento AS REAL) AS nota,
        CASE WHEN CAST(s.estacionamento AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.estacionamento AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'estacionamento'
    WHERE CAST(s.estacionamento AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.qualidade_das_instalacoes_de_estacionamento AS REAL) AS nota,
        CASE WHEN CAST(s.qualidade_das_instalacoes_de_estacionamento AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.qualidade_das_instalacoes_de_estacionamento AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'qualidade_das_instalacoes_de_estacionamento'
    WHERE CAST(s.qualidade_das_instalacoes_de_estacionamento AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.facilidade_para_encontrar_vagas AS REAL) AS nota,
        CASE WHEN CAST(s.facilidade_para_encontrar_vagas AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.facilidade_para_encontrar_vagas AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'facilidade_para_encontrar_vagas'
    WHERE CAST(s.facilidade_para_encontrar_vagas AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.facilidade_de_acesso_ao_terminal AS REAL) AS nota,
        CASE WHEN CAST(s.facilidade_de_acesso_ao_terminal AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.facilidade_de_acesso_ao_terminal AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'facilidade_de_acesso_ao_terminal'
    WHERE CAST(s.facilidade_de_acesso_ao_terminal AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.relacao_custo_x_beneficio AS REAL) AS nota,
        CASE WHEN CAST(s.relacao_custo_x_beneficio AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.relacao_custo_x_beneficio AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'relacao_custo_x_beneficio'
    WHERE CAST(s.relacao_custo_x_beneficio AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.controle_migratorio AS REAL) AS nota,
        CASE WHEN CAST(s.controle_migratorio AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.controle_migratorio AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'controle_migratorio'
    WHERE CAST(s.controle_migratorio AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.tempo_de_espera_em_fila3 AS REAL) AS nota,
        CASE WHEN CAST(s.tempo_de_espera_em_fila3 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.tempo_de_espera_em_fila3 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'tempo_de_espera_em_fila3'
    WHERE CAST(s.tempo_de_espera_em_fila3 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.organizacao_das_filas4 AS REAL) AS nota,
        CASE WHEN CAST(s.organizacao_das_filas4 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.organizacao_das_filas4 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'organizacao_das_filas4'
    WHERE CAST(s.organizacao_das_filas4 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.atendimento_dos_funcionarios5 AS REAL) AS nota,
        CASE WHEN CAST(s.atendimento_dos_funcionarios5 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.atendimento_dos_funcionarios5 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'atendimento_dos_funcionarios5'
    WHERE CAST(s.atendimento_dos_funcionarios5 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.quantidade_de_guiches AS REAL) AS nota,
        CASE WHEN CAST(s.quantidade_de_guiches AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.quantidade_de_guiches AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'quantidade_de_guiches'
    WHERE CAST(s.quantidade_de_guiches AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.controle_aduaneiro AS REAL) AS nota,
        CASE WHEN CAST(s.controle_aduaneiro AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.controle_aduaneiro AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'controle_aduaneiro'
    WHERE CAST(s.controle_aduaneiro AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.tempo_de_espera_em_fila2 AS REAL) AS nota,
        CASE WHEN CAST(s.tempo_de_espera_em_fila2 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.tempo_de_espera_em_fila2 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'tempo_de_espera_em_fila2'
    WHERE CAST(s.tempo_de_espera_em_fila2 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.organizacao_das_filas3 AS REAL) AS nota,
        CASE WHEN CAST(s.organizacao_das_filas3 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.organizacao_das_filas3 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'organizacao_das_filas3'
    WHERE CAST(s.organizacao_das_filas3 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.atendimento_dos_funcionarios4 AS REAL) AS nota,
        CASE WHEN CAST(s.atendimento_dos_funcionarios4 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.atendimento_dos_funcionarios4 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'atendimento_dos_funcionarios4'
    WHERE CAST(s.atendimento_dos_funcionarios4 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.localizacao_e_deslocamento AS REAL) AS nota,
        CASE WHEN CAST(s.localizacao_e_deslocamento AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.localizacao_e_deslocamento AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'localizacao_e_deslocamento'
    WHERE CAST(s.localizacao_e_deslocamento AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.sinalizacao AS REAL) AS nota,
        CASE WHEN CAST(s.sinalizacao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.sinalizacao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'sinalizacao'
    WHERE CAST(s.sinalizacao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.acessibilidade_do_terminal AS REAL) AS nota,
        CASE WHEN CAST(s.acessibilidade_do_terminal AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.acessibilidade_do_terminal AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'acessibilidade_do_terminal'
    WHERE CAST(s.acessibilidade_do_terminal AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.disponibilidade_de_paineis_de_informacoes_de_voo AS REAL) AS nota,
        CASE WHEN CAST(s.disponibilidade_de_paineis_de_informacoes_de_voo AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.disponibilidade_de_paineis_de_informacoes_de_voo AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'disponibilidade_de_paineis_de_informacoes_de_voo'
    WHERE CAST(s.disponibilidade_de_paineis_de_informacoes_de_voo AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.conforto_da_sala_de_embarque AS REAL) AS nota,
        CASE WHEN CAST(s.conforto_da_sala_de_embarque AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.conforto_da_sala_de_embarque AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'conforto_da_sala_de_embarque'
    WHERE CAST(s.conforto_da_sala_de_embarque AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.conforto_termico AS REAL) AS nota,
        CASE WHEN CAST(s.conforto_termico AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.conforto_termico AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'conforto_termico'
    WHERE CAST(s.conforto_termico AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.conforto_acustico AS REAL) AS nota,
        CASE WHEN CAST(s.conforto_acustico AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.conforto_acustico AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'conforto_acustico'
    WHERE CAST(s.conforto_acustico AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.disponibilidade_de_assentos AS REAL) AS nota,
        CASE WHEN CAST(s.disponibilidade_de_assentos AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.disponibilidade_de_assentos AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'disponibilidade_de_assentos'
    WHERE CAST(s.disponibilidade_de_assentos AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.disponibilidade_de_assentos_reservados AS REAL) AS nota,
        CASE WHEN CAST(s.disponibilidade_de_assentos_reservados AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.disponibilidade_de_assentos_reservados AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'disponibilidade_de_assentos_reservados'
    WHERE CAST(s.disponibilidade_de_assentos_reservados AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.disponibilidade_de_tomadas AS REAL) AS nota,
        CASE WHEN CAST(s.disponibilidade_de_tomadas AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.disponibilidade_de_tomadas AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'disponibilidade_de_tomadas'
    WHERE CAST(s.disponibilidade_de_tomadas AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.internet_disponibilizada_pelo_aeroporto AS REAL) AS nota,
        CASE WHEN CAST(s.internet_disponibilizada_pelo_aeroporto AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.internet_disponibilizada_pelo_aeroporto AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'internet_disponibilizada_pelo_aeroporto'
    WHERE CAST(s.internet_disponibilizada_pelo_aeroporto AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.velocidade_de_conexao AS REAL) AS nota,
        CASE WHEN CAST(s.velocidade_de_conexao AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.velocidade_de_conexao AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'velocidade_de_conexao'
    WHERE CAST(s.velocidade_de_conexao AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.facilidade_de_acesso_a_rede AS REAL) AS nota,
        CASE WHEN CAST(s.facilidade_de_acesso_a_rede AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.facilidade_de_acesso_a_rede AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'facilidade_de_acesso_a_rede'
    WHERE CAST(s.facilidade_de_acesso_a_rede AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.sanitarios AS REAL) AS nota,
        CASE WHEN CAST(s.sanitarios AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.sanitarios AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'sanitarios'
    WHERE CAST(s.sanitarios AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.quantidade_de_banheiros AS REAL) AS nota,
        CASE WHEN CAST(s.quantidade_de_banheiros AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.quantidade_de_banheiros AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'quantidade_de_banheiros'
    WHERE CAST(s.quantidade_de_banheiros AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.limpeza_dos_banheiros AS REAL) AS nota,
        CASE WHEN CAST(s.limpeza_dos_banheiros AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.limpeza_dos_banheiros AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'limpeza_dos_banheiros'
    WHERE CAST(s.limpeza_dos_banheiros AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.manutencao_geral_dos_sanitarios AS REAL) AS nota,
        CASE WHEN CAST(s.manutencao_geral_dos_sanitarios AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.manutencao_geral_dos_sanitarios AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'manutencao_geral_dos_sanitarios'
    WHERE CAST(s.manutencao_geral_dos_sanitarios AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.limpeza_geral_do_aeroporto AS REAL) AS nota,
        CASE WHEN CAST(s.limpeza_geral_do_aeroporto AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.limpeza_geral_do_aeroporto AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'limpeza_geral_do_aeroporto'
    WHERE CAST(s.limpeza_geral_do_aeroporto AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.processo_de_inspecao_de_seguranca AS REAL) AS nota,
        CASE WHEN CAST(s.processo_de_inspecao_de_seguranca AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.processo_de_inspecao_de_seguranca AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'processo_de_inspecao_de_seguranca'
    WHERE CAST(s.processo_de_inspecao_de_seguranca AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.tempo_de_espera_em_fila AS REAL) AS nota,
        CASE WHEN CAST(s.tempo_de_espera_em_fila AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.tempo_de_espera_em_fila AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'tempo_de_espera_em_fila'
    WHERE CAST(s.tempo_de_espera_em_fila AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.organizacao_das_filas2 AS REAL) AS nota,
        CASE WHEN CAST(s.organizacao_das_filas2 AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.organizacao_das_filas2 AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'organizacao_das_filas2'
    WHERE CAST(s.organizacao_das_filas2 AS REAL) BETWEEN 1 AND 5    UNION ALL
SELECT
        s.chave,
        s.ano_fonte,
        s.data_key,
        da.aeroporto_key,
        dop.operacao_key,
        dpp.perfil_key,
        di.indicador_key,
        CAST(s.atendimento_dos_funcionarios AS REAL) AS nota,
        CASE WHEN CAST(s.atendimento_dos_funcionarios AS REAL) >= 4 THEN 1 ELSE 0 END AS nota_positiva,
        CASE WHEN CAST(s.atendimento_dos_funcionarios AS REAL) <= 3 THEN 1 ELSE 0 END AS nota_negativa_ou_neutra
    FROM stg_pesquisa_satisfacao s
    LEFT JOIN dim_aeroporto da ON da.codigo_icao = s.aeroporto
    LEFT JOIN dim_operacao dop
        ON dop.processo = COALESCE(NULLIF(TRIM(s.processo), ''), 'Não informado')
       AND dop.tipo_de_voo = COALESCE(NULLIF(TRIM(s.tipo_de_voo), ''), 'Não informado')
       AND dop.conexao = COALESCE(NULLIF(TRIM(s.conexao), ''), 'Não informado')
       AND dop.forma_de_check_in = COALESCE(NULLIF(TRIM(s.forma_de_check_in), ''), 'Não informado')
       AND dop.forma_de_desembarque_utilizada = COALESCE(NULLIF(TRIM(s.forma_de_desembarque_utilizada), ''), 'Não informado')
       AND dop.terminal = COALESCE(NULLIF(TRIM(s.terminal), ''), 'Não informado')
    LEFT JOIN dim_perfil_passageiro dpp
        ON dpp.nacionalidade = COALESCE(NULLIF(TRIM(s.nacionalidade), ''), 'Não informado')
       AND dpp.genero = COALESCE(NULLIF(TRIM(s.genero), ''), 'Não informado')
       AND dpp.idade = COALESCE(NULLIF(TRIM(s.idade), ''), 'Não informado')
       AND dpp.escolaridade = COALESCE(NULLIF(TRIM(s.escolaridade), ''), 'Não informado')
       AND dpp.renda_familiar = COALESCE(NULLIF(TRIM(s.renda_familiar), ''), 'Não informado')
       AND dpp.viajando_sozinho = COALESCE(NULLIF(TRIM(s.viajando_sozinho), ''), 'Não informado')
       AND dpp.motivo_da_viagem = COALESCE(NULLIF(TRIM(s.motivo_da_viagem), ''), 'Não informado')
       AND dpp.quantidade_de_viagens_nos_ultimos_12_meses = COALESCE(NULLIF(TRIM(s.quantidade_de_viagens_nos_ultimos_12_meses), ''), 'Não informado')
       AND dpp.ja_embarcou_desembarcou_antes_no_aeroporto = COALESCE(NULLIF(TRIM(s.ja_embarcou_desembarcou_antes_no_aeroporto), ''), 'Não informado')
       AND dpp.possui_deficiencia = COALESCE(NULLIF(TRIM(s.possui_deficiencia), ''), 'Não informado')
       AND dpp.utiliza_recurso_assistivo = COALESCE(NULLIF(TRIM(s.utiliza_recurso_assistivo), ''), 'Não informado')
       AND dpp.solicitou_assistencia_especial = COALESCE(NULLIF(TRIM(s.solicitou_assistencia_especial), ''), 'Não informado')
    JOIN dim_indicador di ON di.coluna_normalizada = 'atendimento_dos_funcionarios'
    WHERE CAST(s.atendimento_dos_funcionarios AS REAL) BETWEEN 1 AND 5
);

CREATE INDEX IF NOT EXISTS idx_elt_fato_entrevista_chave ON fato_entrevista(chave);
CREATE INDEX IF NOT EXISTS idx_elt_fato_entrevista_data ON fato_entrevista(data_key);
CREATE INDEX IF NOT EXISTS idx_elt_fato_avaliacao_indicador ON fato_avaliacao(indicador_key);
CREATE INDEX IF NOT EXISTS idx_elt_fato_avaliacao_aeroporto ON fato_avaliacao(aeroporto_key);
