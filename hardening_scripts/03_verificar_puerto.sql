-- ============================================================================
-- PUNTO 3: VERIFICAR CAMBIO DE PUERTO
-- ============================================================================
-- 
-- OBJETIVO: Verificar que MySQL esté escuchando en el puerto 3308
--
-- RIESGO MITIGADO:
--   - Ataques automatizados al puerto por defecto 3306
--   - Escaneo masivo de vulnerabilidades conocidas
--   - Reducción de ruido en logs
--   - Defensa en profundidad
--
-- ESTÁNDAR: CIS Benchmark for MySQL 8.0 - Network Configuration
--           NIST SP 800-123 - Server Hardening
-- ============================================================================

SELECT '=== VERIFICACIÓN DE PUERTO ===' AS '';

-- Verificar puerto configurado
SELECT @@port AS 'Puerto configurado';

-- Verificar global port
SHOW VARIABLES LIKE 'port';

-- Verificar hostname
SHOW VARIABLES LIKE 'hostname';

-- Verificar todas las variables de red relevantes
SELECT '=== CONFIGURACIÓN DE RED ===' AS '';
SHOW VARIABLES LIKE '%port%';

-- Información de conexión actual
SELECT '=== INFORMACIÓN DE CONEXIÓN ACTUAL ===' AS '';
SELECT 
    USER() AS 'Usuario actual',
    CURRENT_USER() AS 'Usuario autenticado',
    @@hostname AS 'Hostname',
    @@port AS 'Puerto';

-- Verificar procesos conectados
SELECT '=== PROCESOS CONECTADOS ===' AS '';
SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE
FROM information_schema.PROCESSLIST
ORDER BY ID;

-- Resultado
SELECT '=== RESULTADO ===' AS '';
SELECT 
    CASE 
        WHEN @@port = 3308 
        THEN '✅ ÉXITO: MySQL está configurado para escuchar en puerto 3308'
        WHEN @@port = 3306 
        THEN '❌ ERROR: MySQL aún está en puerto por defecto 3306'
        ELSE CONCAT('⚠️ ADVERTENCIA: Puerto configurado es ', @@port, ' (esperado: 3308)')
    END AS 'RESULTADO';

-- ============================================================================
-- NOTAS:
--
-- Este script verifica la configuración DENTRO de MySQL.
-- Para verificar que el puerto está abierto a nivel de red, usar:
--   - nc -zv localhost 3308
--   - netstat -tuln | grep 3308
--   - lsof -i :3308
--   - docker port mysql-hardening
-- ============================================================================
