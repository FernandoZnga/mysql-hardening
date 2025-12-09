# PUNTO 5: Deshabilitar Acceso Remoto del Usuario Root

## 📋 Parte Teórica

### ¿Qué es root@%?

En MySQL, los usuarios se definen como `usuario@host`, donde:

```
root@localhost  → Root solo desde el mismo servidor (SEGURO)
root@%          → Root desde cualquier host (PELIGROSO)
root@IP         → Root solo desde IP específica
```

El símbolo **%** es un comodín que significa **"desde cualquier host"**.

---

## 🔐 ¿Por qué root@% es extremadamente peligroso?

### 1. **Superpoderes sin restricción de red**

```
root tiene TODOS los privilegios:
├── Crear/eliminar bases de datos
├── Crear/eliminar usuarios
├── Modificar configuración del servidor
├── Apagar el servidor (SHUTDOWN)
├── Leer archivos del sistema (FILE privilege)
├── Ejecutar comandos del OS (en configuraciones inseguras)
└── GRANT OPTION (dar privilegios a otros)

Si root@% existe:
→ Cualquiera que descubra la contraseña puede hacer TODO
→ Desde CUALQUIER ubicación en la red
→ Sin restricción geográfica o de red
```

### 2. **Target #1 de atacantes**

```
Atacantes siempre intentan:
1. Escanear puerto MySQL (3306/3308)
2. Intentar usuario 'root'
3. Fuerza bruta de contraseña
4. Si root@% existe → Control total del servidor

Estadísticas reales:
- 90% de intentos de ataque usan 'root' como usuario
- Herramientas automáticas buscan root@%
- Exploits publicados asumen root@% existe
```

### 3. **Violación de principio de mínimo privilegio**

```
PREGUNTA: ¿Necesitas conectarte como root remotamente?
RESPUESTA CORRECTA: NO

Razones:
- Administración remota → SSH tunnel + root@localhost
- Aplicaciones → Usuario específico con privilegios limitados
- Backups → Usuario de solo lectura
- Monitoreo → Usuario con privilegios mínimos
```

### 4. **Cumplimiento normativo**

Estándares que PROHÍBEN root remoto:

- **CIS Benchmark for MySQL 8.0** - Section 2.7 (Ensure 'root' login is restricted to localhost)
- **PCI-DSS** - Requirement 2.1 (Change vendor defaults)
- **ISO 27001** - Control A.9.2.3 (Management of privileged access rights)
- **NIST SP 800-53** - AC-6 (Least Privilege)
- **SOC 2** - Privileged account management
- **HIPAA** - Administrative safeguards

---

## 🎯 Arquitectura correcta de usuarios

### Usuarios que DEBEN existir:

```sql
-- 1. Root local (DEBE existir)
root@localhost
- Acceso: Solo desde el mismo servidor
- Uso: Administración directa, emergencias
- Acceso remoto: Vía SSH tunnel

-- 2. Usuario admin alternativo (RECOMENDADO)
admin@%
- Acceso: Remoto con contraseña fuerte
- Uso: Administración diaria
- Alternativa a root remoto

-- 3. Usuarios de aplicación (REQUERIDO)
app_user@'192.168.1.50'
- Acceso: Solo desde servidor de aplicación
- Privilegios: Solo lo necesario (SELECT, INSERT, UPDATE en BDs específicas)

-- 4. Usuario de solo lectura (RECOMENDADO)
readonly@'192.168.1.100'
- Acceso: Servidor de reportes/analytics
- Privilegios: Solo SELECT

-- 5. Usuario de backup (RECOMENDADO)
backup@localhost
- Acceso: Solo local
- Privilegios: SELECT, LOCK TABLES, RELOAD
```

### Usuarios que NO DEBEN existir:

```sql
-- ❌ Root remoto
root@%

-- ❌ Usuarios anónimos
''@localhost

-- ❌ Usuarios con privilegios excesivos
app@'%' WITH ALL PRIVILEGES
```

---

## 🔧 Cómo acceder a root de forma segura

### Opción 1: SSH Tunnel (RECOMENDADO)

```bash
# Paso 1: Crear túnel SSH
ssh -L 3308:localhost:3308 usuario@servidor-mysql

# Paso 2: Conectar a través del túnel
mysql -h 127.0.0.1 -P 3308 -u root -p

# MySQL ve la conexión como root@localhost ✓
```

**Ventajas:**
- Root solo desde localhost (seguro)
- Tráfico cifrado por SSH
- Autenticación SSH (keys, 2FA)
- Auditable

### Opción 2: VPN

```
Cliente → VPN → Red interna → MySQL root@localhost
```

### Opción 3: Bastion Host

```
Cliente → Bastion → MySQL root@'IP_BASTION'
```

### Opción 4: Usuario admin alternativo (lo que hicimos)

```sql
-- En lugar de root@%, usar:
CREATE USER 'admin'@'%' WITH STRONG PASSWORD
```

---

