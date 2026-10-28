
-- =====================================================
-- Projeto: Credit Intelligence
-- Objetivo: verificar a integridade dos dados carregados
-- Banco de dados: PostgreSQL
-- Tabela: public.clientes_credito
-- =====================================================


-- 1. QUANTIDADE DE REGISTROS, IDS DISTINTOS E IDS NULOS

SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT id) AS ids_distintos,
    COUNT(*) FILTER (WHERE id IS NULL) AS ids_nulos
FROM public.clientes_credito;


-- 2. IDENTIFICAR IDS DUPLICADOS

SELECT
    id,
    COUNT(*) AS quantidade_registros
FROM public.clientes_credito
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY quantidade_registros DESC;


-- 3. VERIFICAR VALORES DA VARIÁVEL DE INADIMPLÊNCIA
-- Valores esperados: 0 (adimplente) e 1 (inadimplente).

SELECT
    default_payment_next_month AS inadimplencia,
    COUNT(*) AS quantidade_clientes
FROM public.clientes_credito
GROUP BY default_payment_next_month
ORDER BY default_payment_next_month;


-- 4. IDENTIFICAR VALORES NULOS NAS COLUNAS PRINCIPAIS

SELECT
    COUNT(*) FILTER (WHERE id IS NULL) AS ids_nulos,
    COUNT(*) FILTER (WHERE limit_bal IS NULL) AS limites_nulos,
    COUNT(*) FILTER (WHERE age IS NULL) AS idades_nulas,
    COUNT(*) FILTER (
        WHERE default_payment_next_month IS NULL
    ) AS inadimplencia_nula
FROM public.clientes_credito;


-- 5. VERIFICAR SE EXISTEM VALORES FORA DO PADRÃO
-- A variável de inadimplência deve conter somente 0 ou 1.

SELECT
    default_payment_next_month AS valor_invalido,
    COUNT(*) AS quantidade_registros
FROM public.clientes_credito
WHERE default_payment_next_month NOT IN (0, 1)
   OR default_payment_next_month IS NULL
GROUP BY default_payment_next_month
ORDER BY default_payment_next_month;
