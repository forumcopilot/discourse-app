import 'package:flutter/painting.dart';

/// Colours written by post authors (`<font color="…">`, from the BBCode
/// `[color=…]` tag) as they reach the renderer.
///
/// Two problems with passing them to flutter_html as-is:
///
///  * flutter_html parses any value starting with `#` straight into an
///    integer, so a typo such as `#PG985740` throws a `FormatException` and
///    takes the whole post down with it; it also only knows 16 colour
///    names, so `LimeGreen` or `BurlyWood` are silently dropped.
///  * An author picks a colour against the forum's light background. The
///    same `navy` or `black` is unreadable on the app's dark theme, and a
///    pale `#43C6DB` is barely visible on a light one.
///
/// [normalizeHtmlColor] turns any value a browser would accept into
/// `#rrggbb` (or null, so the attribute can be dropped the way a browser
/// ignores it), and [readableOn] nudges a colour's lightness until it
/// contrasts with the background it is drawn on.

/// `#rgb`, `#rrggbb`, a CSS colour name, or `rgb()` → `#rrggbb` in lower case.
/// Null for anything a browser would ignore.
String? normalizeHtmlColor(String? raw) {
  if (raw == null) return null;
  final value = raw.trim().toLowerCase();
  if (value.isEmpty) return null;
  final hex = RegExp(r'^#?([0-9a-f]{3}|[0-9a-f]{6})$').firstMatch(value);
  if (hex != null && (value.startsWith('#') || !_cssColorNames.containsKey(value))) {
    var digits = hex.group(1)!;
    if (digits.length == 3) {
      digits = digits.split('').map((c) => '$c$c').join();
    }
    return '#$digits';
  }
  final named = _cssColorNames[value];
  if (named != null) return named;
  final rgb = RegExp(r'^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})').firstMatch(value);
  if (rgb != null) {
    final parts = [rgb.group(1), rgb.group(2), rgb.group(3)]
        .map((p) => int.parse(p!).clamp(0, 255).toRadixString(16).padLeft(2, '0'));
    return '#${parts.join()}';
  }
  return null;
}

/// `#rrggbb` → [Color]. Only for values [normalizeHtmlColor] produced.
Color colorFromHex(String hex) =>
    Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

