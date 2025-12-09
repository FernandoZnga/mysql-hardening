# Estado de Seguridad ANTES del Hardening

Fecha: 2025-12-09
Versión: MySQL 8.0 Community

---

## Resumen de Vulnerabilidades Identificadas

### 🔴 CRÍTICO: 5 vulnerabilidades encontradas

| # | Vulnerabilidad | Estado Actual | Riesgo |
|---|----------------|---------------|--------|
| 1 | **Usuarios anónimos** | ✅ NO PRESENTES | Bajo |
| 2 | **Base de datos 'test'** | ⚠️ EXISTE ('testdb') | Medio |
| 3 | **Puerto por defecto** | 🔴 3306 (ESTÁNDAR) | Alto |
| 4 | **Bind address abierto** | 🔴 0.0.0.0 (TODAS LAS IPs) | Crítico |
| 5 | **Root remoto activo** | 🔴 root@% HABILITADO | Crítico |
| 6 | **SQL Mode inseguro** | ⚠️ MODO TRADICIONAL | Medio |
| 7 | **Sin política de contraseñas** | 🔴 validate_password NO INSTALADO | Alto |

---

## Detalle de Hallazgos

### 1. Usuarios Anónimos
```
✅ Estado: NO HAY USUARIOS ANÓNIMOS
- No se encontraron usuarios con User = ''
- Este punto ya está seguro
```

### 2. Base de Datos de Prueba
```
⚠️ Estado: EXISTE BASE 'testdb'
- Se encontró una base de datos que coincide con 'test%'
- Aunque no es la base 'test' por defecto, podría ser confundida
- Acción: Eliminar o renombrar
```

### 3. Puerto de Escucha
```
🔴 Estado: PUERTO POR DEFECTO (3306)
Variable: port = 3306
- Facilita ataques automatizados
- Los escáneres de red buscan este puerto primero
- Acción: Cambiar a puerto no estándar (ej: 3308)
```

### 4. Bind Address
```
🔴 Estado: ABIERTO A TODAS LAS IPs
Variable: bind_address = 0.0.0.0
- Acepta conexiones desde cualquier dirección IP
- Expone el servidor a ataques remotos
- Acción: Limitar a IPs específicas o localhost
```

### 5. Acceso Remoto de Root
```
🔴 Estado: ROOT PUEDE CONECTARSE REMOTAMENTE
Usuarios root encontrados:
  - root@%        (PELIGROSO - desde cualquier host)
  - root@localhost (CORRECTO - solo local)

- El comodín '%' permite conexiones desde CUALQUIER IP
- Violación grave de seguridad
- Acción: Eliminar root@% y dejar solo root@localhost
```

### 6. SQL Mode
```
⚠️ Estado: MODO TRADICIONAL (MEJORABLE)
Actual: STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,
        NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,
        NO_ENGINE_SUBSTITUTION

Faltantes recomendados:
  - NO_AUTO_CREATE_USER (previene creación accidental de usuarios)
  - Otros modos de seguridad adicionales

- Acción: Agregar modos de seguridad adicionales
```

### 7. Política de Contraseñas
```
🔴 Estado: SIN PLUGIN DE VALIDACIÓN
- El plugin 'validate_password' NO está instalado
- No hay requisitos mínimos de complejidad
- Permite contraseñas débiles
- Acción: Instalar y configurar validate_password
```

---

## Usuarios Actuales del Sistema

| Usuario | Host | Plugin | Vencido | Bloqueado |
|---------|------|--------|---------|-----------|
| mysql.infoschema | localhost | caching_sha2_password | N | Y |
| mysql.session | localhost | caching_sha2_password | N | Y |
| mysql.sys | localhost | caching_sha2_password | N | Y |
| **root** | **%** | caching_sha2_password | N | **N** |
| root | localhost | caching_sha2_password | N | N |

---

## Recomendaciones Prioritarias

1. **URGENTE**: Eliminar acceso remoto de root (root@%)
2. **URGENTE**: Configurar bind-address a IPs específicas
3. **ALTO**: Cambiar puerto por defecto
4. **ALTO**: Instalar validate_password plugin
5. **MEDIO**: Reforzar sql_mode con opciones adicionales
6. **MEDIO**: Revisar base de datos 'testdb'

---

## Próximos Pasos

Ahora procederemos a aplicar el hardening punto por punto, documentando cada cambio y verificando su efectividad.

**Comando para iniciar el primer punto:**
```bash
# Conectarse a MySQL
docker exec -it mysql-hardening mysql -uroot -pRootPass123!
```
