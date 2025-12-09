# PUNTO 6: Establecer sql_mode Seguro

## 📋 Parte Teórica

### ¿Qué es sql_mode?

El **sql_mode** es una variable de sistema en MySQL que controla cómo el servidor maneja la validación de datos, conversiones de tipos, divisiones por cero, y otros comportamientos de SQL.

```sql
-- Ver sql_mode actual
SELECT @@sql_mode;
```

---

## 🔐 ¿Por qué es importante para seguridad?

### 1. **Previene truncamiento silencioso de datos**

```sql
-- Con sql_mode permisivo:
CREATE TABLE users (username VARCHAR(10));
INSERT INTO users VALUES ('usuario_muy_largo');
-- MySQL trunca a 'usuario_mu' SIN ERROR ❌

-- Con sql_mode estricto:
INSERT INTO users VALUES ('usuario_muy_largo');
-- ERROR: Data too long for column ✅
```

**Riesgo de seguridad:**
- Contraseñas/tokens pueden truncarse
- IDs pueden perder dígitos
- Datos críticos se pierden silenciosamente

### 2. **Evita división por cero sin error**

```sql
-- Con sql_mode permisivo:
SELECT 10/0;
-- Resultado: NULL (sin error) ❌

-- Con sql_mode estricto:
SELECT 10/0;
-- ERROR: Division by zero ✅
```

**Riesgo:** Cálculos financieros incorrectos sin advertencia

### 3. **Previene fechas inválidas**

```sql
-- Con sql_mode permisivo:
INSERT INTO events VALUES ('2024-02-30');
-- Acepta '0000-00-00' ❌

-- Con sql_mode estricto:
INSERT INTO events VALUES ('2024-02-30');
-- ERROR: Incorrect date value ✅
```

### 4. **Evita creación accidental de usuarios**

```sql
-- Con NO_AUTO_CREATE_USER (MySQL < 8.0):
GRANT SELECT ON db.* TO 'newuser'@'%';
-- No crea usuario sin password ✅

-- Sin NO_AUTO_CREATE_USER:
GRANT SELECT ON db.* TO 'newuser'@'%';
-- Crea usuario SIN PASSWORD ❌ PELIGRO
```

---

## 🎯 Modos de SQL recomendados para seguridad

### Modos esenciales de seguridad:

| Modo | Propósito | Seguridad |
|------|-----------|-----------|
| **STRICT_TRANS_TABLES** | Rechaza valores inválidos en transacciones | 🔴 CRÍTICO |
| **STRICT_ALL_TABLES** | Rechaza valores inválidos (todas las tablas) | 🔴 CRÍTICO |
| **NO_ZERO_IN_DATE** | Prohíbe '2024-00-15' | 🟡 IMPORTANTE |
| **NO_ZERO_DATE** | Prohíbe '0000-00-00' | 🟡 IMPORTANTE |
| **ERROR_FOR_DIVISION_BY_ZERO** | Error en vez de NULL para división/0 | 🟡 IMPORTANTE |
| **NO_ENGINE_SUBSTITUTION** | Error si motor no disponible | 🟢 RECOMENDADO |
| **ONLY_FULL_GROUP_BY** | GROUP BY debe incluir todas columnas SELECT | 🟢 RECOMENDADO |

### Modo histórico (NO usar):

```sql
NO_AUTO_CREATE_USER  -- Deprecated en MySQL 8.0, ya no necesario
```

---

## 📊 Configuración recomendada

### Para MySQL 8.0:

```sql
sql_mode = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY'
```

### Desglose:

```sql
STRICT_TRANS_TABLES
  → Valores inválidos causan error en transacciones InnoDB
  
STRICT_ALL_TABLES
  → Valores inválidos causan error en MyISAM y otras engines
  
NO_ZERO_IN_DATE
  → '2024-00-15' es inválido
  
NO_ZERO_DATE
  → '0000-00-00' es inválido
  
ERROR_FOR_DIVISION_BY_ZERO
  → SELECT 1/0 produce error, no NULL
  
NO_ENGINE_SUBSTITUTION
  → Si engine solicitado no existe, error en vez de sustituir
  
ONLY_FULL_GROUP_BY
  → Queries ambiguos con GROUP BY causan error
```

---

## 🚫 Modos inseguros (NO usar)

```sql
-- ❌ Modo permisivo antiguo
sql_mode = ''

-- ❌ ANSI mode sin validaciones estrictas
sql_mode = 'ANSI'

-- ❌ Combinaciones que permiten datos inválidos
ALLOW_INVALID_DATES  -- Acepta fechas como '2024-02-30'
```

---

## 🔧 Ejemplos prácticos

### Ejemplo 1: Truncamiento de datos

```sql
-- Configuración INSEGURA:
SET sql_mode = '';
CREATE TABLE users (email VARCHAR(50));
INSERT INTO users VALUES ('este_es_un_email_extremadamente_largo@ejemplo.com');
-- Se trunca a 'este_es_un_email_extremadamente_largo@ejempl'
-- ❌ Email inválido guardado sin error

-- Configuración SEGURA:
SET sql_mode = 'STRICT_ALL_TABLES';
INSERT INTO users VALUES ('este_es_un_email_extremadamente_largo@ejemplo.com');
-- ERROR 1406: Data too long for column 'email'
-- ✅ Aplicación debe manejar el error y ajustar el valor
```

### Ejemplo 2: División por cero

