# PUNTO 4: Configurar bind-address para IPs Específicas

## 📋 Parte Teórica

### ¿Qué es bind-address?

El parámetro **bind-address** en MySQL determina en qué interfaz de red escucha el servidor para conexiones entrantes.

```
bind-address: Dirección IP específica en la que MySQL escuchará
Puerto: Definido por 'port' (ahora 3308)
Combinación: MySQL escucha en bind-address:port
```

### Valores comunes de bind-address

```
0.0.0.0      → Escucha en TODAS las interfaces de red
127.0.0.1    → Solo interfaz localhost (loopback)
192.168.1.10 → Solo en esa IP específica
::           → Todas las interfaces IPv6
::1          → Localhost IPv6
```

---

## 🔐 ¿Por qué 0.0.0.0 es inseguro?

### Significado de 0.0.0.0

**0.0.0.0** es una dirección especial que significa "todas las interfaces":

```
Interfaces típicas en un servidor:
├── lo (loopback): 127.0.0.1
├── eth0: 192.168.1.100 (red interna)
├── eth1: 10.0.0.50 (otra red)
└── wlan0: 172.16.0.10 (wifi)

bind-address=0.0.0.0
→ MySQL escucha en TODAS estas interfaces
→ Accesible desde cualquier red conectada
```

### Riesgos de seguridad

#### 1. **Exposición innecesaria**

```
Escenario: Servidor con bind-address=0.0.0.0

Red Internet (eth0: IP pública)
  ↓
  ├→ Acceso permitido ❌ (PELIGRO)
  
Red Corporativa (eth1: IP privada)  
  ↓
  ├→ Acceso permitido ✓ (necesario)
  
Red WiFi Guest (wlan0)
  ↓
  ├→ Acceso permitido ❌ (PELIGRO)
```

**Problema:** MySQL accesible desde redes no confiables

#### 2. **Violación del principio de mínimo privilegio**

```
Necesidad real: Solo la aplicación local necesita acceso
Configuración actual: Todo el mundo puede intentar conectarse
```

#### 3. **Superficie de ataque ampliada**

```
Atacante desde internet:
  1. Escanea puerto 3308 → Lo encuentra
  2. Intenta conectarse → bind-address=0.0.0.0 lo permite
  3. Ataque de fuerza bruta → Sin limitación de red
  4. Exploit de vulnerabilidad → Puede intentarlo
```

#### 4. **Compliance y auditoría**

Estándares que requieren limitar bind-address:
- **CIS Benchmark for MySQL 8.0** - Section 3.1
- **PCI-DSS** - Requirement 1.3 (limitar tráfico entre zonas)
- **ISO 27001** - Control A.13.1.3 (segregación de redes)
- **NIST SP 800-53** - SC-7 (Boundary Protection)
- **SOC 2** - Network segmentation controls

---

## 🎯 Configuraciones recomendadas

### 1. Solo localhost (127.0.0.1) - MÁS SEGURO

**Cuándo usar:**
- Aplicación y BD en el mismo servidor
- Sin necesidad de acceso remoto directo
- Usar túneles SSH para admin remoto

```ini
bind-address=127.0.0.1
```

**Arquitectura típica:**
```
Mismo servidor:
├── Aplicación web (conecta via 127.0.0.1:3308)
├── MySQL (escucha solo en 127.0.0.1)
└── Admin remoto → SSH tunnel → 127.0.0.1:3308
```

**Ventajas:**
- ✅ Máxima seguridad
- ✅ Zero exposición a red externa
- ✅ Conexiones solo desde mismo host
- ✅ Fuerza uso de SSH tunnels para remote

**Limitaciones:**
- ❌ No permite conexiones desde otros servidores
- ❌ Requiere SSH tunnel para admin remoto
- ❌ No funciona en clusters distribuidos

### 2. IP privada específica - SEGURO

**Cuándo usar:**
- Aplicación en servidor diferente
- Red privada segura
- Firewall bien configurado