String colorToHex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// WCAG contrast ratio between two opaque colours (1–21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// [color], or the closest colour of the same hue that reaches [minContrast]
/// against [background] — lighter on a dark background, darker on a light
/// one. Colours that already read well are returned unchanged, so an author's
/// red stays red in both themes; only the lightness moves, never the hue.
Color readableOn(Color color, Color background, {double minContrast = 4.5}) {
  if (contrastRatio(color, background) >= minContrast) return color;
  final hsl = HSLColor.fromColor(color);
  final towardLight = background.computeLuminance() < 0.5;
  var lo = hsl.lightness;
  var hi = towardLight ? 1.0 : 0.0;
  // Binary search for the smallest lightness change that is readable.
  for (var i = 0; i < 16; i++) {
    final mid = (lo + hi) / 2;
    if (contrastRatio(hsl.withLightness(mid).toColor(), background) >= minContrast) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return hsl.withLightness(hi).toColor();
}

const Map<String, String> _cssColorNames = {
  'aliceblue': '#f0f8ff', 'antiquewhite': '#faebd7', 'aqua': '#00ffff',
  'aquamarine': '#7fffd4', 'azure': '#f0ffff', 'beige': '#f5f5dc',
  'bisque': '#ffe4c4', 'black': '#000000', 'blanchedalmond': '#ffebcd',
  'blue': '#0000ff', 'blueviolet': '#8a2be2', 'brown': '#a52a2a',
  'burlywood': '#deb887', 'cadetblue': '#5f9ea0', 'chartreuse': '#7fff00',
  'chocolate': '#d2691e', 'coral': '#ff7f50', 'cornflowerblue': '#6495ed',
  'cornsilk': '#fff8dc', 'crimson': '#dc143c', 'cyan': '#00ffff',
  'darkblue': '#00008b', 'darkcyan': '#008b8b', 'darkgoldenrod': '#b8860b',
  'darkgray': '#a9a9a9', 'darkgreen': '#006400', 'darkgrey': '#a9a9a9',
  'darkkhaki': '#bdb76b', 'darkmagenta': '#8b008b', 'darkolivegreen': '#556b2f',
  'darkorange': '#ff8c00', 'darkorchid': '#9932cc', 'darkred': '#8b0000',
  'darksalmon': '#e9967a', 'darkseagreen': '#8fbc8f', 'darkslateblue': '#483d8b',
  'darkslategray': '#2f4f4f', 'darkslategrey': '#2f4f4f', 'darkturquoise': '#00ced1',
  'darkviolet': '#9400d3', 'deeppink': '#ff1493', 'deepskyblue': '#00bfff',
  'dimgray': '#696969', 'dimgrey': '#696969', 'dodgerblue': '#1e90ff',
  'firebrick': '#b22222', 'floralwhite': '#fffaf0', 'forestgreen': '#228b22',
  'fuchsia': '#ff00ff', 'gainsboro': '#dcdcdc', 'ghostwhite': '#f8f8ff',
  'gold': '#ffd700', 'goldenrod': '#daa520', 'gray': '#808080',
  'green': '#008000', 'greenyellow': '#adff2f', 'grey': '#808080',
  'honeydew': '#f0fff0', 'hotpink': '#ff69b4', 'indianred': '#cd5c5c',
  'indigo': '#4b0082', 'ivory': '#fffff0', 'khaki': '#f0e68c',
  'lavender': '#e6e6fa', 'lavenderblush': '#fff0f5', 'lawngreen': '#7cfc00',
  'lemonchiffon': '#fffacd', 'lightblue': '#add8e6', 'lightcoral': '#f08080',
  'lightcyan': '#e0ffff', 'lightgoldenrodyellow': '#fafad2', 'lightgray': '#d3d3d3',
  'lightgreen': '#90ee90', 'lightgrey': '#d3d3d3', 'lightpink': '#ffb6c1',
  'lightsalmon': '#ffa07a', 'lightseagreen': '#20b2aa', 'lightskyblue': '#87cefa',
  'lightslategray': '#778899', 'lightslategrey': '#778899', 'lightsteelblue': '#b0c4de',
  'lightyellow': '#ffffe0', 'lime': '#00ff00', 'limegreen': '#32cd32',
  'linen': '#faf0e6', 'magenta': '#ff00ff', 'maroon': '#800000',
  'mediumaquamarine': '#66cdaa', 'mediumblue': '#0000cd', 'mediumorchid': '#ba55d3',
  'mediumpurple': '#9370db', 'mediumseagreen': '#3cb371', 'mediumslateblue': '#7b68ee',
  'mediumspringgreen': '#00fa9a', 'mediumturquoise': '#48d1cc', 'mediumvioletred': '#c71585',
  'midnightblue': '#191970', 'mintcream': '#f5fffa', 'mistyrose': '#ffe4e1',
  'moccasin': '#ffe4b5', 'navajowhite': '#ffdead', 'navy': '#000080',
  'oldlace': '#fdf5e6', 'olive': '#808000', 'olivedrab': '#6b8e23',
  'orange': '#ffa500', 'orangered': '#ff4500', 'orchid': '#da70d6',
  'palegoldenrod': '#eee8aa', 'palegreen': '#98fb98', 'paleturquoise': '#afeeee',
  'palevioletred': '#db7093', 'papayawhip': '#ffefd5', 'peachpuff': '#ffdab9',
  'peru': '#cd853f', 'pink': '#ffc0cb', 'plum': '#dda0dd',
  'powderblue': '#b0e0e6', 'purple': '#800080', 'rebeccapurple': '#663399',
  'red': '#ff0000', 'rosybrown': '#bc8f8f', 'royalblue': '#4169e1',
  'saddlebrown': '#8b4513', 'salmon': '#fa8072', 'sandybrown': '#f4a460',
  'seagreen': '#2e8b57', 'seashell': '#fff5ee', 'sienna': '#a0522d',
  'silver': '#c0c0c0', 'skyblue': '#87ceeb', 'slateblue': '#6a5acd',
  'slategray': '#708090', 'slategrey': '#708090', 'snow': '#fffafa',
  'springgreen': '#00ff7f', 'steelblue': '#4682b4', 'tan': '#d2b48c',
  'teal': '#008080', 'thistle': '#d8bfd8', 'tomato': '#ff6347',
  'turquoise': '#40e0d0', 'violet': '#ee82ee', 'wheat': '#f5deb3',
  'white': '#ffffff', 'whitesmoke': '#f5f5f5', 'yellow': '#ffff00',
  'yellowgreen': '#9acd32',
};
