SELECT 
    c.id AS klient_id,
    c.first_name,
    c.last_name,
    ca.id AS samochod_id,
    ca.marka,
    ca.model,
    ca.rok,
    c.email,

    CASE
        WHEN CAST(ca.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
        WHEN CAST(ca.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
        WHEN CAST(ca.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
        ELSE 1000
    END AS cena_bazowa_zł,

    -- Rabat za flotę jako osobna kolumna z aliasem
    CASE
        WHEN cp.fleet_count = 1 THEN 0.95
        WHEN cp.fleet_count = 2 THEN 0.90
        WHEN cp.fleet_count = 3 THEN 0.85
        WHEN cp.fleet_count = 4 THEN 0.80
        WHEN cp.fleet_count >= 5 THEN 0.75
        ELSE 1
    END AS rabat_za_flote_proc,

    -- Cena końcowa z aliasem
    (
        CASE
            WHEN CAST(ca.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(ca.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(ca.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
        END
        *
        CASE WHEN c.email LIKE '%apple%' THEN 1.4 ELSE 1 END
        *
        CASE WHEN c.country IN ('Polska', 'Chiny') THEN 0.7 ELSE 1 END
        *
        CASE
            WHEN cp.fleet_count = 1 THEN 0.95
            WHEN cp.fleet_count = 2 THEN 0.90
            WHEN cp.fleet_count = 3 THEN 0.85
            WHEN cp.fleet_count = 4 THEN 0.80
            WHEN cp.fleet_count >= 5 THEN 0.75
            ELSE 1
        END
        *
        (1 - (cp.fleet_count * 0.05))
    ) AS cena_po_rabatach_zł

FROM clients c
JOIN cars ca ON c.id = ca.client_id
JOIN (
    SELECT client_id, COUNT(*) AS fleet_count
    FROM cars
    GROUP BY client_id
) cp ON cp.client_id = c.id
ORDER BY cena_po_rabatach_zł DESC;