```ini
bind-address=192.168.1.100
```

**Arquitectura típica:**
```
Red Privada 192.168.1.0/24:
├── App Server (192.168.1.50) → conecta → MySQL
├── MySQL Server (192.168.1.100) → escucha solo aquí
└── Internet → Firewall → ❌ No puede llegar
```

**Ventajas:**
- ✅ Permite conexiones de red interna
- ✅ No expone a internet
- ✅ Soporta arquitecturas distribuidas
- ✅ Balance entre seguridad y funcionalidad

**Consideración:**
- Requiere firewall adicional para limitar a IPs específicas

### 3. Múltiples IPs - CASO ESPECIAL

MySQL 8.0+ permite múltiples bind-address:

```ini
bind-address=127.0.0.1,192.168.1.100
```

---

## 🚫 Configuración insegura: 0.0.0.0

```ini
bind-address=0.0.0.0  ← INSEGURO
```

**Problemas:**
- 🔴 Escucha en TODAS las interfaces
- 🔴 Accesible desde cualquier red
- 🔴 Ignora segmentación de red
- 🔴 Máxima superficie de ataque
- 🔴 Viola principio de mínimo privilegio

**Única justificación válida:**
- Entorno de desarrollo aislado
- Contenedor en red privada
- Prototipado rápido (NUNCA en producción)

---

## 🔒 Nuestra configuración: 127.0.0.1

Para este ejercicio de hardening, configuraremos:

```ini
bind-address=127.0.0.1
```

**Razón:**
- Máxima seguridad para ejercicio educativo
- Simula aplicación monolítica (app + DB en mismo host)
- Fuerza buenas prácticas (SSH tunnel para admin)
- Cumple con todos los estándares de seguridad

**Impacto:**
- ✅ MySQL solo acepta conexiones de localhost
- ❌ DataGrip local seguirá funcionando (localhost)
- ✅ Elimina posibilidad de acceso remoto no autorizado
- ⚠️ Admin remoto requeriría SSH tunnel

---

## 🔧 Cómo funciona bind-address

### A nivel de red

```
1. MySQL inicia y se "bindea" a la interfaz especificada
2. Crea un socket escuchando en bind-address:port
3. Solo acepta conexiones que lleguen a esa interfaz

Ejemplo: bind-address=127.0.0.1, port=3308

Socket creado: 127.0.0.1:3308
Acepta conexiones:
  - localhost:3308 ✅
  - 127.0.0.1:3308 ✅
  
Rechaza conexiones:
  - 192.168.1.100:3308 ❌ (otra interfaz)
  - 0.0.0.0:3308 ❌ (dirección comodín)
```

### Verificación con netstat

```bash
# Ver qué interfaces escucha MySQL
netstat -tuln | grep 3308

# Con bind-address=0.0.0.0
tcp  0.0.0.0:3308  *.*  LISTEN  ← TODAS las interfaces

# Con bind-address=127.0.0.1
tcp  127.0.0.1:3308  *.*  LISTEN  ← Solo localhost
```

---

## 🔄 Relación con otros controles de seguridad

### 1. Complementa cambio de puerto (Punto 3)

```
Puerto 3308 + bind-address=127.0.0.1
= Puerto no estándar Y solo accesible localmente
= Doble protección
```

### 2. Requiere firewall en producción

```
Configuración ideal:

MySQL:
  bind-address: 192.168.1.100 (IP específica)
  port: 3308

Firewall:
  iptables -A INPUT -p tcp -s 192.168.1.50 --dport 3308 -j ACCEPT
  iptables -A INPUT -p tcp --dport 3308 -j DROP
```

### 3. Habilita acceso remoto seguro con SSH

```bash
# Admin remoto seguro con tunnel SSH
ssh -L 3308:localhost:3308 usuario@servidor-mysql

# Luego conectar localmente
mysql -h 127.0.0.1 -P 3308 -u root -p
```

