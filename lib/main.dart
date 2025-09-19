import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // Expanded demo float set around India
  static List<_FloatInfo> _demoFloats() => [
        // Arabian Sea / West coast
        _FloatInfo(id: 'ID-1101', point: LatLng(15.5, 70.0), region: 'Arabian Sea', sensors: 'T, S, O₂, Chl-a', lastProfileUtc: '2025-08-15 03:30', distanceKm: 12),
        _FloatInfo(id: 'ID-1102', point: LatLng(18.0, 69.0), region: 'Arabian Sea', sensors: 'T, S', lastProfileUtc: '2025-08-14 10:05', distanceKm: 28),
        _FloatInfo(id: 'ID-1103', point: LatLng(12.0, 73.0), region: 'Laccadive Sea', sensors: 'T, S, O₂', lastProfileUtc: '2025-08-12 22:18', distanceKm: 35),
        _FloatInfo(id: 'ID-1104', point: LatLng(9.8, 75.0), region: 'Laccadive Sea', sensors: 'T, S, Chl-a', lastProfileUtc: '2025-08-11 07:40', distanceKm: 41),

        // Bay of Bengal / East coast
        _FloatInfo(id: 'ID-1201', point: LatLng(15.0, 84.0), region: 'Bay of Bengal', sensors: 'T, S, O₂', lastProfileUtc: '2025-08-13 05:55', distanceKm: 22),
        _FloatInfo(id: 'ID-1202', point: LatLng(18.5, 86.0), region: 'Bay of Bengal', sensors: 'T, S', lastProfileUtc: '2025-08-10 18:10', distanceKm: 48),
        _FloatInfo(id: 'ID-1203', point: LatLng(12.8, 82.5), region: 'Bay of Bengal', sensors: 'T, S, Chl-a', lastProfileUtc: '2025-08-09 09:32', distanceKm: 52),

        // Andaman Sea
        _FloatInfo(id: 'ID-1301', point: LatLng(11.8, 92.8), region: 'Andaman Sea', sensors: 'T, S, O₂, Chl-a', lastProfileUtc: '2025-08-08 03:12', distanceKm: 37),
        _FloatInfo(id: 'ID-1302', point: LatLng(9.5, 94.0), region: 'Andaman Sea', sensors: 'T, S', lastProfileUtc: '2025-08-07 12:22', distanceKm: 44),

        // Equatorial Indian Ocean
        _FloatInfo(id: 'ID-1401', point: LatLng(0.5, 78.0), region: 'Equatorial Indian Ocean', sensors: 'T, S, O₂', lastProfileUtc: '2025-08-06 20:41', distanceKm: 60),
        _FloatInfo(id: 'ID-1402', point: LatLng(-2.0, 80.5), region: 'Equatorial Indian Ocean', sensors: 'T, S, Chl-a', lastProfileUtc: '2025-08-05 14:05', distanceKm: 72),

        // Arabian Sea (NW)
        _FloatInfo(id: 'ID-1501', point: LatLng(20.0, 66.5), region: 'NE Arabian Sea', sensors: 'T, S', lastProfileUtc: '2025-08-04 04:40', distanceKm: 55),
        _FloatInfo(id: 'ID-1502', point: LatLng(22.0, 64.0), region: 'NE Arabian Sea', sensors: 'T, S, O₂', lastProfileUtc: '2025-08-03 16:20', distanceKm: 78),
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Center on Indian region
    final center = LatLng(13.0, 79.0);
    final floats = _demoFloats();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Icon(Icons.public, color: cs.primary),
          const SizedBox(width: 8),
          const Text('Explore Map'),
        ]),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 4.7,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.argolens.floatchat', // ← set to your real applicationId
          ),
          MarkerLayer(
            markers: [
              for (final f in floats)
                Marker(
                  width: 44,
                  height: 44,
                  point: f.point,
                  child: GestureDetector(
                    onTap: () => _showFloatDetails(context, f),
                    child: const _FloatMarker(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Open details sheet
  static Future<void> _showFloatDetails(BuildContext context, _FloatInfo f) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FloatDetailsSheet(f: f),
    );
  }
}

// --------------------
// Details Sheet Widget
// --------------------
class _FloatDetailsSheet extends StatefulWidget {
  final _FloatInfo f;
  const _FloatDetailsSheet({required this.f});

  @override
  State<_FloatDetailsSheet> createState() => _FloatDetailsSheetState();
}

class _FloatDetailsSheetState extends State<_FloatDetailsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350))
        ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, .06), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic))
          .animate(_anim);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f = widget.f;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.48,
      minChildSize: 0.32,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: cs.primary.withOpacity(0.15),
                        child: Icon(Icons.sailing, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(f.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('${f.distanceKm} km',
                            style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Meta
                  _kv('Region', f.region, cs),
                  _kv('Sensors', f.sensors, cs),
                  _kv('Last profile (UTC)', f.lastProfileUtc, cs),
                  const SizedBox(height: 12),

                  // Mini synthetic profile preview (reuses your painter)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 120,
                      child: CustomPaint(painter: _MiniProfileChart()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // 👉 Navigate to the Profiles page
                            Navigator.of(context).pop();
                            Navigator.of(context).push(_OceanRoute(const ProfilesScreen()));
                          },
                          icon: const Icon(Icons.show_chart),
                          label: const Text('Open Profiles'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Downloading ${f.id} CSV (demo)…')),
                            );
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('CSV'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _kv(String k, String v, ColorScheme cs) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(width: 160, child: Text(k, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
        Expanded(child: Text(v)),
      ],
    ),
  );
}

// --------------------
// Marker + Data models
// --------------------
class _FloatInfo {
  final String id;
  final LatLng point;
  final String region;
  final String sensors;
  final String lastProfileUtc;
  final int distanceKm;
  _FloatInfo({
    required this.id,
    required this.point,
    required this.region,
    required this.sensors,
    required this.lastProfileUtc,
    required this.distanceKm,
  });
}

class _FloatMarker extends StatelessWidget {
  const _FloatMarker();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              )
            ],
          ),
        ),
      ],
    );
  }
}
// Your existing marker widget (kept as-is)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'FloatChat',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF2A73FF), // accent blue
                  brightness: Brightness.light,
                  primary: const Color(0xFF2A73FF),
                  background: const Color(0xFFF5F6FA),
                  surface: const Color(0xFFFFFFFF),
                  onSurface: const Color(0xFF1B1F2A),
                ),
                scaffoldBackgroundColor: const Color(0xFFF5F6FA),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFFFFFFFF),
                  foregroundColor: Color(0xFF1B1F2A),
                  elevation: 0,
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                fontFamily: 'Roboto',
              ),

              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF2A73FF), // accent blue
                  brightness: Brightness.dark,
                  primary: const Color(0xFF2A73FF),
                  background: const Color(0xFF121212),   // page bg
                  surface: const Color(0xFF1E1E2F),      // panel/card bg (matches your screenshot)
                  onSurface: const Color(0xFFE6E8EF),
                  surfaceContainerHighest: const Color(0xFF24243A), // richer panels your code uses
                  surfaceContainerHigh: const Color(0xFF22223A),
                  surfaceContainer: const Color(0xFF1F1F33),
                  outlineVariant: const Color(0xFF3A3A55),
                ),
                scaffoldBackgroundColor: const Color(0xFF121212),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1E1E2F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                fontFamily: 'Roboto',
              ),

          home: HomeScreen(onToggleTheme: () {
            _themeMode.value =
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          }, themeMode: mode),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const HomeScreen({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _titleCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _titleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(_OceanRoute(page));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          OceanBackground(controller: _bgCtrl),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _titleCtrl,
                          builder: (context, _) {
                            final t = Curves.easeOutExpo.transform(_titleCtrl.value);
                            return Transform.translate(
                              offset: Offset(0, (1 - t) * -20),
                              child: Opacity(
                                opacity: t,
                                child: const Text(
                                  'FloatChat',
                                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Toggle theme',
                        onPressed: widget.onToggleTheme,
                        icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.wb_sunny_outlined : Icons.nightlight_round),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Field-first, alert-first companion for ARGO insights',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.98,
                      ),
                      children: [
                        // ⬇️ ADD this as the first tile in the GridView children list
                        AnimatedMenuButton(
                          label: 'Chat',
                          icon: Icons.chat_bubble_outline_rounded,
                          gradient: [cs.primary, cs.secondary],
                          subtitle: 'Ask anything',
                          onTap: () => _open(const ChatScreen()),
                          heroTag: 'chat',
                        ),

                        AnimatedMenuButton(
                          label: 'Explore Map',
                          icon: Icons.public,
                          gradient: [cs.primary, cs.tertiary],
                          subtitle: 'Pan & tap floats',
                          onTap: () => _open(const MapScreen()),
                          heroTag: 'map',
                        ),
                        AnimatedMenuButton(
                          label: 'Nearby Floats',
                          icon: Icons.my_location,
                          gradient: [cs.secondary, cs.primary],
                          subtitle: 'Based on your GPS',
                          onTap: () => _open(const NearbyScreen()),
                          heroTag: 'nearby',
                        ),
                        AnimatedMenuButton(
                          label: 'Alerts',
                          icon: Icons.notifications_active_outlined,
                          gradient: [cs.error, cs.primary],
                          subtitle: 'Anomalies & updates',
                          onTap: () => _open(const AlertsScreen()),
                          heroTag: 'alerts',
                        ),
                        AnimatedMenuButton(
                          label: 'Profiles',
                          icon: Icons.show_chart,
                          gradient: [cs.primaryContainer, cs.secondaryContainer],
                          subtitle: 'Depth–time views',
                          onTap: () => _open(const ProfilesScreen()),
                          heroTag: 'profiles',
                        ),
                        AnimatedMenuButton(
                          label: 'Downloads',
                          icon: Icons.download_rounded,
                          gradient: [cs.surfaceTint, cs.tertiaryContainer],
                          subtitle: 'NetCDF & CSV',
                          onTap: () => _open(const DownloadsScreen()),
                          heroTag: 'downloads',
                        ),
                        AnimatedMenuButton(
                          label: 'Settings',
                          icon: Icons.settings_suggest_rounded,
                          gradient: [cs.outlineVariant, cs.primary],
                          subtitle: 'Theme & cache',
                          onTap: () => _open(const SettingsScreen()),
                          heroTag: 'settings',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedMenuButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final String heroTag;
  const AnimatedMenuButton({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.heroTag,
  });

  @override
  State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<AnimatedMenuButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _pressCtrl.forward();
  void _onTapUp(_) => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final press = Tween<double>(begin: 0, end: 1).animate(_pressCtrl);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedBuilder(
          animation: press,
          builder: (_, __) {
            final p = press.value;
            final scale = 1 - (p * 0.03) + (_hovering ? 0.01 : 0.0);
            final tilt = (p * 0.02) * math.pi;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(tilt)
                ..scale(scale),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.gradient.first.withOpacity(0.85),
                      widget.gradient.last.withOpacity(0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(widget.icon, size: 120, color: cs.onPrimary),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'icon-${widget.heroTag}',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(widget.icon, size: 28, color: cs.onPrimary),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.label,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OceanBackground extends StatelessWidget {
  final AnimationController controller;
  const OceanBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return CustomPaint(
          painter: _OceanPainter(t: t, colorScheme: cs),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _OceanPainter extends CustomPainter {
  final double t;
  final ColorScheme colorScheme;
  _OceanPainter({required this.t, required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    // Animated gradient background
    final rect = Offset.zero & size;
    final c1 = Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.4)!;
    final c2 = Color.lerp(colorScheme.surface, colorScheme.secondaryContainer, 0.7)!;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        c1.withOpacity(0.25 + 0.15 * math.sin(2 * math.pi * t)),
        c2.withOpacity(0.6),
      ],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Waves
    _drawWave(canvas, size, phase: t * 2 * math.pi, amplitude: 12, yOffset: size.height * 0.78, color: colorScheme.primary.withOpacity(0.20));
    _drawWave(canvas, size, phase: t * 2 * math.pi + math.pi / 2, amplitude: 16, yOffset: size.height * 0.82, color: colorScheme.primary.withOpacity(0.16));
    _drawWave(canvas, size, phase: t * 2 * math.pi + math.pi, amplitude: 22, yOffset: size.height * 0.86, color: colorScheme.tertiary.withOpacity(0.14));
  }

  void _drawWave(Canvas canvas, Size size, {required double phase, required double amplitude, required double yOffset, required Color color}) {
    final path = Path()..moveTo(0, yOffset);
    const waveLen = 220.0;
    for (double x = 0; x <= size.width + 10; x += 10) {
      final y = yOffset + math.sin((x / waveLen * 2 * math.pi) + phase) * amplitude;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OceanPainter oldDelegate) => oldDelegate.t != t || oldDelegate.colorScheme != colorScheme;
}

class _OceanRoute extends PageRouteBuilder {
  _OceanRoute(Widget page)
      : super(
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondary, child) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            final slide = Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}


class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Hero(tag: 'icon-nearby', child: Icon(Icons.my_location, color: cs.primary)),
          const SizedBox(width: 8),
          const Text('Nearby Floats'),
        ]),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final distKm = (i + 1) * 12 + 5;
          final id = 'ID-${1000 + i}';
          return _FloatTile(id: id, distKm: distKm);
        },
      ),
    );
  }
}

class _FloatTile extends StatefulWidget {
  final String id;
  final int distKm;
  const _FloatTile({required this.id, required this.distKm});

  @override
  State<_FloatTile> createState() => _FloatTileState();
}

class _FloatTileState extends State<_FloatTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sailing, color: cs.primary),
                  const SizedBox(width: 10),
                  Text(widget.id, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('${widget.distKm} km', style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12)),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                firstChild: const SizedBox(height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv('Last profile', '2025-08-15 03:30 UTC'),
                      _kv('Region', 'Arabian Sea'),
                      _kv('Sensors', 'T, S, O₂, Chl-a'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 100,
                          child: CustomPaint(painter: _MiniProfileChart()),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(width: 110, child: Text(k, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text(v)),
        ]),
      );
}

class _MiniProfileChart extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black12;
    final line = Paint()
      ..color = Colors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i <= 30; i++) {
      final x = i / 30 * size.width;
      final y = size.height * (0.15 + 0.7 * math.pow(i / 30, 0.8) * (1 + 0.2 * math.sin(i / 3)) / 1.2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)), bg);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Hero(tag: 'icon-alerts', child: Icon(Icons.notifications_active_outlined, color: cs.primary)),
          const SizedBox(width: 8),
          const Text('Alerts'),
        ]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune))
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, i) {
          final kind = i % 3;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AlertCard(
              title: kind == 0 ? 'Chl-a spike' : kind == 1 ? 'Low O₂ event' : 'Warm surface layer',
              subtitle: 'Region • Arabian Sea  • Float ID-${1100 + i}',
              severity: kind,
            ),
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final int severity; // 0,1,2
  const _AlertCard({required this.title, required this.subtitle, required this.severity});

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.severity == 0
        ? Colors.deepOrangeAccent     // mid severity
        : widget.severity == 1
            ? Colors.redAccent        // high severity
            : Colors.amberAccent;     // low severity / info
    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(Icons.warning_amber_rounded, color: color)),
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(widget.subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
        ),
      ),
    );
  }
}

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Hero(tag: 'icon-profiles', child: Icon(Icons.show_chart, color: cs.primary)),
          const SizedBox(width: 8),
          const Text('Profiles'),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(child: _Pill(text: 'Temperature (°C)')),
                SizedBox(width: 8),
                Expanded(child: _Pill(text: 'Salinity (PSU)')),
                SizedBox(width: 8),
                Expanded(child: _Pill(text: 'Oxygen (ml/l)')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: cs.surfaceContainerHighest,
                  child: CustomPaint(
                    painter: _DepthTimePainter(),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Demo depth–time heatmap (synthetic data)', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Center(child: Text(text, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600))),
    );
  }
}

