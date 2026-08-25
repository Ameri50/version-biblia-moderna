#!/bin/bash

# Crear estructura de carpetas
mkdir -p Resources/Bible/RV1909

echo "📥 Descargando 66 libros de la Biblia RV1909..."
echo ""

# Array con los números de los 66 libros
for i in {1..66}; do
    # Formatear el número con dos dígitos (01, 02, 03... 66)
    num=$(printf "%02d" $i)
    
    # URL del archivo JSON (ajusta según tu fuente)
    url="https://raw.githubusercontent.com/tonybeltramelli/Bible-API/master/books/${i}.json"
    
    # Descargar el archivo
    echo "📖 Descargando libro $num..."
    curl -s "$url" -o "Resources/Bible/RV1909/${num}.content.json"
    
    # Pequeña pausa para no saturar el servidor
    sleep 0.5
done

echo ""
echo "✅ ¡Descarga completada!"
echo "📁 Archivos guardados en: Resources/Bible/RV1909/"
ls -1 Resources/Bible/RV1909/ | wc -l
echo "archivos descargados"
