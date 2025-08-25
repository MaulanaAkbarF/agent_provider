import 'package:agent/ui/layouts/styleconfig/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constant_values/assets_values.dart';
import '../../../core/constant_values/global_values.dart';
import '../../../core/models/_global_widget_model/bottom_navbar.dart';
import '../../../core/state_management/providers/_global_widget/main_navbar_provider.dart';
import '../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../core/utilities/functions/media_query_func.dart';
import '../../../core/utilities/functions/system_func.dart';
import '../../layouts/global_return_widgets/media_widgets_func.dart';
import '../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../../layouts/global_state_widgets/dialog/dialog_button/dialog_two_button.dart';
import '../../layouts/styleconfig/themecolors.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';

List<BottomNavbarModel> listBottomNavbar = [
  BottomNavbarModel(page: DashboardScreen(), title: 'Beranda', iconImage: loadImageAssetSVG(path: iconMainDashboard)),
  BottomNavbarModel(page: DashboardScreen(), title: 'Promo', iconImage: loadImageAssetSVG(path: iconMainPromo)),
  BottomNavbarModel(page: DashboardScreen(), title: 'Riwayat', iconImage: loadImageAssetSVG(path: iconMainHistory)),
  BottomNavbarModel(page: ProfileScreen(), title: 'Chat', iconImage: loadImageAssetSVG(path: iconMainChat)),
];

class MainNavbarCustom extends StatelessWidget {
  const MainNavbarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        await showDialog(context: context, builder: (context) => DialogTwoButton(header: 'Keluar Aplikasi?', description: 'Anda yakin ingin keluar dari aplikasi?',
          acceptedOnTap: () => quitApp()));
      },
      child: Consumer2<AppearanceSettingProvider, MainNavbarProvider>(
        builder: (context, provider, provider2, child) {
          if (provider.isTabletMode.condition){
            if (getMediaQueryWidth(context) > provider.tabletModePixel.value) return _setTabletLayout(context, provider2);
            if (getMediaQueryWidth(context) < provider.tabletModePixel.value) return _setPhoneLayout(context, provider2);
          }
          return _setPhoneLayout(context, provider2);
        }
      ),
    );
  }

  Widget _setPhoneLayout(BuildContext context, MainNavbarProvider provider){
    return CustomScaffold(
      canPop: false,
      padding: EdgeInsets.zero,
      body: _bodyWidget(context, provider),
      bottomNavigation: _customBottomNavigation(context, provider)
    );
  }

  Widget _setTabletLayout(BuildContext context, MainNavbarProvider provider){
    return CustomScaffold(
      canPop: false,
      padding: EdgeInsets.zero,
      body: _bodyWidget(context, provider),
      bottomNavigation: _customBottomNavigation(context, provider)
    );
  }

  Widget _bodyWidget(BuildContext context, MainNavbarProvider provider) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: provider.pageController,
            onPageChanged: (index) => provider.changePageIndex(index),
            children: listBottomNavbar.map((data) => data.page).toList()
          ),
        ),
      ],
    );
  }

  Widget _customBottomNavigation(BuildContext context, MainNavbarProvider provider) {
    return Container(
      color: ThemeColors.greyVeryLowContrast(context),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: paddingNear),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: listBottomNavbar.asMap().entries.map((entry) {
              int index = entry.key;
              BottomNavbarModel data = entry.value;
              bool isSelected = provider.selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.changePageIndex(index),
                  child: _buildCustomNavItem(context, data, isSelected),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem(BuildContext context, BottomNavbarModel data, bool isSelected) {
    if (isSelected) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: paddingMid),
        child: Container(
          constraints: BoxConstraints(minWidth: double.infinity),
          padding: EdgeInsets.symmetric(vertical: paddingNear, horizontal: paddingMid),
          decoration: BoxDecoration(color: ThemeColors.primary(context), borderRadius: BorderRadius.circular(radiusSquare)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: iconBtnMid,
                child: data.iconData != null ? Icon(
                  data.iconData,
                  size: MainNavbarProvider.read(context).iconSize,
                  color: ThemeColors.surface(context),
                ) : data.iconImage,
              ),
              cText(context, data.title, maxLines: 1, style: TextStyles.medium(context).copyWith(fontWeight: FontWeight.bold, color: Colors.white))
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: paddingMid),
        child: Container(
          constraints: BoxConstraints(minWidth: double.infinity),
          padding: EdgeInsets.symmetric(vertical: paddingNear, horizontal: paddingMid),
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(radiusSquare)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: iconBtnMid,
                child: data.iconData != null ? Icon(
                  data.iconData,
                  size: MainNavbarProvider.read(context).iconSize,
                  color: ThemeColors.surface(context),
                ) : data.iconImage,
              ),
              cText(context, data.title, maxLines: 1, style: TextStyles.medium(context).copyWith(fontWeight: FontWeight.bold, color: ThemeColors.surface(context)))
            ],
          ),
        ),
      );
    }
  }
}