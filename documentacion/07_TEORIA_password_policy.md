# PUNTO 7: Política de Contraseñas con validate_password

## 📋 Parte Teórica

### ¿Qué es validate_password?

**validate_password** es un plugin de MySQL que valida la fortaleza de las contraseñas y aplica políticas de complejidad.

```sql
-- Verificar si está instalado
SELECT PLUGIN_NAME, PLUGIN_STATUS 
FROM INFORMATION_SCHEMA.PLUGINS 
WHERE PLUGIN_NAME LIKE 'validate%';
```

---

## 🔐 ¿Por qué es crítico para seguridad?

### 1. **Previene contraseñas débiles**

```
SIN validate_password:
  - Password: "123456" ✓ Aceptado ❌
  - Password: "password" ✓ Aceptado ❌
  - Password: "admin" ✓ Aceptado ❌

CON validate_password:
  - Password: "123456" ❌ Rechazado ✓
  - Password: "password" ❌ Rechazado ✓
  - Password: "MyP@ssw0rd2024!" ✓ Aceptado ✓
```

### 2. **Las 10 contraseñas más usadas (2023)**

```
1. 123456
2. password
3. 123456789
4. 12345678
5. 12345
6. qwerty
7. 111111
8. abc123
9. password1
10. admin

Tiempo para hackear: < 1 segundo
```

**validate_password rechaza todas estas.**

### 3. **Estadísticas de ataques**

```
- 81% de brechas de datos involucran contraseñas débiles
- 65% de personas reutilizan contraseñas
- 30% de usuarios usan contraseñas obvias
- $4.24M costo promedio de una brecha de datos (IBM, 2023)
```

### 4. **Cumplimiento normativo**

Estándares que REQUIEREN políticas de contraseñas:

- **NIST SP 800-63B** - Longitud mínima 8 caracteres
- **PCI-DSS 8.3.6** - Mínimo 7 caracteres, alfanumérico
- **ISO 27001** - Control A.9.4.3 (Password management)
- **HIPAA** - Password requirements
- **GDPR** - Medidas técnicas apropiadas
- **SOC 2** - Authentication controls

---

## 🎯 Componentes del plugin validate_password

### En MySQL 8.0+:

```
Componente: validate_password
    (Antes era: validate_password plugin en MySQL 5.7)
```

### Políticas disponibles:

| Nivel | Nombre | Requisitos |
|-------|--------|-----------|
| 0 | **LOW** | Solo longitud mínima |
| 1 | **MEDIUM** | Longitud + números + mayúsculas + minúsculas + especiales |
| 2 | **STRONG** | MEDIUM + diccionario de palabras comunes |

---

## 📊 Parámetros configurables

### Parámetros principales:

```sql
-- Política (LOW=0, MEDIUM=1, STRONG=2)
validate_password.policy = 1

-- Longitud mínima
validate_password.length = 8

-- Números mínimos requeridos
validate_password.number_count = 1

-- Caracteres especiales mínimos
validate_password.special_char_count = 1

-- Mayúsculas mínimas
validate_password.mixed_case_count = 1

-- Archivo de diccionario (para STRONG)
validate_password.dictionary_file = '/ruta/diccionario.txt'
```

### Valores recomendados de seguridad:

```sql
-- CONFIGURACIÓN RECOMENDADA:
validate_password.policy = STRONG (2)
validate_password.length = 12
validate_password.number_count = 1
validate_password.special_char_count = 1
validate_password.mixed_case_count = 1
```

### Valores mínimos aceptables:

```sql
-- CONFIGURACIÓN MÍNIMA:
validate_password.policy = MEDIUM (1)
validate_password.length = 8
validate_password.number_count = 1
validate_password.special_char_count = 1
validate_password.mixed_case_count = 1
```

---

## 🔧 Instalación y configuración

### Paso 1: Instalar el componente

```sql
-- MySQL 8.0+
INSTALL COMPONENT 'file://component_validate_password';
```

### Paso 2: Verificar instalación

```sql
SELECT * FROM mysql.component;
```

### Paso 3: Configurar política