### 4. Soporta arquitecturas de microservicios

```
Microservicio en contenedor:
  - bind-address: IP del contenedor en red Docker
  - Firewall: Solo otros contenedores autorizados
  - Zero trust: Autenticación + cifrado + segmentación
```

---

## 📊 Comparativa de configuraciones

| Configuración | Seguridad | Flexibilidad | Uso recomendado |
|---------------|-----------|--------------|-----------------|
| **127.0.0.1** | ⭐⭐⭐⭐⭐ | ⭐ | App monolítica |
| **IP privada** | ⭐⭐⭐⭐ | ⭐⭐⭐ | Arquitectura distribuida |
| **0.0.0.0** | ⭐ | ⭐⭐⭐⭐⭐ | Dev/testing SOLO |

---

## 🛡️ Defensa en profundidad

```
Capa 1: Network Firewall (iptables/AWS Security Groups)
Capa 2: bind-address (MySQL nivel de aplicación)  ← Esta capa
Capa 3: Autenticación (usuarios/passwords)
Capa 4: Autorización (privilegios granulares)
Capa 5: Cifrado (TLS/SSL)
Capa 6: Auditoría (logs de accesos)
```

**Bind-address es capa 2:** Incluso si firewall falla, bind-address restringe

---

## ⚠️ Errores comunes

### 1. Confundir con firewall

```
ERROR: "Ya tengo firewall, no necesito bind-address"
CORRECTO: Son capas diferentes, ambos necesarios
```

### 2. Olvidar actualizar aplicaciones

```
ERROR: Cambiar bind-address sin actualizar connection strings
RESULTADO: Aplicaciones no pueden conectar
SOLUCIÓN: Planificar y comunicar cambios
```

### 3. Problemas con Docker/contenedores

```
ERROR: bind-address=127.0.0.1 en contenedor
PROBLEMA: Otros contenedores no pueden conectar
SOLUCIÓN: Usar IP del contenedor en red Docker
```

### 4. IPv4 vs IPv6

```
bind-address=127.0.0.1  → Solo IPv4
bind-address=::1         → Solo IPv6
bind-address=::          → Todas IPv6
```

---

## 🧪 Testing y verificación

### 1. Verificar configuración interna

```sql
SHOW VARIABLES LIKE 'bind_address';
```

### 2. Verificar a nivel de red

```bash
# Ver socket escuchando
netstat -tuln | grep 3308
lsof -i :3308

# Intentar conectar desde remoto (debe fallar si 127.0.0.1)
mysql -h IP_PUBLICA -P 3308 -u root -p
# ERROR: Can't connect to MySQL server
```

### 3. Verificar desde localhost (debe funcionar)

```bash
mysql -h 127.0.0.1 -P 3308 -u root -p
# SUCCESS
```

---

## 📚 Referencias

- **CIS MySQL 8.0 Benchmark v1.2.0** - Section 3.1: Ensure 'bind_address' is configured
- **PCI-DSS v4.0** - Requirement 1.3: Limit connections between untrusted networks
- **ISO 27001:2013** - A.13.1.3: Segregation in networks
- **NIST SP 800-53** - SC-7: Boundary Protection
- **MySQL 8.0 Reference Manual** - Server System Variables

---

## ✅ Checklist de verificación

- [ ] Modificar `my.cnf` con nuevo bind-address
- [ ] Reiniciar servicio MySQL
- [ ] Verificar bind-address con SHOW VARIABLES
- [ ] Verificar socket con netstat
- [ ] Probar conexión desde localhost (debe funcionar)
- [ ] Probar conexión desde otra IP (debe fallar si 127.0.0.1)
- [ ] Actualizar aplicaciones si es necesario
- [ ] Documentar cambio
- [ ] Comunicar a equipo

---

## 🚀 Próximo paso

Una vez configurado bind-address seguro, proceder al **Punto 5: Deshabilitar acceso remoto del usuario root**.
