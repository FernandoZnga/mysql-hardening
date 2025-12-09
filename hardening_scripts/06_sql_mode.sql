-- ============================================================================
-- PUNTO 6: Establecer sql_mode Seguro
-- ============================================================================
-- Descripción: Este script verifica y valida la configuración de sql_mode
--              para asegurar que el servidor MySQL tenga validaciones
--              estrictas de datos habilitadas.
-- Fecha: 2025-12-09
-- ============================================================================

SELECT '=== CONFIGURACIÓN SQL_MODE ACTUAL ===' AS '';

-- Verificar sql_mode global (para todas las nuevas conexiones)
SELECT @@GLOBAL.sql_mode AS 'SQL_MODE GLOBAL';

-- Verificar sql_mode de la sesión actual
SELECT @@SESSION.sql_mode AS 'SQL_MODE SESSION';

SELECT '\n=== VERIFICACIÓN DE MODOS CRÍTICOS DE SEGURIDAD ===' AS '';

-- Verificar si contiene los modos esenciales de seguridad
SELECT 
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%STRICT_TRANS_TABLES%' 
        THEN '✓ ACTIVO'
        ELSE '✗ FALTA - CRÍTICO'
    END AS 'STRICT_TRANS_TABLES',
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%STRICT_ALL_TABLES%' 
        THEN '✓ ACTIVO'
        ELSE '✗ FALTA - CRÍTICO'
    END AS 'STRICT_ALL_TABLES',
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%NO_ZERO_IN_DATE%' 
        THEN '✓ ACTIVO'
        ELSE '✗ FALTA - IMPORTANTE'
    END AS 'NO_ZERO_IN_DATE',
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%NO_ZERO_DATE%' 
        THEN '✓ ACTIVO'
        ELSE '✗ FALTA - IMPORTANTE'
    END AS 'NO_ZERO_DATE',
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%ERROR_FOR_DIVISION_BY_ZERO%' 
        THEN '✓ ACTIVO'
        ELSE '✗ FALTA - IMPORTANTE'
    END AS 'ERROR_FOR_DIVISION_BY_ZERO',
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%NO_ENGINE_SUBSTITUTION%' 
        THEN '✓ ACTIVO'
        ELSE '✗ FALTA - RECOMENDADO'
    END AS 'NO_ENGINE_SUBSTITUTION',
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%ONLY_FULL_GROUP_BY%' 
        THEN '✓ ACTIVO'
        ELSE '✗ FALTA - RECOMENDADO'
    END AS 'ONLY_FULL_GROUP_BY';

SELECT '\n=== PRUEBAS DE VALIDACIÓN ===' AS '';

-- Test 1: Verificar que rechaza truncamiento de datos
SELECT '--- Test 1: Truncamiento de datos ---' AS '';
CREATE TEMPORARY TABLE test_truncate (col VARCHAR(5));
-- Intentar insertar valor más largo (debería fallar con sql_mode estricto)
-- INSERT INTO test_truncate VALUES ('123456');  -- Descomentado causaría error

SELECT 'Si sql_mode es estricto, el INSERT anterior daría error' AS 'Resultado Test 1';
DROP TEMPORARY TABLE test_truncate;

-- Test 2: Verificar división por cero
SELECT '--- Test 2: División por cero ---' AS '';
-- Con sql_mode estricto, esto debería dar error o warning
-- SELECT 1/0;  -- Descomentado causaría error

SELECT 'Con ERROR_FOR_DIVISION_BY_ZERO activo, división por cero genera error' AS 'Resultado Test 2';

-- Test 3: Verificar fecha inválida
SELECT '--- Test 3: Fechas inválidas ---' AS '';
CREATE TEMPORARY TABLE test_date (d DATE);
-- Intentar insertar fecha inválida (debería fallar)
-- INSERT INTO test_date VALUES ('2024-02-30');  -- Descomentado causaría error
-- INSERT INTO test_date VALUES ('0000-00-00');  -- Descomentado causaría error

SELECT 'Con NO_ZERO_DATE activo, fechas como 0000-00-00 o 2024-02-30 generan error' AS 'Resultado Test 3';
DROP TEMPORARY TABLE test_date;

SELECT '\n=== RESUMEN DE SEGURIDAD ===' AS '';

-- Evaluación final
SELECT 
    CASE 
        WHEN @@GLOBAL.sql_mode LIKE '%STRICT_TRANS_TABLES%' 
         AND @@GLOBAL.sql_mode LIKE '%STRICT_ALL_TABLES%'
         AND @@GLOBAL.sql_mode LIKE '%NO_ZERO_IN_DATE%'
         AND @@GLOBAL.sql_mode LIKE '%NO_ZERO_DATE%'
         AND @@GLOBAL.sql_mode LIKE '%ERROR_FOR_DIVISION_BY_ZERO%'
        THEN 'SEGURO ✓ - Todos los modos críticos activos'
        ELSE 'INSEGURO ✗ - Faltan modos críticos de seguridad'
    END AS 'ESTADO DE SEGURIDAD';

SELECT '\n=== RECOMENDACIONES ===' AS '';

SELECT 
    'NOTA: Este sql_mode debe estar configurado en my.cnf para persistir' AS 'Importante',
    'después de reiniciar el servidor MySQL.' AS '';

SELECT 
    'sql_mode recomendado:' AS '',
    'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,' AS '',
    'ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY' AS '';

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
