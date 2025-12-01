/// Configuração do Google AdMob
///
/// IDs do AdMob são públicos e podem ser commitados.
/// Eles só funcionam com o bundle ID específico do app.
class AdMobConfig {
  // Application ID do AdMob (obtido no console do AdMob)
  // Formato: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
  static const String androidAppId = 'ca-app-pub-0748346709668865~3939961942';

  // Banner Ad Unit ID para tela principal
  // Formato: ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
  static const String bannerAdUnitId = 'ca-app-pub-0748346709668865/5416695145';

  // Test Ad Unit IDs do Google (não modificar)
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
}
