# 🔄 Guía para Resetear MySQL y Re-ejecutar Ejercicios

Esta guía te ayuda a restaurar MySQL a su estado inicial para volver a practicar los ejercicios de hardening.

---

## 🎯 Método 1: Script Automático (RECOMENDADO)

### Paso 1: Ejecutar el script de reset

```bash
./reset_mysql.sh
```

El script te preguntará si estás seguro antes de proceder.

### ¿Qué hace el script?

1. ✅ Detiene el contenedor MySQL
2. ✅ Elimina el volumen de datos (borra toda la data)
3. ✅ Hace backup de `my.cnf` actual → `my.cnf.hardened`
4. ✅ Restaura `my.cnf` al estado inicial
5. ✅ Inicia MySQL con configuración insegura
6. ✅ Verifica que MySQL está listo

### Resultado

MySQL estará en estado **INSEGURO** inicial:
- Puerto: `3306` (por defecto)
- Usuarios: `root@%` y `root@localhost` 
- Base de datos: `testdb` presente
- sql_mode: `TRADITIONAL` (básico)
- Sin política de contraseñas estricta

---

## 🛠️ Método 2: Manual (Paso a Paso)

### Paso 1: Detener y limpiar

```bash
# Detener contenedor
docker-compose down

# Eliminar volumen (¡ESTO BORRA TODOS LOS DATOS!)
docker volume rm mysql-hardening_mysql-data
```

### Paso 2: Restaurar configuración inicial

```bash
# Hacer backup de configuración hardened
cp my.cnf my.cnf.hardened

# Restaurar configuración inicial
cp my.cnf.initial my.cnf
```

O crear manualmente `my.cnf` con:

```ini
[mysqld]
# Configuración INICIAL - Sin hardening
port=3306
bind-address=0.0.0.0
sql_mode=TRADITIONAL
```

### Paso 3: Reiniciar MySQL

```bash
# Iniciar contenedor
docker-compose up -d

# Esperar 10 segundos
sleep 10

# Verificar que está listo
docker exec mysql-hardening mysql -uroot -pRootPass123! -e "SELECT 'OK' AS Status;"
```

---

## 📋 Verificar Estado Inicial

Después del reset, ejecuta:

```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < check_before_hardening.sql > estado_inicial_nuevo.txt
```

Deberías ver:
- ✅ Usuarios anónimos: `''@localhost` presente
- ✅ Base de datos `testdb` presente
- ✅ Puerto `3306` activo
- ✅ bind_address `0.0.0.0`
- ✅ Usuario `root@%` presente (acceso remoto)
- ✅ sql_mode `TRADITIONAL`

---

## 🔁 Re-ejecutar Ejercicios de Hardening

Una vez reseteado, puedes ejecutar los ejercicios en orden:

### 1. Eliminar usuarios anónimos
```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < hardening_scripts/01_eliminar_usuarios_anonimos.sql
```

### 2. Eliminar base de datos de prueba
```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < hardening_scripts/02_eliminar_base_test.sql
```

### 3. Verificar puerto (requiere cambio en my.cnf y restart)
```bash
# Editar my.cnf y cambiar port=3306 a port=3308
docker-compose restart
docker exec -i mysql-hardening mysql -uroot -pRootPass123! -P3308 < hardening_scripts/03_verificar_puerto.sql
```

### 4. Verificar bind_address
```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < hardening_scripts/04_verificar_bind_address.sql
```

### 5. Eliminar root remoto
```bash
# Primero crear usuario admin
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < hardening_scripts/crear_usuario_admin.sql
# Luego eliminar root@%
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < hardening_scripts/05_eliminar_root_remoto.sql
```

### 6. Configurar sql_mode (requiere cambio en my.cnf y restart)
```bash
# Editar my.cnf y agregar línea sql_mode=...
docker-compose restart
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < hardening_scripts/06_sql_mode.sql
```

### 7. Política de contraseñas (requiere cambio en my.cnf y restart)
```bash
# Editar my.cnf y agregar configuración validate_password
docker-compose restart
docker exec -i mysql-hardening mysql -uroot -pRootPass123! < hardening_scripts/07_password_policy.sql
```

---

## 🔒 Restaurar Estado Hardened

Si quieres volver al estado hardened después del reset:

```bash
# Restaurar configuración hardened
cp my.cnf.hardened my.cnf

# Reiniciar MySQL
docker-compose restart
```

---

## ⚠️ ADVERTENCIAS

### ¡ESTO BORRA TODOS LOS DATOS!

El reset:
- ❌ Elimina TODOS los datos del MySQL
- ❌ Elimina TODAS las bases de datos (excepto las del sistema)
- ❌ Elimina TODOS los usuarios creados (excepto root)
- ❌ Elimina TODA la configuración de seguridad

### Solo usar en entornos de práctica

Este script está diseñado para:
- ✅ Entornos de desarrollo local
- ✅ Contenedores Docker de práctica
- ✅ Ejercicios académicos

**NUNCA** ejecutar en:
- ❌ Producción
- ❌ Servidores con datos reales
- ❌ Bases de datos con información importante

---

## 📚 Archivos Relacionados

- `reset_mysql.sh` - Script automático de reset
- `my.cnf.initial` - Configuración inicial (insegura)
- `my.cnf.hardened` - Configuración hardened (creada por el script)
- `check_before_hardening.sql` - Script de verificación inicial
- `docker-compose.yml` - Configuración de Docker

---

## 🆘 Troubleshooting

### El script falla al eliminar el volumen

```bash
# Forzar eliminación
docker volume rm mysql-hardening_mysql-data -f
```

### MySQL no inicia después del reset

```bash
# Ver logs
docker-compose logs mysql

# Reintentar
docker-compose down
docker-compose up -d
```

### Puerto 3306 ya está en uso

Otro MySQL puede estar corriendo en tu máquina:

```bash
# Ver qué está usando el puerto
lsof -i :3306

# Detener MySQL del sistema (macOS)
brew services stop mysql
```

### No puedo conectarme después del reset

Verifica:
1. ¿MySQL está corriendo? `docker ps`
2. ¿Puerto correcto? Después del reset es `3306`
3. ¿Contraseña correcta? `RootPass123!`

```bash
# Intentar conectar
docker exec -it mysql-hardening mysql -uroot -pRootPass123!
```

---

## 💡 Tips

- Haz commit de tus cambios antes de resetear
- Guarda tus evidencias en archivos separados
- Usa `my.cnf.hardened` para comparar configuraciones
- Puedes hacer reset múltiples veces sin problema

---

**Última actualización:** 2025-12-09  
**Versión:** 1.0
