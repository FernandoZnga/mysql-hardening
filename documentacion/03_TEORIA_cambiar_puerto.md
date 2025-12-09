# PUNTO 3: Cambiar Puerto por Defecto de MySQL

## 📋 Parte Teórica

### ¿Qué es el puerto por defecto?

MySQL utiliza el **puerto TCP 3306** como puerto estándar para conexiones de red. Este puerto es:

```
Protocolo: TCP
Puerto: 3306
Servicio: MySQL/MariaDB
Asignado por: IANA (Internet Assigned Numbers Authority)
```

### ¿Por qué 3306 es el estándar?

1. **Convención histórica:** MySQL siempre ha usado 3306 desde sus primeras versiones
2. **Estandarización IANA:** Oficialmente registrado para MySQL
3. **Herramientas y drivers:** Todos asumen 3306 por defecto
4. **Documentación:** Ejemplos y tutoriales usan 3306

**Conexión típica:**
```bash
mysql -h servidor -P 3306 -u usuario -p
# Si no se especifica puerto, asume 3306
mysql -h servidor -u usuario -p
```

---

## 🔐 ¿Por qué cambiar el puerto es una medida de seguridad?

### 1. **Reducir ataques automatizados (Security through Obscurity)**

**Escáneres automáticos buscan puertos conocidos:**
```bash
# Atacantes ejecutan:
nmap -p 3306 192.168.1.0/24

# Si encuentran puerto abierto:
# → Intentan exploits conocidos de MySQL
# → Ataques de fuerza bruta
# → Exploits de versiones vulnerables
```

**Beneficio:** Los escáneres automáticos pasan de largo si no encuentran 3306

### 2. **Reducción de ruido y logs**

Los servidores en internet reciben **miles de intentos diarios** en 3306:
- Bots escaneando vulnerabilidades
- Ataques de fuerza bruta automatizados
- Escaneo de botnets
- Intentos de exploits conocidos

**Impacto:** Logs más limpios, menos tráfico malicioso, menos recursos consumidos

### 3. **Defensa en profundidad**

```
Capa 1: Firewall ✓
Capa 2: Puerto no estándar ✓  ← Capa adicional
Capa 3: Autenticación fuerte ✓
Capa 4: Cifrado ✓
Capa 5: Auditoría ✓
```

Cambiar el puerto añade una capa más de protección.

### 4. **Cumplimiento y mejores prácticas**

Algunos estándares recomiendan cambiar puertos por defecto:
- **CIS Benchmark for MySQL 8.0** - Consideración en sección de red
- **NIST SP 800-123** - Hardening de servidores
- **PCI-DSS** - Cambiar configuraciones por defecto cuando sea posible
- **ISO 27001** - Configuración segura de servicios de red

---

## ⚖️ Security through Obscurity: Controversia

### ❌ Críticas válidas

**"La obscuridad NO es seguridad real"**
- No protege contra atacantes determinados
- No reemplaza autenticación fuerte
- No es una defensa primaria
- Puede dar falsa sensación de seguridad

```
MALO: "Cambié el puerto, ya no necesito firewall"
BUENO: "Cambié el puerto ADEMÁS de tener firewall, autenticación, etc."
```

### ✅ Beneficios prácticos

**"Reduce superficie de ataque automatizado"**
- Elimina 95%+ de tráfico malicioso automatizado
- Logs más limpios y útiles
- Menos consumo de recursos
- Facilita detección de ataques dirigidos

**Analogía:** Es como poner tu casa detrás de una calle sin señalización.
- No detiene a un ladrón que busca específicamente tu casa
- Pero elimina ladrones casuales que buscan cualquier casa
- Además, tienes cerraduras (autenticación), alarma (IDS), etc.

---

## 🎯 Cuándo cambiar el puerto

### ✅ Cambiar SI:
- Servidor expuesto a internet
- Alto volumen de intentos de conexión maliciosos
- Política de seguridad lo requiere
- Cumplimiento normativo
- Múltiples instancias MySQL en el mismo servidor

### ⚠️ Considerar NO cambiar SI:
- Red completamente aislada (sin acceso externo)
- Firewall bien configurado (whitelist estricta)
- Solo conexiones locales (localhost)
- Aplicaciones legacy que no permiten configurar puerto

---

## 🔧 Consideraciones técnicas

### Puertos recomendados

**Evitar:**
- 0-1023: Puertos privilegiados (requieren root)
- Puertos ya asignados: Verificar `/etc/services`
- Puertos muy conocidos: 8080, 8443, etc.

**Buenas opciones:**
```
3307: Puerto común alternativo para MySQL
3308: Siguiente opción lógica
33060: MySQL X Protocol (no confundir)
13306: Usando prefijo diferente
43306: Suficientemente diferente
```

Para este ejercicio: **3308**

### Impacto en el ecosistema

