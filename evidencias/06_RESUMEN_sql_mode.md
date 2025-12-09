# EVIDENCIA - PUNTO 6: Establecer sql_mode Seguro

**Fecha de ejecución:** 2025-12-09 04:30 UTC  
**Responsable:** Fernando  
**Sistema:** MySQL 8.0 Community (Docker)  
**Contenedor:** mysql-hardening  

---

## 📋 Resumen Ejecutivo

✅ **RESULTADO: EXITOSO**

Se configuró exitosamente el sql_mode con validaciones estrictas de datos, implementando 7 modos críticos de seguridad que previenen truncamiento de datos, divisiones por cero, fechas inválidas y otros comportamientos inseguros. La configuración está persistida en my.cnf y verificada en el servidor activo.

---

## 🎯 Objetivo del Control

**Control de Seguridad:** Configurar sql_mode estricto para validación rigurosa de datos

**Estándares aplicables:**
- CIS Benchmark for MySQL 8.0 - Section 4.2
- PCI-DSS Requirement 6.5.5 - Improper Error Handling
- ISO 27001 Control A.12.2.1 - Controls against malware
- NIST SP 800-53 SI-10 (Information Input Validation)
- OWASP - Database Security Requirements

**Riesgos mitigados:**
- Truncamiento silencioso de datos críticos (passwords, tokens, IDs)
- Cálculos financieros incorrectos sin advertencia (división/0)
- Fechas inválidas que permiten bypass de controles temporales
- Pérdida de integridad de datos
- Vulnerabilidades de inyección SQL por validación débil

---

## 📊 Estado ANTES del Hardening

### Configuración inicial:
```sql
sql_mode = 'TRADITIONAL'
-- o equivalente a:
STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,
ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
```

### Análisis de gaps:
```
❌ FALTA: ONLY_FULL_GROUP_BY - Permite queries ambiguos
⚠️  Configuración básica pero incompleta
⚠️  No incluye todas las validaciones recomendadas
```

**Hallazgos:**
- ⚠️ Modo TRADITIONAL es buena base pero no completo
- ❌ Falta ONLY_FULL_GROUP_BY para prevenir queries ambiguos
- ✅ Ya incluye validaciones estrictas básicas
- ⚠️ Necesita optimización para máxima seguridad

---

## 🔧 Acciones Realizadas

### Configuración aplicada en my.cnf:
```ini
[mysqld]
sql_mode=STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY
```

### Script de verificación ejecutado:
```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! \
  < hardening_scripts/06_sql_mode.sql
```

### Modos configurados:

#### 1. **STRICT_TRANS_TABLES** 🔴 CRÍTICO
```
Propósito: Rechaza valores inválidos en transacciones InnoDB
Ejemplo:  INSERT INTO users(email) VALUES('email_extremadamente_largo...')
          → ERROR: Data too long for column (en lugar de truncar)
```

#### 2. **STRICT_ALL_TABLES** 🔴 CRÍTICO
```
Propósito: Rechaza valores inválidos en todas las tablas (MyISAM, etc.)
Ejemplo:  INSERT INTO logs(level VARCHAR(5)) VALUES('WARNING_CRITICAL')
          → ERROR en lugar de truncar a 'WARNI'
```

#### 3. **NO_ZERO_IN_DATE** 🟡 IMPORTANTE
```
Propósito: Prohíbe fechas con mes o día 0
Ejemplo:  INSERT INTO events(date) VALUES('2024-00-15')
          → ERROR: Incorrect date value
```

#### 4. **NO_ZERO_DATE** 🟡 IMPORTANTE
```
Propósito: Prohíbe fecha '0000-00-00'
Ejemplo:  INSERT INTO contracts(expiry) VALUES('0000-00-00')
          → ERROR: Invalid date
```

#### 5. **ERROR_FOR_DIVISION_BY_ZERO** 🟡 IMPORTANTE
```
Propósito: Genera error en vez de NULL para división por cero
Ejemplo:  SELECT price / discount WHERE discount = 0
          → ERROR: Division by 0 (en lugar de NULL silencioso)
```

#### 6. **NO_ENGINE_SUBSTITUTION** 🟢 RECOMENDADO
```
Propósito: Error si storage engine solicitado no está disponible
Ejemplo:  CREATE TABLE t1(id INT) ENGINE=MyRocks;
          → ERROR si MyRocks no existe (en lugar de sustituir por InnoDB)
```

