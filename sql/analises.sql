
-- =====================================================
-- Projeto: Credit Intelligence
-- Objetivo: analisar fatores associados à inadimplência
-- Banco de dados: PostgreSQL
-- Tabela: public.clientes_credito
-- =====================================================


-- 1. VISÃO GERAL DA INADIMPLÊNCIA

SELECT
    COUNT(*) AS total_clientes,
    SUM(default_payment_next_month) AS inadimplentes,
    COUNT(*) - SUM(default_payment_next_month) AS adimplentes,
    ROUND(
        AVG(default_payment_next_month::numeric) * 100,
        2
    ) AS taxa_inadimplencia_pct
FROM public.clientes_credito;


-- 2. INADIMPLÊNCIA POR HISTÓRICO DE PAGAMENTO

WITH resumo AS (
    SELECT
        pay_0,
        COUNT(*) AS quantidade_clientes,
        SUM(default_payment_next_month) AS inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_inadimplencia_pct
    FROM public.clientes_credito
    GROUP BY pay_0
),
total AS (
    SELECT
        COUNT(*) AS total_clientes,
        SUM(default_payment_next_month) AS total_inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_geral_pct
    FROM public.clientes_credito
)
SELECT
    r.pay_0,
    r.quantidade_clientes,
    r.inadimplentes,
    ROUND(r.taxa_inadimplencia_pct, 2)
        AS taxa_inadimplencia_pct,
    ROUND(
        r.taxa_inadimplencia_pct - t.taxa_geral_pct,
        2
    ) AS diferenca_pontos_percentuais,
    ROUND(
        100.0 * r.inadimplentes
        / NULLIF(t.total_inadimplentes, 0),
        2
    ) AS participacao_inadimplentes_pct
FROM resumo r
CROSS JOIN total t
ORDER BY r.pay_0;


-- 3. INADIMPLÊNCIA POR FAIXA DE LIMITE DE CRÉDITO

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
),
resumo AS (
    SELECT
        faixa_limite,
        ordem_faixa,
        COUNT(*) AS quantidade_clientes,
        SUM(default_payment_next_month) AS inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_inadimplencia_pct
    FROM clientes_faixas
    GROUP BY faixa_limite, ordem_faixa
),
total AS (
    SELECT
        SUM(default_payment_next_month) AS total_inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_geral_pct
    FROM public.clientes_credito
)
SELECT
    r.faixa_limite,
    r.quantidade_clientes,
    r.inadimplentes,
    ROUND(r.taxa_inadimplencia_pct, 2)
        AS taxa_inadimplencia_pct,
    ROUND(
        r.taxa_inadimplencia_pct - t.taxa_geral_pct,
        2
    ) AS diferenca_pontos_percentuais,
    ROUND(
        100.0 * r.inadimplentes
        / NULLIF(t.total_inadimplentes, 0),
        2
    ) AS participacao_inadimplentes_pct
FROM resumo r
CROSS JOIN total t
ORDER BY r.ordem_faixa;


-- 4. INADIMPLÊNCIA POR FAIXA ETÁRIA

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
),
resumo AS (
    SELECT
        faixa_etaria,
        ordem_faixa,
        COUNT(*) AS quantidade_clientes,
        SUM(default_payment_next_month) AS inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_inadimplencia_pct
    FROM clientes_faixas
    GROUP BY faixa_etaria, ordem_faixa
),
total AS (
    SELECT
        SUM(default_payment_next_month) AS total_inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_geral_pct
    FROM public.clientes_credito
)
SELECT
    r.faixa_etaria,
    r.quantidade_clientes,
    r.inadimplentes,
    ROUND(r.taxa_inadimplencia_pct, 2)
        AS taxa_inadimplencia_pct,
    ROUND(
        r.taxa_inadimplencia_pct - t.taxa_geral_pct,
        2
    ) AS diferenca_pontos_percentuais,
    ROUND(
        100.0 * r.inadimplentes
        / NULLIF(t.total_inadimplentes, 0),
        2
    ) AS participacao_inadimplentes_pct
FROM resumo r
CROSS JOIN total t
ORDER BY r.ordem_faixa;


-- 5. ANÁLISE COMBINADA: IDADE E LIMITE DE CRÉDITO

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
),
resumo AS (
    SELECT
        faixa_etaria,
        faixa_limite,
        ordem_etaria,
        ordem_limite,
        COUNT(*) AS quantidade_clientes,
        SUM(default_payment_next_month) AS inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_inadimplencia_pct
    FROM clientes_faixas
    GROUP BY
        faixa_etaria,
        faixa_limite,
        ordem_etaria,
        ordem_limite
),
total AS (
    SELECT
        SUM(default_payment_next_month) AS total_inadimplentes,
        AVG(default_payment_next_month::numeric) * 100
            AS taxa_geral_pct
    FROM public.clientes_credito
)
SELECT
    r.faixa_etaria,
    r.faixa_limite,
    r.quantidade_clientes,
    r.inadimplentes,
    ROUND(r.taxa_inadimplencia_pct, 2)
        AS taxa_inadimplencia_pct,
    ROUND(
        r.taxa_inadimplencia_pct - t.taxa_geral_pct,
        2
    ) AS diferenca_pontos_percentuais,
    ROUND(
        100.0 * r.inadimplentes
        / NULLIF(t.total_inadimplentes, 0),
        2
    ) AS participacao_inadimplentes_pct
FROM resumo r
CROSS JOIN total t
ORDER BY
    r.ordem_etaria,
    r.ordem_limite;
