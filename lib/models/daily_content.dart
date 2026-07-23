class DailyContent {
  final String text;
  final String source;
  final String type; // 'Günün Ayeti' or 'Günün Hadisi'

  const DailyContent({
    required this.text,
    required this.source,
    required this.type,
  });

  static List<DailyContent> get contents => const [
        // === AYETLER ===
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
          text: 'Kalpler ancak Allah\'ı anmakla huzur bulur.',
          source: 'Ra\'d Suresi, 28. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Kim Allah\'a güvenirse, O kendisine yeter.',
          source: 'Talâk Suresi, 3. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Sabredin. Şüphesiz Allah sabredenlerle beraberdir.',
          source: 'Enfâl Suresi, 46. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Şüphesiz her güçlükle birlikte bir kolaylık vardır.',
          source: 'İnşirah Suresi, 6. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Rabbinize yalvararak ve gizlice dua edin. Şüphesiz O, haddi aşanları sevmez.',
          source: 'A\'râf Suresi, 55. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'İyilik yapın. Çünkü Allah iyilik yapanları sever.',
          source: 'Bakara Suresi, 195. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Her nefis ölümü tadacaktır. Sonunda bize döndürüleceksiniz.',
          source: 'Ankebût Suresi, 57. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'De ki: Rabbim, ilmimi artır.',
          source: 'Tâhâ Suresi, 114. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Allah adaleti, iyilik yapmayı ve yakınlara yardım etmeyi emreder.',
          source: 'Nahl Suresi, 90. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Kötülüğü en güzel şekilde savuştur. Bir de bakarsın ki aranızda düşmanlık bulunan kimse, sanki candan bir dost oluvermiştir.',
          source: 'Fussilet Suresi, 34. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Allah, bir toplumun durumunu, onlar kendi durumlarını değiştirmedikçe değiştirmez.',
          source: 'Ra\'d Suresi, 11. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'And olsun ki biz insanı en güzel biçimde yarattık.',
          source: 'Tîn Suresi, 4. Ayet',
          type: 'Günün Ayeti',
        ),
        DailyContent(
          text: 'Rabbim! Beni ve soyumdan gelecekleri namazı dosdoğru kılanlardan eyle.',
          source: 'İbrâhîm Suresi, 40. Ayet',
          type: 'Günün Ayeti',
        ),
        // === HADİSLER ===
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
          text: 'Güzel söz sadakadır.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Kolaylaştırınız, güçleştirmeyiniz. Müjdeleyiniz, nefret ettirmeyiniz.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Müslüman, elinden ve dilinden Müslümanların güvende olduğu kimsedir.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Sabır, acı bir olay karşısında gösterilir. Asıl sabır budur.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Sizin en hayırlınız, ahlakı en güzel olanınızdır.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Kim bir kötülük görürse onu eliyle düzeltsin. Buna gücü yetmezse diliyle, ona da gücü yetmezse kalbiyle buğzetsin.',
          source: 'Hz. Muhammed (S.A.V) - Müslim',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Bir Müslümanın yoldan eziyet veren şeyi kaldırması imandandır.',
          source: 'Hz. Muhammed (S.A.V) - Müslim',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Komşusu aç iken tok yatan bizden değildir.',
          source: 'Hz. Muhammed (S.A.V) - Hâkim',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Merhamet etmeyene merhamet olunmaz.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'İlim Çin\'de de olsa gidip öğreniniz.',
          source: 'Hz. Muhammed (S.A.V) - Beyhakî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Kişi sevdiğiyle beraberdir.',
          source: 'Hz. Muhammed (S.A.V) - Buhârî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Temizlik imanın yarısıdır.',
          source: 'Hz. Muhammed (S.A.V) - Müslim',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Cennet annelerin ayakları altındadır.',
          source: 'Hz. Muhammed (S.A.V) - Nesâî',
          type: 'Günün Hadisi',
        ),
        DailyContent(
          text: 'Dünya ahiretin tarlasıdır.',
          source: 'Hz. Muhammed (S.A.V) - Deylemî',
          type: 'Günün Hadisi',
        ),
      ];

  static DailyContent getTodayContent() {
    final now = DateTime.now();
    final index = (now.day + now.month) % contents.length;
    return contents[index];
  }
}