#### 7. **ONLY_FULL_GROUP_BY** 🟢 RECOMENDADO
```
Propósito: Queries con GROUP BY deben incluir todas las columnas SELECT
Ejemplo:  SELECT user_id, email FROM users GROUP BY user_id
          → ERROR: email no está en GROUP BY ni es función agregada
```

---

## 📊 Estado DESPUÉS del Hardening

### Configuración verificada:
```sql
-- GLOBAL sql_mode (para todas las nuevas conexiones)
STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,
ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY

-- SESSION sql_mode (sesión actual)
STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,
ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY
```

### Resultados de verificación:
```
✅ STRICT_TRANS_TABLES    - ACTIVO
✅ STRICT_ALL_TABLES      - ACTIVO
✅ NO_ZERO_IN_DATE        - ACTIVO
✅ NO_ZERO_DATE           - ACTIVO
✅ ERROR_FOR_DIVISION_BY_ZERO - ACTIVO
✅ NO_ENGINE_SUBSTITUTION - ACTIVO
✅ ONLY_FULL_GROUP_BY     - ACTIVO
```

**Confirmación:**
- ✅ Los 7 modos críticos están activos
- ✅ Configuración persistida en my.cnf
- ✅ Verificado en GLOBAL y SESSION
- ✅ Pruebas de validación pasadas
- ✅ Sin errores en la configuración

---

## 📸 Evidencias

### Salida completa del script:

```
=== CONFIGURACIÓN SQL_MODE ACTUAL ===

SQL_MODE GLOBAL
STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,
ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY

=== VERIFICACIÓN DE MODOS CRÍTICOS DE SEGURIDAD ===

STRICT_TRANS_TABLES: ✓ ACTIVO
STRICT_ALL_TABLES: ✓ ACTIVO
NO_ZERO_IN_DATE: ✓ ACTIVO
NO_ZERO_DATE: ✓ ACTIVO
ERROR_FOR_DIVISION_BY_ZERO: ✓ ACTIVO
NO_ENGINE_SUBSTITUTION: ✓ ACTIVO
ONLY_FULL_GROUP_BY: ✓ ACTIVO

=== RESUMEN DE SEGURIDAD ===

ESTADO DE SEGURIDAD
SEGURO ✓ - Todos los modos críticos activos
```

**Archivos generados:**
- `hardening_scripts/06_sql_mode.sql` - Script de verificación
- `evidencias/06_resultado_sql_mode.txt` - Log de ejecución
- `documentacion/06_TEORIA_sql_mode.md` - Documentación teórica
- `my.cnf` - Configuración persistente

---

## 🔍 Análisis de Resultados

### ✅ Hallazgos Positivos

1. **Validación estricta de datos activada**
   - Previene truncamiento silencioso de datos críticos
   - Protege integridad de passwords, tokens, IDs
   - Rechaza datos inválidos con errores claros

2. **Protección contra errores matemáticos**
   - División por cero genera error visible
   - Cálculos financieros seguros
   - No más resultados NULL silenciosos

3. **Validación de fechas robusta**
   - Fechas inválidas rechazadas (2024-02-30, 0000-00-00)
   - Previene bypass de controles temporales
   - Integridad de datos temporales garantizada

4. **Queries SQL más seguros**
   - GROUP BY queries deben ser explícitos
   - Previene resultados ambiguos
   - Código SQL más mantenible y predecible

### 📝 Impacto del cambio

**Antes:**
- Modo TRADITIONAL (básico)
- 6 validaciones activas
- Queries ambiguos permitidos

**Después:**
- Modo ESTRICTO COMPLETO
- 7 validaciones activas (todas recomendadas)
- Máxima protección de integridad de datos

### 🎓 Aprendizajes

1. **sql_mode es defensa en profundidad**
   - Última línea de defensa en la base de datos
   - Complementa validaciones de frontend y backend
   - Crítico para cumplimiento normativo

2. **Diferencia entre TRADITIONAL y configuración óptima**
   - TRADITIONAL es buena base pero no completa
   - Agregar ONLY_FULL_GROUP_BY mejora calidad de queries
   - Configuración explícita mejor que alias predefinidos

3. **Impacto en aplicaciones legacy**
   - Aplicaciones antiguas pueden depender de comportamiento permisivo
   - Testing exhaustivo necesario antes de cambiar en producción
   - Puede romper código que asume truncamiento automático

4. **Integridad de datos = Seguridad**
   - Datos corruptos pueden crear vulnerabilidades
   - Token truncado → colisión de sesiones
   - Fecha inválida → bypass de expiración
   - Precio/0 → productos "gratis"

---

## 🛡️ Mejores prácticas aplicadas

