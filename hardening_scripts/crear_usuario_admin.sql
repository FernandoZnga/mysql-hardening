-- ============================================================================
-- CREAR USUARIO ADMINISTRADOR ALTERNATIVO
-- ============================================================================
-- 
-- OBJETIVO: Crear un usuario administrador con privilegios completos
--           ANTES de eliminar root@% para no quedarnos sin acceso
--
-- BUENA PRÁCTICA: Nunca eliminar root remoto sin tener un usuario alternativo
-- ============================================================================

-- Verificar usuarios existentes
SELECT '=== USUARIOS ACTUALES ===' AS '';
SELECT User, Host, plugin FROM mysql.user ORDER BY User, Host;

-- Crear usuario administrador
-- Usuario: admin
-- Password: Admin123!Secure
-- Host: % (acceso desde cualquier host - puedes cambiarlo después)

CREATE USER IF NOT EXISTS 'admin'@'%' 
IDENTIFIED BY 'Admin123!Secure';

-- Otorgar TODOS los privilegios (equivalente a root)
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;

-- Recargar privilegios
FLUSH PRIVILEGES;

-- Verificar usuario creado
SELECT '=== USUARIO ADMIN CREADO ===' AS '';
SELECT User, Host, plugin 
FROM mysql.user 
WHERE User = 'admin';

-- Verificar privilegios del usuario admin
SELECT '=== PRIVILEGIOS DEL USUARIO ADMIN ===' AS '';
SHOW GRANTS FOR 'admin'@'%';

-- Resultado
SELECT 'Usuario admin creado exitosamente con todos los privilegios' AS 'RESULTADO';

-- ============================================================================
-- CREDENCIALES DEL NUEVO USUARIO:
--
-- Usuario: admin
-- Password: Admin123!Secure
-- Host: % (desde cualquier IP)
--
-- IMPORTANTE: Después del Punto 5, usarás este usuario en lugar de root
--
-- Para conectar:
--   mysql -h 127.0.0.1 -P 3308 -u admin -p
--   Password: Admin123!Secure
-- ============================================================================
