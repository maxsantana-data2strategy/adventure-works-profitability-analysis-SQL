-- ============================================================================
-- TERRITORIAL PROFITABILITY ANALYSIS — Adventure Works
-- SQL Queries for Financial KPI Analysis by Territory
-- ============================================================================

-- ============================================================================
-- PHASE 1: SCHEMA EXPLORATION
-- ============================================================================

-- 1.1 Explore table: ventas_2017
SELECT *
FROM ventas_2017
LIMIT 10;

-- 1.2 Explore table: productos
SELECT *
FROM productos
LIMIT 10;

-- 1.3 Explore table: productos_categorias
SELECT *
FROM productos_categorias
LIMIT 10;

-- 1.4 Explore table: territorios
SELECT *
FROM territorios
LIMIT 10;

-- 1.5 Explore table: campanas
SELECT *
FROM campanas
LIMIT 10;


-- ============================================================================
-- PHASE 2: DATA EXTRACTION & CLEANING
-- ============================================================================

-- 2.1 Create clean view: ventas_clean
-- Combine sales, products, and territorial data with calculated financials
CREATE VIEW ventas_clean AS
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    COALESCE(p.precio_producto, 0) AS precio_producto,
    COALESCE(v.cantidad_pedido, 0) AS cantidad_pedido,
    COALESCE(p.costo_producto, 0) AS costo_producto,
    t.pais,
    t.continente,
    v.clave_territorio,
    -- Calculate ingreso_total and costo_total per order line
    COALESCE(p.precio_producto, 0) * COALESCE(v.cantidad_pedido, 0) AS ingreso_total,
    COALESCE(p.costo_producto, 0) * COALESCE(v.cantidad_pedido, 0) AS costo_total
FROM ventas_2017 AS v
LEFT JOIN productos AS p
    ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
    ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
    ON v.clave_territorio = t.clave_territorio;


-- ============================================================================
-- PHASE 3: FINANCIAL KPI CALCULATION
-- ============================================================================

-- 3.1 Create view: pais_ingreso_costo
-- Aggregate revenue and cost by country/territory
CREATE VIEW pais_ingreso_costo AS
SELECT
    pais,
    clave_territorio,
    SUM(ingreso_total) AS ingresos,
    SUM(costo_total) AS costos
FROM ventas_clean
GROUP BY pais, clave_territorio;


-- 3.2 Create view: pais_campanas
-- Aggregate marketing campaign spend by territory
CREATE VIEW pais_campanas AS
SELECT
    clave_territorio,
    SUM(costo_campana) AS costo_campana
FROM campanas
GROUP BY clave_territorio;


-- 3.3 Create view: kpi_por_territorio
-- Final KPI table: Revenue, Costs, Gross Profit, Margin %, ROI %
CREATE VIEW kpi_por_territorio AS
SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.ingresos)::integer AS ingresos,
    SUM(p.costos)::integer AS costos,
    COALESCE(SUM(c.costo_campana), 0)::integer AS costo_campana,
    -- Gross Profit = Revenue - Direct Costs
    SUM(p.ingresos)::integer - SUM(p.costos)::integer AS beneficio_bruto,
    -- Margin % = (Revenue - Cost) / Revenue * 100
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0) / NULLIF(SUM(p.ingresos), 0) AS margen_pct,
    -- ROI % = Gross Profit / Marketing Spend * 100
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0) / NULLIF(SUM(c.costo_campana), 0) AS roi_pct
FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c
    ON p.clave_territorio = c.clave_territorio
GROUP BY
    p.pais,
    p.clave_territorio
ORDER BY
    p.clave_territorio, ingresos DESC, costos DESC;


-- ============================================================================
-- PHASE 4: VALIDATION & QUALITY ASSURANCE
-- ============================================================================

-- 4.1 Validate: no negative prices
SELECT COUNT(*) AS productos_precio_invalido
FROM productos
WHERE precio_producto < 0;

-- 4.2 Validate: no negative costs
SELECT COUNT(*) AS productos_costo_invalido
FROM productos
WHERE costo_producto < 0;

