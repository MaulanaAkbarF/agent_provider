import 'package:agent/ui/layouts/styleconfig/themecolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../../core/constant_values/_setting_value/appearance_values.dart';
import '../../../core/constant_values/global_values.dart';
import '../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../core/state_management/providers/_settings/preference_provider.dart';

class TextStyles {
  static TextStyle getStyle(BuildContext context, double multiplier, {ListFontType? fontType}) {
    return TextStyle(
      color: ThemeColors.surface(context),
      fontFamily: fontType?.text ?? Provider.of<AppearanceSettingProvider>(context, listen: false).fontType,
      fontSize: Provider.of<AppearanceSettingProvider>(context, listen: false).fontSizeString.value * multiplier,
      fontWeight: FontWeight.normal,
      overflow: TextOverflow.ellipsis,
    );
  }

  static TextStyle nano(BuildContext context) => getStyle(context, 0.35);
  static TextStyle micro(BuildContext context) => getStyle(context, 0.45);
  static TextStyle verySmall(BuildContext context) => getStyle(context, 0.55);
  static TextStyle small(BuildContext context) => getStyle(context, 0.68);
  static TextStyle semiMedium(BuildContext context) => getStyle(context, 0.73);
  static TextStyle medium(BuildContext context) => getStyle(context, 0.78);
  static TextStyle semiLarge(BuildContext context) => getStyle(context, 0.9);
  static TextStyle large(BuildContext context) => getStyle(context, 1);
  static TextStyle semiGiant(BuildContext context) => getStyle(context, 1.2);
  static TextStyle giant(BuildContext context) => getStyle(context, 1.4);
  static TextStyle semiMega(BuildContext context) => getStyle(context, 1.75);
  static TextStyle mega(BuildContext context) => getStyle(context, 2.10);
  static TextStyle semiGiga(BuildContext context) => getStyle(context, 2.6);
  static TextStyle giga(BuildContext context) => getStyle(context, 3);
  static TextStyle colossal(BuildContext context) => getStyle(context, 4);
}

class HtmlStyles {
  /// Kode untuk menggunakan styling pada teks HTML menggunakan flutter_html
  static Style getHtmlStyle(BuildContext context, double multiplier, {ListFontType? fontType}) {
    return Style(
      color: ThemeColors.surface(context),
      fontFamily: fontType?.text ?? Provider.of<AppearanceSettingProvider>(context, listen: false).fontType,
      fontSize: FontSize(Provider.of<AppearanceSettingProvider>(context, listen: false).fontSizeString.value * multiplier),
      fontWeight: FontWeight.normal,
      textOverflow: TextOverflow.ellipsis,
      margin: Margins.zero,
    );
  }

  static Style nanoHtml(BuildContext context) => getHtmlStyle(context, 0.35);
  static Style microHtml(BuildContext context) => getHtmlStyle(context, 0.45);
  static Style verySmallHtml(BuildContext context) => getHtmlStyle(context, 0.55);
  static Style smallHtml(BuildContext context) => getHtmlStyle(context, 0.68);
  static Style semiMediumHtml(BuildContext context) => getHtmlStyle(context, 0.73);
  static Style mediumHtml(BuildContext context) => getHtmlStyle(context, 0.78);
  static Style semiLargeHtml(BuildContext context) => getHtmlStyle(context, 0.9);
  static Style largeHtml(BuildContext context) => getHtmlStyle(context, 1);
  static Style semiGiantHtml(BuildContext context) => getHtmlStyle(context, 1.2);
  static Style giantHtml(BuildContext context) => getHtmlStyle(context, 1.4);
  static Style semiMegaHtml(BuildContext context) => getHtmlStyle(context, 1.75);
  static Style megaHtml(BuildContext context) => getHtmlStyle(context, 2.10);
  static Style semiGigaHtml(BuildContext context) => getHtmlStyle(context, 2.6);
  static Style gigaHtml(BuildContext context) => getHtmlStyle(context, 3);
  static Style colossalHtml(BuildContext context) => getHtmlStyle(context, 4);
}

Widget cText(BuildContext context, String text, {int? maxLines,  TextAlign? align, TextStyle? style, Function()? onTap}){
  return onTap != null ? GestureDetector(
    onTap: () async => onTap(),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: paddingMid),
      color: Colors.transparent,
      child: Text(
        text,
        maxLines: maxLines ?? 10,
        textAlign: align ?? TextAlign.left,
        semanticsLabel: text,
        locale: Locale(Provider.of<PreferenceSettingProvider>(context, listen: false).language.countryId),
        style: style ?? TextStyles.medium(context).copyWith(color: ThemeColors.blue(context)),
      ),
    ),
  ) : Text(
    text,
    maxLines: maxLines ?? 10,
    textAlign: align ?? TextAlign.left,
    semanticsLabel: text,
    locale: Locale(Provider.of<PreferenceSettingProvider>(context, listen: false).language.countryId),
    style: style ?? TextStyles.medium(context).copyWith(),
  );
}