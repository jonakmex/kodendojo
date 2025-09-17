# Domain Template — README

## 1) What is this?
A minimal **Java + Gradle library** template to bootstrap “domain” style modules (pure business logic, no framework wiring).  
It provides a sample service (`MyService`) and a unit test (`MyServiceTest`) to validate the setup.

---

## 2) Prerequisites
- **Java 21+** (Temurin/OpenJDK recommended)
- **Gradle Wrapper** will be generated per project (no global Gradle required)
- This template located at: `~/dev-scripts/tpl/domain/`  
  (or set `DEV_TEMPLATES_DIR` to your templates root)

Check:
```bash
java -version
```

---

## 3) Install the template (one‑time)
Place the template in your templates folder. Examples:

```bash
# Option A: default location used by the generator
mkdir -p ~/dev-scripts/tpl
unzip domain-template.zip -d ~/dev-scripts/tpl/domain

# Option B: custom location
export DEV_TEMPLATES_DIR="$HOME/my-templates"
mkdir -p "$DEV_TEMPLATES_DIR"
unzip domain-template.zip -d "$DEV_TEMPLATES_DIR/domain"
```

> If you haven’t set up your generator script yet, save it as `~/dev-scripts/mk-gradle.sh` and add `~/dev-scripts` to your PATH.

---

## 4) Create a new project from this template
**Command:**
```bash
mk-gradle.sh <app_name> <base_package> domain
```

**Example:**
```bash
mk-gradle.sh hello-world com.example.hello domain
```

This will generate:
```
hello-world/
├─ build.gradle              # from template (placeholders resolved)
├─ settings.gradle           # from template
└─ src/
   ├─ main/
   │  ├─ java/com/example/hello/MyService.java
   │  └─ resources/
   └─ test/
      ├─ java/com/example/hello/MyServiceTest.java
      └─ resources/
```

---

## 5) Build & test the project
From inside the newly created project directory:

```bash
cd hello-world

# generate Gradle Wrapper (first time only)
./gradlew wrapper

# compile & run tests
./gradlew clean build

# run tests only
./gradlew test
```

Expected output ends with:
```
BUILD SUCCESSFUL
```

---

## 6) Expected result
- The project compiles successfully.
- `MyServiceTest` passes, demonstrating a working JUnit 5 setup.
- You can start adding your own domain classes under `src/main/java/<your package>/` and tests under `src/test/java/<your package>/`.

---

## 7) Troubleshooting
- **Java not found**: install Temurin 21 and ensure `java -version` works.
- **Wrapper not executable**: `chmod +x ./gradlew` (macOS/Linux).
- **Template not found**: verify `DEV_TEMPLATES_DIR` or place under `~/dev-scripts/tpl/domain`.

---

## 8) Why this template?
- **Frictionless**: no frameworks; pure Java library.
- **Test‑first**: includes a minimal unit test.
- **Composable**: perfect as a base module in layered or hexagonal architectures.
