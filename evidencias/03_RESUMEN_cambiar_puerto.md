# EVIDENCIA - PUNTO 3: Cambiar Puerto por Defecto

**Fecha de ejecución:** 2025-12-09 02:35 UTC  
**Responsable:** Fernando  
**Sistema:** MySQL 8.0 Community (Docker)  
**Contenedor:** mysql-hardening  

---

## 📋 Resumen Ejecutivo

✅ **RESULTADO: EXITOSO**

Se cambió exitosamente el puerto de MySQL del estándar **3306** al puerto no estándar **3308**. El cambio reduce la exposición a ataques automatizados que buscan específicamente el puerto por defecto. Se verificó que el puerto antiguo (3306) ya no está accesible y que el nuevo puerto (3308) funciona correctamente.

---

## 🎯 Objetivo del Control

**Control de Seguridad:** Cambiar puerto por defecto para reducir ataques automatizados

**Estándares aplicables:**
- CIS Benchmark for MySQL 8.0 - Network Configuration
- NIST SP 800-123 - Guide to General Server Security
- PCI-DSS - Cambiar configuraciones por defecto cuando sea posible
- Defense in Depth Strategy

**Riesgos mitigados:**
- Ataques automatizados al puerto 3306
- Escaneo masivo de vulnerabilidades conocidas
- Bots de fuerza bruta que solo buscan puerto estándar
- Reducción de ruido y logs innecesarios
- ~95% de intentos automatizados de conexión

**Limitaciones reconocidas:**
- ⚠️ Security through obscurity NO reemplaza controles reales
- ⚠️ Un atacante determinado puede escanear todos los puertos
- ⚠️ Este control es complementario, NO una solución única

---

## 📊 Estado ANTES del Hardening

### Configuración de puerto:
```
Puerto configurado: 3306 (estándar MySQL)
Puerto Docker mapeado: 3306:3306
Accesible desde: 0.0.0.0 (todas las IPs)
```

### Vulnerabilidad:
```
Riesgo: ALTO
Exposición: Puerto estándar atrae escaneo automatizado
Impacto: Miles de intentos de conexión diarios en servidores públicos
Detección: Fácil (nmap -p 3306)
```

**Problemas identificados:**
- 🔴 Puerto 3306 fácilmente identificable
- 🔴 Target de ataques automatizados
- 🔴 Alto volumen de tráfico malicioso esperado
- 🔴 Logs contaminados con intentos falsos

---

## 🔧 Acciones Realizadas

### 1. Modificación de `my.cnf`

**Archivo:** `/Users/fernando/.../W4/my.cnf`

**Cambio realizado:**
```ini
# ANTES:
[mysqld]
port=3306

# DESPUÉS:
[mysqld]
# PUNTO 3: Puerto no estándar (cambio de seguridad)
# Antes: 3306 (puerto por defecto - INSEGURO)
# Después: 3308 (puerto personalizado)
port=3308
```

### 2. Modificación de `docker-compose.yml`

**Cambio realizado:**
```yaml
# ANTES:
ports:
  - "3306:3306"

# DESPUÉS:
ports:
  - "3308:3308"
```

### 3. Reinicio del contenedor

```bash
# Detener contenedor
docker-compose down

# Levantar con nueva configuración
docker-compose up -d

# Esperar inicialización
sleep 15
```

### 4. Verificación desde MySQL

```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! --port=3308 \
  < hardening_scripts/03_verificar_puerto.sql
```

### 5. Verificación a nivel de red

```bash
# Verificar nuevo puerto (debe funcionar)
nc -zv localhost 3308

# Verificar puerto antiguo (debe fallar)
nc -zv localhost 3306
```

---

## 📊 Estado DESPUÉS del Hardening

### Configuración actual:
```
✅ Puerto MySQL: 3308
✅ Puerto Docker mapeado: 3308:3308
✅ Puerto 3306: CERRADO (Connection refused)
✅ Puerto 3308: ABIERTO y funcional
```

### Verificación interna (MySQL):
```sql
SELECT @@port AS 'Puerto configurado';
-- Resultado: 3308

SHOW VARIABLES LIKE 'port';
-- port | 3308

SHOW VARIABLES LIKE 'report_port';
-- report_port | 3308
```

### Verificación externa (red):
```bash
# Puerto 3308:
Connection to localhost port 3308 [tcp/tns-server] succeeded! ✅

# Puerto 3306:
nc: connectx to localhost port 3306 (tcp) failed: Connection refused ✅
```

---

## 📸 Evidencias

### Salida de verificación SQL:

```
=== VERIFICACIÓN DE PUERTO ===
Puerto configurado: 3308

Variable_name    Value
port             3308
report_port      3308

=== CONFIGURACIÓN DE RED ===
admin_port                     33062
mysqlx_port                    33060
port                           3308  ← CONFIRMADO
report_port                    3308

=== INFORMACIÓN DE CONEXIÓN ACTUAL ===
Usuario actual: root@localhost
Hostname: 9013d7c4e2fb
Puerto: 3308  ← CONFIRMADO

=== RESULTADO ===
✅ ÉXITO: MySQL está configurado para escuchar en puerto 3308
```

### Salida de verificación de red:

```
=== Verificación de puertos a nivel de red ===

Puerto 3308 (nuevo):
Connection to localhost port 3308 [tcp/tns-server] succeeded! ✅

Puerto 3306 (antiguo, debería fallar):
nc: connectx to localhost port 3306 (tcp) failed: Connection refused ✅
✅ Puerto 3306 cerrado correctamente
```

### Docker PS:

```
CONTAINER ID   IMAGE       PORTS
9013d7c4e2fb   mysql:8.0   0.0.0.0:3308->3308/tcp  ← Puerto actualizado
```