-- 4.3 Validate totals: sum reconciliation
SELECT
    'Total Ingresos' AS metrica,
    SUM(ingreso_total) AS valor_total
FROM ventas_clean
UNION ALL
SELECT
    'Total Costos' AS metrica,
    SUM(costo_total) AS valor_total
FROM ventas_clean;

-- 4.4 Validate margins: ensure margen_pct is within logical range (0-100%)
SELECT
    pais,
    margen_pct,
    CASE
        WHEN margen_pct < 0 OR margen_pct > 100 THEN 'ANOMALIA'
        ELSE 'OK'
    END AS validacion
FROM kpi_por_territorio
ORDER BY margen_pct ASC;

-- 4.5 Validate: no unexpected NULLs in key fields
SELECT
    'ventas_2017' AS tabla,
    COUNT(*) AS total_registros,
    COUNT(CASE WHEN numero_pedido IS NULL THEN 1 END) AS nulos_numero_pedido,
    COUNT(CASE WHEN clave_producto IS NULL THEN 1 END) AS nulos_clave_producto,
    COUNT(CASE WHEN clave_territorio IS NULL THEN 1 END) AS nulos_clave_territorio
FROM ventas_2017
UNION ALL
SELECT
    'productos' AS tabla,
    COUNT(*) AS total_registros,
    COUNT(CASE WHEN clave_producto IS NULL THEN 1 END) AS nulos_clave_producto,
    0, 0
FROM productos
UNION ALL
SELECT
    'territorios' AS tabla,
    COUNT(*) AS total_registros,
    COUNT(CASE WHEN clave_territorio IS NULL THEN 1 END) AS nulos_clave_territorio,
    0, 0
FROM territorios;

-- 4.6 Final KPI reconciliation by territory
SELECT
    pais,
    clave_territorio,
    ingresos,
    costos,
    beneficio_bruto,
    margen_pct,
    roi_pct
FROM kpi_por_territorio
ORDER BY roi_pct DESC;


-- ============================================================================
-- ADDITIONAL QUERIES FOR DEEPER ANALYSIS
-- ============================================================================

-- A.1 Top 10 products by total revenue
SELECT
    nombre_producto,
    SUM(ingreso_total)::integer AS ingresos_totales,
    COUNT(*) AS cantidad_vendidas
FROM ventas_clean
GROUP BY nombre_producto
ORDER BY ingresos_totales DESC
LIMIT 10;

-- A.2 Average margin by product category
SELECT
    clave_categoria,
    COUNT(*) AS cantidad_lineas,
    AVG(((precio_producto - costo_producto) / NULLIF(precio_producto, 0) * 100)) AS margen_promedio_pct
FROM ventas_clean
GROUP BY clave_categoria
ORDER BY margen_promedio_pct DESC;

-- A.3 Marketing spend vs. gross profit comparison by territory
SELECT
    p.pais,
    p.clave_territorio,
    p.beneficio_bruto,
    c.costo_campana,
    (p.beneficio_bruto - c.costo_campana)::integer AS utilidad_neta,
    ROUND(((p.beneficio_bruto - c.costo_campana) / NULLIF(c.costo_campana, 0) * 100), 2) AS roi_neto_pct
FROM kpi_por_territorio AS p
LEFT JOIN pais_campanas AS c
    ON p.clave_territorio = c.clave_territorio
ORDER BY roi_neto_pct DESC;

-- A.4 Identify underperforming territories (ROI < 25%)
SELECT
    pais,
    clave_territorio,
    ingresos,
    costo_campana,
    beneficio_bruto,
    roi_pct
FROM kpi_por_territorio
WHERE roi_pct < 25
ORDER BY roi_pct ASC;

-- A.5 Identify high-performing territories (ROI > 50%)
SELECT
    pais,
    clave_territorio,
    ingresos,
    costo_campana,
    beneficio_bruto,
    roi_pct
FROM kpi_por_territorio
WHERE roi_pct > 50
ORDER BY roi_pct DESC;
