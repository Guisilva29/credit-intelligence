# Credit Intelligence — Análise de Risco de Crédito

Projeto de análise de dados desenvolvido para explorar o comportamento de pagamento de clientes de cartão de crédito e identificar padrões associados à inadimplência, utilizando Python e Power BI.

## Sobre o projeto

O Credit Intelligence tem como objetivo analisar dados de clientes, compreender o perfil de inadimplência e transformar os dados em informações visuais que apoiem a análise de risco de crédito.

O projeto inclui um processo de ETL em Python para extração, transformação e validação dos dados, além de um dashboard interativo desenvolvido no Power BI.

## Dashboard

### 1. Visão Geral

Visão consolidada dos principais indicadores da carteira, incluindo quantidade de clientes, inadimplência, limite médio e distribuição por faixa de limite.

![Visão Geral](reports/visao-geral.png)

### 2. Perfil dos Clientes

Análise do perfil dos clientes por idade, escolaridade, estado civil e utilização do limite de crédito, explorando características relacionadas ao risco de inadimplência.

![Perfil dos Clientes](reports/perfil-dos-clientes.png)

### 3. Comportamento de Pagamento

Análise da distribuição dos clientes por nível de atraso e histórico de pagamento, permitindo explorar diferentes padrões de comportamento financeiro.

![Comportamento de Pagamento](reports/comportamento-pagamento.png)

## Principais indicadores

- **30.000 clientes** analisados.
- **6.636 clientes inadimplentes** no período de referência da variável-alvo.
- **22,12% de taxa de inadimplência** na base analisada.
- Análises por perfil demográfico, faixa de limite e histórico de pagamento.

Os resultados representam a base utilizada no projeto e não devem ser interpretados como indicadores atuais do mercado de crédito.

## Tecnologias utilizadas

- **Python:** processamento e transformação dos dados.
- **Pandas:** manipulação e análise de dados.
- **Power BI:** construção do dashboard e visualização dos indicadores.
- **DAX:** criação de medidas e cálculos para as análises.
- **SQL:** consultas e análise de dados, conforme os scripts disponíveis no projeto.

## Estrutura do projeto

```text
credit-intelligence/
├── data/
├── dashboards/
│   └── credit-intelligence.pbix
├── notebooks/
├── reports/
│   ├── visao-geral.png
│   ├── perfil-dos-clientes.png
│   └── comportamento-pagamento.png
├── sql/
├── src/
├── .gitignore
└── README.md
```

## Processo de ETL

O processo de preparação dos dados contempla três etapas principais:

1. **Extração:** leitura da base de dados original.
2. **Transformação:** preparação das variáveis e organização dos dados para análise.
3. **Validação:** verificação de valores ausentes, duplicidades e estrutura das colunas.

## Objetivo de aprendizado

Este projeto faz parte do meu desenvolvimento em Análise de Dados e tem como foco a prática de ETL, análise exploratória, criação de indicadores e construção de dashboards voltados à interpretação de dados para apoio à tomada de decisão.

## Observação

Projeto desenvolvido para fins educacionais e de portfólio. Os resultados são descritivos e não representam um modelo preditivo de crédito.

