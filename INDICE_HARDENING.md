# Índice del Ejercicio: Hardening de MySQL Community

**Alumno:** Fernando  
**Fecha inicio:** 2025-12-09  
**Sistema:** MySQL 8.0 Community (Docker)  

---

## 📁 Estructura del Proyecto

```
W4/
├── README.md                           # Guía general del proyecto
├── INDICE_HARDENING.md                 # Este archivo
├── ESTADO_INICIAL.md                   # Análisis de vulnerabilidades inicial
├── docker-compose.yml                  # Configuración Docker
├── my.cnf                              # Configuración MySQL
├── estado_antes.txt                    # Log del estado inicial
│
├── documentacion/                      # Parte teórica de cada punto
│   ├── 01_TEORIA_usuarios_anonimos.md
│   ├── 02_TEORIA_base_test.md
│   ├── 03_TEORIA_cambiar_puerto.md
│   ├── 04_TEORIA_bind_address.md
│   ├── 05_TEORIA_root_remoto.md
│   ├── 06_TEORIA_sql_mode.md
│   └── 07_TEORIA_password_policy.md
│
├── hardening_scripts/                  # Scripts SQL de hardening
│   ├── 01_eliminar_usuarios_anonimos.sql
│   ├── 02_eliminar_base_test.sql
│   ├── 03_cambiar_puerto.sql
│   ├── 04_configurar_bind_address.sql
│   ├── 05_deshabilitar_root_remoto.sql
│   ├── 06_configurar_sql_mode.sql
│   └── 07_password_policy.sql
│
└── evidencias/                         # Resultados y evidencias
    ├── 01_RESUMEN_usuarios_anonimos.md
    ├── 01_resultado_usuarios_anonimos.txt
    ├── 02_RESUMEN_base_test.md
    ├── 02_resultado_base_test.txt
    ├── 03_RESUMEN_cambiar_puerto.md
    ├── 03_resultado_cambiar_puerto.txt
    ├── 04_RESUMEN_bind_address.md
    ├── 04_resultado_bind_address.txt
    ├── 05_RESUMEN_root_remoto.md
    ├── 05_resultado_root_remoto.txt
    ├── 06_RESUMEN_sql_mode.md
    ├── 06_resultado_sql_mode.txt
    ├── 07_RESUMEN_password_policy.md
    ├── 07_resultado_password_policy.txt
    └── COMPARATIVA_ANTES_DESPUES.md
```

---

## ✅ Checklist de Hardening

### Estado Inicial (ANTES)
- 🔴 **5 vulnerabilidades críticas/altas identificadas**
- ⚠️ **2 configuraciones mejorables**

### Puntos del Hardening

| # | Control de Seguridad | Estado | Prioridad | Evidencia |
|---|---------------------|--------|-----------|-----------|
| 1 | **Deshabilitar usuarios anónimos** | ✅ COMPLETO | Bajo | [Ver evidencia](evidencias/01_RESUMEN_usuarios_anonimos.md) |
|| 2 | **Eliminar base de datos test** | ✅ COMPLETO | Medio | [Ver evidencia](evidencias/02_RESUMEN_base_test.md) |
| 3 | **Cambiar puerto por defecto** | ⏳ PENDIENTE | Alto | - |
| 4 | **Configurar bind-address** | ⏳ PENDIENTE | Crítico | - |
| 5 | **Deshabilitar root remoto** | ⏳ PENDIENTE | Crítico | - |
| 6 | **Establecer sql_mode seguro** | ⏳ PENDIENTE | Medio | - |
| 7 | **Política de contraseñas** | ⏳ PENDIENTE | Alto | - |

**Progreso:** 2/7 (29%)

---

## 📊 Resumen por Punto

### ✅ Punto 1: Deshabilitar usuarios anónimos
- **Estado:** COMPLETO
- **Resultado:** No había usuarios anónimos (MySQL 8.0 seguro por defecto)
- **Archivos:**
  - Teoría: `documentacion/01_TEORIA_usuarios_anonimos.md`
  - Script: `hardening_scripts/01_eliminar_usuarios_anonimos.sql`
  - Evidencia: `evidencias/01_RESUMEN_usuarios_anonimos.md`
- **Estándares:** CIS 1.2, PCI-DSS 8.2, ISO 27001 A.9.2.1