```sql
-- Configuración INSEGURA:
SET sql_mode = '';
SELECT price / discount FROM products WHERE discount = 0;
-- Resultado: NULL (sin error)
-- ❌ Cálculo incorrecto pasa desapercibido

-- Configuración SEGURA:
SET sql_mode = 'ERROR_FOR_DIVISION_BY_ZERO';
SELECT price / discount FROM products WHERE discount = 0;
-- ERROR 1365: Division by 0
-- ✅ Aplicación detecta el problema
```

### Ejemplo 3: Fechas inválidas

```sql
-- Configuración INSEGURA:
SET sql_mode = '';
INSERT INTO reservations (date) VALUES ('2024-02-30');
-- Guarda '0000-00-00' o fecha incorrecta
-- ❌ Dato corrupto en la BD

-- Configuración SEGURA:
SET sql_mode = 'NO_ZERO_DATE,NO_ZERO_IN_DATE';
INSERT INTO reservations (date) VALUES ('2024-02-30');
-- ERROR 1292: Incorrect date value
-- ✅ Validación en capa de base de datos
```

---

## 🛡️ Relación con seguridad

### 1. Integridad de datos

```
Datos válidos = Decisiones correctas
Datos corruptos = Vulnerabilidades potenciales

Ejemplo real:
  - Token de sesión truncado → Colisión de sesiones
  - Fecha inválida → Bypass de expiración
  - Precio con división/0 → Productos "gratis"
```

### 2. Defensa en profundidad

```
Capa 1: Validación en frontend (JavaScript)
Capa 2: Validación en backend (Python/Java/PHP)
Capa 3: Validación en BD (sql_mode) ← Esta capa
Capa 4: Constraints (CHECK, FK)
```

### 3. Compliance

```
GDPR: Integridad de datos personales
PCI-DSS: Integridad de datos de tarjetas
HIPAA: Integridad de datos médicos
SOX: Integridad de datos financieros

sql_mode estricto = Evidencia de controles técnicos
```

---

## ⚠️ Consideraciones de compatibilidad

### Aplicaciones legacy

```
Si tienes aplicaciones antiguas:
  - Pueden depender de comportamiento permisivo
  - Cambiar sql_mode puede romper funcionalidad
  - Necesitas testing exhaustivo

Estrategia:
  1. Probar en desarrollo con sql_mode estricto
  2. Identificar queries problemáticos
  3. Corregir queries
  4. Aplicar en producción
```

### Diferencias entre versiones

```sql
-- MySQL < 5.7:
sql_mode con NO_AUTO_CREATE_USER

-- MySQL 5.7+:
sql_mode sin NO_AUTO_CREATE_USER (ya no necesario)

-- MySQL 8.0+:
sql_mode estricto por defecto
```

---

## 📚 Modos adicionales (opcionales)

### TRADITIONAL

```sql
-- "TRADITIONAL" es un alias para:
STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,
NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION

-- Es una buena base, pero puedes agregar más
```

### ANSI

```sql
-- "ANSI" para compatibilidad con SQL estándar
REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,
IGNORE_SPACE,ONLY_FULL_GROUP_BY

-- Menos enfocado en seguridad, más en estándares
```

---

## 🔍 Verificación y testing

### Cómo verificar sql_mode actual:

```sql
-- Global (para nuevas conexiones)
SELECT @@GLOBAL.sql_mode;

-- Sesión actual
SELECT @@SESSION.sql_mode;

-- Ambos
SHOW VARIABLES LIKE 'sql_mode';
```

### Testing de sql_mode:

```sql
-- Test 1: Truncamiento
CREATE TEMPORARY TABLE test (col VARCHAR(5));
INSERT INTO test VALUES ('123456');
-- Debe dar ERROR con sql_mode estricto

-- Test 2: División por cero
SELECT 1/0;
-- Debe dar ERROR con ERROR_FOR_DIVISION_BY_ZERO

-- Test 3: Fecha inválida
CREATE TEMPORARY TABLE test_date (d DATE);
INSERT INTO test_date VALUES ('2024-02-30');
-- Debe dar ERROR con NO_ZERO_DATE
```

---

## 📝 Configuración persistente

### En my.cnf:

```ini
[mysqld]
sql_mode = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY'
```

### Dinámicamente (no persistente):

```sql
-- Para la sesión actual
SET SESSION sql_mode = 'STRICT_ALL_TABLES,...';

-- Globalmente (para nuevas conexiones)
SET GLOBAL sql_mode = 'STRICT_ALL_TABLES,...';
```

---

## 🎯 Best Practices

1. **Siempre usar modo estricto en producción**
2. **Testing exhaustivo antes de cambiar sql_mode**
3. **Documentar el sql_mode usado**
4. **Monitorear errores después del cambio**
5. **Mantener consistencia entre dev/staging/prod**

---

## ✅ Checklist de verificación

- [ ] Revisar sql_mode actual
- [ ] Agregar modos de seguridad faltantes
- [ ] Actualizar my.cnf
- [ ] Reiniciar MySQL
- [ ] Verificar sql_mode después del reinicio
- [ ] Testing de aplicaciones
- [ ] Monitorear logs de errores
- [ ] Documentar cambio

---

## 📚 Referencias

- **MySQL 8.0 Reference Manual** - Server SQL Modes
- **CIS MySQL 8.0 Benchmark** - SQL Mode Configuration
- **OWASP Database Security** - Data Validation
- **PCI-DSS** - Data Integrity Requirements

---

## 🚀 Próximo paso

Una vez configurado sql_mode seguro, proceder al **Punto 7: Política de contraseñas con validate_password**.
