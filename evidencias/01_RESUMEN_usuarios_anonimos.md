# EVIDENCIA - PUNTO 1: Deshabilitar Usuarios Anónimos

**Fecha de ejecución:** 2025-12-09  
**Responsable:** Fernando  
**Sistema:** MySQL 8.0 Community (Docker)  
**Contenedor:** mysql-hardening  

---

## 📋 Resumen Ejecutivo

✅ **RESULTADO: EXITOSO**

El sistema MySQL 8.0 Community ya venía seguro por defecto. No se encontraron usuarios anónimos en el sistema. Se ejecutó el script de verificación y limpieza como parte del checklist de hardening estándar.

---

## 🎯 Objetivo del Control

**Control de Seguridad:** Eliminar usuarios anónimos que permitan acceso sin autenticación

**Estándares aplicables:**
- CIS Benchmark for MySQL 8.0 - Section 1.2
- PCI-DSS Requirement 8.2
- ISO 27001 Control A.9.2.1
- NIST SP 800-53 IA-2

**Riesgos mitigados:**
- Acceso no autorizado sin credenciales
- Escalación de privilegios
- Falta de trazabilidad de accesos
- Incumplimiento normativo

---

## 📊 Estado ANTES del Hardening

```sql
-- Consulta ejecutada:
SELECT User, Host, plugin 
FROM mysql.user 
WHERE User = '';

-- Resultado:
Total de usuarios anónimos encontrados: 0
```

**Análisis:**
- ✅ No se encontraron usuarios anónimos
- ✅ MySQL 8.0 no crea usuarios anónimos por defecto
- ✅ El sistema ya cumple con este requisito de seguridad

---

## 🔧 Acciones Realizadas

### Script ejecutado:
```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! \
  < hardening_scripts/01_eliminar_usuarios_anonimos.sql
```

### Comandos SQL ejecutados:

1. **Verificación inicial:**
   ```sql
   SELECT User, Host FROM mysql.user WHERE User = '';
   ```

2. **Conteo de usuarios anónimos:**
   ```sql
   SELECT COUNT(*) FROM mysql.user WHERE User = '';
   ```

3. **Eliminación (preventiva):**
   ```sql
   DELETE FROM mysql.user WHERE User = '';
   FLUSH PRIVILEGES;
   ```

4. **Verificación final:**
   ```sql
   SELECT User, Host FROM mysql.user WHERE User = '';
   ```

---

## 📊 Estado DESPUÉS del Hardening

```
RESULTADO: ✅ ÉXITO: No hay usuarios anónimos en el sistema
```

**Verificación:**
- ✅ 0 usuarios anónimos en el sistema
- ✅ Control implementado correctamente
- ✅ Sistema cumple con requisitos de seguridad

---

## 📸 Evidencias

### Salida completa del script:

```
mysql: [Warning] Using a password on the command line interface can be insecure.

VERIFICACIÓN: Usuarios anónimos ANTES de eliminar

Total de usuarios anónimos encontrados: 0

VERIFICACIÓN: Usuarios anónimos DESPUÉS de eliminar
RESULTADO
✅ ÉXITO: No hay usuarios anónimos en el sistema
```

**Archivos generados:**
- `hardening_scripts/01_eliminar_usuarios_anonimos.sql` - Script de hardening
- `evidencias/01_resultado_usuarios_anonimos.txt` - Log de ejecución
- `documentacion/01_TEORIA_usuarios_anonimos.md` - Documentación teórica

---

## 🔍 Análisis de Resultados

### ✅ Hallazgos Positivos

1. **MySQL 8.0 seguro por defecto**
   - La versión moderna ya no crea usuarios anónimos
   - Mejora significativa vs versiones antiguas (< 5.7)

2. **Cumplimiento inmediato**
   - Este control ya estaba satisfecho
   - No requirió remediación

3. **Buena práctica validada**
   - El checklist permite verificar incluso en sistemas modernos
   - Útil para migraciones y auditorías

### 📝 Notas Importantes

- **Warning sobre password en CLI:** Es normal en Docker, se resolverá en configuración de producción
- **Diferencia con versiones antiguas:** En MySQL < 5.7 este paso sería crítico
- **Validación continua:** Debe repetirse periódicamente en auditorías

---

## 🎓 Aprendizajes

1. **Evolución de MySQL**
   - Las versiones modernas son más seguras por defecto
   - El hardening sigue siendo necesario para otros aspectos

2. **Importancia del checklist**
   - Verificar es mejor que asumir
   - Los checklists detectan regresiones y configuraciones personalizadas

3. **Defensa en profundidad**
   - Este control es solo el primero de varios
   - La seguridad requiere múltiples capas

---

## ✅ Estado del Control

| Criterio | Estado | Observaciones |
|----------|--------|---------------|
| **Usuarios anónimos presentes** | ❌ NO | Sistema seguro |
| **Script ejecutado** | ✅ SÍ | Sin errores |
| **Verificación post-cambio** | ✅ SÍ | Confirmado |
| **Documentación completa** | ✅ SÍ | Teoría + evidencia |
| **Cumplimiento CIS Benchmark** | ✅ SÍ | Section 1.2 OK |

---

## 🚀 Próximos Pasos

**Control completado exitosamente.**

Continuar con:
- **Punto 2:** Eliminar la base de datos de prueba (test) y privilegios asociados

---

## 📚 Referencias

- [MySQL 8.0 Security Guide - Account Management](https://dev.mysql.com/doc/refman/8.0/en/account-management-statements.html)
- [CIS MySQL 8.0 Benchmark v1.2.0](https://www.cisecurity.org/benchmark/mysql)
- Script: `hardening_scripts/01_eliminar_usuarios_anonimos.sql`
- Teoría: `documentacion/01_TEORIA_usuarios_anonimos.md`

---

**Firmado:** Fernando  
**Fecha:** 2025-12-09 02:15 UTC
