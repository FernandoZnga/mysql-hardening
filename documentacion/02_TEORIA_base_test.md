# PUNTO 2: Eliminar Base de Datos de Prueba (test)

## 📋 Parte Teórica

### ¿Qué es la base de datos 'test'?

En versiones antiguas de MySQL (anteriores a 5.7), el instalador creaba automáticamente una base de datos llamada **'test'** con las siguientes características:

```sql
-- Base de datos 'test' histórica
Database: test
Privilegios: Cualquier usuario podía crear/modificar tablas
Propósito: Ambiente de pruebas inicial
```

### ¿Por qué existía?

1. **Facilitar aprendizaje:** Permitir a nuevos usuarios experimentar sin configuración
2. **Testing rápido:** Probar comandos SQL sin crear bases de datos
3. **Demos y tutoriales:** Muchos ejemplos asumían la existencia de 'test'
4. **Conveniencia de desarrollo:** Espacio temporal para pruebas

**Privilegios por defecto:**
```sql
-- Cualquier usuario autenticado tenía acceso
GRANT ALL ON test.* TO ''@'localhost';
GRANT ALL ON `test\_%`.* TO ''@'localhost';
```

---

## 🔐 ¿Por qué es un riesgo de seguridad?

### 1. **Exposición de datos sensibles**
- Los desarrolladores pueden usar 'test' para datos reales "temporalmente"
- Contraseñas, tokens, datos de clientes pueden terminar aquí
- No hay controles de acceso estrictos
- Los datos "temporales" a menudo se vuelven permanentes

### 2. **Vector de ataque lateral**
- Un atacante con acceso mínimo puede usar 'test' como punto de entrada
- Puede almacenar malware, scripts, datos robados
- Sirve como staging area para ataques más complejos
- Dificulta la detección de actividad maliciosa

### 3. **Falta de auditoría**
- Base de datos "descartable" → logs ignorados
- Difícil rastrear quién hizo qué
- Violaciones de datos pueden pasar desapercibidas
- No hay ownership claro

### 4. **Confusión de ambientes**
- Scripts de desarrollo pueden ejecutarse en producción
- Datos de prueba mezclados con datos reales
- Dificulta la gestión de cambios
- Aumenta riesgo de errores operacionales

### 5. **Cumplimiento normativo**
Estándares que requieren eliminar bases de datos de prueba en producción:
- **CIS Benchmark for MySQL 8.0** - Sección 1.3
- **PCI-DSS** - Requisito 2.2 (eliminar funcionalidad innecesaria)
- **ISO 27001** - Control A.12.5.1 (controles de software en producción)
- **SOC 2** - Control de separación de ambientes
- **HIPAA** - Protección de datos sensibles

---

## 🎯 Objetivos de seguridad al eliminarla

| Objetivo | Descripción |
|----------|-------------|
| **Reducir superficie de ataque** | Menos bases = menos vectores de entrada |
| **Claridad de propósito** | Cada BD tiene un owner y propósito definido |
| **Separación de ambientes** | Dev/Test/Prod claramente diferenciados |
| **Auditoría efectiva** | Solo monitorear BDs legítimas |
| **Cumplimiento** | Alineación con estándares de seguridad |

---

## 📊 Impacto y consideraciones

### ✅ Ventajas de eliminarla
- Elimina espacio de almacenamiento inseguro
- Reduce confusión entre desarrollo y producción
- Mejora postura de seguridad general
- Facilita auditorías y cumplimiento
- Fuerza buenas prácticas (BDs dedicadas por proyecto)

### ⚠️ Consideraciones
- **Scripts antiguos** pueden fallar si asumen existencia de 'test'
- **Tutoriales** pueden necesitar adaptación
- **Desarrolladores** necesitan crear sus propias BDs de prueba
- **Documentación** debe actualizarse

