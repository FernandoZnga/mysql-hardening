-- ============================================================================
-- PUNTO 4: VERIFICAR CONFIGURACIÓN DE BIND-ADDRESS
-- ============================================================================
-- 
-- OBJETIVO: Verificar que MySQL esté configurado para escuchar solo en
--           interfaces específicas (127.0.0.1 en lugar de 0.0.0.0)
--
-- RIESGO MITIGADO:
--   - Exposición a redes no confiables
--   - Acceso desde interfaces de red públicas
--   - Violación de principio de mínimo privilegio
--   - Superficie de ataque ampliada
--   - Cumplimiento con CIS 3.1, PCI-DSS 1.3
--
-- ESTÁNDAR: CIS Benchmark for MySQL 8.0 - Section 3.1
--           PCI-DSS Requirement 1.3
--           ISO 27001 A.13.1.3
-- ============================================================================

SELECT '=== VERIFICACIÓN DE BIND-ADDRESS ===' AS '';

-- Verificar bind-address configurado
SELECT @@bind_address AS 'Bind Address Configurado';

-- Verificar con SHOW VARIABLES
SHOW VARIABLES LIKE 'bind_address';

-- Verificar todas las variables de red
SELECT '=== CONFIGURACIÓN COMPLETA DE RED ===' AS '';
SHOW VARIABLES LIKE '%address%';

-- Información de conexión actual
SELECT '=== INFORMACIÓN DE CONEXIÓN ACTUAL ===' AS '';
SELECT 
    USER() AS 'Usuario actual',
    CURRENT_USER() AS 'Usuario autenticado',
    @@hostname AS 'Hostname',
    @@port AS 'Puerto',
    @@bind_address AS 'Bind Address';

-- Ver procesos conectados y desde dónde
SELECT '=== CONEXIONES ACTIVAS ===' AS '';
SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE, INFO
FROM information_schema.PROCESSLIST
WHERE USER != 'system user'
ORDER BY ID;

-- Análisis de seguridad del bind-address
SELECT '=== ANÁLISIS DE SEGURIDAD ===' AS '';
SELECT 
    CASE 
        WHEN @@bind_address = '127.0.0.1' 
        THEN '✅ SEGURO: Solo conexiones localhost'
        WHEN @@bind_address = '0.0.0.0' 
        THEN '🔴 INSEGURO: Acepta conexiones de todas las interfaces'
        WHEN @@bind_address LIKE '192.168.%' OR @@bind_address LIKE '10.%' OR @@bind_address LIKE '172.%'
        THEN '⚠️ ADVERTENCIA: IP privada específica (verificar segmentación de red)'
        ELSE CONCAT('❓ REVISAR: Bind address no estándar: ', @@bind_address)
    END AS 'Evaluación de Seguridad';

-- Resultado final
SELECT '=== RESULTADO ===' AS '';
SELECT 
    CASE 
        WHEN @@bind_address = '127.0.0.1' 
        THEN '✅ ÉXITO: MySQL configurado con máxima seguridad de red'
        WHEN @@bind_address = '0.0.0.0' 
        THEN '❌ ERROR: MySQL acepta conexiones de cualquier interfaz (INSEGURO)'
        ELSE CONCAT('⚠️ REVISAR: bind-address = ', @@bind_address)
    END AS 'RESULTADO';

-- ============================================================================
-- NOTAS:
--
-- Este script verifica la configuración DENTRO de MySQL.
-- Para verificar a nivel de red (socket), usar en el host:
--
--   # Ver qué interfaces escucha MySQL
--   netstat -tuln | grep 3308
--   lsof -i :3308
--
--   # Con bind-address=127.0.0.1 debería mostrar:
--   tcp  127.0.0.1:3308  *.*  LISTEN
--
--   # Con bind-address=0.0.0.0 mostraría:
--   tcp  0.0.0.0:3308  *.*  LISTEN
--
-- VALORES ESPERADOS:
--   - 127.0.0.1 (localhost) = MÁXIMA SEGURIDAD
--   - IP privada específica = SEGURO (con firewall)
--   - 0.0.0.0 = INSEGURO (todas las interfaces)
--   - * (asterisco) = INSEGURO (equivalente a 0.0.0.0)
-- ============================================================================