| Práctica | Implementado | Observaciones |
|----------|--------------|---------------|
| **Modo estricto en producción** | ✅ | Todos los modos críticos activos |
| **Configuración persistente** | ✅ | Guardado en my.cnf |
| **Verificación post-cambio** | ✅ | Script de validación ejecutado |
| **Documentación completa** | ✅ | Teoría + evidencia + ejemplos |
| **Testing de aplicaciones** | ⚠️ N/A | Ejercicio académico, en prod sería necesario |

---

## 🔒 Ejemplos de protección

### Ejemplo 1: Protección de tokens
```sql
-- ANTES (modo permisivo):
CREATE TABLE sessions (token VARCHAR(32));
INSERT INTO sessions VALUES('este_es_un_token_de_sesion_extremadamente_largo_123456');
-- Se trunca a 'este_es_un_token_de_sesion_ex' ❌
-- Riesgo: Colisión de tokens, sesiones comprometidas

-- DESPUÉS (modo estricto):
INSERT INTO sessions VALUES('este_es_un_token_de_sesion_extremadamente_largo_123456');
-- ERROR: Data too long for column 'token' ✅
-- Aplicación debe manejar el error correctamente
```

### Ejemplo 2: Protección de cálculos financieros
```sql
-- ANTES (modo permisivo):
SELECT order_total / commission_rate FROM orders WHERE commission_rate = 0;
-- Resultado: NULL (sin error) ❌
-- Riesgo: Comisiones calculadas incorrectamente

-- DESPUÉS (modo estricto):
SELECT order_total / commission_rate FROM orders WHERE commission_rate = 0;
-- ERROR: Division by 0 ✅
-- Aplicación detecta el problema y lo maneja
```

### Ejemplo 3: Protección de fechas de expiración
```sql
-- ANTES (modo permisivo):
INSERT INTO contracts (expiry_date) VALUES ('2024-02-30');
-- Guarda fecha incorrecta o '0000-00-00' ❌
-- Riesgo: Contratos sin expiración real

-- DESPUÉS (modo estricto):
INSERT INTO contracts (expiry_date) VALUES ('2024-02-30');
-- ERROR: Incorrect date value '2024-02-30' ✅
-- Validación en capa de base de datos
```

---

## ✅ Estado del Control

| Criterio | Estado | Observaciones |
|----------|--------|---------------|
| **STRICT_TRANS_TABLES activo** | ✅ SÍ | Verificado en GLOBAL y SESSION |
| **STRICT_ALL_TABLES activo** | ✅ SÍ | Todas las engines protegidas |
| **NO_ZERO_IN_DATE activo** | ✅ SÍ | Fechas validadas |
| **NO_ZERO_DATE activo** | ✅ SÍ | Sin fechas 0000-00-00 |
| **ERROR_FOR_DIVISION_BY_ZERO activo** | ✅ SÍ | División/0 genera error |
| **NO_ENGINE_SUBSTITUTION activo** | ✅ SÍ | Engines explícitos |
| **ONLY_FULL_GROUP_BY activo** | ✅ SÍ | GROUP BY queries estrictos |
| **Configuración persistente** | ✅ SÍ | Guardado en my.cnf |
| **Script ejecutado** | ✅ SÍ | Sin errores |
| **Verificación post-cambio** | ✅ SÍ | Confirmado activo |
| **Documentación completa** | ✅ SÍ | Teoría + evidencia |
| **Cumplimiento CIS Benchmark** | ✅ SÍ | Section 4.2 OK |
| **Cumplimiento PCI-DSS** | ✅ SÍ | Req 6.5.5 OK |

---

## 🚀 Próximos Pasos

**Control completado exitosamente.**

Continuar con:
- **Punto 7:** Política de contraseñas con validate_password

---

## 📚 Referencias

- [CIS MySQL 8.0 Benchmark v1.2.0 - Section 4.2](https://www.cisecurity.org/benchmark/mysql)
- [PCI-DSS v4.0 - Requirement 6.5.5](https://www.pcisecuritystandards.org/)
- [MySQL 8.0 Server SQL Modes](https://dev.mysql.com/doc/refman/8.0/en/sql-mode.html)
- [OWASP Database Security](https://owasp.org/www-community/vulnerabilities/Improper_Data_Validation)
- Script: `hardening_scripts/06_sql_mode.sql`
- Teoría: `documentacion/06_TEORIA_sql_mode.md`

---

**Firmado:** Fernando  
**Fecha:** 2025-12-09 04:30 UTC  
**Status:** ✅ COMPLETO
