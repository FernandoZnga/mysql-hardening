-- ============================================================================
-- PUNTO 1: DESHABILITAR USUARIOS ANÓNIMOS
-- ============================================================================
-- 
-- OBJETIVO: Eliminar cualquier usuario anónimo (User='') que permita
--           conexiones sin autenticación
--
-- RIESGO MITIGADO:
--   - Acceso no autorizado sin credenciales
--   - Escalación de privilegios desde usuarios anónimos
--   - Cumplimiento con CIS MySQL Benchmark 1.2
--
-- ESTÁNDAR: CIS Benchmark for MySQL 8.0 - Section 1.2
-- ============================================================================

-- Verificar si existen usuarios anónimos
SELECT 'VERIFICACIÓN: Usuarios anónimos ANTES de eliminar' AS '';
SELECT User, Host, plugin 
FROM mysql.user 
WHERE User = '' 
ORDER BY Host;

-- Contar usuarios anónimos
SELECT CONCAT('Total de usuarios anónimos encontrados: ', COUNT(*)) AS '' 
FROM mysql.user 
WHERE User = '';

-- Eliminar usuarios anónimos
-- Nota: En MySQL 8.0 Community, por defecto NO se crean usuarios anónimos
-- pero este paso es parte del checklist de seguridad estándar

DELETE FROM mysql.user WHERE User = '';

-- Recargar privilegios para aplicar cambios
FLUSH PRIVILEGES;

-- Verificar eliminación
SELECT 'VERIFICACIÓN: Usuarios anónimos DESPUÉS de eliminar' AS '';
SELECT User, Host 
FROM mysql.user 
WHERE User = '' 
ORDER BY Host;

-- Mostrar resultado
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM mysql.user WHERE User = '') = 0 
        THEN '✅ ÉXITO: No hay usuarios anónimos en el sistema'
        ELSE '❌ ERROR: Aún existen usuarios anónimos'
    END AS 'RESULTADO';

-- ============================================================================
-- NOTAS ADICIONALES:
--
-- En versiones antiguas de MySQL (< 5.7), el instalador creaba usuarios
-- anónimos por defecto. MySQL 8.0 ha mejorado esto y ya no los crea.
--
-- Sin embargo, mantener este paso en el checklist es una buena práctica
-- para ambientes migrados o instalaciones personalizadas.
--
-- EVIDENCIA A DOCUMENTAR:
--   1. Captura de pantalla del estado ANTES
--   2. Ejecución del script
--   3. Captura de pantalla del estado DESPUÉS
-- ============================================================================
