
-- =====================================================
-- Projeto: Credit Intelligence
-- Objetivo: analisar fatores associados à inadimplência
-- Banco de dados: PostgreSQL
-- Tabela: public.clientes_credito
-- =====================================================


-- 1. VISÃO GERAL DA INADIMPLÊNCIA
-- Pergunta: qual é a taxa geral de inadimplência?

SELECT
    COUNT(*) AS total_clientes,
    SUM(default_payment_next_month) AS inadimplentes,
    COUNT(*) - SUM(default_payment_next_month) AS adimplentes,
    ROUND(
        AVG(default_payment_next_month::numeric) * 100,
        2
    ) AS taxa_inadimplencia_pct
FROM public.clientes_credito;


-- 2. INADIMPLÊNCIA POR SITUAÇÃO DE PAGAMENTO
-- Pergunta: como o atraso mais recente se relaciona
-- com a inadimplência no mês seguinte?
-- PAY_0 representa o histórico de pagamento mais recente
-- disponível nesta base de dados.

SELECT
    pay_0,
    COUNT(*) AS quantidade_clientes,
    SUM(default_payment_next_month) AS inadimplentes,
    ROUND(
        AVG(default_payment_next_month::numeric) * 100,
        2
    ) AS taxa_inadimplencia_pct
FROM public.clientes_credito
GROUP BY pay_0
ORDER BY pay_0;


-- 3. INADIMPLÊNCIA POR FAIXA DE LIMITE DE CRÉDITO
-- Pergunta: como a taxa varia entre as faixas de limite?

WITH clientes_faixas AS (
    SELECT
        limit_bal,
        default_payment_next_month,
        CASE
            WHEN limit_bal <= 50000 THEN 'Até 50 mil'
            WHEN limit_bal <= 100000 THEN '50 a 100 mil'
            WHEN limit_bal <= 200000 THEN '100 a 200 mil'
            WHEN limit_bal <= 300000 THEN '200 a 300 mil'
            ELSE 'Acima de 300 mil'
        END AS faixa_limite,
        CASE
            WHEN limit_bal <= 50000 THEN 1
            WHEN limit_bal <= 100000 THEN 2
            WHEN limit_bal <= 200000 THEN 3
            WHEN limit_bal <= 300000 THEN 4
            ELSE 5
        END AS ordem_faixa
    FROM public.clientes_credito
)
SELECT
    faixa_limite,
    COUNT(*) AS quantidade_clientes,
    SUM(default_payment_next_month) AS inadimplentes,
    ROUND(
        AVG(default_payment_next_month::numeric) * 100,
        2
    ) AS taxa_inadimplencia_pct
FROM clientes_faixas
GROUP BY faixa_limite, ordem_faixa
ORDER BY ordem_faixa;


-- 4. INADIMPLÊNCIA POR FAIXA ETÁRIA
-- Pergunta: existem diferenças entre os grupos de idade?

WITH clientes_faixas AS (
    SELECT
        age,
        default_payment_next_month,
        CASE
            WHEN age BETWEEN 21 AND 29 THEN '21-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS faixa_etaria,
        CASE
            WHEN age BETWEEN 21 AND 29 THEN 1
            WHEN age BETWEEN 30 AND 39 THEN 2
            WHEN age BETWEEN 40 AND 49 THEN 3
            WHEN age BETWEEN 50 AND 59 THEN 4
            ELSE 5
        END AS ordem_faixa
    FROM public.clientes_credito
)
SELECT
    faixa_etaria,
    COUNT(*) AS quantidade_clientes,
    SUM(default_payment_next_month) AS inadimplentes,
    ROUND(
        AVG(default_payment_next_month::numeric) * 100,
        2
    ) AS taxa_inadimplencia_pct
FROM clientes_faixas
GROUP BY faixa_etaria, ordem_faixa
ORDER BY ordem_faixa;


-- 5. ANÁLISE COMBINADA: IDADE E LIMITE DE CRÉDITO
-- Pergunta: a relação entre faixa de limite e inadimplência
-- varia conforme a faixa etária?

WITH clientes_faixas AS (
    SELECT
        age,
        limit_bal,
        default_payment_next_month,
        CASE
            WHEN age BETWEEN 21 AND 29 THEN '21-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS faixa_etaria,
        CASE
            WHEN age BETWEEN 21 AND 29 THEN 1
            WHEN age BETWEEN 30 AND 39 THEN 2
            WHEN age BETWEEN 40 AND 49 THEN 3
            WHEN age BETWEEN 50 AND 59 THEN 4
            ELSE 5
        END AS ordem_etaria,
        CASE
            WHEN limit_bal <= 50000 THEN 'Até 50 mil'
            WHEN limit_bal <= 100000 THEN '50 a 100 mil'
            WHEN limit_bal <= 200000 THEN '100 a 200 mil'
            WHEN limit_bal <= 300000 THEN '200 a 300 mil'
            ELSE 'Acima de 300 mil'
        END AS faixa_limite,
        CASE
            WHEN limit_bal <= 50000 THEN 1
            WHEN limit_bal <= 100000 THEN 2
            WHEN limit_bal <= 200000 THEN 3
            WHEN limit_bal <= 300000 THEN 4
            ELSE 5
        END AS ordem_limite
    FROM public.clientes_credito
)
SELECT
    faixa_etaria,
    faixa_limite,
    COUNT(*) AS quantidade_clientes,
    SUM(default_payment_next_month) AS inadimplentes,
    ROUND(
        AVG(default_payment_next_month::numeric) * 100,
        2
    ) AS taxa_inadimplencia_pct
FROM clientes_faixas
GROUP BY
    faixa_etaria,
    faixa_limite,
    ordem_etaria,
    ordem_limite
ORDER BY
    ordem_etaria,
    ordem_limite;
