# Guía para Subir Proyecto Flutter a GitHub

## 📋 Requisitos Previos

1. **Tener Git instalado** en tu sistema
2. **Tener una cuenta en GitHub** creada
3. **Tener el proyecto Flutter** listo para subir

---

## 🚀 Paso a Paso Completo

### 1. Inicializar Repositorio Git Local

Abre una terminal en la raíz de tu proyecto y ejecuta:

```bash
git init
```

### 2. Verificar Archivos Ignorados

Tu proyecto ya tiene un `.gitignore` configurado correctamente para Flutter, lo cual excluye:
- Archivos de compilación (`build/`, `.dart_tool/`)
- Configuración de IDE (`.idea/`, `.vscode/`)
- Dependencias (`.flutter-plugins-dependencies`)
- Archivos temporales y de logs

### 3. Agregar Archivos al Staging

```bash
git add .
```

### 4. Hacer el Primer Commit

```bash
git commit -m "Initial commit: Flutter daily routine app"
```

### 5. Crear Repositorio en GitHub

1. Inicia sesión en [GitHub](https://github.com)
2. Haz clic en **"New repository"**
3. Configura tu repositorio:
   - **Repository name**: `app_rutina_diaria`
   - **Description**: `Flutter app for daily routine management`
   - **Visibility**: Private o Public (según prefieras)
   - **NO marques** "Add a README file" (ya tienes uno)
   - **NO marques** "Add .gitignore" (ya tienes uno)
4. Haz clic en **"Create repository"**

### 6. Conectar con Repositorio Remoto

GitHub te mostrará los comandos. Elige la opción **"push an existing repository from the command line"**:

```bash
git remote add origin https://github.com/TU_USERNAME/app_rutina_diaria.git
git branch -M main
git push -u origin main
```

> **Nota**: Reemplaza `TU_USERNAME` con tu nombre de usuario de GitHub

### 7. Autenticación (si es necesario)

Si te pide autenticación, tienes dos opciones:

#### Opción A: Personal Access Token (Recomendado)
1. Ve a GitHub Settings → Developer settings → Personal access tokens
2. Genera un nuevo token con permisos `repo`
3. Úsalo como contraseña cuando Git la solicite

#### Opción B: SSH Key
1. Genera una clave SSH: `ssh-keygen -t ed25519 -C "tu-email@example.com"`
2. Agrégala a tu cuenta GitHub
3. Usa la URL SSH: `git@github.com:TU_USERNAME/app_rutina_diaria.git`

---

## 📝 Comandos Útiles Post-Subida

### Verificar Estado
```bash
git status
```

### Ver Historial de Commits
```bash
git log --oneline
```

### Ver Repositorios Remotos
```bash
git remote -v
```

---

## 🔧 Mejoras Recomendadas para tu README

Actualiza tu `README.md` con información específica del proyecto:

```markdown
# App Rutina Diaria

Una aplicación Flutter para gestionar tu rutina diaria.

## 📱 Características
- [Lista las características principales]
- [Funcionalidades destacadas]

## 🚀 Cómo Ejecutar

1. Clona el repositorio:
   ```bash
   git clone https://github.com/TU_USERNAME/app_rutina_diaria.git
   cd app_rutina_diaria
   ```

2. Instala dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecuta la app:
   ```bash
   flutter run
   ```

## 📸 Screenshots
[Agrega capturas de pantalla de tu app]

## 🛠️ Tecnologías
- Flutter
- Dart
- [Otras tecnologías usadas]
```

---

## 🔄 Flujo de Trabajo Futuro

Para futuros cambios:

```bash
# 1. Verificar cambios
git status

# 2. Agregar archivos modificados
git add .

# 3. Hacer commit con mensaje descriptivo
git commit -m "feat: agregar nueva funcionalidad"

# 4. Subir cambios a GitHub
git push
```

---

## ⚠️ Problemas Comunes y Soluciones

### Error: "refusing to merge unrelated histories"
```bash
git pull origin main --allow-unrelated-histories
```

### Error: "Permission denied (publickey)"
- Verifica que tu SSH key esté correctamente configurada
- O usa HTTPS con Personal Access Token

### Archivos grandes que no deberían subirse
- Asegúrate que los archivos pesados estén en `.gitignore`
- Usa `git rm --cached archivo.ext` para eliminar archivos ya subidos

---

## ✅ Verificación Final

Una vez completado, verifica que:
1. ✅ Tu repositorio aparece en GitHub
2. ✅ Todos los archivos importantes están visibles
3. ✅ El README se muestra correctamente
4. ✅ Los archivos sensibles NO están subidos (contraseñas, API keys)

¡Listo! Tu proyecto Flutter ahora está en GitHub. 🎉
