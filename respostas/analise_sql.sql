-- 1. Quantos chamados foram abertos no dia 01/04/2023?
SELECT COUNT(DISTINCT id_chamado) AS qtd_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE DATE(data_inicio) = '2023-04-01';

-- 2. Qual o tipo de chamado que teve mais chamados abertos no dia 01/04/2023?
SELECT tipo, COUNT(*) AS qtd_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE DATE(data_inicio) = '2023-04-01'
GROUP BY tipo
ORDER BY qtd_chamados DESC
LIMIT 1;

-- 3. Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?
WITH top_bairros AS (
    SELECT id_bairro, COUNT(*) AS qtd_chamados
    FROM `datario.adm_central_atendimento_1746.chamado`
    WHERE DATE(data_inicio) = '2023-04-01'
        AND id_bairro IS NOT NULL
    GROUP BY id_bairro
    ORDER BY qtd_chamados DESC
    LIMIT 3
)
SELECT b.nome, tb.qtd_chamados
FROM top_bairros tb
JOIN `datario.dados_mestres.bairro` b
ON tb.id_bairro = b.id_bairro;

-- 4. Qual o nome da subprefeitura com mais chamados abertos nesse dia?
SELECT b.subprefeitura, COUNT(*) AS qtd_chamados
FROM `datario.adm_central_atendimento_1746.chamado` c
LEFT JOIN `datario.dados_mestres.bairro` b
ON c.id_bairro = b.id_bairro
WHERE DATE(c.data_inicio) = '2023-04-01'
GROUP BY b.subprefeitura
ORDER BY qtd_chamados DESC
LIMIT 1;

-- 5. Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros?
--    Se sim, por que isso acontece?
SELECT COUNT(*) AS qtd_registros_sem_id_bairro
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE id_bairro IS NULL
    AND DATE(data_inicio) = '2023-04-01';


-- 6. Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?
SELECT COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE DATE(data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
    AND subtipo = 'Perturbação do sossego';

-- 7. Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).
WITH eventos AS (
    SELECT evento, data_inicial, data_final
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`
)
SELECT c.*
FROM `datario.adm_central_atendimento_1746.chamado` c
JOIN eventos e
    ON DATE(c.data_inicio) BETWEEN e.data_inicial AND e.data_final
WHERE c.subtipo = 'Perturbação do sossego'
    AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31';

-- 8. Quantos chamados desse subtipo foram abertos em cada evento?
WITH eventos AS (
    SELECT evento, data_inicial, data_final
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`
)
SELECT e.evento, COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado` c
JOIN eventos e
    ON DATE(c.data_inicio) BETWEEN e.data_inicial AND e.data_final
WHERE c.subtipo = 'Perturbação do sossego'
    AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
GROUP BY e.evento;


-- 9. Qual evento teve a maior média diária de chamados abertos desse subtipo?
WITH eventos AS (
    SELECT evento, data_inicial, data_final, 
        DATE_DIFF(data_final, data_inicial, DAY) + 1 AS dias_evento
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`
),
chamados_por_evento AS (
    SELECT e.evento, COUNT(*) AS total_chamados, e.dias_evento
    FROM `datario.adm_central_atendimento_1746.chamado` c
    JOIN eventos e
        ON DATE(c.data_inicio) BETWEEN e.data_inicial AND e.data_final
    WHERE c.subtipo = 'Perturbação do sossego'
        AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
    GROUP BY e.evento, e.dias_evento
)
SELECT evento, (total_chamados / dias_evento) AS media_diaria
FROM chamados_por_evento
ORDER BY media_diaria DESC
LIMIT 1;

-- 6. Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?
SELECT COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE DATE(data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
    AND subtipo = 'Perturbação do sossego';

-- 7. Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).
WITH eventos AS (
    SELECT evento, data_inicial, data_final
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`
    WHERE evento IN ('Reveillon', 'Carnaval', 'Rock in Rio')
)
SELECT c.*
FROM `datario.adm_central_atendimento_1746.chamado` c
JOIN eventos e
    ON DATE(c.data_inicio) BETWEEN e.data_inicial AND e.data_final
WHERE c.subtipo = 'Perturbação do sossego'
    AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31';

-- 8. Quantos chamados desse subtipo foram abertos em cada evento?
WITH eventos AS (
    SELECT evento, data_inicial, data_final
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`
    WHERE evento IN ('Reveillon', 'Carnaval', 'Rock in Rio')
)
SELECT e.evento, COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado` c
JOIN eventos e
    ON DATE(c.data_inicio) BETWEEN e.data_inicial AND e.data_final
WHERE c.subtipo = 'Perturbação do sossego'
    AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
GROUP BY e.evento;

-- 9. Qual evento teve a maior média diária de chamados abertos desse subtipo?
WITH eventos AS (
    SELECT evento, data_inicial, data_final, 
        DATE_DIFF(data_final, data_inicial, DAY) + 1 AS dias_evento
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`
),
chamados_por_evento AS (
    SELECT e.evento, COUNT(*) AS total_chamados, e.dias_evento
    FROM `datario.adm_central_atendimento_1746.chamado` c
    JOIN eventos e
        ON DATE(c.data_inicio) BETWEEN e.data_inicial AND e.data_final
    WHERE c.subtipo = 'Perturbação do sossego'
        AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
    GROUP BY e.evento, e.dias_evento
)
SELECT evento, (total_chamados / dias_evento) AS media_diaria
FROM chamados_por_evento
ORDER BY media_diaria DESC
LIMIT 1;


-- 10. Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.
WITH eventos AS (
    SELECT evento, data_inicial, data_final, 
        DATE_DIFF(data_final, data_inicial, DAY) + 1 AS dias_evento
    FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`
    WHERE evento IN ('Reveillon', 'Carnaval', 'Rock in Rio')
),
chamados_por_evento AS (
    SELECT e.evento, COUNT(*) AS total_chamados, e.dias_evento
    FROM `datario.adm_central_atendimento_1746.chamado` c
    JOIN eventos e
        ON DATE(c.data_inicio) BETWEEN e.data_inicial AND e.data_final
    WHERE c.subtipo = 'Perturbação do sossego'
        AND DATE(c.data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
    GROUP BY e.evento, e.dias_evento
),
media_eventos AS (
    SELECT evento, (total_chamados / dias_evento) AS media_diaria
    FROM chamados_por_evento
),
media_total AS (
    SELECT COUNT(*) / DATE_DIFF(DATE '2023-12-31', DATE '2022-01-01', DAY) + 1 AS media_diaria_total
    FROM `datario.adm_central_atendimento_1746.chamado`
    WHERE subtipo = 'Perturbação do sossego'
        AND DATE(data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
)
SELECT evento, media_diaria
FROM media_eventos
UNION ALL
SELECT 'Média Geral' AS evento, media_diaria_total
FROM media_total;

