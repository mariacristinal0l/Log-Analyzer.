#!/bin/bash

# Define la variable para el archivo de log (debe ser el primer argumento)
LOG_FILE=$1

# Verifica si el archivo fue proporcionado. Si no existe, sale.
if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
    echo "Error: Uso: $0 <archivo_de_log> (Asegúrate de que el archivo exista)"
    exit 1
fi

# ----------------------------------------------------------------
# Funciones de Análisis
# ----------------------------------------------------------------

analizar_ips_mas_activas() {
    echo "--- [ 🕵️ Top 10 Direcciones IP Más Activas ] ---"
    # cut extrae la IP, sort ordena, uniq -c cuenta y sort -nr ordena por número (descendente)
    cut -d' ' -f1 "$LOG_FILE" | sort | uniq -c | sort -nr | head -10
    echo ""
}

identificar_errores_4xx_5xx() {
    echo "--- [ 🚨 URLs con Códigos de Error (4xx y 5xx) ] ---"
    
    # Busca todas las URLs que resultaron en errores 4xx (cliente) y 5xx (servidor)
    echo "--- Errores 4xx ---"
    grep -E ' " 4[0-9]{2} ' "$LOG_FILE" | cut -d'"' -f2 | sort | uniq -c | sort -nr | head -5
    
    echo "--- Errores 5xx ---"
    grep -E ' " 5[0-9]{2} ' "$LOG_FILE" | cut -d'"' -f2 | sort | uniq -c | sort -nr | head -5
    echo ""
}

identificar_posibles_ataques() {
    echo "--- [ ⚠️ Posibles Intentos de Ataque (SQLi / XSS) ] ---"
    
    # Busca patrones comunes usados en ataques de inyección SQL y XSS
    grep -E "UNION|SELECT|--|SLEEP|<script>|onload=|javascript:" "$LOG_FILE" | cut -d' ' -f1,6,7 | sort | uniq
    echo ""
}


# ----------------------------------------------------------------
# Ejecución del Script Principal
# ----------------------------------------------------------------

echo "=================================================="
echo "      Log Analyzer - Iniciando Análisis del Archivo: $LOG_FILE"
echo "=================================================="

# Llamada a las funciones de análisis
analizar_ips_mas_activas
identificar_errores_4xx_5xx
identificar_posibles_ataques

echo "=================================================="
echo "Análisis Finalizado. Resultados mostrados arriba."
echo "=================================================="
