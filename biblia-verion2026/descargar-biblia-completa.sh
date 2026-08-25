#!/bin/bash

mkdir -p Resources/Bible/RV1909

echo "📥 Descargando 66 libros - Reina Valera 1909..."
echo ""

REPO="https://raw.githubusercontent.com/aruljohn/Reina-Valera/master"

for i in {1..66}; do
    num=$(printf "%02d" $i)
    echo "📖 [$i/66] Descargando libro $num..."
    
    curl -s "${REPO}/${i}.json" -o "Resources/Bible/RV1909/${num}.content.json"
    sleep 0.2
done

echo ""
echo "✅ ¡Descarga completada!"
echo "📊 Total de archivos descargados:"
ls -1 Resources/Bible/RV1909/ | wc -l
echo "archivos ✓"
