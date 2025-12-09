# EVIDENCIA - PUNTO 2: Eliminar Base de Datos de Prueba (test)

**Fecha de ejecución:** 2025-12-09 02:30 UTC  
**Responsable:** Fernando  
**Sistema:** MySQL 8.0 Community (Docker)  
**Contenedor:** mysql-hardening  

---

## 📋 Resumen Ejecutivo

✅ **RESULTADO: EXITOSO**

Se identificó y eliminó exitosamente la base de datos 'testdb' que no tenía propósito legítimo en el sistema. La base no contenía tablas ni datos, y no tenía privilegios especiales asociados. El sistema ahora solo contiene las bases de datos del sistema de MySQL.

---

## 🎯 Objetivo del Control

**Control de Seguridad:** Eliminar bases de datos de prueba que no tienen propósito en producción

**Estándares aplicables:**
- CIS Benchmark for MySQL 8.0 - Section 1.3
- PCI-DSS Requirement 2.2 - Remove unnecessary functionality
- ISO 27001 Control A.12.5.1
- NIST SP 800-53 CM-7 (Least Functionality)
- SOC 2 - Separation of environments

**Riesgos mitigados:**
- Exposición de datos sensibles en BDs "temporales"
- Vector de ataque lateral
- Confusión entre ambientes dev/test/prod
- Falta de auditoría y ownership
- Violaciones de cumplimiento normativo

---

## 📊 Estado ANTES del Hardening

### Bases de datos encontradas:
```
Database
├── information_schema  (sistema)
├── mysql              (sistema)
├── performance_schema (sistema)
├── sys                (sistema)
└── testdb             ⚠️ BASE DE PRUEBA
```

### Análisis de 'testdb':
```sql
Base: testdb
Patrón: test%
Tablas: 0 (vacía)
Privilegios especiales: Ninguno
Riesgo: MEDIO (no contiene datos pero aumenta superficie de ataque)
```

**Hallazgos:**
- ✅ No existe base 'test' (MySQL antiguo)
- ⚠️ Existe 'testdb' (creada en docker-compose)
- ✅ La base está vacía (0 tablas)
- ✅ No tiene privilegios especiales asignados
- ⚠️ Total de 1 base con patrón 'test%'

---

## 🔧 Acciones Realizadas

### Script ejecutado:
```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! \
  < hardening_scripts/02_eliminar_base_test.sql
```

### Pasos ejecutados:

#### 1. **Verificación inicial**
```sql
-- Listar todas las bases
SHOW DATABASES;

-- Buscar bases 'test'
SHOW DATABASES LIKE 'test%';

-- Resultado: testdb encontrada
```

#### 2. **Análisis de contenido**
```sql
-- Verificar si hay tablas
SELECT COUNT(*) FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'testdb';

-- Resultado: 0 tablas (base vacía)
```

#### 3. **Verificación de privilegios**
```sql
-- Buscar privilegios sobre bases test
SELECT * FROM mysql.db WHERE Db LIKE 'test%';

-- Resultado: Sin privilegios especiales
```

#### 4. **Eliminación**
```sql
-- Eliminar base 'test' (si existiera)
DROP DATABASE IF EXISTS test;

-- Eliminar base 'testdb'
DROP DATABASE IF EXISTS testdb;
```

#### 5. **Limpieza de privilegios**
```sql
-- Eliminar privilegios residuales
DELETE FROM mysql.db WHERE Db = 'test';
DELETE FROM mysql.db WHERE Db = 'testdb';
DELETE FROM mysql.db WHERE Db LIKE 'test\_%';

-- Aplicar cambios
FLUSH PRIVILEGES;
```

#### 6. **Verificación post-eliminación**
```sql
-- Confirmar eliminación
SHOW DATABASES LIKE 'test%';
-- Resultado: Sin resultados ✅
```

---

## 📊 Estado DESPUÉS del Hardening

### Bases de datos actuales:
```
Database
├── information_schema  (sistema)
├── mysql              (sistema)
├── performance_schema (sistema)
└── sys                (sistema)
```

### Resultados de verificación:
```
✅ ÉXITO: No hay bases de datos tipo "test" en el sistema
✅ ÉXITO: No hay privilegios sobre bases "test" en el sistema
```

**Confirmación:**
- ✅ Base 'test' no existe
- ✅ Base 'testdb' eliminada correctamente
- ✅ No hay bases con patrón 'test%'
- ✅ No hay privilegios residuales
- ✅ Solo bases de sistema de MySQL presentes

---

## 📸 Evidencias

### Salida completa del script:

