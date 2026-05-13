# Configuración de API de TMDB (The Movie Database)

## 📋 Requisitos

Para utilizar la funcionalidad de búsqueda de películas de Jean Diary, necesitas configurar una API key de TMDB.

## 🚀 Pasos para obtener tu API Key

1. **Regístrate en TMDB**
   - Visita [https://www.themoviedb.org/](https://www.themoviedb.org/)
   - Crea una cuenta gratuita

2. **Solicita una API Key**
   - Inicia sesión en tu cuenta
   - Ve a **Settings** > **API**
   - Haz clic en **Request an API Key**
   - Selecciona **Developer**
   - Completa el formulario con tus datos
   - Acepta los términos y condiciones

3. **Verifica tu email**
   - TMDB enviará un email de verificación
   - Haz clic en el enlace de verificación

4. **Copia tu API Key**
   - Una vez verificada, tu API Key aparecerá en la página de API
   - Copia la API Key (es una cadena larga de caracteres)

## ⚙️ Configuración en el Proyecto

1. **Copia el archivo de ejemplo**
   ```
   cp .env.example .env
   ```

2. **Edita el archivo `.env`** y reemplaza tu API key:
   ```
   TMDB_API_KEY=TU_API_KEY_AQUI
   ```

3. **Ejecuta flutter pub get** para instalar la dependencia:
   ```
   flutter pub get
   ```

## 🔧 Características de la API

Una vez configurada, tendrás acceso a:

- ✅ **Búsqueda de películas y series**
- ✅ **Películas populares**
- ✅ **Películas en cartelera**
- ✅ **Próximos estrenos**
- ✅ **Detalles completos de películas**
- ✅ **Pósteres y backdrops**
- ✅ **Trailers de YouTube**
- ✅ **Proveedores de streaming**
- ✅ **Películas similares**

## 📱 Uso en la App

1. **Abre la sección de Películas**
   - Toca el ítem "Películas" en la navegación inferior

2. **Busca películas**
   - Toca el botón de búsqueda 🔵 (botón superior)
   - Escribe el nombre de una película, serie o actor
   - Explora los resultados

3. **Agrega a tu colección**
   - Toca en cualquier película para ver detalles
   - Presiona "Agregar" para añadirla a tu biblioteca

## 🛠️ Solución de Problemas

### Error: "API key de TMDB no configurada"
- Asegúrate de haber completado el archivo `.env` con tu API key real
- Verifica que no hay espacios alrededor de la API key
- Ejecuta `flutter pub get` después de crear el archivo

### Error: "Failed to search movies"
- Verifica tu conexión a internet
- Asegúrate de que tu API key esté activa
- Revisa que hayas completado la verificación por email

### Error: "No se encontraron resultados"
- Intenta con términos de búsqueda diferentes
- Verifica la ortografía
- Prueba con títulos en inglés si no encuentras resultados en español

## 📊 Límites de la API

TMDB tiene los siguientes límites para la API gratuita:
- **40 solicitudes** cada 10 segundos
- **Búsqueda ilimitada** de películas y series
- **Acceso completo** a todos los endpoints básicos

## 🔒 Seguridad

- **El archivo `.env` está excluido de Git** por seguridad
- **Nunca compartas tu API key** públicamente
- **No la subas a repositorios públicos** de GitHub
- El archivo `.env.example` sirve como plantilla sin datos reales

## 📞 Soporte

Si tienes problemas con la API de TMDB:
- **Documentación oficial**: [https://developers.themoviedb.org/3](https://developers.themoviedb.org/3)
- **Foro de TMDB**: [https://www.themoviedb.org/forum/](https://www.themoviedb.org/forum/)
- **Twitter**: @themoviedb

## 🎯 Tips de Uso

- **Usa términos específicos**: "Avengers: Endgame" en lugar de "Avengers"
- **Prueba en inglés**: Si no encuentras resultados en español
- **Explora categorías**: Usa las pestañas "Populares", "Cartelera" y "Próximamente"
- **Guarda tus favoritas**: Agrega películas a tu biblioteca para seguimiento

---

**¡Disfruta de tu experiencia cinematográfica con Jean Diary!** 🎬✨