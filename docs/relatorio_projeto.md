# Relatório do Projeto de Integração

**Tema:** Indicadores que avaliam a satisfação do passageiro com os processos e serviços aeroportuários a ele oferecidos, coletados nos 20 aeroportos principais durante a pesquisa.  
**Disciplina:** Banco de Dados - Projeto de Integração - 2026.1  
**Curso:** Ciência da Computação - Centro de Informática - UFPE  
**Aluno:** Abhner Adriel Cristóvão Silva - abhner.adriel

## 1. Descrição da Base de Dados Unificada

A base unificada foi criada a partir de três planilhas da Pesquisa de Satisfação do Passageiro em Aeroportos, referentes ao 1º trimestre de 2024, 2025 e 2026. Cada arquivo representa um período anual da mesma pesquisa e possui a mesma estrutura de 98 campos principais, além das informações técnicas de origem adicionadas no pipeline.

Depois da integração, a base consolidada ficou com **77,194 entrevistas** e **533,891 avaliações de indicadores**. A modelagem final foi feita em **Esquema Estrela**, usando o SQLite como banco final do projeto.

O grão principal da tabela `fato_entrevista` é uma entrevista respondida por passageiro. Já a tabela `fato_avaliacao` possui um grão mais analítico: uma linha para cada indicador avaliado por um passageiro. Essa segunda fato foi criada porque a pesquisa possui muitos indicadores de satisfação em uma única linha original, e deixá-los em formato longo facilita consultas por indicador, categoria, aeroporto e ano.

### Tabelas do Data Warehouse

| tabela                |   linhas_etl |   linhas_elt |   diferenca |
|:----------------------|-------------:|-------------:|------------:|
| dim_tempo             |          271 |          271 |           0 |
| dim_aeroporto         |           20 |           20 |           0 |
| dim_cia_aerea         |           39 |           39 |           0 |
| dim_operacao          |           77 |           77 |           0 |
| dim_perfil_passageiro |        15382 |        15382 |           0 |
| dim_indicador         |           62 |           62 |           0 |
| fato_entrevista       |        77194 |        77194 |           0 |
| fato_avaliacao        |       533891 |       533891 |           0 |

As dimensões criadas foram:

- `dim_tempo`: datas, ano, trimestre, mês, dia e dia da semana;
- `dim_aeroporto`: código ICAO, nome do aeroporto, cidade, UF e região;
- `dim_cia_aerea`: companhias aéreas identificadas na pesquisa;
- `dim_operacao`: processo da entrevista, tipo de voo, conexão, forma de check-in, forma de desembarque e terminal;
- `dim_perfil_passageiro`: informações declaradas do passageiro, como nacionalidade, gênero, faixa etária, escolaridade, renda, motivo da viagem e informações de acessibilidade;
- `dim_indicador`: indicadores avaliados na pesquisa, com código, nome, categoria e tipo de indicador.

## 2. Explicação Detalhada do Processo de Integração

O processo começou com a leitura dos três arquivos XLSX. As planilhas tinham as duas primeiras linhas como metadados da pesquisa e a terceira linha como cabeçalho real. Por isso, a leitura foi feita usando a terceira linha como cabeçalho.

Em seguida, os nomes das colunas foram padronizados para `snake_case`, sem acentos e sem espaços. Essa decisão deixou o código mais limpo e também evitou problemas na criação das tabelas SQL.

Depois da extração, fiz a etapa de limpeza. Os principais cuidados foram:

1. remover linhas vazias;
2. garantir que a coluna `chave` fosse tratada como identificador da entrevista;
3. converter datas para um formato único;
4. tratar datas do arquivo de 2024 que vieram como número serial do Excel;
5. transformar horários de início e fim da coleta para `HH:MM:SS`;
6. padronizar textos vazios como `Não informado` nas dimensões;
7. converter notas de satisfação para número, aceitando apenas valores entre 1 e 5;
8. tratar respostas como `NS/NR` como ausência de nota válida;
9. remover duplicidades de entrevista, mantendo a primeira ocorrência.

