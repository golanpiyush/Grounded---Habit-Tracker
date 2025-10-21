import 'dart:core';

class EmojiAssets {
  // Base path
  static const String _basePath = 'assets/illustrations';
  static const String _basePath2 = 'assets/substances';

  // Stats
  static const String sun = '$_basePath/sun.png';
  static const String moon = '$_basePath/moon.png';
  static const String fire = '$_basePath/fire.png';
  static const String trophy = '$_basePath/trophy.png';
  static const String barChart = '$_basePath/bar_chart.png';
  static const String moneyBag = '$_basePath/money_bag.png';
  static const String calendar = '$_basePath/calendar.png';

  // Medals
  static const String firstPlace = '$_basePath/1st_place_medal.png';
  static const String secondPlace = '$_basePath/2nd_place_medal.png';
  static const String thirdPlace = '$_basePath/3rd_place_medal.png';
  static const String bell = '$_basePath/bell.png';
  static const String sparkles = '$_basePath/sparkles.png';
  static const String palette = '$_basePath/palette.png';

  // Time of day
  static const String day = '$_basePath/sun.png';
  static const String sunrise = '$_basePath/sunrise.png';
  static const String evening = '$_basePath/sunset.png';
  static const String night = '$_basePath/night.png';

  // Seasons
  static const String autumn = '$_basePath/fallen_leaves.png';
  static const String summer = '$_basePath/sun.png';
  static const String rain = '$_basePath/cloud_with_rain.png';
  static const String winter = '$_basePath/cloud_with_snow.png';

  // Moods
  static const String smileGood =
      '$_basePath/smiling_face_with_smiling_eyes.png';
  static const String neutralFace = '$_basePath/neutral_face.png';
  static const String sadFace = '$_basePath/crying_face.png';
  static const String happyFace = '$_basePath/grinning_face.png';
  static const String worriedFace = '$_basePath/worried_face.png';
  static const String noWorries = '$_basePath/smiling_face_with_sunglasses.png';
  static const String sleepingFace = '$_basePath/sleeping_face.png';
  static const String sleepyFace = '$_basePath/sleepy_face.png';
  static const String catCrying = '$_basePath/crying_cat.png';

  // Insights
  static const String chartUp = '$_basePath/chart_increasing.png';
  static const String lightbulb = '$_basePath/light_bulb.png';

  // Actions
  static const String checkmark = '$_basePath/check_mark.png';
  static const String target = '$_basePath/target.png';
  static const String pencil = '$_basePath/pencil.png';
  static const String plus = '$_basePath/plus.png';
  static const String settings = '$_basePath/gear.png';
  static const String pill = '$_basePath/pill.png';
  static const String seedling = '$_basePath/seedling.png';

  // Misc
  static const String download = '$_basePath/download.png';
  static const String shield = '$_basePath/shield.png';
  static const String logout = '$_basePath/logout.png';
  static const String trash = '$_basePath/trash.png';
  static const String memo = '$_basePath/memo.png';
  static const String fileFolder = '$_basePath/fileFolder.png';
  static const String lock = '$_basePath/locks.png';
  static const String family = '$_basePath/family.png';
  static const String link = '$_basePath/link.png';
  static const String email = '$_basePath/email.png';
  static const String heart = '$_basePath/heart.png';

  // Substances
  static const String cannabis = '$_basePath2/herb.png';
  static const String alcohol = '$_basePath2/alcohol.png';
  static const String tobacco = '$_basePath2/cigarette.png';
  static const String caffeine = '$_basePath2/caffeine.png';
  static const String vaping = '$_basePath2/vaping.png';
  static const String prescription = '$_basePath2/prescription.png';
  static const String cocaine = '$_basePath2/cocaine.png';
  static const String heroin = '$_basePath2/heroin.png';
  static const String fentanyl = '$_basePath2/fentanyl.png';
  static const String meth = '$_basePath2/meth.png';
  static const String mdma = '$_basePath2/mdma.png';
  static const String lsd = '$_basePath2/lsd.png';
  static const String psilocybin = '$_basePath2/psilocybin.png';
  static const String ketamine = '$_basePath2/ketamine.png';
  static const String benzos = '$_basePath2/benzos.png';
  static const String opioids = '$_basePath2/opioids.png';
  static const String amphetamines = '$_basePath2/amphetamines.png';
  static const String sugar = '$_basePath2/sugar.png';
  static const String others = '$_basePath2/others.png';

  // --- Helpers ---

  /// Returns the correct emoji asset for a given [mood].
  static String getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'good':
        return smileGood;
      case 'happy':
        return happyFace;
      case 'neutral':
        return neutralFace;
      case 'sad':
        return sadFace;
      case 'worried':
        return worriedFace;
      default:
        return neutralFace;
    }
  }

  /// Returns the correct emoji asset for a given [season].
  static String getSeasonEmoji(String season) {
    switch (season.toLowerCase()) {
      case 'summer':
        return summer;
      case 'autumn':
        return autumn;
      case 'rain':
      case 'monsoon':
        return rain;
      case 'winter':
        return winter;
      default:
        return summer;
    }
  }

  /// Returns the correct emoji asset for a given [timeOfDay].
  static String getTimeEmoji(String timeOfDay) {
    switch (timeOfDay.toLowerCase()) {
      case 'day':
        return day;
      case 'evening':
        return evening;
      case 'night':
        return night;
      default:
        return day;
    }
  }
}