### ✅ Punto 2: Eliminar base de datos test
- **Estado:** COMPLETO
- **Resultado:** Base 'testdb' eliminada exitosamente (estaba vacía)
- **Archivos:**
  - Teoría: `documentacion/02_TEORIA_base_test.md`
  - Script: `hardening_scripts/02_eliminar_base_test.sql`
  - Evidencia: `evidencias/02_RESUMEN_base_test.md`
- **Estándares:** CIS 1.3, PCI-DSS 2.2, ISO 27001 A.12.5.1

### ⏳ Punto 3: Cambiar puerto por defecto
- **Estado:** PENDIENTE  
- **Riesgo actual:** Puerto 3306 (estándar)
- **Acción:** Cambiar a 3308

### ⏳ Punto 4: Configurar bind-address
- **Estado:** PENDIENTE
- **Riesgo actual:** 0.0.0.0 (CRÍTICO)
- **Acción:** Limitar a localhost o IPs específicas

### ⏳ Punto 5: Deshabilitar root remoto
- **Estado:** PENDIENTE
- **Riesgo actual:** root@% activo (CRÍTICO)
- **Acción:** Eliminar root@%, mantener solo root@localhost

### ⏳ Punto 6: Establecer sql_mode seguro
- **Estado:** PENDIENTE
- **Riesgo actual:** Modo tradicional, falta NO_AUTO_CREATE_USER
- **Acción:** Agregar modos de seguridad adicionales

### ⏳ Punto 7: Política de contraseñas
- **Estado:** PENDIENTE
- **Riesgo actual:** validate_password NO instalado
- **Acción:** Instalar y configurar plugin

---

## 🎯 Objetivos de Aprendizaje

### Parte Teórica
- [x] Usuarios anónimos y riesgos
- [x] Seguridad de bases de datos de prueba
- [ ] Oscuridad de puertos (security by obscurity)
- [ ] Segmentación de red con bind-address
- [ ] Principio de mínimo privilegio (root remoto)
- [ ] SQL modes y su impacto en seguridad
- [ ] Políticas de contraseñas (NIST, ISO)

### Parte Práctica
- [x] Verificación de usuarios en mysql.user
- [x] Ejecución de scripts SQL de hardening
- [x] Documentación de evidencias
- [ ] Modificación de archivos de configuración
- [ ] Reinicio de servicios MySQL
- [ ] Validación de cambios persistentes
- [ ] Análisis comparativo antes/después

### Cumplimiento de Estándares
- [ ] CIS Benchmark for MySQL 8.0
- [ ] ISO 27001:2013
- [ ] PCI-DSS v4.0
- [ ] NIST SP 800-53

---

## 📝 Notas de Implementación

### Comandos Útiles

**Conectarse al contenedor:**
```bash
docker exec -it mysql-hardening mysql -uroot -pRootPass123!
```

**Ejecutar script de hardening:**
```bash
docker exec -i mysql-hardening mysql -uroot -pRootPass123! \
  < hardening_scripts/0X_nombre_script.sql \
  | tee evidencias/0X_resultado.txt
```

**Verificar logs:**
```bash
docker logs mysql-hardening
```

**Reiniciar contenedor:**
```bash
docker restart mysql-hardening
```

**Ver configuración activa:**
```bash
docker exec mysql-hardening cat /etc/mysql/my.cnf
```

---

## 🚀 Próximos Pasos

1. ✅ ~~Punto 1: Usuarios anónimos~~ (COMPLETO)
2. ✅ ~~Punto 2: Eliminar base test~~ (COMPLETO)
3. **⏭️ Punto 3: Cambiar puerto** (SIGUIENTE)
3. Punto 3: Cambiar puerto
4. Punto 4: Bind address
5. Punto 5: Root remoto
6. Punto 6: SQL mode
7. Punto 7: Password policy
8. Crear comparativa final ANTES vs DESPUÉS

---

## 📚 Referencias Principales

- [MySQL 8.0 Security Guide](https://dev.mysql.com/doc/refman/8.0/en/security.html)
- [CIS MySQL 8.0 Benchmark](https://www.cisecurity.org/benchmark/mysql)
- [OWASP Database Security](https://cheatsheetseries.owasp.org/cheatsheets/Database_Security_Cheat_Sheet.html)
- [PCI Security Standards](https://www.pcisecuritystandards.org/)

---

**Última actualización:** 2025-12-09 02:15 UTC
