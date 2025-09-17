#!/usr/bin/env bash
# Uso:
#   mk-gradle-lib.sh <app_name> <package> <kind>
# Ejemplo:
#   mk-gradle-lib.sh my-library com.example.mylib domain
#
# Plantillas:
#   Se buscan en $DEV_TEMPLATES_DIR (o ~/dev-scripts/tpl por defecto)
#   Estructura esperada:
#     <kind>/
#       build.gradle.tpl        # (opcional) si no existe, se genera uno mínimo
#       settings.gradle.tpl     # (opcional) si existe, reemplaza al generado
#       gradle.properties.tpl   # (opcional)
#       README.md.tpl           # (opcional)
#       <otros-archivos>.tpl    # (opcional)
#       src/
#         main/java/__PACKAGE_PATH__/...
#         test/java/__PACKAGE_PATH__/...
#         (resources opcionales)
#
# Placeholders soportados en contenido:
#   __APP_NAME__, __PACKAGE__, __PACKAGE_PATH__
# En rutas de archivos/directorios:
#   __PACKAGE_PATH__  -> com/example/mylib
#
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Uso: $0 <app_name> <package> <kind>"
  echo "Ejemplo: $0 my-library com.example.mylib domain"
  exit 1
fi

APP_NAME="$1"
PACKAGE="$2"
KIND="$3"

TEMPLATES_ROOT="${DEV_TEMPLATES_DIR:-$HOME/dev-scripts/gradle/tpl}"
KIND_DIR="$TEMPLATES_ROOT/$KIND"

if [[ ! -d "$KIND_DIR" ]]; then
  echo "❌ No existe el template kind='$KIND' en: $KIND_DIR"
  echo "   Define DEV_TEMPLATES_DIR o crea la carpeta: $TEMPLATES_ROOT/$KIND"
  exit 1
fi

pkg_path() { echo "$PACKAGE" | tr '.' '/'; }
subst_file() {
  # $1 = src, $2 = dest
  local src="$1" dest="$2" tmp
  tmp="$(mktemp)"
  # Reemplazos de placeholders en contenido
  sed -e "s|__APP_NAME__|$APP_NAME|g" \
      -e "s|__PACKAGE__|$PACKAGE|g" \
      -e "s|__PACKAGE_PATH__|$(pkg_path)|g" \
      "$src" > "$tmp"
  mv "$tmp" "$dest"
}

# --- Crear carpeta del proyecto ---
mkdir -p "$APP_NAME"

# --- settings.gradle: del template si existe; si no, mínimo ---
if [[ -f "$KIND_DIR/settings.gradle.tpl" ]]; then
  subst_file "$KIND_DIR/settings.gradle.tpl" "$APP_NAME/settings.gradle"
else
  cat > "$APP_NAME/settings.gradle" <<EOF
rootProject.name = '$APP_NAME'
EOF
fi

# --- build.gradle: del template si existe; si no, mínimo ---
if [[ -f "$KIND_DIR/build.gradle.tpl" ]]; then
  subst_file "$KIND_DIR/build.gradle.tpl" "$APP_NAME/build.gradle"
else
  cat > "$APP_NAME/build.gradle" <<'EOF'
plugins { id 'java' }

repositories { mavenCentral() }

dependencies {
    testImplementation platform('org.junit:junit-bom:5.10.2')
    testImplementation 'org.junit.jupiter:junit-jupiter'
    testRuntimeOnly  'org.junit.platform:junit-platform-launcher'
}

test { useJUnitPlatform() }
EOF
fi

# --- Copiar otros archivos de raíz del template (*.tpl) con reemplazos ---
# (ej: gradle.properties.tpl, README.md.tpl, .editorconfig.tpl, etc.)
shopt -s nullglob
for root_tpl in "$KIND_DIR"/*.tpl "$KIND_DIR"/.*.tpl; do
  fname="$(basename "$root_tpl")"
  # Oculta '.' y '..'
  [[ "$fname" == "." || "$fname" == ".." ]] && continue
  # Ya gestionados arriba
  [[ "$fname" == "build.gradle.tpl" || "$fname" == "settings.gradle.tpl" ]] && continue
  # Quitar sufijo .tpl
  out_name="${fname%.tpl}"
  # Sustituir __PACKAGE_PATH__ en el nombre si aparece
  out_name="${out_name//__PACKAGE_PATH__/$(pkg_path)}"
  subst_file "$root_tpl" "$APP_NAME/$out_name"
done
shopt -u nullglob

# --- Asegurar carpetas resources ---
mkdir -p "$APP_NAME/src/main/resources" "$APP_NAME/src/test/resources"

# --- Copiar /src del template con reemplazos de rutas y contenido ---
SRC_ROOT="$KIND_DIR/src"
if [[ -d "$SRC_ROOT" ]]; then
  while IFS= read -r -d '' src; do
    rel="${src#$SRC_ROOT/}"
    # __PACKAGE_PATH__ en la ruta
    rel="${rel//__PACKAGE_PATH__/$(pkg_path)}"
    dest="$APP_NAME/src/$rel"
    mkdir -p "$(dirname "$dest")"
    subst_file "$src" "$dest"
  done < <(find "$SRC_ROOT" -type f -print0)
fi

echo "✅ Proyecto '$APP_NAME' creado desde template kind='$KIND'."
echo "📂 Ubicación: $PWD/$APP_NAME"
echo "👉 Comandos sugeridos:"
echo "   cd $APP_NAME"
echo "   ./gradlew wrapper && ./gradlew build"