Após a limpeza, foi criada a modelagem dimensional. Primeiro foram montadas as dimensões e, depois, as tabelas fato. No ETL, as transformações foram feitas com Python e Pandas antes da carga no SQLite. No ELT, os dados foram carregados primeiro em uma tabela de staging e as transformações principais foram executadas dentro do banco por SQL.

## 3. Justificativa da Escolha da Base de Dados

Essa base foi escolhida porque possui um tema real, público e relevante: a qualidade percebida pelos passageiros nos aeroportos brasileiros. Ela permite analisar serviços como check-in, inspeção de segurança, conforto da sala de embarque, sanitários, internet, alimentação, comércio, bagagem e satisfação geral.

Também é uma boa base para um projeto de integração porque existem arquivos de anos diferentes com estrutura semelhante, permitindo comparação temporal. Além disso, a metodologia da pesquisa é bem documentada e a escala de avaliação é simples de interpretar, indo de 1 a 5.

Outro ponto positivo é que a base envolve os 20 principais aeroportos pesquisados, o que permite análises por aeroporto, região, tipo de voo e processo de embarque ou desembarque. Para mim, isso torna o projeto mais interessante do que apenas juntar planilhas, porque dá para chegar em conclusões úteis sobre a experiência do passageiro.

## 4. Descrição dos Processos de Transformação Aplicados

As transformações foram pensadas para melhorar a qualidade dos dados e preparar a base para análise. As principais foram:

### 4.1 Padronização de colunas

Colunas como `SATISFAÇÃO GERAL`, `CIA AÉREA` e `INÍCIO COLETA` foram transformadas em nomes como `satisfacao_geral`, `cia_aerea` e `inicio_coleta`. Isso deixou os scripts mais organizados e facilitou as consultas SQL.

### 4.2 Correção de datas

Algumas datas de 2024 vieram como número serial do Excel. Por exemplo, valores numéricos foram convertidos usando a origem de datas do Excel. Sem esse tratamento, parte das datas seria interpretada incorretamente como 1970.

### 4.3 Tratamento de valores ausentes

Campos textuais vazios foram padronizados como `Não informado` nas dimensões. Já valores como `NS/NR` em indicadores de satisfação não foram transformados em zero, porque zero não existe na escala da pesquisa. Eles foram tratados como valor ausente.

### 4.4 Conversão das notas

As notas dos indicadores foram convertidas para número e somente valores entre 1 e 5 foram aceitos. Isso respeita a escala Likert da pesquisa: 1 para avaliação muito ruim e 5 para avaliação muito boa.

### 4.5 Criação da tabela fato de avaliação

Na planilha original, os indicadores aparecem em várias colunas. Para facilitar a análise, eles foram transformados para o formato longo, criando a tabela `fato_avaliacao`. Assim, consultas como “quais indicadores têm menor média?” ficaram mais simples.

### 4.6 Criação de chaves substitutas

Foram criadas chaves como `aeroporto_key`, `perfil_key`, `operacao_key` e `indicador_key`. Isso segue o padrão de modelagem dimensional e evita depender diretamente de textos longos nas tabelas fato.

## 5. Comparativo entre ETL e ELT

No **ETL**, os dados foram extraídos das planilhas, transformados com Python/Pandas e só depois carregados no banco final. Esse caminho é mais fácil de acompanhar pelo código Python, porque cada etapa fica bem explícita.

No **ELT**, os dados foram extraídos e carregados primeiro em uma tabela de staging no SQLite. Depois, a transformação foi feita dentro do banco usando SQL. Esse caminho deixa mais claro o papel do banco como motor de transformação e se aproxima do que acontece em muitos ambientes de dados.

| Critério | ETL | ELT |
|---|---|---|
| Ordem | Extrai, transforma e carrega | Extrai, carrega e transforma |
| Transformação | Principalmente em Python/Pandas | Principalmente em SQL dentro do banco |
| Vantagem | Mais controle no código e melhor para tratamentos complexos | Mais próximo do banco e bom para rastrear consultas SQL |
| Desvantagem | Pode exigir mais memória antes da carga | Depende mais da capacidade do banco |
| Uso neste projeto | Pipeline `src/etl/run_etl.py` | Pipeline `src/elt/run_elt.py` |

