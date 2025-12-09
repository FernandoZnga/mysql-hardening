#!/bin/bash
# ============================================================================
# Script para resetear MySQL a su estado inicial (ANTES del hardening)
# ============================================================================
# Uso: ./reset_mysql.sh
# ============================================================================

set -e  # Detener si hay errores

echo "🔄 RESET DE MYSQL A ESTADO INICIAL"
echo "===================================="
echo ""
echo "⚠️  ADVERTENCIA: Este script va a:"
echo "   - Detener y eliminar el contenedor MySQL"
echo "   - BORRAR TODOS LOS DATOS del volumen"
echo "   - Restaurar configuración inicial (sin hardening)"
echo "   - Reiniciar MySQL con configuración insegura"
echo ""
read -p "¿Continuar? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operación cancelada"
    exit 1
fi

echo ""
echo "📋 Paso 1: Deteniendo contenedor..."
docker-compose down

echo ""
echo "🗑️  Paso 2: Eliminando volumen de datos..."
docker volume rm mysql-hardening_mysql-data 2>/dev/null || echo "   (Volumen no existía)"

echo ""
echo "⚙️  Paso 3: Restaurando configuración inicial..."
if [ -f "my.cnf.initial" ]; then
    cp my.cnf my.cnf.hardened  # Backup de configuración hardened
    cp my.cnf.initial my.cnf
    echo "   ✅ my.cnf restaurado al estado inicial"
    echo "   💾 Backup de configuración hardened guardado en my.cnf.hardened"
else
    echo "   ⚠️  No se encontró my.cnf.initial, creando uno nuevo..."
    cat > my.cnf << 'EOF'
[mysqld]
# Configuración INICIAL - Sin hardening
port=3306
bind-address=0.0.0.0
sql_mode=TRADITIONAL
EOF
    echo "   ✅ my.cnf inicial creado"
fi

echo ""
echo "🚀 Paso 4: Iniciando MySQL con configuración inicial..."
docker-compose up -d

echo ""
echo "⏳ Paso 5: Esperando que MySQL esté listo..."
sleep 10

# Verificar que MySQL está corriendo
if docker exec mysql-hardening mysql -uroot -pRootPass123! -e "SELECT 'MySQL está listo' AS Status;" 2>/dev/null | grep -q "MySQL está listo"; then
    echo "   ✅ MySQL está corriendo y listo"
else
    echo "   ⚠️  MySQL aún está iniciando, espera unos segundos más"
fi

echo ""
echo "✅ RESET COMPLETADO"
echo "==================="
echo ""
echo "📊 Estado actual:"
echo "   - Puerto: 3306 (por defecto)"
echo "   - Usuarios: root@% y root@localhost (INSEGURO)"
echo "   - Base de datos 'testdb' presente"
echo "   - sql_mode: TRADITIONAL (básico)"
echo "   - Sin política de contraseñas estricta"
echo ""
echo "🎯 Ahora puedes:"
echo "   1. Ejecutar: docker exec -i mysql-hardening mysql -uroot -pRootPass123! < check_before_hardening.sql"
echo "   2. Guardar resultados en: estado_antes.txt"
echo "   3. Comenzar los ejercicios de hardening desde el inicio"
echo ""
echo "💡 Tip: Para volver al estado hardened:"
echo "   cp my.cnf.hardened my.cnf && docker-compose restart"
echo ""