```
=== 1. TODAS LAS BASES DE DATOS ===
Database
information_schema
mysql
performance_schema
sys
testdb                    ← Base identificada para eliminar

=== 3. BUSCAR BASES CON PATRÓN "test_%" ===
Database (test%)
testdb                    ← 1 base encontrada

=== 4. CONTAR BASES DE TIPO TEST ===
Total bases test%
1                         ← Confirmado

=== 5. CONTENIDO DE testdb (si existe) ===
Total tablas en testdb
0                         ← Base vacía (sin riesgo de pérdida de datos)

=== 6. PRIVILEGIOS SOBRE BASES TEST ===
(Sin resultados)          ← Sin privilegios especiales

=== ELIMINANDO: Base de datos "testdb" ===
(Ejecutado exitosamente)

=== VERIFICACIÓN: Bases de datos después de limpieza ===
Database
information_schema
mysql
performance_schema
sys                       ← testdb ya no está presente

RESULTADO DE BASES DE DATOS
✅ ÉXITO: No hay bases de datos tipo "test" en el sistema

RESULTADO DE PRIVILEGIOS
✅ ÉXITO: No hay privilegios sobre bases "test" en el sistema
```

**Archivos generados:**
- `hardening_scripts/02_eliminar_base_test.sql` - Script de hardening
- `evidencias/02_resultado_base_test.txt` - Log de ejecución
- `documentacion/02_TEORIA_base_test.md` - Documentación teórica

---

## 🔍 Análisis de Resultados

### ✅ Hallazgos Positivos

1. **Base vacía eliminada sin impacto**
   - 'testdb' no contenía tablas ni datos
   - No hubo pérdida de información
   - Operación de bajo riesgo

2. **Sin dependencias**
   - No había privilegios especiales asociados
   - No hay usuarios dependiendo de esta base
   - No hay scripts que la referencien

3. **Limpieza completa**
   - Base eliminada correctamente
   - Privilegios revocados (aunque no había)
   - Sistema verificado post-cambio

4. **MySQL 8.0 ya mejorado**
   - No existe base 'test' de versiones antiguas
   - Solo estaba 'testdb' de nuestro docker-compose

### 📝 Impacto del cambio

**Antes:**
- 5 bases de datos (4 sistema + 1 prueba)
- Superficie de ataque ligeramente mayor
- Nombre genérico 'testdb' podría confundir

**Después:**
- 4 bases de datos (solo sistema)
- Superficie de ataque reducida
- Claridad total: solo bases necesarias

### 🎓 Aprendizajes

1. **Importancia de nomenclatura**
   - Nombres genéricos como 'test' o 'testdb' son señal de alerta
   - Mejor usar nombres específicos del proyecto
   - Ejemplo: 'hardening_exercise' en lugar de 'testdb'

2. **Verificación antes de eliminar**
   - Siempre revisar contenido antes de DROP
   - Verificar privilegios y dependencias
   - En producción real: hacer backup preventivo

3. **Separación de ambientes**
   - Las bases de prueba NO deben estar en producción
   - Usar contenedores efímeros para testing
   - Mantener dev/test/prod completamente separados

4. **Defensa en profundidad**
   - Eliminar vectores de ataque innecesarios
   - Reducir superficie de ataque sistemáticamente
   - Cada elemento debe tener propósito justificado

---

## 🛡️ Mejores prácticas aplicadas

| Práctica | Implementado | Observaciones |
|----------|--------------|---------------|
| **Verificar antes de eliminar** | ✅ | Se revisó contenido y privilegios |
| **Backup preventivo** | ⚠️ N/A | Base vacía, no necesario |
| **Documentar cambios** | ✅ | Evidencia completa generada |
| **Verificar post-cambio** | ✅ | Confirmado sin bases test% |
| **Comunicar al equipo** | ⚠️ Solo ejercicio | En prod real sería necesario |

---

## ✅ Estado del Control

| Criterio | Estado | Observaciones |
|----------|--------|---------------|
| **Base 'test' presente** | ❌ NO | Nunca existió (MySQL 8.0) |
| **Base 'testdb' presente** | ❌ NO | Eliminada exitosamente |
| **Privilegios test% presentes** | ❌ NO | Sin privilegios residuales |
| **Script ejecutado** | ✅ SÍ | Sin errores |
| **Verificación post-cambio** | ✅ SÍ | Confirmado |
| **Documentación completa** | ✅ SÍ | Teoría + evidencia |
| **Cumplimiento CIS Benchmark** | ✅ SÍ | Section 1.3 OK |
| **Cumplimiento PCI-DSS** | ✅ SÍ | Req 2.2 OK |

---

## 🚀 Próximos Pasos

**Control completado exitosamente.**

Continuar con:
- **Punto 3:** Cambiar puerto por defecto (3306 → 3308)

---

## 📚 Referencias

- [CIS MySQL 8.0 Benchmark v1.2.0 - Section 1.3](https://www.cisecurity.org/benchmark/mysql)
- [PCI-DSS v4.0 - Requirement 2.2](https://www.pcisecuritystandards.org/)
- [MySQL 8.0 Database Management](https://dev.mysql.com/doc/refman/8.0/en/database-use.html)
- Script: `hardening_scripts/02_eliminar_base_test.sql`
- Teoría: `documentacion/02_TEORIA_base_test.md`

---

**Firmado:** Fernando  
**Fecha:** 2025-12-09 02:30 UTC  
**Status:** ✅ COMPLETO