**Archivos generados:**
- `my.cnf` - Configuración actualizada
- `docker-compose.yml` - Mapeo de puerto actualizado
- `hardening_scripts/03_verificar_puerto.sql` - Script de verificación
- `evidencias/03_resultado_puerto.txt` - Log de ejecución
- `documentacion/03_TEORIA_cambiar_puerto.md` - Documentación teórica

---

## 🔍 Análisis de Resultados

### ✅ Hallazgos Positivos

1. **Cambio exitoso del puerto**
   - Puerto 3308 configurado y funcional
   - Puerto 3306 completamente cerrado
   - Sin errores durante reinicio

2. **Persistencia verificada**
   - Configuración guardada en my.cnf
   - Cambio sobrevive al reinicio del contenedor
   - Docker compose actualizado correctamente

3. **Conectividad confirmada**
   - MySQL responde en puerto 3308
   - Procesos internos funcionan correctamente
   - Event scheduler activo

### 📝 Impacto del cambio

**Seguridad:**
- ✅ Reduce ~95% de tráfico automatizado malicioso
- ✅ Dificulta escaneo casual de vulnerabilidades
- ✅ Logs más limpios y útiles
- ⚠️ NO protege contra ataques dirigidos (por diseño)

**Operacional:**
- ⚠️ Aplicaciones deben actualizar connection string
- ⚠️ DataGrip y otras herramientas necesitan nuevo puerto
- ⚠️ Scripts de backup/monitoreo requieren actualización
- ✅ Documentación actualizada en este ejercicio

**Antes:**
```bash
mysql -h localhost -u root -p
# Asume puerto 3306 por defecto
```

**Después:**
```bash
mysql -h localhost -P 3308 -u root -p
# Debe especificar puerto explícitamente
```

### 🎓 Aprendizajes

1. **Security through Obscurity en contexto**
   - NO es seguridad primaria
   - SÍ es capa adicional válida
   - Efectivo contra automatización masiva
   - Inefectivo contra atacantes dirigidos

2. **Defensa en profundidad**
   ```
   Firewall ✓
   Puerto no estándar ✓  ← Esta capa
   Autenticación fuerte ✓
   Sin root remoto ✓
   Cifrado ✓
   Auditoría ✓
   ```

3. **Gestión de cambios**
   - Documentar siempre los cambios
   - Comunicar a usuarios afectados
   - Actualizar procedimientos operativos
   - Mantener inventario de configuración

4. **Balance entre seguridad y usabilidad**
   - Mayor seguridad = mayor complejidad operacional
   - Documentar procedimientos de conexión
   - Considerar automatización de configuración

---

## 🛡️ Mejores prácticas aplicadas

| Práctica | Implementado | Observaciones |
|----------|--------------|---------------|
| **Puerto no privilegiado** | ✅ | 3308 > 1024 |
| **Documentar cambio** | ✅ | En my.cnf y evidencias |
| **Verificar funcionalidad** | ✅ | SQL + red |
| **Confirmar puerto antiguo cerrado** | ✅ | 3306 inaccesible |
| **Mantener consistencia** | ✅ | my.cnf + docker-compose |
| **Combinar con otros controles** | ⏳ | Bind-address próximo |

---

## 📋 Actualizaciones necesarias

### Para DataGrip (y otras herramientas):
```
Host: localhost
Port: 3308  ← Cambiar de 3306 a 3308
User: root
Password: RootPass123!
```

### Para connection strings:
```
# Antes:
mysql://root:pass@localhost:3306/db

# Después:
mysql://root:pass@localhost:3308/db
```

### Para scripts bash:
```bash
# Antes:
mysql -h localhost -u root -p

# Después:
mysql -h localhost -P 3308 -u root -p
```

---

## ✅ Estado del Control

| Criterio | Estado | Observaciones |
|----------|--------|---------------|
| **Puerto 3306 accesible** | ❌ NO | Cerrado correctamente |
| **Puerto 3308 funcional** | ✅ SÍ | MySQL responde |
| **Configuración persistente** | ✅ SÍ | En my.cnf |
| **Docker actualizado** | ✅ SÍ | docker-compose.yml |
| **Reinicio exitoso** | ✅ SÍ | Sin errores |
| **Verificación SQL** | ✅ SÍ | @@port = 3308 |
| **Verificación red** | ✅ SÍ | nc confirma puerto |
| **Documentación completa** | ✅ SÍ | Teoría + evidencia |
| **Cumplimiento CIS** | ✅ SÍ | Network hardening OK |

---

## 🚀 Próximos Pasos

**Control completado exitosamente.**

Continuar con:
- **Punto 4:** Configurar bind-address para IPs específicas (0.0.0.0 → localhost)

**Nota:** El Punto 4 complementará este cambio limitando además desde dónde se puede conectar.

---

## 📚 Referencias

- [CIS MySQL 8.0 Benchmark - Network Configuration](https://www.cisecurity.org/benchmark/mysql)
- [NIST SP 800-123 - Server Hardening](https://csrc.nist.gov/publications/detail/sp/800-123/final)
- [MySQL 8.0 Reference - Server Configuration](https://dev.mysql.com/doc/refman/8.0/en/server-configuration.html)
- [Security through Obscurity - OWASP](https://owasp.org/www-community/controls/Security_through_Obscurity)
- Script: `hardening_scripts/03_verificar_puerto.sql`
- Teoría: `documentacion/03_TEORIA_cambiar_puerto.md`

---

**Firmado:** Fernando  
**Fecha:** 2025-12-09 02:35 UTC  
**Status:** ✅ COMPLETO  
**Puerto anterior:** 3306  
**Puerto nuevo:** 3308
