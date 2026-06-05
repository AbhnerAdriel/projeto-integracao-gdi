"""Metadados manuais do projeto.

Aqui ficam duas informações importantes:
1. A referência dos 20 aeroportos principais avaliados pela pesquisa.
2. O mapa dos indicadores de satisfação usados para montar a tabela fato de avaliações.

Manter esse conteúdo centralizado ajuda a deixar o pipeline mais transparente e fácil
de conferir no relatório.
"""

from __future__ import annotations

import pandas as pd

from src.utils import to_snake_case


AIRPORTS = [
    {"codigo_icao": "SBGR", "nome_aeroporto": "Guarulhos / Governador André Franco Montoro", "cidade": "Guarulhos", "uf": "SP", "regiao": "Sudeste"},
    {"codigo_icao": "SBSP", "nome_aeroporto": "São Paulo / Congonhas", "cidade": "São Paulo", "uf": "SP", "regiao": "Sudeste"},
    {"codigo_icao": "SBBR", "nome_aeroporto": "Brasília / Pres. Juscelino Kubitschek", "cidade": "Brasília", "uf": "DF", "regiao": "Centro-Oeste"},
    {"codigo_icao": "SBGL", "nome_aeroporto": "Rio de Janeiro / Antônio Carlos Jobim - Galeão", "cidade": "Rio de Janeiro", "uf": "RJ", "regiao": "Sudeste"},
    {"codigo_icao": "SBCF", "nome_aeroporto": "Confins / Tancredo Neves", "cidade": "Confins", "uf": "MG", "regiao": "Sudeste"},
    {"codigo_icao": "SBKP", "nome_aeroporto": "Campinas / Viracopos", "cidade": "Campinas", "uf": "SP", "regiao": "Sudeste"},
    {"codigo_icao": "SBRJ", "nome_aeroporto": "Rio de Janeiro / Santos Dumont", "cidade": "Rio de Janeiro", "uf": "RJ", "regiao": "Sudeste"},
    {"codigo_icao": "SBPA", "nome_aeroporto": "Porto Alegre / Salgado Filho", "cidade": "Porto Alegre", "uf": "RS", "regiao": "Sul"},
    {"codigo_icao": "SBSV", "nome_aeroporto": "Salvador / Deputado Luís Eduardo Magalhães", "cidade": "Salvador", "uf": "BA", "regiao": "Nordeste"},
    {"codigo_icao": "SBRF", "nome_aeroporto": "Recife / Gilberto Freyre - Guararapes", "cidade": "Recife", "uf": "PE", "regiao": "Nordeste"},
    {"codigo_icao": "SBCT", "nome_aeroporto": "Curitiba / Afonso Pena", "cidade": "São José dos Pinhais", "uf": "PR", "regiao": "Sul"},
    {"codigo_icao": "SBFZ", "nome_aeroporto": "Fortaleza / Pinto Martins", "cidade": "Fortaleza", "uf": "CE", "regiao": "Nordeste"},
    {"codigo_icao": "SBFL", "nome_aeroporto": "Florianópolis / Hercílio Luz", "cidade": "Florianópolis", "uf": "SC", "regiao": "Sul"},
    {"codigo_icao": "SBBE", "nome_aeroporto": "Belém / Val de Cans - Júlio Cezar Ribeiro", "cidade": "Belém", "uf": "PA", "regiao": "Norte"},
    {"codigo_icao": "SBVT", "nome_aeroporto": "Vitória / Eurico de Aguiar Salles", "cidade": "Vitória", "uf": "ES", "regiao": "Sudeste"},
    {"codigo_icao": "SBGO", "nome_aeroporto": "Goiânia / Santa Genoveva", "cidade": "Goiânia", "uf": "GO", "regiao": "Centro-Oeste"},
    {"codigo_icao": "SBCY", "nome_aeroporto": "Cuiabá / Marechal Rondon", "cidade": "Várzea Grande", "uf": "MT", "regiao": "Centro-Oeste"},
    {"codigo_icao": "SBEG", "nome_aeroporto": "Manaus / Eduardo Gomes", "cidade": "Manaus", "uf": "AM", "regiao": "Norte"},
    {"codigo_icao": "SBSG", "nome_aeroporto": "Natal / Governador Aluízio Alves", "cidade": "São Gonçalo do Amarante", "uf": "RN", "regiao": "Nordeste"},
    {"codigo_icao": "SBMO", "nome_aeroporto": "Maceió / Zumbi dos Palmares", "cidade": "Rio Largo", "uf": "AL", "regiao": "Nordeste"},
]