**Cambios necesarios:**
1. **Archivo de configuración MySQL:** `my.cnf`
2. **Aplicaciones:** Actualizar connection strings
3. **Firewall:** Abrir nuevo puerto, cerrar 3306
4. **Monitoreo:** Actualizar checks de salud
5. **Documentación:** Actualizar procedimientos
6. **Backups:** Scripts que usan conexión de red

**Ejemplo de connection string:**
```bash
# Antes
mysql -h db.example.com -u app_user -p

# Después
mysql -h db.example.com -P 3308 -u app_user -p
```

---

## 📊 Efectividad: Datos reales

### Estudios y observaciones

**Reducción de intentos de ataque:**
- Puerto 3306: ~5,000-10,000 intentos/día (promedio internet)
- Puerto no estándar: ~0-50 intentos/día

**Tiempo para ser descubierto:**
- Puerto 3306: Minutos después de exposición
- Puerto no estándar: Días o semanas (si es escaneado)

**Tipo de ataques bloqueados:**
- ✅ 99% de bots automatizados
- ✅ 95% de escaneo masivo
- ✅ 90% de ataques oportunistas
- ❌ 0% de ataques dirigidos (APT)

---

## 🛡️ Mejores prácticas al cambiar puerto

### 1. Cambiar puerto + otras medidas

```yaml
Configuración de seguridad completa:
  Red:
    - Puerto no estándar (3308)
    - Firewall con whitelist de IPs
    - VPN o túnel SSH cuando sea posible
  
  Autenticación:
    - Contraseñas fuertes
    - Sin usuario root remoto
    - Certificados TLS/SSL
  
  Auditoría:
    - Logs de conexiones
    - Monitoreo de intentos fallidos
    - Alertas de conexiones inusuales
```

### 2. Documentar el cambio

```
Documentación requerida:
  - Puerto utilizado: 3308
  - Fecha del cambio: 2025-12-09
  - Aplicaciones afectadas: [lista]
  - Procedimientos de conexión actualizados
  - Contacto para soporte
```

### 3. Comunicar a los usuarios

Avisar antes del cambio:
- Desarrolladores
- DBAs
- Operaciones
- Herramientas de monitoreo
- Scripts automatizados

### 4. Mantener consistencia

Si tienes múltiples servidores:
- Usar el mismo puerto no estándar en todos
- O documentar claramente las diferencias
- Mantener inventario actualizado

---

## 🔄 Relación con otros controles de seguridad

Este control se complementa con:

### 1. **Bind-address** (Punto 4)
```
Puerto 3308 + bind-address=127.0.0.1
→ Puerto no estándar Y solo conexiones locales
→ Protección doble
```

### 2. **Firewall**
```
iptables -A INPUT -p tcp --dport 3308 -s IP_PERMITIDA -j ACCEPT
iptables -A INPUT -p tcp --dport 3308 -j DROP
→ Solo IPs autorizadas pueden intentar conectar
```

### 3. **TLS/SSL**
```
Puerto 3308 + require_secure_transport=ON
→ Incluso si encuentran el puerto, deben tener certificados
```

### 4. **VPN/SSH Tunnel**
```
Cliente → VPN → Red interna → MySQL:3308
→ Mejor opción para acceso remoto
```

---

## ⚠️ Limitaciones y advertencias

### 1. **NO es una solución completa**
Cambiar el puerto NO reemplaza:
- Autenticación fuerte
- Cifrado de conexiones
- Políticas de acceso
- Actualizaciones de seguridad

### 2. **Escaneo completo de puertos**
Un atacante determinado puede escanear todos los puertos:
```bash
nmap -p 1-65535 target.com
# Encontrará tu puerto 3308 eventualmente
```

### 3. **Falsa sensación de seguridad**
```
MAL: "Ya no necesito firewall, cambié el puerto"
BIEN: "Cambié el puerto como parte de defensa en profundidad"
```

### 4. **Mantenimiento adicional**
- Documentación debe mantenerse
- Scripts deben actualizarse
- Nuevos desarrolladores deben informarse

---

## 📚 Referencias

- **CIS MySQL 8.0 Benchmark** - Network Configuration
- **NIST SP 800-123** - Guide to General Server Security
- **OWASP Database Security** - Network Hardening
- **MySQL 8.0 Reference Manual** - Server Configuration

---

## ✅ Checklist de verificación

- [ ] Modificar `my.cnf` con nuevo puerto
- [ ] Actualizar `docker-compose.yml` (mapeo de puertos)
- [ ] Reiniciar servicio MySQL
- [ ] Verificar que puerto 3308 está escuchando
- [ ] Probar conexión en nuevo puerto
- [ ] Verificar que puerto 3306 ya no escucha
- [ ] Actualizar connection strings de aplicaciones
- [ ] Actualizar documentación
- [ ] Comunicar cambio al equipo
- [ ] Actualizar firewall (si aplica)

---

## 🚀 Próximo paso

Una vez cambiado el puerto, proceder al **Punto 4: Configurar bind-address para IPs específicas**.
