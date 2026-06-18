/// Maps the `origin_country` strings OpenSky returns (full English names)
/// to a flag emoji, purely for visual flavor in lists/cards. This is a
/// best-effort lookup table covering the countries that show up most
/// often in ADS-B data; unknown countries just fall back to a generic
/// airplane icon in the UI instead of a flag.
class CountryFlags {
  CountryFlags._();

  static const Map<String, String> _flagByCountry = {
    'United States': '🇺🇸',
    'United Kingdom': '🇬🇧',
    'Germany': '🇩🇪',
    'France': '🇫🇷',
    'Spain': '🇪🇸',
    'Italy': '🇮🇹',
    'Netherlands': '🇳🇱',
    'Belgium': '🇧🇪',
    'Switzerland': '🇨🇭',
    'Austria': '🇦🇹',
    'Portugal': '🇵🇹',
    'Ireland': '🇮🇪',
    'Poland': '🇵🇱',
    'Sweden': '🇸🇪',
    'Norway': '🇳🇴',
    'Denmark': '🇩🇰',
    'Finland': '🇫🇮',
    'Iceland': '🇮🇸',
    'Greece': '🇬🇷',
    'Turkey': '🇹🇷',
    'Russia': '🇷🇺',
    'Ukraine': '🇺🇦',
    'Canada': '🇨🇦',
    'Mexico': '🇲🇽',
    'Brazil': '🇧🇷',
    'Argentina': '🇦🇷',
    'Chile': '🇨🇱',
    'Colombia': '🇨🇴',
    'Peru': '🇵🇪',
    'China': '🇨🇳',
    'Japan': '🇯🇵',
    'South Korea': '🇰🇷',
    'India': '🇮🇳',
    'Indonesia': '🇮🇩',
    'Thailand': '🇹🇭',
    'Vietnam': '🇻🇳',
    'Philippines': '🇵🇭',
    'Malaysia': '🇲🇾',
    'Singapore': '🇸🇬',
    'Australia': '🇦🇺',
    'New Zealand': '🇳🇿',
    'United Arab Emirates': '🇦🇪',
    'Qatar': '🇶🇦',
    'Saudi Arabia': '🇸🇦',
    'Israel': '🇮🇱',
    'Egypt': '🇪🇬',
    'South Africa': '🇿🇦',
    'Nigeria': '🇳🇬',
    'Kenya': '🇰🇪',
    'Morocco': '🇲🇦',
    'Czech Republic': '🇨🇿',
    'Romania': '🇷🇴',
    'Hungary': '🇭🇺',
    'Croatia': '🇭🇷',
    'Bulgaria': '🇧🇬',
    'Serbia': '🇷🇸',
    'Luxembourg': '🇱🇺',
  };

  /// Returns a flag emoji for [countryName], or `null` if unknown.
  static String? flagFor(String countryName) => _flagByCountry[countryName];
}
