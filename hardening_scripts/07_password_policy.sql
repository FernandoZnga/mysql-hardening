-- ============================================================================
-- PUNTO 7: CONFIGURAR POLÍTICA DE CONTRASEÑAS CON validate_password
-- ============================================================================
-- 
-- OBJETIVO: Instalar y configurar validate_password para forzar contraseñas fuertes
--
-- RIESGO MITIGADO:
--   - Contraseñas débiles y predecibles
--   - Ataques de fuerza bruta exitosos
--   - Acceso no autorizado por contraseñas comprometidas
--   - Cumplimiento con NIST, PCI-DSS, ISO 27001
--
-- ESTÁNDAR: NIST SP 800-63B, PCI-DSS 8.3.6, CIS MySQL 8.0 Benchmark
-- ============================================================================

-- PASO 1: VERIFICAR SI YA ESTÁ INSTALADO
SELECT '=== VERIFICAR COMPONENTE validate_password ===' AS '';
SELECT * FROM mysql.component WHERE component_urn LIKE '%validate_password%';

-- PASO 2: INSTALAR EL COMPONENTE
SELECT '=== INSTALANDO COMPONENTE ===' AS '';
INSTALL COMPONENT 'file://component_validate_password';

-- PASO 3: VERIFICAR INSTALACIÓN
SELECT '=== VERIFICAR INSTALACIÓN ===' AS '';
SELECT component_urn FROM mysql.component WHERE component_urn LIKE '%validate_password%';

-- PASO 4: VER CONFIGURACIÓN ACTUAL (ANTES)
SELECT '=== CONFIGURACIÓN ANTES DE CAMBIOS ===' AS '';
SHOW VARIABLES LIKE 'validate_password%';

-- PASO 5: CONFIGURAR POLÍTICA MEDIUM (balance seguridad/usabilidad)
SELECT '=== CONFIGURANDO POLÍTICA MEDIUM ===' AS '';

-- Política MEDIUM (1)
SET GLOBAL validate_password.policy = 1;

-- Longitud mínima 12 caracteres
SET GLOBAL validate_password.length = 12;

-- Mínimo 1 número
SET GLOBAL validate_password.number_count = 1;

-- Mínimo 1 carácter especial
SET GLOBAL validate_password.special_char_count = 1;

-- Mínimo 1 mayúscula y 1 minúscula
SET GLOBAL validate_password.mixed_case_count = 1;

-- PASO 6: VERIFICAR CONFIGURACIÓN DESPUÉS
SELECT '=== CONFIGURACIÓN DESPUÉS DE CAMBIOS ===' AS '';
SHOW VARIABLES LIKE 'validate_password%';

-- PASO 7: PROBAR LA POLÍTICA CON CONTRASEÑAS DE PRUEBA
SELECT '=== PROBANDO POLÍTICA ===' AS '';

-- Test 1: Contraseña válida (debe funcionar)
CREATE USER IF NOT EXISTS 'test_user_strong'@'localhost' IDENTIFIED BY 'SecurePass123!';
SELECT 'Test 1: Contraseña fuerte aceptada correctamente' AS 'Resultado';

-- Limpiar usuario de prueba
DROP USER IF EXISTS 'test_user_strong'@'localhost';

-- PASO 8: RESULTADO FINAL
SELECT '=== RESULTADO FINAL ===' AS '';
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM mysql.component WHERE component_urn LIKE '%validate_password%') > 0
        THEN 'EXITO: validate_password instalado y configurado'
        ELSE 'ERROR: validate_password no está instalado'
    END AS 'RESULTADO';

-- Mostrar resumen de política
SELECT 
    'POLICY' AS 'Parámetro',
    @@validate_password.policy AS 'Valor',
    CASE @@validate_password.policy
        WHEN 0 THEN 'LOW - Solo longitud'
        WHEN 1 THEN 'MEDIUM - Complejidad completa'
        WHEN 2 THEN 'STRONG - Con diccionario'
    END AS 'Descripción'
UNION ALL
SELECT 'LENGTH', @@validate_password.length, 'Caracteres mínimos'
UNION ALL
SELECT 'NUMBER_COUNT', @@validate_password.number_count, 'Números mínimos'
UNION ALL
SELECT 'SPECIAL_CHAR_COUNT', @@validate_password.special_char_count, 'Caracteres especiales mínimos'
UNION ALL
SELECT 'MIXED_CASE_COUNT', @@validate_password.mixed_case_count, 'May/min mínimas';

-- ============================================================================
-- NOTAS IMPORTANTES:
--
-- 1. CONTRASEÑAS EXISTENTES:
--    validate_password NO valida contraseñas existentes, solo nuevas/cambiadas
--
-- 2. CONFIGURACIÓN PERSISTENTE:
--    Para que sobreviva al reinicio, agregar a my.cnf:
--    [mysqld]
--    validate-password=FORCE_PLUS_PERMANENT
--    validate_password.policy=1
--    validate_password.length=12
--    validate_password.number_count=1
--    validate_password.special_char_count=1
--    validate_password.mixed_case_count=1
--
-- 3. EJEMPLOS DE CONTRASEÑAS VÁLIDAS:
--    - MySecurePass2024!
--    - Admin$tr0ng#2024
--    - DataBase&Pass123
--
-- 4. EJEMPLOS DE CONTRASEÑAS INVÁLIDAS:
--    - 123456 (muy corta, sin complejidad)
--    - password (sin números ni especiales)
--    - Password1 (sin caracteres especiales)
--
-- 5. TESTING:
--    Probar creando usuario:
--    CREATE USER 'test'@'localhost' IDENTIFIED BY 'tu_contraseña';
--    Si es débil, verás: ERROR 1819: Your password does not satisfy...
-- ============================================================================