## 📊 Comparativa de configuraciones

| Configuración | Seguridad | Flexibilidad | Recomendación |
|---------------|-----------|--------------|---------------|
| **root@localhost** | ⭐⭐⭐⭐⭐ | ⭐ | ✅ SIEMPRE |
| **root@IP_específica** | ⭐⭐⭐ | ⭐⭐ | ⚠️ Solo con firewall |
| **root@%** | ⭐ | ⭐⭐⭐⭐⭐ | ❌ NUNCA |
| **admin@%** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ Alternativa válida |

---

## 🚨 Escenarios de ataque real

### Ataque 1: Fuerza bruta

```
Atacante descubre:
- Servidor MySQL en puerto 3308
- Usuario root@% existe

Ejecuta:
hydra -l root -P passwords.txt mysql://target:3308

Si la contraseña es débil:
→ Acceso completo al servidor
→ Robo de datos
→ Ransomware
→ Destrucción de datos
```

### Ataque 2: Credenciales filtradas

```
Escenario:
- Contraseña de root@% en código fuente
- Código fuente en GitHub público
- Atacante encuentra credenciales

Resultado:
→ Acceso inmediato desde cualquier lugar del mundo
```

### Ataque 3: Explotación de vulnerabilidad

```
Si se descubre vulnerabilidad en MySQL:
- Exploits asumen root@% existe
- Escalación directa a privilegios máximos
- Sin necesidad de contraseña (algunos exploits)
```

---

## ✅ Proceso correcto de eliminación

### Paso 1: Verificar usuarios actuales

```sql
SELECT User, Host FROM mysql.user WHERE User = 'root';
```

### Paso 2: Asegurar alternativa

```sql
-- Crear usuario admin ANTES de eliminar root@%
CREATE USER 'admin'@'%' IDENTIFIED BY 'StrongPassword!';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
```

### Paso 3: Eliminar root@%

```sql
DROP USER 'root'@'%';
FLUSH PRIVILEGES;
```

### Paso 4: Verificar

```sql
SELECT User, Host FROM mysql.user WHERE User = 'root';
-- Debe mostrar SOLO root@localhost
```

### Paso 5: Probar conectividad

```sql
-- Esto debe funcionar (root local)
mysql -h localhost -u root -p

-- Esto debe FALLAR (root remoto eliminado)
mysql -h IP_SERVIDOR -u root -p
```

---

## 🛡️ Defensa en profundidad

```
Capa 1: Firewall (bloquear puerto excepto IPs autorizadas)
Capa 2: bind-address (limitar interfaces de escucha)
Capa 3: No root@% (eliminar usuario todopoderoso remoto) ← Esta capa
Capa 4: Contraseñas fuertes (punto 7)
Capa 5: Cifrado TLS/SSL
Capa 6: Auditoría de accesos
```

---

## ⚠️ Consideraciones importantes

### 1. No te quedes sin acceso

```
ANTES de eliminar root@%:
✓ Verifica que root@localhost existe
✓ Crea usuario admin alternativo
✓ Prueba el usuario alternativo
✓ Documenta credenciales seguramente

DESPUÉS de eliminar root@%:
✓ Actualiza aplicaciones
✓ Actualiza scripts
✓ Documenta el cambio
✓ Comunica al equipo
```

### 2. Aplicaciones afectadas

```
Revisar y actualizar:
- Connection strings en aplicaciones
- Scripts de backup
- Herramientas de monitoreo
- Procedimientos de administración
```

### 3. Docker/Contenedores

En contenedores, root@% puede ser "aceptable" si:
- El contenedor está en red privada
- No hay port mapping expuesto
- Es ambiente de desarrollo local

**Pero incluso así, es mejor práctica eliminarlo.**

---

## 📚 Referencias

- **CIS MySQL 8.0 Benchmark v1.2.0** - Section 2.7
- **PCI-DSS v4.0** - Requirement 2.1
- **OWASP Database Security** - Privileged Account Management
- **NIST SP 800-53** - AC-6 (Least Privilege)
- **ISO 27001:2013** - A.9.2.3

---

## 🎓 Lección clave

```
root@% es el equivalente de:
"Dejar la llave maestra de tu casa bajo el felpudo, 
con un letrero que dice 'La contraseña es 1234'"

root@localhost + SSH tunnel es:
"Llave maestra en caja fuerte, solo accesible 
con autenticación biométrica + 2FA"
```

---

## ✅ Checklist de verificación

- [ ] Verificar que existe root@localhost
- [ ] Crear usuario admin alternativo
- [ ] Probar usuario admin
- [ ] Eliminar root@%
- [ ] Verificar eliminación
- [ ] Probar que root remoto ya no funciona
- [ ] Actualizar DataGrip/herramientas
- [ ] Documentar cambio
- [ ] Comunicar al equipo

---

## 🚀 Próximo paso

Una vez eliminado root@%, proceder al **Punto 6: Establecer sql_mode seguro**.