### 🔄 Cambios en MySQL moderno
**MySQL 8.0** ya no crea la base 'test' por defecto:
- Instalación más limpia "out of the box"
- Los usuarios deben ser explícitos sobre sus BDs
- Mantener este paso es importante para:
  - Migraciones desde versiones antiguas
  - Detectar BDs de prueba creadas manualmente
  - Validar que no existen patrones `test_%`

---

## 🔍 Qué buscar y eliminar

### 1. Base de datos 'test'
```sql
SHOW DATABASES LIKE 'test';
DROP DATABASE IF EXISTS test;
```

### 2. Bases de datos con patrón 'test_%'
```sql
SHOW DATABASES LIKE 'test\_%';
-- Evaluar cada una y eliminar si no es necesaria
```

### 3. Privilegios asociados
```sql
-- Privilegios sobre 'test'
SELECT * FROM mysql.db WHERE Db = 'test';
DELETE FROM mysql.db WHERE Db = 'test';

-- Privilegios sobre patrón 'test_%'
SELECT * FROM mysql.db WHERE Db LIKE 'test\_%';
DELETE FROM mysql.db WHERE Db LIKE 'test\_%';

FLUSH PRIVILEGES;
```

---

## 🛡️ Mejores prácticas alternativas

### En lugar de 'test', usar:

1. **Ambientes dedicados**
   ```
   - dev_database    (desarrollo local)
   - staging_database (pre-producción)
   - prod_database   (producción)
   ```

2. **Prefijos por proyecto**
   ```
   - proyecto_a_dev
   - proyecto_a_test
   - proyecto_a_prod
   ```

3. **Contenedores efímeros**
   ```bash
   # Crear BD temporal en Docker, usarla, eliminar contenedor
   docker run --rm -e MYSQL_DATABASE=temp_test mysql:8.0
   ```

4. **Bases de datos personales**
   ```sql
   -- Cada desarrollador tiene su espacio
   CREATE DATABASE dev_fernando;
   GRANT ALL ON dev_fernando.* TO 'fernando'@'localhost';
   ```

---

## 🔄 Relación con otros controles de seguridad

Este control se complementa con:

1. **Principio de mínimo privilegio** (Punto 5)
   - No dar acceso global a BDs genéricas
   - Cada usuario solo accede a sus BDs específicas

2. **Auditoría de accesos**
   - Más fácil auditar BDs con propósito definido
   - Logs más significativos

3. **Separación de ambientes**
   - Producción sin artefactos de desarrollo
   - Reduce confusión operacional

4. **Gestión de configuración**
   - Infraestructura como código
   - BDs declaradas explícitamente

---

## 📚 Referencias

- **CIS MySQL 8.0 Benchmark v1.2.0** - Section 1.3: Remove test database
- **PCI-DSS v4.0** - Requirement 2.2: Remove unnecessary functionality
- **OWASP Database Security** - Test Data Management
- **NIST SP 800-53** - CM-7 (Least Functionality)
- **ISO 27001:2013** - A.12.5.1 (Installation of software on operational systems)

---

## ⚠️ Casos especiales

### Si encuentras 'testdb' (nuestro caso)
Esta es la base que creamos en el `docker-compose.yml` como ejemplo. Opciones:

1. **Eliminarla** si no es necesaria (recomendado para hardening)
2. **Renombrarla** a algo más específico
3. **Mantenerla** solo si tiene un propósito legítimo documentado

Para este ejercicio de hardening, la **eliminaremos** para demostrar el proceso completo.

---

## ✅ Checklist de verificación

- [ ] Identificar todas las bases de datos tipo 'test'
- [ ] Verificar que no contienen datos importantes
- [ ] Consultar con desarrolladores/usuarios
- [ ] Hacer backup preventivo (si es necesario)
- [ ] Eliminar base de datos
- [ ] Revocar privilegios asociados
- [ ] Verificar eliminación completa
- [ ] Actualizar documentación
- [ ] Comunicar cambios al equipo

---

## 🚀 Próximo paso

Una vez eliminadas las bases de datos de prueba, proceder al **Punto 3: Cambiar puerto por defecto**.