# Cada item aponta para a coluna original da planilha e para o grupo analítico usado no DW.
INDICATORS = [
    {"codigo_indicador": "B1", "campo_original": "AVALIAÇÃO DO MÉTODO DE DESEMBARQUE", "categoria": "Desembarque", "tipo_indicador": "macro", "somente_pcd": "sim"},
    {"codigo_indicador": "A2", "campo_original": "FACILIDADE DE DESEMBARQUE NO MEIO-FIO", "categoria": "Acesso", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "A3", "campo_original": "OPÇÕES DE TRANSPORTE ATÉ O AEROPORTO", "categoria": "Acesso", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "C2", "campo_original": "PROCESSO DE CHECK IN", "categoria": "Check-in", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "C2.a", "campo_original": "TEMPO DE ESPERA NA FILA", "categoria": "Check-in", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "C2.b", "campo_original": "ORGANIZAÇÃO DAS FILAS", "categoria": "Check-in", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "C2.c", "campo_original": "QUANTIDADE DE TOTENS AA", "categoria": "Check-in", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "C2.d", "campo_original": "QUANTIDADE DE BALCÕES", "categoria": "Check-in", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "C2.e", "campo_original": "CORDIALIDADE DOS FUNCIONÁRIOS", "categoria": "Check-in", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "C2.f", "campo_original": "TEMPO DE ATENDIMENTO", "categoria": "Check-in", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "C3", "campo_original": "PROCESSO DE AQUISIÇÃO DA PASSAGEM", "categoria": "Compra da passagem", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "C4", "campo_original": "ATENDIMENTO DA CIA. AÉREA", "categoria": "Companhia aérea", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "S1", "campo_original": "PROCESSO DE INSPEÇÃO DE SEGURANÇA", "categoria": "Inspeção de segurança", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "S1.a", "campo_original": "TEMPO DE ESPERA EM FILA", "categoria": "Inspeção de segurança", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "S1.b", "campo_original": "ORGANIZAÇÃO DAS FILAS2", "categoria": "Inspeção de segurança", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "S1.c", "campo_original": "ATENDIMENTO DOS FUNCIONÁRIOS", "categoria": "Inspeção de segurança", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "O1", "campo_original": "CONTROLE MIGRATÓRIO", "categoria": "Órgãos públicos", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "O1.a", "campo_original": "TEMPO DE ESPERA EM FILA3", "categoria": "Órgãos públicos", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "O1.b", "campo_original": "ORGANIZAÇÃO DAS FILAS4", "categoria": "Órgãos públicos", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "O1.c", "campo_original": "ATENDIMENTO DOS FUNCIONÁRIOS5", "categoria": "Órgãos públicos", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "O1.d", "campo_original": "QUANTIDADE DE GUICHÊS", "categoria": "Órgãos públicos", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "O2", "campo_original": "CONTROLE ADUANEIRO", "categoria": "Órgãos públicos", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "O2.a", "campo_original": "TEMPO DE ESPERA EM FILA2", "categoria": "Órgãos públicos", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "O2.b", "campo_original": "ORGANIZAÇÃO DAS FILAS3", "categoria": "Órgãos públicos", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "O2.c", "campo_original": "ATENDIMENTO DOS FUNCIONÁRIOS4", "categoria": "Órgãos públicos", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M2", "campo_original": "ESTABELECIMENTOS DE ALIMENTAÇÃO", "categoria": "Comércio e serviços", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "M2.a", "campo_original": "QUANTIDADE DE ESTABELECIMENTOS DE ALIMENTAÇÃO", "categoria": "Comércio e serviços", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M2.b", "campo_original": "QUALIDADE E VARIEDADE DE OPÇÕES DE ESTABELECIMENTOS DE ALIMENTAÇÃO", "categoria": "Comércio e serviços", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M2.c", "campo_original": "RELAÇÃO PREÇO x QUALIDADE DOS ESTABELECIMENTOS DE ALIMENTAÇÃO", "categoria": "Comércio e serviços", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M4", "campo_original": "ESTABELECIMENTOS COMERCIAIS", "categoria": "Comércio e serviços", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "M4.a", "campo_original": "QUANTIDADE DE ESTABELECIMENTOS COMERCIAIS", "categoria": "Comércio e serviços", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M4.b", "campo_original": "QUALIDADE E VARIEDADE DE OPÇÕES DE ESTABELECIMENTOS COMERCIAIS", "categoria": "Comércio e serviços", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M4.c", "campo_original": "RELAÇÃO PREÇO x QUALIDADE DOS ESTABELECIMENTOS COMERCIAIS", "categoria": "Comércio e serviços", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M5", "campo_original": "ESTACIONAMENTO", "categoria": "Estacionamento", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "M5.a", "campo_original": "QUALIDADE DAS INSTALAÇÕES DE ESTACIONAMENTO", "categoria": "Estacionamento", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M5.b", "campo_original": "FACILIDADE PARA ENCONTRAR VAGAS", "categoria": "Estacionamento", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M5.c", "campo_original": "FACILIDADE DE ACESSO AO TERMINAL", "categoria": "Estacionamento", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "M5.d", "campo_original": "RELAÇÃO CUSTO X BENEFÍCIO", "categoria": "Estacionamento", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R1", "campo_original": "LOCALIZAÇÃO E DESLOCAMENTO", "categoria": "Infraestrutura", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "R1.a", "campo_original": "SINALIZAÇÃO", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R1.c", "campo_original": "DISPONIBILIDADE DE PAINÉIS DE INFORMAÇÕES DE VOO", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R1.b", "campo_original": "ACESSIBILIDADE DO TERMINAL", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "sim"},
    {"codigo_indicador": "R2", "campo_original": "CONFORTO DA SALA DE EMBARQUE", "categoria": "Infraestrutura", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "R2.a", "campo_original": "CONFORTO TÉRMICO", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R2.b", "campo_original": "CONFORTO ACÚSTICO", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R2.c", "campo_original": "DISPONIBILIDADE DE ASSENTOS", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R3", "campo_original": "DISPONIBILIDADE DE ASSENTOS RESERVADOS", "categoria": "Infraestrutura", "tipo_indicador": "macro", "somente_pcd": "sim"},
    {"codigo_indicador": "R4", "campo_original": "DISPONIBILIDADE DE TOMADAS", "categoria": "Infraestrutura", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "R6", "campo_original": "INTERNET DISPONIBILIZADA PELO AEROPORTO", "categoria": "Infraestrutura", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "R6.a", "campo_original": "VELOCIDADE DE CONEXÃO", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R6.b", "campo_original": "FACILIDADE DE ACESSO À REDE", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R8", "campo_original": "SANITÁRIOS", "categoria": "Infraestrutura", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "R8.a", "campo_original": "QUANTIDADE DE BANHEIROS", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R8.b", "campo_original": "LIMPEZA DOS BANHEIROS", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R8.c", "campo_original": "MANUTENÇÃO GERAL DOS SANITÁRIOS", "categoria": "Infraestrutura", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "R9", "campo_original": "LIMPEZA GERAL DO AEROPORTO", "categoria": "Infraestrutura", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "B3", "campo_original": "PROCESSO DE RESTITUIÇÃO DE BAGAGENS", "categoria": "Bagagem", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "B3.a", "campo_original": "FACILIDADE DE IDENTIFICAÇÃO DA ESTEIRA DE RESTITUIÇÃO", "categoria": "Bagagem", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "B3.b", "campo_original": "TEMPO DE RESTITUIÇÃO", "categoria": "Bagagem", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "B3.c", "campo_original": "INTEGRIDADE DA BAGAGEM", "categoria": "Bagagem", "tipo_indicador": "subindicador", "somente_pcd": "não"},
    {"codigo_indicador": "B4", "campo_original": "ATENDIMENTO DA CIA. AÉREA2", "categoria": "Companhia aérea", "tipo_indicador": "macro", "somente_pcd": "não"},
    {"codigo_indicador": "G1", "campo_original": "SATISFAÇÃO GERAL", "categoria": "Satisfação geral", "tipo_indicador": "geral", "somente_pcd": "não"},
]


def get_airports_df() -> pd.DataFrame:
    """Retorna a dimensão de aeroportos com chave substituta."""
    df = pd.DataFrame(AIRPORTS).sort_values("codigo_icao").reset_index(drop=True)
    df.insert(0, "aeroporto_key", range(1, len(df) + 1))
    return df


def get_indicators_df() -> pd.DataFrame:
    """Retorna a dimensão de indicadores com chave substituta e nome de coluna padronizado."""
    df = pd.DataFrame(INDICATORS).copy()
    df["coluna_normalizada"] = df["campo_original"].apply(to_snake_case)
    # Ajuste pontual: o processo de normalização remove o ponto dos nomes duplicados,
    # mas as colunas da planilha já têm nomes exclusivos como ORGANIZAÇÃO DAS FILAS2.
    df = df.sort_values("codigo_indicador").reset_index(drop=True)
    df.insert(0, "indicador_key", range(1, len(df) + 1))
    return df
