#!/usr/bin/env bash
# Uso: ./mk-gradle-lib.sh <nombre-proyecto> <paquete-base>
# Ejemplo: ./mk-gradle-lib.sh my-library com.example.mylib

set -euo pipefail

APP_NAME=${1:-my-library}
PACKAGE=${2:-mylib}

# Ruta base
mkdir -p "$APP_NAME"

# 1️⃣ settings.gradle
cat > "$APP_NAME/settings.gradle" <<EOF
rootProject.name = '$APP_NAME'
EOF

# 2️⃣ build.gradle (solo plugin 'java' y JUnit 5 para tests)
cat > "$APP_NAME/build.gradle" <<'EOF'
plugins {
    id 'java'
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation platform('org.junit:junit-bom:5.10.2')
    testImplementation 'org.junit.jupiter:junit-jupiter'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

test {
    useJUnitPlatform()
}
EOF

# 3️⃣ Estructura de carpetas estándar
mkdir -p "$APP_NAME/src/main/java/$(echo $PACKAGE | tr . /)"
mkdir -p "$APP_NAME/src/main/resources"
mkdir -p "$APP_NAME/src/test/java/$(echo $PACKAGE | tr . /)"
mkdir -p "$APP_NAME/src/test/resources"

# 4️⃣ Clase de ejemplo de librería
cat > "$APP_NAME/src/main/java/$(echo $PACKAGE | tr . /)/MyService.java" <<EOF
package $PACKAGE;

/**
 * Ejemplo de clase de librería.
 */
public class MyService {
    public String greet(String name) {
        return "Hello, " + name + "!";
    }
}
EOF

# 5️⃣ Test básico
cat > "$APP_NAME/src/test/java/$(echo $PACKAGE | tr . /)/MyServiceTest.java" <<EOF
package $PACKAGE;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class MyServiceTest {

    @Test
    void testGreet() {
        MyService svc = new MyService();
        assertEquals("Hello, World!", svc.greet("World"));
    }
}
EOF

echo "✅ Proyecto Gradle de librería '$APP_NAME' creado."
echo "Para compilar y probar:"
echo "  cd $APP_NAME"
echo "  ./gradlew wrapper && ./gradlew build"