A validação mostrou que os dois processos chegaram à mesma quantidade de linhas nas tabelas finais. Isso foi importante para comprovar que as duas abordagens estavam coerentes.

## 6. Apresentação de Três Análises e Insights

### Análise 1 - Evolução da satisfação geral por ano

|   ano |   total_entrevistas |   media_satisfacao_geral |   percentual_avaliacoes_positivas |
|------:|--------------------:|-------------------------:|----------------------------------:|
|  2024 |               25586 |                    4.414 |                             92.99 |
|  2025 |               25829 |                    4.443 |                             93.72 |
|  2026 |               25779 |                    4.485 |                             94.61 |

A média de satisfação geral cresceu de **4.414** em 2024 para **4.485** em 2026. O percentual de avaliações positivas também subiu, chegando a **94.61%** em 2026. Isso indica uma melhora geral na percepção dos passageiros no período analisado.

### Análise 2 - Aeroportos com maiores e menores médias de satisfação

**Cinco maiores médias:**

| codigo_icao   | nome_aeroporto                    | uf   |   total_entrevistas |   media_satisfacao_geral |   percentual_positivo |
|:--------------|:----------------------------------|:-----|--------------------:|-------------------------:|----------------------:|
| SBFL          | Florianópolis / Hercílio Luz      | SC   |                3862 |                    4.726 |                 97.62 |
| SBVT          | Vitória / Eurico de Aguiar Salles | ES   |                3700 |                    4.646 |                 98.03 |
| SBPA          | Porto Alegre / Salgado Filho      | RS   |                3952 |                    4.572 |                 96.96 |
| SBMO          | Maceió / Zumbi dos Palmares       | AL   |                3883 |                    4.559 |                 96.57 |
| SBCT          | Curitiba / Afonso Pena            | PR   |                3912 |                    4.515 |                 96.5  |

**Cinco menores médias:**

| codigo_icao   | nome_aeroporto                                 | uf   |   total_entrevistas |   media_satisfacao_geral |   percentual_positivo |
|:--------------|:-----------------------------------------------|:-----|--------------------:|-------------------------:|----------------------:|
| SBGL          | Rio de Janeiro / Antônio Carlos Jobim - Galeão | RJ   |                3747 |                    4.353 |                 93.03 |
| SBGR          | Guarulhos / Governador André Franco Montoro    | SP   |                5336 |                    4.344 |                 91.45 |
| SBRJ          | Rio de Janeiro / Santos Dumont                 | RJ   |                3706 |                    4.337 |                 93.9  |
| SBSP          | São Paulo / Congonhas                          | SP   |                3678 |                    4.25  |                 88.61 |
| SBBE          | Belém / Val de Cans - Júlio Cezar Ribeiro      | PA   |                3851 |                    4.138 |                 84.11 |

O aeroporto de **Florianópolis / Hercílio Luz (SBFL)** apareceu com a maior média geral, enquanto **Belém / Val de Cans - Júlio Cezar Ribeiro (SBBE)** ficou com a menor média. Mesmo assim, todas as médias ficaram acima de 4, o que mostra uma avaliação geral positiva, mas com diferenças relevantes entre aeroportos.

### Análise 3 - Indicadores mais críticos

