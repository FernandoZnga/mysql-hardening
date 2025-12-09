-- Script para verificar el estado ANTES del hardening
-- Ejecutar: docker exec -i mysql-hardening mysql -uroot -pRootPass123! < check_before_hardening.sql

SELECT '=== 1. USUARIOS ANÓNIMOS ===' AS '';
SELECT User, Host FROM mysql.user WHERE User = '';

SELECT '=== 2. BASE DE DATOS TEST ===' AS '';
SHOW DATABASES LIKE 'test%';

SELECT '=== 3. PUERTO ACTUAL ===' AS '';
SHOW VARIABLES LIKE 'port';

SELECT '=== 4. BIND ADDRESS ===' AS '';
SHOW VARIABLES LIKE 'bind_address';

SELECT '=== 5. ACCESO REMOTO DE ROOT ===' AS '';
SELECT User, Host FROM mysql.user WHERE User = 'root';

SELECT '=== 6. SQL MODE ===' AS '';
SELECT @@sql_mode;

SELECT '=== 7. POLÍTICA DE CONTRASEÑAS ===' AS '';
SHOW VARIABLES LIKE 'validate_password%';

SELECT '=== 8. TODOS LOS USUARIOS ===' AS '';
SELECT User, Host, plugin, password_expired, account_locked 
FROM mysql.user 
ORDER BY User, Host;
