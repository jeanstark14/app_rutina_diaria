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

1. **Abre el archivo de configuración**
   ```
   lib/services/tmdb_config.dart
   ```

2. **Reemplaza la API Key**
   ```dart
   class TmdbConfig {
     static const String apiKey = 'TU_API_KEY_AQUI'; // Reemplaza esto
     // ... resto del código
   }
   ```

3. **Guarda el archivo**

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
- Asegúrate de haber reemplazado 'YOUR_API_KEY_HERE' con tu API key real
- Verifica que no hay espacios extraños alrededor de la API key

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

- **Nunca compartas tu API key** públicamente
- **No la subas a repositorios públicos** de GitHub
- La API key está incluida en el archivo `.gitignore` por seguridad

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
