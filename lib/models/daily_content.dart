class DailyContent {
  final String text;
  final String source;
  final String type; // 'Ayet' or 'Hadis'

  const DailyContent({
    required this.text,
    required this.source,
    required this.type,
  });

  static List<DailyContent> get contents => const [
        DailyContent(
          text: 'Şüphesiz namaz, müminler üzerine belirli vakitlerde farz kılınmıştır.',
          source: 'Nisâ Suresi, 103. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Beni anın ki ben de sizi anayım. Bana şükredin, nankörlük etmeyin.',
          source: 'Bakara Suresi, 152. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Dualarınızda kararlı olun. Allah katında en sevimli amel, az da olsa devamlı olanıdır.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'İnsanların en hayırlısı, insanlara faydalı olanıdır.',
          source: 'Hz. Muhammed (S.A.V) - Taberânî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Kalpler ancak Allah\'ı anmakla huzur bulur.',
          source: 'Ra\'d Suresi, 28. Ayet',
          type: 'Günün Ayeti',
        ),
      ];

  static DailyContent getTodayContent() {
    final now = DateTime.now();
    final index = (now.day + now.month) % contents.length;
    return contents[index];
  }
}