class _DepthTimePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw a simple heatmap grid (depth vs time) with synthetic values
    const cols = 24; // time steps
    const rows = 20; // depth bins
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final t = c / (cols - 1);
        final d = r / (rows - 1);
        final value = (math.sin(t * 2 * math.pi) * 0.5 + 0.5) * (1 - d * 0.8);
        final color = HSVColor.lerp(
          const HSVColor.fromAHSV(1, 210, 0.6, 0.95),
          const HSVColor.fromAHSV(1, 10, 0.8, 0.9),
          value,
        )!
            .toColor()
            .withOpacity(0.95);
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW + 0.5, cellH + 0.5);
        final paint = Paint()..color = color;
        canvas.drawRect(rect, paint);
      }
    }

    // Axes labels
    final tp1 = TextPainter(text: const TextSpan(text: 'Time →', style: TextStyle(fontSize: 12, color: Colors.white)), textDirection: TextDirection.ltr)..layout();
    tp1.paint(canvas, Offset(size.width - tp1.width - 8, size.height - tp1.height - 4));

    final tp2 = TextPainter(text: const TextSpan(text: 'Depth ↓', style: TextStyle(fontSize: 12, color: Colors.white)), textDirection: TextDirection.ltr)..layout();
    tp2.paint(canvas, const Offset(8, 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});
  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _netcdf = true;
  bool _csv = false;
  bool _geojson = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Hero(tag: 'icon-downloads', child: Icon(Icons.download_rounded, color: cs.primary)),
          const SizedBox(width: 8),
          const Text('Downloads'),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _netcdf,
              title: const Text('NetCDF profiles'),
              onChanged: (v) => setState(() => _netcdf = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _csv,
              title: const Text('CSV summaries'),
              onChanged: (v) => setState(() => _csv = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _geojson,
              title: const Text('GeoJSON tracks'),
              onChanged: (v) => setState(() => _geojson = v),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                final snack = SnackBar(content: Text('Queued downloads: '
                    '${_netcdf ? 'NetCDF ' : ''}'
                    '${_csv ? 'CSV ' : ''}'
                    '${_geojson ? 'GeoJSON' : ''}'.trim()));
                ScaffoldMessenger.of(context).showSnackBar(snack);
              },
              icon: const Icon(Icons.cloud_download),
              label: const Text('Simulate Download'),
            ),
            const SizedBox(height: 24),
            Text('Note: This PoC is offline-only—no network or storage access used.', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  double _cacheMb = 256;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Hero(tag: 'icon-settings', child: Icon(Icons.settings_suggest_rounded, color: cs.primary)),
          const SizedBox(width: 8),
          const Text('Settings'),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const _ThemeHint(),
          const SizedBox(height: 16),
          const Text('Cache', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _cacheMb,
                  min: 64,
                  max: 1024,
                  divisions: 15,
                  label: '${_cacheMb.round()} MB',
                  onChanged: (v) => setState(() => _cacheMb = v),
                ),
              ),
              SizedBox(
                width: 90,
                child: Text('${_cacheMb.round()} MB', textAlign: TextAlign.end),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
            title: const Text('Enable push alerts'),
            subtitle: const Text('New profiles near you, anomalies, cyclone watch'),
          ),
        ],
      ),
    );
  }
}

