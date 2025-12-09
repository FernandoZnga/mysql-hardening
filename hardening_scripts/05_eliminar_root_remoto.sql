-- ============================================================================
-- PUNTO 5: ELIMINAR ACCESO REMOTO DEL USUARIO ROOT
-- ============================================================================
-- 
-- OBJETIVO: Eliminar root@% para que root solo pueda conectarse localmente
--
-- RIESGO MITIGADO:
--   - Acceso no autorizado con credenciales root desde red externa
--   - Ataques de fuerza bruta contra cuenta root
--   - Explotación de vulnerabilidades con privilegios máximos
--   - Cumplimiento con CIS 2.7, PCI-DSS 2.1, ISO 27001 A.9.2.3
--
-- ESTÁNDAR: CIS Benchmark for MySQL 8.0 - Section 2.7
--           PCI-DSS Requirement 2.1
--           ISO 27001 A.9.2.3
-- ============================================================================

-- PASO 1: VERIFICAR ESTADO ACTUAL
SELECT '=== USUARIOS ROOT ACTUALES ===' AS '';
SELECT User, Host, plugin, password_expired, account_locked
FROM mysql.user 
WHERE User = 'root'
ORDER BY Host;

-- PASO 2: VERIFICAR QUE EXISTE USUARIO ALTERNATIVO
SELECT '=== VERIFICAR USUARIO ADMIN ALTERNATIVO ===' AS '';
SELECT User, Host, plugin
FROM mysql.user 
WHERE User = 'admin';

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM mysql.user WHERE User = 'admin' AND Host = '%') > 0 
        THEN 'OK: Usuario admin existe como alternativa'
        ELSE 'ERROR: No existe usuario admin - NO ELIMINAR root@% todavia!'
    END AS 'Verificacion';

-- PASO 3: MOSTRAR TODOS LOS USUARIOS (para referencia)
SELECT '=== TODOS LOS USUARIOS ===' AS '';
SELECT User, Host FROM mysql.user WHERE User NOT LIKE 'mysql.%' ORDER BY User, Host;

-- PASO 4: ELIMINAR root@%
SELECT '=== ELIMINANDO root@% ===' AS '';
DROP USER IF EXISTS 'root'@'%';

-- PASO 5: RECARGAR PRIVILEGIOS
FLUSH PRIVILEGES;

-- PASO 6: VERIFICAR ELIMINACIÓN
SELECT '=== USUARIOS ROOT DESPUÉS DE ELIMINACIÓN ===' AS '';
SELECT User, Host
FROM mysql.user 
WHERE User = 'root'
ORDER BY Host;

-- PASO 7: VERIFICAR QUE SOLO QUEDA root@localhost
SELECT '=== VERIFICACIÓN FINAL ===' AS '';
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM mysql.user WHERE User = 'root') = 1 
             AND (SELECT Host FROM mysql.user WHERE User = 'root' LIMIT 1) = 'localhost'
        THEN 'EXITO: Solo existe root@localhost'
        
        WHEN (SELECT COUNT(*) FROM mysql.user WHERE User = 'root' AND Host = '%') > 0
        THEN 'ERROR: root@% aun existe!'
        
        ELSE CONCAT('VERIFICAR: Existen ', 
                    (SELECT COUNT(*) FROM mysql.user WHERE User = 'root'), 
                    ' usuarios root')
    END AS 'RESULTADO';

-- ============================================================================
-- RESULTADO ESPERADO:
--
-- ANTES:
--   root@localhost  ← DEBE MANTENERSE
--   root@%          ← DEBE ELIMINARSE
--
-- DESPUÉS:
--   root@localhost  ← ÚNICO root que debe existir
--
-- ACCESO REMOTO A ROOT:
--   - Via SSH tunnel: ssh -L 3308:localhost:3308 user@servidor
--   - Via usuario admin: mysql -h servidor -P 3308 -u admin -p
--
-- IMPORTANTE: 
--   - root@localhost SIEMPRE debe existir
--   - Tener usuario admin@% como alternativa
--   - Actualizar DataGrip para usar 'admin' en lugar de 'root'
-- ============================================================================
