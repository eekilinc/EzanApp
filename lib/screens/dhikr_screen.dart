import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  int _count = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;

  final List<Map<String, String>> _dhikrList = [
    {
      'name_tr': 'Subhanallah',
      'name_en': 'Subhanallah',
      'arabic': 'سُبْحَانَ اللَّهِ',
      'meaning_tr': 'Allah eksikliklerden münezzehtir',
      'meaning_en': 'Glory be to Allah',
    },
    {
      'name_tr': 'Elhamdülillah',
      'name_en': 'Alhamdulillah',
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'meaning_tr': 'Hamd Allah\'a mahsustur',
      'meaning_en': 'Praise be to Allah',
    },
    {
      'name_tr': 'Allahu Ekber',
      'name_en': 'Allahu Akbar',
      'arabic': 'اللَّهُ أَكْبَرُ',
      'meaning_tr': 'Allah en büyüktür',
      'meaning_en': 'Allah is the Greatest',
    },
    {
      'name_tr': 'Estağfirullah',
      'name_en': 'Astaghfirullah',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'meaning_tr': 'Allah\'tan bağışlanma dilerim',
      'meaning_en': 'I seek forgiveness from Allah',
    },
    {
      'name_tr': 'La İlahe İllallah',
      'name_en': 'La ilaha illallah',
      'arabic': 'لَا إِلٰهَ إِلَّا اللَّهُ',
      'meaning_tr': 'Allah\'tan başka ilah yoktur',
      'meaning_en': 'There is no god but Allah',
    },
    {
      'name_tr': 'Salavat-ı Şerife',
      'name_en': 'Salawat',
      'arabic': 'اللَّهُمَّ صَلِّ عَلَىٰ سَيِّدِنَا مُحَمَّدٍ',
      'meaning_tr': 'Allah\'ım Efendimiz Muhammed\'e salat eyle',
      'meaning_en': 'O Allah, send blessings upon Master Muhammad',
    },
  ];

  void _incrementCount() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      if (_target > 0 && _count == _target) {
        HapticFeedback.vibrate();
      }
    });
  }

  void _resetCount() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isEn = settingsProvider.appLanguage == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = settingsProvider.primaryColor;
    final currentDhikr = _dhikrList[_selectedDhikrIndex];

    final isTargetReached = _target > 0 && _count >= _target;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Dhikr Counter 📿' : 'Zikirmatik 📿'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isEn ? 'Reset' : 'Sıfırla',
            onPressed: _resetCount,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.teal.shade900,
                    Colors.green.shade900,
                    const Color(0xFF0F1210),
                  ]
                : [
                    primaryColor.withValues(alpha: 0.15),
                    primaryColor.withValues(alpha: 0.05),
                    Colors.grey.shade50,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Dhikr Selector Dropdown Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: isDark ? 0 : 2,
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? Colors.teal.shade300.withValues(alpha: 0.3)
                          : primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedDhikrIndex,
                        dropdownColor: isDark ? Colors.teal.shade900 : Colors.white,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.amber : primaryColor),
                        items: List.generate(_dhikrList.length, (index) {
                          final item = _dhikrList[index];
                          final name = isEn ? item['name_en'] : item['name_tr'];
                          return DropdownMenuItem(
                            value: index,
                            child: Text(
                              '$name  (${item['arabic']})',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDhikrIndex = val;
                              _count = 0;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Arabic Text & Meaning Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.amber.withValues(alpha: 0.4) : primaryColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Text(
                      currentDhikr['arabic'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        color: isDark ? Colors.amber : primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEn ? (currentDhikr['meaning_en'] ?? '') : (currentDhikr['meaning_tr'] ?? ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Target Selector Chips (Fixed high contrast for light and dark theme)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [33, 99, 100, 0].map((targetVal) {
                  final isSelected = _target == targetVal;
                  final label = targetVal == 0 ? (isEn ? 'Free' : 'Serbest') : '$targetVal';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade200,
                      selectedColor: isDark ? Colors.amber.shade700 : primaryColor,
                      side: BorderSide(
                        color: isSelected
                            ? (isDark ? Colors.amber.shade300 : primaryColor)
                            : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _target = targetVal;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Main Interactive Counter Button (Vibrant high contrast in both themes)
              GestureDetector(
                onTap: _incrementCount,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isTargetReached
                          ? [Colors.amber.shade600, Colors.orange.shade800]
                          : (isDark
                              ? [Colors.teal.shade500, Colors.teal.shade900]
                              : [primaryColor, settingsProvider.primaryMaterialColor.shade800]),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isTargetReached
                            ? Colors.amber.withValues(alpha: 0.6)
                            : primaryColor.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                      color: isTargetReached ? Colors.white : Colors.amber.shade400,
                      width: 4,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_count',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      if (_target > 0)
                        Text(
                          '/ $_target',
                          style: TextStyle(
                            fontSize: 16,
                            color: isTargetReached ? Colors.black87 : Colors.amber.shade200,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        isTargetReached
                            ? (isEn ? 'Completed! 🎉' : 'Tamamlandı! 🎉')
                            : (isEn ? 'TAP TO COUNT' : 'DOKUN VE SAY'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isTargetReached ? Colors.black : Colors.amber.shade100,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
