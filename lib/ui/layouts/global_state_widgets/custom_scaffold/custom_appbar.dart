import 'package:agent/ui/layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant_values/global_values.dart';
import '../../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../../core/utilities/functions/media_query_func.dart';
import '../../global_return_widgets/media_widgets_func.dart';
import '../../styleconfig/textstyle.dart';
import '../../styleconfig/themecolors.dart';
import '../divider/custom_divider.dart';

SliverAppBar sliverAppBarWidget({
  required BuildContext context,
  required String imagePath,
  String? title,
  bool? showAppLogo,
  Color? titleColor,
  Color? backgroundColor,
  Widget? leading,
  List<Widget>? actions,
}) {
  return SliverAppBar(
    expandedHeight: getMediaQueryHeight(context) * .25,
    backgroundColor: backgroundColor ?? (AppearanceSettingProvider.read(context).trueBlack ? ThemeColors.onSurface(context) : null),
    leading: leading ?? GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(paddingMid),
          child: Icon(Icons.arrow_back, color: ThemeColors.primary(context), size: iconBtnMid),
        ),
      )
    ),
    title: showAppLogo != null && showAppLogo ? loadDefaultAppLogoPNG() : title != null
        ? Align(
      alignment: Alignment.centerLeft,
          child: cText(context, title, maxLines: 1,
          style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold, color: titleColor ?? ThemeColors.surface(context))),
        ) : null,
    actions: actions,
    flexibleSpace: imagePath.contains('http')
        ? loadImageNetwork(imageUrl: imagePath, height: 300)
        : imagePath.contains('assets') ? imagePath.contains('svg')
        ? Padding(
          padding: EdgeInsets.only(top: getMediaQueryHeight(context) * .09),
          child: loadImageAssetSVG(path: imagePath, height: getMediaQueryHeight(context) * .2),
        ) : loadImageAssetPNG(path: imagePath, height: 300)
        : loadDefaultAppLogoSVG(),
  );
}

AppBar appBarWidget({
  required BuildContext context,
  String? title,
  bool? showAppLogo,
  bool? showBackButton,
  Color? backgroundColor,
  Color? titleColor,
  String? labelButton,
  Function()? onTap,
  TabController? tabController,
  List<Widget>? listTab,
  List<Widget>? actions,
  void Function(dynamic)? onPopupMenuSelected,
  PopupMenuItemBuilder<dynamic>? popupMenuItemBuilder,
}) {
  return AppBar(
    bottom: tabController != null ? TabBar.secondary(
      labelColor: ThemeColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      unselectedLabelColor: ThemeColors.surface(context),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyles.medium(context).copyWith(
        fontWeight: FontWeight.w600,
      ),
      dividerColor: Colors.transparent,
      tabs: listTab ?? [],
    ) : null,
    backgroundColor: backgroundColor ?? (AppearanceSettingProvider.read(context).trueBlack ? ThemeColors.onSurface(context) : null),
    toolbarHeight: 56,
    flexibleSpace: labelButton != null ? Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, paddingFar, paddingMid),
        constraints: BoxConstraints(minWidth: getMediaQueryWidth(context) * .1, maxWidth: getMediaQueryWidth(context) * .35),
        child: AnimateProgressButton(
          labelButton: labelButton,
          labelProgress: 'Proses',
          height: heightMid,
          containerRadius: radiusCircle,
          useShadow: false,
          useArrow: false,
          onTap: () => onTap != null ? onTap() : Navigator.pop(context),
        ),
      ),
    ) : null,
    elevation: 0,
    scrolledUnderElevation: 0,
    leadingWidth: showBackButton != null && showBackButton ? null : 0,
    leading: showBackButton != null && showBackButton ? IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back, color: ThemeColors.primary(context))) : const SizedBox(),
    title: showAppLogo != null && showAppLogo ? Center(child: Padding(padding: const EdgeInsets.only(right: paddingNear),
        child: loadDefaultAppLogoPNG(sizeLogo: 40))) : title != null
        ? Align(
      alignment: Alignment.centerLeft,
          child: cText(context, title, maxLines: 1,
            style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold, color: titleColor ?? ThemeColors.surface(context))),
        ) : null,
    actions: actions ?? [
      if (onPopupMenuSelected != null && popupMenuItemBuilder != null)...[
        RowDivider(space: 8),
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: ThemeColors.surface(context)),
          onSelected: onPopupMenuSelected,
          itemBuilder: popupMenuItemBuilder,
        ),
      ],
      if (showBackButton != null && showBackButton && onPopupMenuSelected == null
        || showBackButton != null && showBackButton && popupMenuItemBuilder == null
        || showBackButton != null && showBackButton && onPopupMenuSelected == null && popupMenuItemBuilder == null
        || showBackButton != null && showBackButton && onPopupMenuSelected == null && popupMenuItemBuilder == null && labelButton == null
      ) RowDivider(space: labelButton != null ? 20 : 58),
    ],
  );
}

AppBar appBarWebWidget({
  required BuildContext context,
  String? title,
  bool? showPopupMenuButton,
  TabController? tabController,
  List<Widget>? listTab,
  Widget? leading,
  List<Widget>? actions,
  void Function(dynamic)? onPopupMenuSelected,
  PopupMenuItemBuilder<dynamic>? popupMenuItemBuilder,
}) {
  return AppBar(
    bottom: tabController != null ? TabBar.secondary( // atau bisa menggunakan TabBar.secondary untuk tampilan lebih kompak
      labelColor: ThemeColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      unselectedLabelColor: ThemeColors.surface(context),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyles.medium(context).copyWith(
        fontWeight: FontWeight.w600,
      ),
      dividerColor: Colors.transparent,
      tabs: listTab ?? [],
    ) : null,
    backgroundColor: ThemeColors.onSurface(context),
    toolbarHeight: 60,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: leading,
    title: title != null ? cText(context, title, style: TextStyles.giant(context)) : null,
    actions: actions ?? [
      if (showPopupMenuButton != null && showPopupMenuButton && popupMenuItemBuilder != null)
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: ThemeColors.surface(context)),
          onSelected: onPopupMenuSelected,
          itemBuilder: popupMenuItemBuilder,
        ),
    ],
  );
}