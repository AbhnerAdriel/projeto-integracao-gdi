-- Modelo dimensional final do projeto.
-- O pipeline cria as tabelas automaticamente, mas este arquivo documenta a estrutura esperada.

-- Dimensões:
-- dim_tempo(data_key, data, ano, trimestre, mes_numero, mes_nome, dia, dia_semana)
-- dim_aeroporto(aeroporto_key, codigo_icao, nome_aeroporto, cidade, uf, regiao)
-- dim_cia_aerea(cia_aerea_key, cia_aerea)
-- dim_operacao(operacao_key, processo, tipo_de_voo, conexao, forma_de_check_in, forma_de_desembarque_utilizada, terminal)
-- dim_perfil_passageiro(perfil_key, nacionalidade, genero, idade, escolaridade, renda_familiar, viajando_sozinho,
--                       motivo_da_viagem, quantidade_de_viagens_nos_ultimos_12_meses,
--                       ja_embarcou_desembarcou_antes_no_aeroporto, possui_deficiencia,
--                       utiliza_recurso_assistivo, solicitou_assistencia_especial)
-- dim_indicador(indicador_key, codigo_indicador, campo_original, categoria, tipo_indicador, somente_pcd, coluna_normalizada)

-- Fatos:
-- fato_entrevista: grão = 1 linha por entrevista/respondente.
-- fato_avaliacao: grão = 1 linha por avaliação de indicador feita em uma entrevista.
