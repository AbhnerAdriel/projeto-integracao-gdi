# Dicionário de Dados do Data Warehouse

## Visão geral

O Data Warehouse foi modelado em Esquema Estrela. A tabela `fato_entrevista` guarda uma entrevista por linha, enquanto `fato_avaliacao` guarda uma avaliação por indicador por entrevista.

## Tabelas

| Tabela | Tipo | Grão | Finalidade |
|---|---|---|---|
| dim_tempo | Dimensão | uma data | Permite análise por ano, trimestre, mês, dia e dia da semana |
| dim_aeroporto | Dimensão | um aeroporto | Identifica aeroporto, cidade, UF e região |
| dim_cia_aerea | Dimensão | uma companhia aérea | Permite análise por companhia aérea |
| dim_operacao | Dimensão | combinação de processo/tipo de voo/conexão/check-in/desembarque/terminal | Descreve o contexto operacional da entrevista |
| dim_perfil_passageiro | Dimensão | combinação de atributos de perfil | Permite análise por perfil declarado do passageiro |
| dim_indicador | Dimensão | um indicador da pesquisa | Identifica indicador, categoria e tipo |
| fato_entrevista | Fato | uma entrevista | Guarda a resposta principal de cada entrevista |
| fato_avaliacao | Fato | uma avaliação de indicador em uma entrevista | Guarda notas de 1 a 5 para análise detalhada por indicador |

## Observações importantes

- Valores `NS/NR` não foram considerados como nota válida.
- As notas seguem a escala de 1 a 5 da metodologia da pesquisa.
- O campo `data_key` usa o formato `AAAAMMDD`.
- As chaves terminadas em `_key` são chaves substitutas criadas pelo pipeline.
