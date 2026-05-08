import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/task_provider.dart';
import '../services/user_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    final tasks = taskProvider.tasks;
    final completedCount = tasks
        .where((t) => t.isCompletedForDate(taskProvider.selectedDate))
        .length;
    final successRate =
        tasks.isEmpty ? 0 : (completedCount / tasks.length * 100).toInt();

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
        'text':
            '"Pero es quien seas en el interior, son tus actos los que te definen."',
        'author': 'Bruce Wayne',
        'saga': 'DC'
      },
      {
        'text':
            '¿Por qué nos caemos? Para que podamos aprender a recuperarnos.',
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
            'Tus decisiones y tus acciones, Clark... eso es lo que te hace ser quien eres. No podría estar más orgulloso de ti.',
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
            'No mires hacia atrás. Si tienes algo que hacer, mira siempre hacia adelante.',
        'author': 'Satoru Gojo',
        'saga': 'Jujutsu Kaisen'
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            quote['author'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            quote['text'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