```sql
-- Establecer política STRONG
SET GLOBAL validate_password.policy = 2;

-- Configurar requisitos
SET GLOBAL validate_password.length = 12;
SET GLOBAL validate_password.number_count = 1;
SET GLOBAL validate_password.special_char_count = 1;
SET GLOBAL validate_password.mixed_case_count = 1;
```

### Paso 4: Hacer configuración persistente (my.cnf)

```ini
[mysqld]
validate-password=FORCE_PLUS_PERMANENT
validate_password.policy=STRONG
validate_password.length=12
validate_password.number_count=1
validate_password.special_char_count=1
validate_password.mixed_case_count=1
```

---

## 🧪 Testing de la política

### Test 1: Contraseña débil

```sql
CREATE USER 'test'@'localhost' IDENTIFIED BY '123456';
-- ERROR 1819: Your password does not satisfy the current policy requirements
```

### Test 2: Contraseña sin números

```sql
CREATE USER 'test'@'localhost' IDENTIFIED BY 'Password!';
-- ERROR 1819: Your password does not satisfy the current policy requirements
```

### Test 3: Contraseña válida

```sql
CREATE USER 'test'@'localhost' IDENTIFIED BY 'MyP@ssw0rd2024';
-- Query OK, 0 rows affected
```

---

## 🎯 Ejemplos de contraseñas

### ❌ Contraseñas RECHAZADAS (con policy=MEDIUM, length=8):

```
123456          - Solo números, muy corta
password        - Diccionario, sin complejidad
admin123        - Predecible, sin especiales
Password1       - Sin caracteres especiales
P@ssword        - Sin números
12345678        - Solo números
qwerty123       - Patrón de teclado
```

### ✅ Contraseñas ACEPTADAS:

```
MyP@ssw0rd2024!   - 15 chars, todos los tipos
Secure#Pass123    - 14 chars, compleja
D@taBase2024!     - 13 chars, mezclada
Admin$tr0ng2024   - 15 chars, fuerte
```

---

## 🛡️ Mejores prácticas de contraseñas

### 1. Longitud vs Complejidad

```
Contraseña corta compleja: P@ss1
  - 5 caracteres
  - Tiempo para hackear: Segundos

Contraseña larga simple: correcthorsebatterystaple
  - 28 caracteres
  - Tiempo para hackear: Siglos

CONCLUSIÓN: Longitud > Complejidad
RECOMENDACIÓN: Ambas (longitud + complejidad)
```

### 2. Passphrases

```
En lugar de: MyP@ss123
Mejor: Correct-Horse-Battery-Staple-2024!

Ventajas:
- Fácil de recordar
- Larga (37 caracteres)
- Incluye complejidad
```

### 3. Gestores de contraseñas

```
Generar contraseñas como:
- K9$mZ#Lp2@vN5qR8
- wX4!nY7&pQ2#sT9
- aB3$cD6&eF9!gH2

Ventajas:
- Máxima seguridad
- Única por servicio
- No necesitas recordarla
```

---

## 📊 Niveles de política explicados

### LOW (0)

```sql
validate_password.policy = 0

Requisitos:
  - Solo longitud mínima

Ejemplo aceptado:
  - "12345678" ✓ (si length=8)

Uso: NO RECOMENDADO para producción
```

### MEDIUM (1) - RECOMENDADO MÍNIMO

```sql
validate_password.policy = 1

Requisitos:
  - Longitud mínima
  - Al menos 1 número
  - Al menos 1 mayúscula
  - Al menos 1 minúscula  
  - Al menos 1 carácter especial

Ejemplo aceptado:
  - "MyPass123!" ✓

Uso: Mínimo aceptable para producción
```

### STRONG (2) - MÁXIMA SEGURIDAD

```sql
validate_password.policy = 2

Requisitos:
  - Todo lo de MEDIUM +
  - No puede contener palabras del diccionario
  - No puede ser substring del nombre de usuario

Ejemplo rechazado:
  - "Password123!" ❌ (palabra común)
  - "admin_Pass1!" ❌ (contiene "admin")

Uso: Recomendado para datos sensibles
```

---

## ⚠️ Consideraciones importantes

### 1. Usuarios existentes