| codigo_indicador   | indicador                                                          | categoria           | tipo_indicador   |   total_avaliacoes |   media_nota |   percentual_positivo |
|:-------------------|:-------------------------------------------------------------------|:--------------------|:-----------------|-------------------:|-------------:|----------------------:|
| M2.c               | RELAÇÃO PREÇO x QUALIDADE DOS ESTABELECIMENTOS DE ALIMENTAÇÃO      | Comércio e serviços | subindicador     |               2923 |        2.276 |                 11.15 |
| M4.c               | RELAÇÃO PREÇO x QUALIDADE DOS ESTABELECIMENTOS COMERCIAIS          | Comércio e serviços | subindicador     |                793 |        2.348 |                 10.84 |
| R6.a               | VELOCIDADE DE CONEXÃO                                              | Infraestrutura      | subindicador     |               1262 |        2.735 |                 14.82 |
| C2.d               | QUANTIDADE DE BALCÕES                                              | Check-in            | subindicador     |                739 |        2.88  |                 34.1  |
| R8.b               | LIMPEZA DOS BANHEIROS                                              | Infraestrutura      | subindicador     |               4238 |        2.935 |                 26.71 |
| C2.a               | TEMPO DE ESPERA NA FILA                                            | Check-in            | subindicador     |                837 |        3.002 |                 36.56 |
| B3.b               | TEMPO DE RESTITUIÇÃO                                               | Bagagem             | subindicador     |               2914 |        3.011 |                 38.81 |
| M4.b               | QUALIDADE E VARIEDADE DE OPÇÕES DE ESTABELECIMENTOS COMERCIAIS     | Comércio e serviços | subindicador     |                794 |        3.103 |                 35.52 |
| M2.b               | QUALIDADE E VARIEDADE DE OPÇÕES DE ESTABELECIMENTOS DE ALIMENTAÇÃO | Comércio e serviços | subindicador     |               2913 |        3.122 |                 35.81 |
| M4.a               | QUANTIDADE DE ESTABELECIMENTOS COMERCIAIS                          | Comércio e serviços | subindicador     |                793 |        3.164 |                 38.34 |

Os indicadores mais críticos ficaram concentrados em preço/qualidade de alimentação e comércio, velocidade de internet, limpeza de banheiros, tempo de fila e restituição de bagagens. O pior indicador foi **RELAÇÃO PREÇO x QUALIDADE DOS ESTABELECIMENTOS DE ALIMENTAÇÃO**, com média **2.276**. Esse resultado mostra que a satisfação geral é alta, mas alguns serviços específicos ainda incomodam bastante os passageiros.

### Complemento - Tipo de voo e processo

| tipo_de_voo   |   total_entrevistas |   media_satisfacao_geral |   percentual_positivo |
|:--------------|--------------------:|-------------------------:|----------------------:|
| Doméstico     |               69427 |                    4.45  |                 93.85 |
| Internacional |                7767 |                    4.428 |                 93.1  |

| processo    |   total_entrevistas |   media_satisfacao_geral |   percentual_positivo |
|:------------|--------------------:|-------------------------:|----------------------:|
| Desembarque |               38728 |                    4.468 |                 93.56 |
| Embarque    |               38466 |                    4.427 |                 93.99 |

A diferença entre voos domésticos e internacionais foi pequena. A satisfação média em voos domésticos foi **4.45**, enquanto em voos internacionais foi **4.428**. Já entre embarque e desembarque, as médias também ficaram próximas.

## 7. Reflexão sobre o Aprendizado

Esse projeto me ajudou a entender melhor que integrar dados não é apenas juntar arquivos. Antes de fazer qualquer análise, foi necessário compreender a metodologia da pesquisa, entender a estrutura das planilhas, padronizar os nomes das colunas, corrigir datas, tratar valores ausentes e pensar em uma modelagem que realmente fizesse sentido.

Uma parte importante do aprendizado foi perceber que a mesma base pode ser organizada de formas diferentes. Se eu mantivesse todos os indicadores como colunas, algumas análises ficariam difíceis. Ao criar a `fato_avaliacao`, cada indicador passou a ser uma linha, o que deixou as consultas mais flexíveis.

Também foi interessante comparar ETL e ELT na prática. No começo, parecia que a diferença era só teórica, mas ao implementar os dois pipelines ficou mais claro que a ordem das etapas muda a forma de pensar o projeto. No ETL, eu transformei antes de carregar. No ELT, precisei pensar mais em SQL e em como o banco criaria as tabelas finais.

O maior desafio foi lidar com pequenas inconsistências da base, principalmente datas que vinham em formatos diferentes e respostas como `NS/NR`. Mesmo assim, isso deixou o projeto mais realista, porque bases reais quase sempre têm detalhes que precisam de tratamento.

No final, considero que o projeto cumpriu o objetivo: integrar três anos de dados, criar um Data Warehouse em esquema estrela, implementar ETL e ELT, documentar o processo e gerar análises que ajudam a entender a satisfação dos passageiros nos aeroportos pesquisados.
