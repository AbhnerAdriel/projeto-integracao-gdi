# Esquema Estrela

```mermaid
erDiagram
    DIM_TEMPO ||--o{ FATO_ENTREVISTA : data_key
    DIM_AEROPORTO ||--o{ FATO_ENTREVISTA : aeroporto_key
    DIM_CIA_AEREA ||--o{ FATO_ENTREVISTA : cia_aerea_key
    DIM_OPERACAO ||--o{ FATO_ENTREVISTA : operacao_key
    DIM_PERFIL_PASSAGEIRO ||--o{ FATO_ENTREVISTA : perfil_key

    DIM_TEMPO ||--o{ FATO_AVALIACAO : data_key
    DIM_AEROPORTO ||--o{ FATO_AVALIACAO : aeroporto_key
    DIM_OPERACAO ||--o{ FATO_AVALIACAO : operacao_key
    DIM_PERFIL_PASSAGEIRO ||--o{ FATO_AVALIACAO : perfil_key
    DIM_INDICADOR ||--o{ FATO_AVALIACAO : indicador_key
```