class _ThemeHint extends StatefulWidget {
  const _ThemeHint();
  @override
  State<_ThemeHint> createState() => _ThemeHintState();
}

class _ThemeHintState extends State<_ThemeHint> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat(reverse: true);
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [cs.primaryContainer.withOpacity(0.6), cs.secondaryContainer.withOpacity(0.6)]),
          ),
          child: Row(
            children: [
              Transform.rotate(
                angle: (t - 0.5) * 0.2,
                child: const Icon(Icons.touch_app_rounded),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Tip: Use the sun/moon button on the home screen to toggle light/dark theme.'),
              )
            ],
          ),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final Widget? attachment; // optional widget (e.g., mini chart or action chip)
  ChatMessage(this.text, {this.isUser = false, this.attachment});
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage('Hi! I can answer ocean data questions. Try: "nearest floats to Kochi", "salinity near equator Mar 2023", or "compare BGC Arabian Sea".'),
  ];
  final TextEditingController _ctrl = TextEditingController();
  bool _botTyping = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text.trim(), isUser: true));
      _ctrl.clear();
      _botTyping = true;
    });
    Future.delayed(const Duration(milliseconds: 450), () => _reply(text.trim()));
  }

  void _reply(String userText) {
    final lower = userText.toLowerCase();
    final out = <ChatMessage>[];

    // 30 demo intents — text + optional attachments (actions/preview)
    if (lower.contains('nearest') || lower.contains('nearby')) {
      out.add(ChatMessage('Here are the 3 nearest demo floats: ID-1101 (12 km), ID-1107 (26 km), ID-1112 (34 km).'));
      out.add(ChatMessage('Open the map to view markers?', attachment: _QuickAction(
        label: 'Open Map',
        icon: Icons.public,
        onTap: () => Navigator.of(context).push(_OceanRoute(const MapScreen())),
      )));
    } else if ((lower.contains('salinity') && lower.contains('equator')) || lower.contains('psu')) {
      out.add(ChatMessage('Salinity near the equator (Mar 2023 • demo): median ≈ 34.7 PSU; stable mixed layer.'));
      out.add(ChatMessage('Here’s a tiny synthetic profile preview:', attachment:
        SizedBox(height: 120, child: CustomPaint(painter: _MiniProfileChart()))));
    } else if (lower.contains('compare') && (lower.contains('bgc') || lower.contains('bio') || lower.contains('biogeochem'))) {
      out.add(ChatMessage('Demo BGC comparison (Arabian Sea • last 6 months): O₂ slightly declining; Chl-a bump in May–Jun.'));
      out.add(ChatMessage('Export a CSV summary?', attachment: _QuickAction(
        label: 'Simulate CSV',
        icon: Icons.download_rounded,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV download queued (demo)'))),
      )));
    } else if (lower.contains('temperature') && lower.contains('arabian')) {
      out.add(ChatMessage('Surface temperatures in the Arabian Sea (demo) range ~27–30 °C.'));
      out.add(ChatMessage('See profiles?', attachment: _QuickAction(
        label: 'Open Profiles',
        icon: Icons.show_chart,
        onTap: () { Navigator.of(context).push(_OceanRoute(const ProfilesScreen())); },
      )));
    } else if (lower.contains('oxygen') && lower.contains('bay of bengal')) {
      out.add(ChatMessage('Low-oxygen (OMZ) signatures in Bay of Bengal (demo), strongest 200–1000 m.'));
      out.add(ChatMessage('Show alerts?', attachment: _QuickAction(
        label: 'View Alerts',
        icon: Icons.warning_amber_rounded,
        onTap: () { Navigator.of(context).push(_OceanRoute(const AlertsScreen())); },
      )));
    } else if (lower.contains('chlorophyll') || lower.contains('chl')) {
      out.add(ChatMessage('Chlorophyll peaks post-monsoon along the coasts (demo).'));
    } else if (lower.contains('how many floats') || lower.contains('count floats')) {
      out.add(ChatMessage('Demo count: ~120 active floats in the wider India region.'));
    } else if ((lower.contains('map') && lower.contains('open')) || lower == 'map') {
      out.add(ChatMessage('Opening the Explore Map…', attachment: _QuickAction(
        label: 'Open Map',
        icon: Icons.public,
        onTap: () => Navigator.of(context).push(_OceanRoute(const MapScreen())),
      )));
    } else if (lower.contains('download')) {
      out.add(ChatMessage('Supported formats (demo): NetCDF profiles, CSV summaries, GeoJSON tracks.'));
      out.add(ChatMessage('Go to Downloads?', attachment: _QuickAction(
        label: 'Open Downloads',
        icon: Icons.download_rounded,
        onTap: () { Navigator.of(context).push(_OceanRoute(const DownloadsScreen())); },
      )));
    } else if (lower.contains('alerts') || lower.contains('anomal')) {
      out.add(ChatMessage('Latest anomaly (demo): Low O₂ event in Eastern Arabian Sea.'));
      out.add(ChatMessage('Open Alerts?', attachment: _QuickAction(
        label: 'View Alerts',
        icon: Icons.notifications_active_outlined,
        onTap: () { Navigator.of(context).push(_OceanRoute(const AlertsScreen())); },
      )));
    } else if (lower.contains('profiles')) {
      out.add(ChatMessage('Profiles show depth–time heatmaps (demo).'));
      out.add(ChatMessage('Open Profiles page?', attachment: _QuickAction(
        label: 'Open Profiles',
        icon: Icons.show_chart,
        onTap: () { Navigator.of(context).push(_OceanRoute(const ProfilesScreen())); },
      )));
    } else if (lower.contains('floats near andaman') || lower.contains('andaman')) {
      out.add(ChatMessage('About 8 demo floats active in the Andaman Sea.'));
      out.add(ChatMessage('See them on the map?', attachment: _QuickAction(
        label: 'Open Map',
        icon: Icons.public,
        onTap: () => Navigator.of(context).push(_OceanRoute(const MapScreen())),
      )));
    } else if (lower.contains('satellite') || lower.contains('sst') || lower.contains('sea surface')) {
      out.add(ChatMessage('Satellite overlays (SST/Chl-a) planned for a future integration.'));
    } else if (lower.contains('currents')) {
      out.add(ChatMessage('Equatorial Indian Ocean currents (demo): predominant westward near 0–5°N.'));
    } else if (lower.contains('ph levels') || lower == 'ph') {
      out.add(ChatMessage('Average surface pH (demo): ~8.05 in recent float snapshots.'));
    } else if (lower.contains('carbon') || lower.contains('co2')) {
      out.add(ChatMessage('Carbon uptake (demo placeholder): regional estimates available in future releases.'));
    } else if (lower.contains('cyclone') || lower.contains('storm')) {
      out.add(ChatMessage('Cyclone watch (demo): Bay of Bengal — track interacts with warm SSTs.'));
      out.add(ChatMessage('Open Alerts?', attachment: _QuickAction(
        label: 'View Alerts',
        icon: Icons.warning_amber_rounded,
        onTap: () { Navigator.of(context).push(_OceanRoute(const AlertsScreen())); },
      )));
    } else if ((lower.contains('depth') && lower.contains('profiles')) || lower.contains('depth-time')) {
      out.add(ChatMessage('Thermocline around 100–200 m in recent demo composites.'));
      out.add(ChatMessage('Preview chart:', attachment:
        SizedBox(height: 120, child: CustomPaint(painter: _MiniProfileChart()))));
    } else if (lower.contains('glider')) {
      out.add(ChatMessage('Glider datasets can be added in a follow-up PoC.'));
    } else if (lower.contains('buoy')) {
      out.add(ChatMessage('Moored buoys complement ARGO — not integrated yet in this demo.'));
    } else if (lower.contains('argo') && (lower.contains('what') || lower.contains('basics') || lower.contains('explain'))) {
      out.add(ChatMessage('Argo floats are autonomous profilers measuring T/S (and sometimes BGC) roughly every 10 days.'));
    } else if (lower.contains('indian ocean dipole') || lower.contains('iod')) {
      out.add(ChatMessage('Positive IOD (demo): warming west / cooling east — affects rainfall and currents.'));
    } else if (lower.contains('enso') || lower.contains('el niño') || lower.contains('el nino') || lower.contains('la niña') || lower.contains('la nina')) {
      out.add(ChatMessage('ENSO modulates winds and SST; connections shown in future overlays (demo).'));
    } else if (lower.contains('thermocline')) {
      out.add(ChatMessage('Thermocline sharpens near ~100 m in the Arabian Sea demo set.'));
    } else if (lower.contains('monsoon')) {
      out.add(ChatMessage('SW monsoon intensifies stratification and coastal upwelling (demo).'));
    } else if (lower.contains('winds')) {
      out.add(ChatMessage('Monsoon winds drive Somali upwelling and EICC variability (demo).'));
    } else if (lower.contains('oxygen minimum zone') || lower.contains('omz')) {
      out.add(ChatMessage('OMZ: pronounced in N. Arabian Sea between ~200–1000 m (demo).'));
    } else if (lower.contains('productivity') || lower.contains('primary')) {
      out.add(ChatMessage('Primary productivity peaks in upwelling zones and during blooms (demo).'));
    } else if (lower.contains('help') || lower.contains('examples')) {
      out.add(ChatMessage(
        'Examples:\n'
        '• nearest floats to Kochi\n'
        '• salinity near equator Mar 2023\n'
        '• compare BGC Arabian Sea last 6 months\n'
        '• temperature Arabian Sea\n'
        '• oxygen Bay of Bengal\n'
        '• chlorophyll levels\n'
        '• how many floats\n'
        '• download data\n'
        '• alerts\n'
        '• profiles\n'
        '• floats near Andaman\n'
        '• satellite overlays\n'
        '• currents / pH / carbon / cyclone\n'
        '• thermocline / monsoon / winds / OMZ / productivity',
      ));
    } else {
      out.add(ChatMessage('I’m a demo bot. Try: "nearest floats", "salinity near equator Mar 2023", "compare BGC Arabian Sea", "oxygen Bay of Bengal".'));
    }

    setState(() {
      _messages.addAll(out);
      _botTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Hero(tag: 'icon-chat', child: Icon(Icons.chat_bubble_outline_rounded, color: cs.primary)),
          const SizedBox(width: 8),
          const Text('Chat'),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              itemCount: _messages.length + (_botTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_botTyping && i == _messages.length) {
                  return const _TypingBubble();
                }
                final m = _messages[i];
                return _ChatBubble(message: m);
              },
            ),
          ),
          _SuggestionBar(onTap: _send),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Ask about ARGO data…',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _send(_ctrl.text),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = isUser ? cs.onPrimaryContainer : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.text, style: TextStyle(color: fg)),
                if (message.attachment != null) ...[
                  const SizedBox(height: 8),
                  message.attachment!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(cs.primary), const SizedBox(width: 4),
            _Dot(cs.primary), const SizedBox(width: 4),
            _Dot(cs.primary),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final Color color; const _Dot(this.color);
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          width: 6 + 2 * t,
          height: 6 + 2 * t,
          decoration: BoxDecoration(color: widget.color.withOpacity(0.7 + 0.3 * t), shape: BoxShape.circle),
        );
      },
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  final void Function(String) onTap;
  const _SuggestionBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      'nearest floats to Kochi',
      'salinity near equator Mar 2023',
      'compare BGC Arabian Sea last 6 months',
      'temperature Arabian Sea',
      'oxygen Bay of Bengal',
      'chlorophyll levels',
      'how many floats',
      'download data',
      'alerts',
      'profiles',
      'floats near Andaman',
      'satellite overlays',
      'currents',
      'pH levels',
      'carbon uptake',
      'cyclone alerts',
      'depth profiles',
      'glider data',
      'buoy data',
      'Argo basics',
      'Indian Ocean Dipole',
      'ENSO / El Niño',
      'thermocline',
      'monsoon impact',
      'winds',
      'oxygen minimum zone',
      'productivity',
      'help',
      'open map',
      'OMZ details',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final s in chips) _Chip(s, onTap),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text; final void Function(String) onTap; const _Chip(this.text, this.onTap);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(text, style: TextStyle(color: cs.onSecondaryContainer)),
        ),
      ),
    );
  }
}

// Quick action button used inside bot replies
class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.onPrimaryContainer),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: cs.onPrimaryContainer)),
            ],
          ),
        ),
      ),
    );
  }
}