```
validate_password NO valida contraseñas existentes
Solo valida al crear/cambiar contraseñas

Para forzar cambio:
ALTER USER 'usuario'@'host' PASSWORD EXPIRE;
```

### 2. Usuario root

```
root@localhost puede tener política diferente
Considerar política más estricta para root
```

### 3. Cuentas de servicio

```
Para aplicaciones:
- Usar contraseñas generadas automáticamente
- Rotación periódica
- Almacenamiento seguro (vaults)
```

### 4. Balance usabilidad vs seguridad

```
Muy estricto:
  - Usuarios frustrados
  - Escriben contraseñas en post-its
  - Llaman a helpdesk constantemente

Muy permisivo:
  - Contraseñas débiles
  - Cuentas comprometidas
  - Brechas de seguridad

BALANCE: MEDIUM + educación de usuarios
```

---

## 🔄 Rotación de contraseñas

### Configurar expiración:

```sql
-- Expirar contraseñas cada 90 días
SET GLOBAL default_password_lifetime = 90;

-- Por usuario específico
ALTER USER 'usuario'@'host' PASSWORD EXPIRE INTERVAL 90 DAY;

-- Nunca expira (no recomendado)
ALTER USER 'usuario'@'host' PASSWORD EXPIRE NEVER;
```

---

## 📚 Relación con otros controles

```
Capa 1: Firewall (limitar acceso de red)
Capa 2: bind-address (interfaces específicas)
Capa 3: No root remoto (eliminar superusuario remoto)
Capa 4: Contraseñas fuertes (validate_password) ← Esta capa
Capa 5: Cifrado TLS/SSL
Capa 6: Auditoría de intentos fallidos
Capa 7: MFA (Multi-Factor Authentication)
```

---

## 🎓 Educación de usuarios

### Mensajes para usuarios:

```
"Tu contraseña debe contener:
  - Mínimo 12 caracteres
  - Al menos 1 mayúscula
  - Al menos 1 minúscula
  - Al menos 1 número
  - Al menos 1 carácter especial (!@#$%^&*)
  - No puede ser una palabra común"

Ejemplos válidos:
  - MySecurePass2024!
  - Admin$tr0ng#Key
  - DataBase&2024Pwd
```

---

## 🔍 Verificación y monitoreo

### Verificar configuración:

```sql
SHOW VARIABLES LIKE 'validate_password%';
```

### Verificar usuarios con contraseñas expiradas:

```sql
SELECT User, Host, password_expired 
FROM mysql.user 
WHERE password_expired = 'Y';
```

### Log de intentos de contraseñas débiles:

```sql
-- Revisar error log de MySQL
-- Buscar: "password does not satisfy"
```

---

## ✅ Checklist de verificación

- [ ] Instalar validate_password component
- [ ] Configurar política MEDIUM o STRONG
- [ ] Establecer longitud mínima 12+
- [ ] Configurar requisitos de complejidad
- [ ] Hacer configuración persistente (my.cnf)
- [ ] Verificar con tests
- [ ] Educar a usuarios
- [ ] Documentar política
- [ ] Configurar rotación de contraseñas
- [ ] Monitorear cumplimiento

---

## 📚 Referencias

- **NIST SP 800-63B** - Digital Identity Guidelines
- **PCI-DSS v4.0** - Requirement 8.3.6
- **CIS MySQL 8.0 Benchmark** - Password Policies
- **OWASP Authentication Cheat Sheet**
- **MySQL 8.0 Reference Manual** - validate_password Component

---

## 🎯 Política recomendada final

```ini
[mysqld]
# Instalar componente al inicio
validate-password=FORCE_PLUS_PERMANENT

# Política STRONG para máxima seguridad
validate_password.policy=STRONG

# Longitud mínima 12 caracteres (NIST recomienda 8+)
validate_password.length=12

# Requisitos de complejidad
validate_password.number_count=1
validate_password.special_char_count=1
validate_password.mixed_case_count=1

# Rotación cada 90 días
default_password_lifetime=90
```

---

## 🏁 Conclusión

Las contraseñas son la primera línea de defensa. validate_password asegura que esta línea sea fuerte.

**"Una cadena es tan fuerte como su eslabón más débil, y ese eslabón suele ser la contraseña."**
