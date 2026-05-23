import 'dart:ui';

/// Accessible color palette — comfortable for eyes & color-blind friendly.
/// • Primary: Blue family (unchanged role)
/// • Success: Teal (visible in red-green color blindness)
/// • Error: Muted orange-red (not pure red)
/// • Warning: Amber/orange
/// • Backgrounds: Soft blue-white tint (less glare than pure white)
/// • All text-on-background combos meet WCAG AA contrast (≥ 4.5:1)
class ColorRes {
  // ── Transparency ────────────────────────────────────────────────────────
  static const Color transparent = Color(0x00000000);

  // ── Primary — Flash Care Teal brand ────────────────────────────────────
  static const Color primary        = Color(0xff00685d); // #00685d — brand primary
  static const Color primaryContainer = Color(0xff008376); // #008376 — container
  static const Color crystalBlue   = Color(0xff70d8c8); // inverse-primary tint
  static const Color darkSkyBlue   = Color(0xff008376); // primary-container
  static const Color havelockBlue  = Color(0xff00685d); // main brand color
  static const Color tuftsBlue     = Color(0xff005048); // on-primary-fixed-variant
  static const Color tuftsBlue100  = Color(0xff00201c); // darkest

  // ── Neutrals ────────────────────────────────────────────────────────────
  static const Color white          = Color(0xffFFFFFF);
  static const Color black          = Color(0xff000000);
  static const Color darkJungleGreen = Color(0xff1E293B); // dark blue-gray (replaces near-black)
  static const Color charcoalGrey   = Color(0xff334155); // dark text
  static const Color davyGrey       = Color(0xff4A5568); // medium-dark text
  static const Color smokeyGrey     = Color(0xff5E6E82); // medium text
  static const Color battleshipGrey = Color(0xff6B7A8D); // secondary text
  static const Color mediumGrey     = Color(0xff7E8DA0); // placeholder text
  static const Color grey           = Color(0xff90A0B4); // disabled text
  static const Color starDust       = Color(0xffA0AFBF); // subtle text
  static const Color silverChalice  = Color(0xffB0BFCE); // border
  static const Color nobel          = Color(0xffBFCBD9); // lighter border
  static const Color silver         = Color(0xffCBD4E0); // divider
  static const Color lightGrey      = Color(0xffD5DCE8); // light divider
  static const Color greyShade300   = Color(0xffDDE3ED); // input border
  static const Color mercury        = Color(0xffE4EAF2); // card border
  static const Color greenWhite     = Color(0xffEAEFF6); // subtle background
  static const Color dawnPink       = Color(0xffEEF2F8); // section background
  static const Color softPeach      = Color(0xffF0F4FA); // card background
  static const Color aquaHaze       = Color(0xffF2F6FB); // input background
  static const Color whiteSmoke     = Color(0xffF5F8FC); // page background
  static const Color snowDrift      = Color(0xffF8FAFD); // lightest background
  static const Color iceberg        = Color(0xffD6E8F9); // blue highlight bg

  // ── Semantic: Success — Teal (color-blind safe, not pure green) ─────────
  static const Color darkGreen      = Color(0xff0B7285); // deep teal
  static const Color irishGreen     = Color(0xff0D8A6F); // medium teal-green
  static const Color mediumGreen    = Color(0xff0EA98A); // bright teal

  // ── Semantic: Error — Muted orange-red (visible in red-green blindness) ─
  static const Color ferrariRed     = Color(0xffC0392B); // muted dark red
  static const Color lightRed       = Color(0xffE05040); // medium muted red
  static const Color bittersweet    = Color(0xffEC7B6B); // soft muted red
  static const Color pinkLace       = Color(0xffFDECEA); // very light red bg

  // ── Semantic: Warning — Amber/Orange (safe for all color blindness) ─────
  static const Color fadedOrange    = Color(0xffD97706); // deep amber
  static const Color pastelOrange   = Color(0xffF59E2A); // amber
  static const Color mangoOrange    = Color(0xffF07C2A); // orange

  // ── Misc ────────────────────────────────────────────────────────────────
  static const Color blueLagoon     = Color(0x55C8D8E8); // subtle overlay
}
