import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/task_provider.dart';
import '../services/user_provider.dart';
import '../services/theme_provider.dart';
import '../services/water_provider.dart';
import '../services/water_provider.dart';
import '../services/movie_provider.dart';
import '../services/nutrition_provider.dart';
import '../models/movie_model.dart';
import '../models/nutrition_model.dart';
import '../theme/app_theme.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final userProvider = context.watch<UserProvider>();
    final waterProvider = context.watch<WaterProvider>();
    final movieProvider = context.watch<MovieProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final nutritionProvider = context.watch<NutritionProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    final tasks = taskProvider.tasks;
    final completedCount = tasks
        .where((t) => t.isCompletedForDate(taskProvider.selectedDate))
        .length;
    final successRate =
        tasks.isEmpty ? 0 : (completedCount / tasks.length * 100).toInt();

    final movies = movieProvider.moviesInAgenda;
    final favoriteCount = movies.where((m) => m.isFavorite).length;
    final upcomingCount = movies.where((m) => m.daysUntilRelease >= 0).length;
    final releasedCount = movies.where((m) => m.daysUntilRelease < 0).length;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('CENTRO DE INTELIGENCIA',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRankCard(userProvider, themeProvider, isDark),
            const SizedBox(height: 32),
            Text('ESTADO DE LA OPERACIÓN',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : AppTheme.textGrey,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatBox('TASA DE ÉXITO', '$successRate%', Icons.ads_click,
                    Colors.green, isDark),
                const SizedBox(width: 16),
                _buildStatBox('RACHA ACTUAL', '${taskProvider.currentStreak}D',
                    Icons.bolt, Colors.orange, isDark),
              ],
            ),
            const SizedBox(height: 32),
            Text('REPORTE CINEMATOGRÁFICO',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : AppTheme.textGrey,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 16),
            _buildMovieStatsCard(movies.length, favoriteCount, upcomingCount, releasedCount, isDark, primaryColor),
            const SizedBox(height: 32),
            Text('SUMINISTRO HÍDRICO',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : AppTheme.textGrey,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 16),
            _buildWaterStatsCard(waterProvider, isDark, primaryColor),
            const SizedBox(height: 32),
            Text('REPORTE DE ALIMENTACIÓN',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : AppTheme.textGrey,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 16),
            _buildNutritionStatsCard(nutritionProvider, isDark, primaryColor),
            const SizedBox(height: 32),
            Text('RENDIMIENTO TÁCTICO',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : AppTheme.textGrey,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  const Text('Misiones de la Semana',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        final weeklyStats =
                            taskProvider.getWeeklyCompletionStats();
                        return _buildBar(
                            weeklyStats[index], index, isDark, primaryColor);
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildMotivationalQuote(isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieStatsCard(int total, int favorites, int upcoming, int released, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat('TOTAL', total.toString(), Icons.movie, Colors.blue),
              _buildSimpleStat('FAVORITOS', favorites.toString(), Icons.favorite, Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Próximos Estrenos', style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textGrey, fontSize: 12)),
              Text('$upcoming', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : upcoming / total,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ya Estrenadas', style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textGrey, fontSize: 12)),
              Text('$released', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRankCard(UserProvider user, ThemeProvider theme, bool isDark) {
    final primaryColor = theme.primaryColor;
    final accentColor = theme.accentColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [primaryColor, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Text('${user.level}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.rank.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  Text(user.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP: ${user.xp}/${user.nextLevelXp}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${(user.levelProgress * 100).toInt()}%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: user.levelProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white))),
        ],
      ),
    );
  }

  Widget _buildStatBox(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double heightFactor, int index, bool isDark, Color color) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
              color: heightFactor >= 1.0
                  ? color
                  : (isDark ? Colors.white10 : color.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 8),
        Text(days[index],
            style: TextStyle(
                fontSize: 10,
                color: AppTheme.textGrey,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMotivationalQuote(bool isDark, Color primaryColor) {
    final quotes = [
      // CRISTIANOS / BIBLIA
      {
        'text': '"Todo lo puedo en Cristo que me fortalece."',
        'author': 'Filipenses 4:13',
        'saga': 'FE'
      },
      {
        'text':
            '"No temas, porque yo estoy contigo; no desmayes, porque yo soy tu Dios."',
        'author': 'Isaías 41:10',
        'saga': 'FE'
      },
      {
        'text': '"El Señor es mi pastor; nada me faltará."',
        'author': 'Salmo 23:1',
        'saga': 'FE'
      },
      {
        'text':
            '"Esforzaos y cobrad ánimo; no temáis, ni tengáis miedo de ellos, porque Jehová tu Dios es el que va contigo; no te dejará, ni te desamparará."',
        'author': 'Deuteronomio 31:6',
        'saga': 'FE'
      },
      {
        'text':
            '"Dios es amor; y el que permanece en amor, permanece en Dios, y Dios en él."',
        'author': '1 Juan 4:16',
        'saga': 'FE'
      },
      {
        'text':
            '"Dios es fiel; él no permitirá que seáis tentados más allá de lo que podéis soportar, sino que os proporcionará también la salida para que podáis resistirlo."',
        'author': '1 Corintios 10:13',
        'saga': 'FE'
      },
      {
        'text': '"Dios es el refugio de los que confían en él."',
        'author': 'Salmo 91:2',
        'saga': 'FE'
      },
      {
        'text':
            '"¡Mira que te mando que te esfuerces y seas valiente; no temas ni desmayes, porque Jehová tu Dios estará contigo en dondequiera que vayas."',
        'author': 'Josué 1:9',
        'saga': 'FE'
      },
      {
        'text':
            '"Pero los que esperan a Jehová tendrán nuevas fuerzas; levantarán alas como las águilas; correrán, y no se cansarán; caminarán, y no se fatigarán."',
        'author': 'Isaías 40:31',
        'saga': 'FE'
      },
      {
        'text':
            '"Porque no nos ha dado Dios espíritu de cobardía, sino de poder, de amor y de dominio propio."',
        'author': '2 Timoteo 1:7',
        'saga': 'FE'
      },
      {
        'text':
            '"Echa sobre Jehová tu carga, y él te sustentará; no dejará para siempre caído al justo."',
        'author': 'Salmo 55:22',
        'saga': 'FE'
      },
      {
        'text':
            '"Mas buscad primeramente el reino de Dios y su justicia, y todas estas cosas os serán añadidas."',
        'author': 'Mateo 6:33',
        'saga': 'FE'
      },
      {
        'text':
            '"Confía en Jehová con todo tu corazón, y no te apoyes en tu propia prudencia. Reconócelo en todos tus caminos, y él enderezará tus veredas."',
        'author': 'Proverbios 3:5-6',
        'saga': 'FE'
      },
      {
        'text':
            '"Clama a mí, y yo te responderé, y te enseñaré cosas grandes y ocultas que tú no conoces."',
        'author': 'Jeremías 33:3',
        'saga': 'FE'
      },
      {
        'text':
            '"Jehová es mi fortaleza y mi escudo; en él confió mi corazón, y fui ayudado."',
        'author': 'Salmo 28:7',
        'saga': 'FE'
      },
      {
        'text':
            '"Por nada estéis afanosos, sino sean conocidas vuestras peticiones delante de Dios en toda oración y ruego, con acción de gracias."',
        'author': 'Filipenses 4:6',
        'saga': 'FE'
      },
      // MARVEL
      {
        'text': '"Un gran poder conlleva una gran responsabilidad."',
        'author': 'Peter Parker',
        'saga': 'MARVEL'
      },
      {'text': '"Yo soy Iron Man."', 'author': 'Tony Stark', 'saga': 'MARVEL'},
      {
        'text': '"Puedo hacer esto todo el día."',
        'author': 'Steve Rogers',
        'saga': 'MARVEL'
      },
      {
        'text': 'No desperdicies tu vida.',
        'author': 'Ho Yinsen',
        'saga': 'MARVEL'
      },
      {
        'text':
            'El precio de la libertad es alto, siempre lo ha sido. Y es un precio que estoy dispuesto a pagar.',
        'author': 'Steve Rogers',
        'saga': 'MARVEL'
      },
      {
        'text':
            'No importa lo que el mundo diga, tú quédate ahí como un árbol y dile al mundo: "No, muévete tú".',
        'author': 'Steve Rogers',
        'saga': 'MARVEL'
      },
      {
        'text':
            'Si alguien necesita ayuda y tú puedes brindarla, tienes la obligación de hacerlo.',
        'author': 'Peter Parker',
        'saga': 'MARVEL'
      },
      {
        'text':
            'Pase lo que pase mañana, prométame algo: que seguirá siendo un buen hombre.',
        'author': 'Dr. Abraham Erskine',
        'saga': 'MARVEL'
      },
      {
        'text':
            'No importa cuántas veces me golpeen, siempre encuentro la manera de volver a levantarme.',
        'author': 'Peter Parker',
        'saga': 'MARVEL'
      },
      {
        'text':
            'Cualquiera puede ponerse la máscara. Lo que importa es cómo la usas.',
        'author': 'Miles Morales',
        'saga': 'MARVEL'
      },
      {
        'text': 'Es solo eso Miles... un salto de fe.',
        'author': 'Peter B. Parker',
        'saga': 'MARVEL'
      },
      // STAR WARS
      {
        'text': '"Que la Fuerza te acompañe."',
        'author': 'Obi-Wan Kenobi',
        'saga': 'STAR WARS'
      },
      {
        'text': '"Hazlo o no lo hagas, pero no lo intentes."',
        'author': 'Yoda',
        'saga': 'STAR WARS'
      },
      {
        'text': 'En mi experiencia, la suerte no existe.',
        'author': 'Obi-Wan Kenobi',
        'saga': 'STAR WARS'
      },
      {
        'text':
            'Si sacrificamos nuestro código, incluso por la victoria, podemos perder lo que es más importante: nuestro honor.',
        'author': 'Obi-Wan Kenobi',
        'saga': 'STAR WARS'
      },
      // DC
      {
        'text': '"Son tus actos los que te definen."',
        'author': 'Bruce Wayne',
        'saga': 'DC'
      },
      {
        'text': '¿Por qué nos caemos? Para aprender a levantarnos',
        'author': 'Alfred Pennyworth',
        'saga': 'DC'
      },
      {
        'text':
            'Los sueños nos salvan. Los sueños nos levantan y nos transforman.',
        'author': 'Superman',
        'saga': 'DC'
      },
      {
        'text':
            'Tu historia también es parte de la historia de otras personas.',
        'author': 'Superman',
        'saga': 'DC'
      },
      {
        'text':
            'Soy tan humano como cualquiera. Amo, tengo miedo. Me despierto cada mañana e intento tomar las mejores decisiones que puedo. Esa es mi mayor fortaleza.',
        'author': 'Superman',
        'saga': 'DC'
      },
      {
        'text':
            'Tus decisiones, Clark... tus actos... son lo que te convierte en el hombre que eres.',
        'author': 'Jonathan Kent',
        'saga': 'DC'
      },
      // ANIME
      {
        'text':
            '"No te rindas, no hay vergüenza en caer. La verdadera vergüenza es no volver a levantarse."',
        'author': 'Goku',
        'saga': 'ANIME'
      },
      {
        'text': '"El límite es solo una ilusión."',
        'author': 'Vegeta',
        'saga': 'ANIME'
      },
      {
        'text':
            'La vida es como un libro. Si no puedes escribir tu propio final, al menos escribe un buen capítulo.',
        'author': 'Satoru Gojo',
        'saga': 'Jujutsu Kaisen'
      },
      {
        'text':
            'No sé cómo me sentiré al morir, ¡pero no quiero arrepentirme de cómo viví!',
        'author': 'Yuji Itadori',
        'saga': 'Jujutsu Kaisen'
      },
      {
        'text':
            'No importa lo débil o indigno que te sientas, ¡mantén tu corazón ardiendo, aprieta los dientes y sigue adelante!',
        'author': 'Kyojuro Rengoku',
        'saga': 'Demon Slayer'
      },
      {
        'text':
            'Escucha cuidadosamente, Thorfinn: No tienes enemigos. Nadie tiene enemigos. No existe nadie a quien esté bien lastimar.',
        'author': 'Thors Snorresson',
        'saga': 'Vinland Saga'
      },
      {
        'text': 'Un verdadero guerrero no necesita una espada.',
        'author': 'Thors Snorresson',
        'saga': 'Vinland Saga'
      },
      {
        'text':
            'Si estás vacío, tienes espacio para meter cualquier cosa. Si quieres empezar una nueva vida, es mejor estar vacío.',
        'author': 'Einar',
        'saga': 'Vinland Saga'
      },
      {
        'text':
            'La verdadera victoria no es matar a todos tus enemigos, es alcanzar la paz con ellos.',
        'author': 'Thorfinn',
        'saga': 'Vinland Saga'
      },
    ];

    final random = Random();
    final quote = quotes[random.nextInt(quotes.length)];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: primaryColor.withOpacity(0.6),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                quote['saga'] ?? 'MOTIVACIÓN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${quote['text'] ?? ''}"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '- ${quote['author'] ?? ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterStatsCard(
      WaterProvider water, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HIDRATACIÓN TÁCTICA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : AppTheme.textGrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${water.todayIntake}/${water.dailyGoal} vasos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (water.currentStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${water.currentStreak} días',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: water.progressPercent,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                water.isGoalCompleted ? Colors.green : Colors.blue.shade600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso: ${(water.progressPercent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : AppTheme.textGrey,
                ),
              ),
              if (water.isGoalCompleted)
                Text(
                  '¡Meta alcanzada!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                )
              else
                Text(
                  '${water.remainingGlasses} vasos restantes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppTheme.textGrey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStatsCard(NutritionProvider nutrition, bool isDark, Color primaryColor) {
    if (nutrition.profile == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text('Perfil nutricional no configurado', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final targets = nutrition.targetMacros;
    final calProgress = (nutrition.totalCalories / nutrition.targetCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CALORÍAS HOY', style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${nutrition.totalCalories} / ${nutrition.targetCalories.toInt()} kcal', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              CircularProgressIndicator(
                value: calProgress,
                backgroundColor: primaryColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(calProgress >= 1.0 ? Colors.green : primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCompactMacroRow('PROTEÍNA', nutrition.totalProtein, targets['protein']!, Colors.redAccent, isDark),
          const SizedBox(height: 12),
          _buildCompactMacroRow('CARBS', nutrition.totalCarbs, targets['carbs']!, Colors.orangeAccent, isDark),
          const SizedBox(height: 12),
          _buildCompactMacroRow('GRASAS', nutrition.totalFat, targets['fat']!, Colors.blueAccent, isDark),
        ],
      ),
    );
  }

  Widget _buildCompactMacroRow(String label, double current, double target, Color color, bool isDark) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text('${current.toInt()}g / ${target.toInt()}g', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
