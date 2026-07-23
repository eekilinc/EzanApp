import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  static final List<Map<String, dynamic>> _duaCategories = [
    {
      'title_tr': 'Sabah & Akşam Duaları',
      'title_en': 'Morning & Evening Duas',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.amber,
      'duas': [
        {
          'name_tr': 'Sabah Duası',
          'name_en': 'Morning Dua',
          'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
          'meaning_tr': 'Sabaha girdik, mülk de sabaha girdi. Hamd Allah\'a mahsustur. Allah\'tan başka ilah yoktur, O tektir, ortağı yoktur.',
          'meaning_en': 'We have entered the morning and the dominion belongs to Allah. Praise is to Allah. None has the right to be worshipped except Allah, alone, without partner.',
          'source': 'Müslim',
        },
        {
          'name_tr': 'Akşam Duası',
          'name_en': 'Evening Dua',
          'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
          'meaning_tr': 'Akşama girdik, mülk de akşama girdi. Hamd Allah\'a mahsustur. Allah\'tan başka ilah yoktur, O tektir, ortağı yoktur.',
          'meaning_en': 'We have entered the evening and the dominion belongs to Allah. Praise is to Allah. None has the right to be worshipped except Allah, alone, without partner.',
          'source': 'Müslim',
        },
        {
          'name_tr': 'Âyetel Kürsî',
          'name_en': 'Ayat al-Kursi',
          'arabic': 'اللَّهُ لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
          'meaning_tr': 'Allah, kendisinden başka hiçbir ilah olmayandır. Diridir, kayyumdur. Onu ne uyuklama tutabilir ne de uyku.',
          'meaning_en': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep.',
          'source': 'Bakara, 255',
        },
      ],
    },
    {
      'title_tr': 'Namaz Duaları',
      'title_en': 'Prayer Duas',
      'icon': Icons.mosque_rounded,
      'color': Colors.green,
      'duas': [
        {
          'name_tr': 'Sübhâneke',
          'name_en': 'Subhanaka',
          'arabic': 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَىٰ جَدُّكَ وَلَا إِلٰهَ غَيْرُكَ',
          'meaning_tr': 'Allah\'ım! Sen eksik sıfatlardan pak ve uzaksın. Seni daima hamd ile anarım. Senin adın mübarektir. Varlığın her şeyden üstündür. Senden başka ilah yoktur.',
          'meaning_en': 'Glory be to You, O Allah, and praise be to You. Blessed is Your name, and exalted is Your majesty. There is no god but You.',
          'source': 'Namaz Açılış Duası',
        },
        {
          'name_tr': 'Ettehiyyâtü',
          'name_en': 'At-Tahiyyat',
          'arabic': 'اَلتَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ اَلسَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ',
          'meaning_tr': 'Bütün tahiyyeler, bütün namazlar ve bütün güzel sözler Allah\'a aittir. Ey Peygamber! Allah\'ın selamı, rahmeti ve bereketleri senin üzerine olsun.',
          'meaning_en': 'All compliments, prayers, and pure words are due to Allah. Peace be upon you, O Prophet, and the mercy of Allah and His blessings.',
          'source': 'Teşehhüd Duası',
        },
        {
          'name_tr': 'Salli - Bârik',
          'name_en': 'Salli - Barik',
          'arabic': 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
          'meaning_tr': 'Allah\'ım! İbrahim\'e ve ailesine rahmet ettiğin gibi, Muhammed\'e ve ailesine de rahmet eyle. Şüphesiz sen övülmeye lâyık ve yücesin.',
          'meaning_en': 'O Allah, send blessings upon Muhammad and the family of Muhammad as You sent blessings upon Ibrahim and the family of Ibrahim.',
          'source': 'Salavat Duası',
        },
        {
          'name_tr': 'Rabbena Âtinâ',
          'name_en': 'Rabbana Atina',
          'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
          'meaning_tr': 'Rabbimiz! Bize dünyada iyilik ver, ahirette de iyilik ver ve bizi cehennem azabından koru.',
          'meaning_en': 'Our Lord, give us in this world that which is good and in the Hereafter that which is good and protect us from the punishment of the Fire.',
          'source': 'Bakara, 201',
        },
      ],
    },
    {
      'title_tr': 'Günlük Yaşam Duaları',
      'title_en': 'Daily Life Duas',
      'icon': Icons.favorite_rounded,
      'color': Colors.teal,
      'duas': [
        {
          'name_tr': 'Yemek Duası (Yemekten Önce)',
          'name_en': 'Before Eating',
          'arabic': 'بِسْمِ اللَّهِ وَعَلَىٰ بَرَكَةِ اللَّهِ',
          'meaning_tr': 'Allah\'ın adıyla ve Allah\'ın bereketine sığınarak.',
          'meaning_en': 'In the name of Allah and with the blessings of Allah.',
          'source': 'Ebû Dâvûd',
        },
        {
          'name_tr': 'Yemek Duası (Yemekten Sonra)',
          'name_en': 'After Eating',
          'arabic': 'اَلْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مِنَ الْمُسْلِمِينَ',
          'meaning_tr': 'Bizi yediren, içiren ve Müslümanlardan kılan Allah\'a hamd olsun.',
          'meaning_en': 'Praise be to Allah who fed us, gave us drink, and made us Muslims.',
          'source': 'Ebû Dâvûd, Tirmizî',
        },
        {
          'name_tr': 'Yolculuk Duası',
          'name_en': 'Travel Dua',
          'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ',
          'meaning_tr': 'Bunu bizim emrimize veren Allah\'ın şanı ne yücedir! Yoksa biz buna güç yetiremezdik. Şüphesiz biz Rabbimize döneceğiz.',
          'meaning_en': 'Glory to Him who has subjected this to us, and we could not have otherwise subdued it. And to our Lord we will surely return.',
          'source': 'Zuhruf, 13-14',
        },
        {
          'name_tr': 'Uyku Duası',
          'name_en': 'Before Sleep',
          'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
          'meaning_tr': 'Allah\'ım, Senin adınla ölürüm ve dirilirim.',
          'meaning_en': 'In Your name, O Allah, I die and I live.',
          'source': 'Buhârî',
        },
        {
          'name_tr': 'Eve Girerken',
          'name_en': 'Entering Home',
          'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَىٰ رَبِّنَا تَوَكَّلْنَا',
          'meaning_tr': 'Allah\'ın adıyla girdik, Allah\'ın adıyla çıktık ve Rabbimize tevekkül ettik.',
          'meaning_en': 'In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we place our trust.',
          'source': 'Ebû Dâvûd',
        },
      ],
    },
    {
      'title_tr': 'Tövbe & İstiğfar',
      'title_en': 'Repentance & Forgiveness',
      'icon': Icons.spa_rounded,
      'color': Colors.indigo,
      'duas': [
        {
          'name_tr': 'Seyyidü\'l-İstiğfar',
          'name_en': 'Master of Forgiveness',
          'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلٰهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
          'meaning_tr': 'Allah\'ım! Sen benim Rabbimsin. Senden başka ilah yoktur. Beni Sen yarattın, ben Senin kulunum ve gücüm yettiği kadar Sana olan ahdime ve vaadime bağlıyım.',
          'meaning_en': 'O Allah, You are my Lord, there is no god but You. You created me and I am Your servant, and I abide by Your covenant and promise as best I can.',
          'source': 'Buhârî',
        },
        {
          'name_tr': 'İstiğfar',
          'name_en': 'Seeking Forgiveness',
          'arabic': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلٰهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
          'meaning_tr': 'Kendisinden başka ilah olmayan, diri ve kayyum olan yüce Allah\'tan mağfiret dilerim ve O\'na tövbe ederim.',
          'meaning_en': 'I seek forgiveness from Allah, the Almighty, whom there is none worthy of worship except Him, the Living, the Sustainer, and I turn to Him in repentance.',
          'source': 'Ebû Dâvûd, Tirmizî',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final primaryColor = settingsProvider.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = settingsProvider.appLanguage == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Duas & Prayers' : 'Dualar & Sûreler'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _duaCategories.length,
        itemBuilder: (context, catIndex) {
          final category = _duaCategories[catIndex];
          final duas = category['duas'] as List<Map<String, dynamic>>;
          final categoryColor = category['color'] as MaterialColor;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (catIndex > 0) const SizedBox(height: 20),
              // Category header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: isDark ? 0.3 : 0.15),
                      categoryColor.withValues(alpha: isDark ? 0.1 : 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(category['icon'] as IconData, color: categoryColor, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      isEn ? category['title_en'] : category['title_tr'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${duas.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Duas list
              ...duas.map((dua) => _DuaCard(
                    dua: dua,
                    isEn: isEn,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    categoryColor: categoryColor,
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _DuaCard extends StatefulWidget {
  final Map<String, dynamic> dua;
  final bool isEn;
  final bool isDark;
  final Color primaryColor;
  final MaterialColor categoryColor;

  const _DuaCard({
    required this.dua,
    required this.isEn,
    required this.isDark,
    required this.primaryColor,
    required this.categoryColor,
  });

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dua = widget.dua;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: widget.isDark ? 0 : 1,
      color: widget.isDark ? const Color(0xFF1A261D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu_book_rounded,
                        color: widget.categoryColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEn ? dua['name_en'] : dua['name_tr'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: widget.isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          dua['source'],
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Copy button
                  IconButton(
                    icon: Icon(Icons.copy, size: 18,
                        color: widget.isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600),
                    tooltip: widget.isEn ? 'Copy' : 'Kopyala',
                    onPressed: () {
                      final text =
                          '${dua['arabic']}\n\n${widget.isEn ? dua['meaning_en'] : dua['meaning_tr']}\n\n— ${dua['source']}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.isEn
                              ? 'Dua copied! 📋'
                              : 'Dua metni kopyalandı! 📋'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: widget.isDark ? Colors.grey : Colors.grey.shade700),
                  ),
                ],
              ),

              // Arabic text (always visible)
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.amber.shade200,
                  ),
                ),
                child: Text(
                  dua['arabic'],
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                    color: widget.isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                  ),
                ),
              ),

              // Meaning (expanded)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? widget.primaryColor.withValues(alpha: 0.1)
                          : widget.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEn ? '📖 Meaning:' : '📖 Anlamı:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: widget.isDark ? Colors.green.shade300 : widget.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.isEn ? dua['meaning_en'] : dua['meaning_tr'],
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: widget.isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                crossFadeState:
                    _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
