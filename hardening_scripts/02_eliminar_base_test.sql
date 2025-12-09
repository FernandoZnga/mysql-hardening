-- ============================================================================
-- PUNTO 2: ELIMINAR BASE DE DATOS DE PRUEBA (TEST) Y PRIVILEGIOS ASOCIADOS
-- ============================================================================
-- 
-- OBJETIVO: Eliminar bases de datos de prueba que no tienen propósito
--           legítimo en un ambiente de producción
--
-- RIESGO MITIGADO:
--   - Exposición de datos sensibles en BDs "temporales"
--   - Vector de ataque lateral
--   - Confusión entre ambientes desarrollo/producción
--   - Falta de auditoría y ownership
--   - Cumplimiento con CIS MySQL Benchmark 1.3
--
-- ESTÁNDAR: CIS Benchmark for MySQL 8.0 - Section 1.3
--           PCI-DSS Requirement 2.2 - Remove unnecessary functionality
-- ============================================================================

-- ============================================================================
-- PASO 1: VERIFICAR ESTADO ANTES DE ELIMINAR
-- ============================================================================

SELECT '=== 1. TODAS LAS BASES DE DATOS ===' AS '';
SHOW DATABASES;

SELECT '=== 2. BUSCAR BASE "test" EXACTA ===' AS '';
SHOW DATABASES LIKE 'test';

SELECT '=== 3. BUSCAR BASES CON PATRÓN "test_%" ===' AS '';
SHOW DATABASES LIKE 'test%';

SELECT '=== 4. CONTAR BASES DE TIPO TEST ===' AS '';
SELECT COUNT(*) AS 'Total bases test%' 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME LIKE 'test%';

-- Listar tablas en 'testdb' si existe (para documentar qué se está eliminando)
SELECT '=== 5. CONTENIDO DE testdb (si existe) ===' AS '';
SELECT COUNT(*) AS 'Total tablas en testdb'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'testdb';

-- Verificar privilegios sobre bases test
SELECT '=== 6. PRIVILEGIOS SOBRE BASES TEST ===' AS '';
SELECT User, Host, Db, Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv
FROM mysql.db 
WHERE Db LIKE 'test%'
ORDER BY Db, User;

-- ============================================================================
-- PASO 2: ELIMINAR BASES DE DATOS
-- ============================================================================

-- Eliminar base 'test' si existe (MySQL antiguo)
SELECT '=== ELIMINANDO: Base de datos "test" ===' AS '';
DROP DATABASE IF EXISTS test;

-- Eliminar base 'testdb' (creada en nuestro docker-compose)
SELECT '=== ELIMINANDO: Base de datos "testdb" ===' AS '';
DROP DATABASE IF EXISTS testdb;

-- NOTA: Si hubiera otras bases con patrón test_%, se evaluarían caso por caso
-- Ejemplo:
-- DROP DATABASE IF EXISTS test_backup;
-- DROP DATABASE IF EXISTS test_old;

-- ============================================================================
-- PASO 3: REVOCAR PRIVILEGIOS ASOCIADOS
-- ============================================================================

SELECT '=== LIMPIANDO: Privilegios sobre bases test ===' AS '';

-- Eliminar privilegios sobre 'test'
DELETE FROM mysql.db WHERE Db = 'test';

-- Eliminar privilegios sobre 'testdb'
DELETE FROM mysql.db WHERE Db = 'testdb';

-- Eliminar privilegios sobre patrón 'test_%'
-- CUIDADO: Solo ejecutar si estás seguro de que no hay BDs legítimas con este patrón
DELETE FROM mysql.db WHERE Db LIKE 'test\_%';

-- Recargar privilegios
FLUSH PRIVILEGES;

-- ============================================================================
-- PASO 4: VERIFICAR ELIMINACIÓN
-- ============================================================================

SELECT '=== VERIFICACIÓN: Bases de datos después de limpieza ===' AS '';
SHOW DATABASES;

SELECT '=== VERIFICACIÓN: Buscar bases test restantes ===' AS '';
SHOW DATABASES LIKE 'test%';

SELECT '=== VERIFICACIÓN: Privilegios test restantes ===' AS '';
SELECT User, Host, Db
FROM mysql.db 
WHERE Db LIKE 'test%';

-- ============================================================================
-- PASO 5: RESULTADO FINAL
-- ============================================================================

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME LIKE 'test%') = 0 
        THEN '✅ ÉXITO: No hay bases de datos tipo "test" en el sistema'
        ELSE '⚠️ ADVERTENCIA: Aún existen bases de datos con patrón "test%"'
    END AS 'RESULTADO DE BASES DE DATOS';

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM mysql.db WHERE Db LIKE 'test%') = 0 
        THEN '✅ ÉXITO: No hay privilegios sobre bases "test" en el sistema'
        ELSE '⚠️ ADVERTENCIA: Aún existen privilegios sobre bases con patrón "test%"'
    END AS 'RESULTADO DE PRIVILEGIOS';

-- ============================================================================
-- RESUMEN DE CAMBIOS
-- ============================================================================

SELECT '=== RESUMEN DE SEGURIDAD ===' AS '';
SELECT 
    'Bases de datos de prueba' AS 'Control',
    'Eliminadas' AS 'Acción',
    'CIS 1.3, PCI-DSS 2.2' AS 'Estándares',
    NOW() AS 'Fecha ejecución';

-- ============================================================================
-- NOTAS IMPORTANTES:
--
-- 1. BACKUP: Si la base 'testdb' contuviera datos importantes, debería
--    haberse hecho backup antes de eliminar. En este caso es solo ejemplo.
--
-- 2. COMUNICACIÓN: En producción real, informar al equipo antes de eliminar
--    bases de datos, incluso si son de "prueba".
--
-- 3. MIGRACIÓN: Si hay scripts que dependen de 'test', actualizarlos para
--    usar bases de datos con nombres más específicos.
--
-- 4. ALTERNATIVAS: En lugar de 'test', usar:
--    - Bases con nombre específico del proyecto
--    - Ambientes Docker efímeros
--    - Bases personales por desarrollador
--
-- EVIDENCIA A DOCUMENTAR:
--   1. Lista de bases ANTES de eliminar
--   2. Contenido de las bases (si lo hay)
--   3. Ejecución del script
--   4. Verificación de que ya no existen
-- ============================================================================
