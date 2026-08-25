// File: Resources/Bible/RV1909_README.md

# Reina-Valera 1909

La app esta preparada para cargar la Biblia completa Reina-Valera 1909 desde archivos JSON de BibleAquifer.

Fuente:
https://github.com/BibleAquifer/ReinaValera1909/tree/main/spa/json

Licencia declarada por la fuente:
Reina-Valera 1909, dominio publico / CC0.

Ruta esperada dentro del proyecto:

```text
biblia-verion2026/Resources/Bible/RV1909/
```

Archivos esperados:

```text
01.content.json
02.content.json
...
66.content.json
```

Cuando esos archivos estan incluidos como recursos del target de la app, `DemoBibleRepository` deja de usar los datos demo y carga automaticamente los 66 libros, sus capitulos y versiculos.

Comando recomendado para preparar los archivos fuera de Xcode:

```sh
mkdir -p biblia-verion2026/Resources/Bible/RV1909
for i in $(seq -w 1 66); do
  curl -fsSL \
    -o "biblia-verion2026/Resources/Bible/RV1909/$i.content.json" \
    "https://raw.githubusercontent.com/BibleAquifer/ReinaValera1909/main/spa/json/$i.content.json"
done
```

Despues de descargar:

1. Arrastra `Resources/Bible/RV1909` al target de la app en Xcode si no aparece como recurso.
2. Verifica en Build Phases > Copy Bundle Resources que los 66 JSON estan incluidos.
3. Compila y abre la pestana Biblia.
