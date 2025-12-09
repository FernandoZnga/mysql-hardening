# PUNTO 1: Deshabilitar Usuarios Anónimos

## 📋 Parte Teórica

### ¿Qué son los usuarios anónimos?

Los **usuarios anónimos** en MySQL son cuentas que permiten conexiones sin proporcionar un nombre de usuario válido. Se identifican porque su campo `User` en la tabla `mysql.user` está vacío (`User = ''`).

```sql
-- Ejemplo de usuario anónimo
User: ''
Host: 'localhost'
```

### ¿Por qué existen?

En versiones antiguas de MySQL (anteriores a 5.7), el instalador creaba automáticamente usuarios anónimos con los siguientes propósitos:

1. **Facilitar pruebas iniciales**: Permitir conexiones sin configurar usuarios
2. **Compatibilidad histórica**: Mantener comportamiento de versiones antiguas
3. **Conveniencia en desarrollo**: Acceso rápido durante el setup inicial

**Ejemplo de conexión anónima:**
```bash
# Sin especificar usuario, se usa el usuario anónimo
mysql -h localhost
```

---

## 🔐 ¿Por qué es un riesgo de seguridad?

### 1. **Acceso no autorizado**
- Cualquier persona con acceso de red puede conectarse sin credenciales
- No hay trazabilidad de quién accedió al sistema
- Viola el principio de "identificación única de usuarios"

### 2. **Escalación de privilegios**
- Los usuarios anónimos pueden tener privilegios sobre bases de datos específicas
- Pueden ser usados como punto de entrada para explotar otras vulnerabilidades
- Dificultan la auditoría de accesos

### 3. **Cumplimiento normativo**
Estándares que requieren eliminar usuarios anónimos:
- **CIS Benchmark for MySQL 8.0** - Sección 1.2
- **PCI-DSS** - Requisito 8.2 (identificación única de usuarios)
- **ISO 27001** - Control A.9.2.1 (registro de usuarios)
- **NIST SP 800-53** - IA-2 (identificación y autenticación de usuarios)

### 4. **Principio de mínimo privilegio**
Los usuarios anónimos violan este principio fundamental:
- Otorgan acceso sin necesidad
- No hay control granular
- Permiten más permisos de los necesarios

---

## 🎯 Objetivos de seguridad al eliminarlos

| Objetivo | Descripción |
|----------|-------------|
| **Autenticación obligatoria** | Toda conexión debe usar credenciales válidas |
| **Trazabilidad** | Cada acción debe asociarse a un usuario identificable |
| **Auditoría** | Logs deben mostrar quién hizo qué y cuándo |
| **Responsabilidad** | Usuarios son responsables de sus acciones |
| **Cumplimiento** | Alineación con estándares de seguridad |

---

## 📊 Impacto y consideraciones

### ✅ Ventajas de eliminarlos
- Mejora la postura de seguridad general
- Facilita auditorías y cumplimiento
- Elimina vector de ataque conocido
- Fuerza buenas prácticas de autenticación

### ⚠️ Consideraciones
- **Ningún impacto negativo** en MySQL 8.0 Community
- En versiones antiguas, podría romper scripts que dependían de acceso anónimo
- Aplicaciones deben configurarse con credenciales explícitas

### 🔄 Cambios en MySQL moderno
**MySQL 8.0** ya no crea usuarios anónimos por defecto:
- Instalación más segura "out of the box"
- Alineado con mejores prácticas modernas
- Mantener este paso es buena práctica para:
  - Migraciones desde versiones antiguas
  - Verificación de instalaciones personalizadas
  - Cumplimiento de checklists de seguridad

---

## 🛡️ Relación con otros controles de seguridad

Este control se complementa con:

1. **Política de contraseñas fuertes** (Punto 7)
   - No sirve eliminar anónimos si las contraseñas son débiles

2. **Restricción de bind-address** (Punto 4)
   - Limita desde dónde se puede intentar la conexión

3. **Eliminación de acceso remoto de root** (Punto 5)
   - Ambos reducen superficie de ataque

4. **Auditoría de accesos**
   - Solo es efectiva si no hay usuarios anónimos

---

## 📚 Referencias

- **CIS MySQL 8.0 Benchmark v1.2.0** - Ensure Anonymous Accounts Are Not Permitted
- **OWASP Database Security Cheat Sheet** - Authentication Controls
- **MySQL 8.0 Security Guide** - Chapter 6: Access Control and Account Management
- **PCI-DSS v4.0** - Requirement 8: Identify users and authenticate access

---

## ✅ Checklist de verificación

- [ ] Verificar que no existan usuarios con `User = ''`
- [ ] Confirmar que todas las aplicaciones usan credenciales explícitas
- [ ] Documentar el cambio en logs de auditoría
- [ ] Actualizar procedimientos de conexión si es necesario
- [ ] Verificar que logs de conexión muestren usuarios reales

---

## 🚀 Próximo paso

Una vez eliminados los usuarios anónimos (o verificado que no existen), proceder al **Punto 2: Eliminar base de datos de prueba**.
