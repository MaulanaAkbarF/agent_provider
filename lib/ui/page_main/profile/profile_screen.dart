import 'package:agent/ui/page_setting/_main_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constant_values/assets_values.dart';
import '../../../core/constant_values/global_values.dart';
import '../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../core/state_management/providers/auth/user_provider.dart';
import '../../../core/utilities/functions/media_query_func.dart';
import '../../../core/utilities/functions/page_routes_func.dart';
import '../../layouts/global_return_widgets/media_widgets_func.dart';
import '../../layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import '../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../../layouts/global_state_widgets/divider/custom_divider.dart';
import '../../layouts/styleconfig/textstyle.dart';
import '../../layouts/styleconfig/themecolors.dart';
import 'detail_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceSettingProvider>(
      builder: (context, provider, child) {
        if (provider.isTabletMode.condition){
          if (getMediaQueryWidth(context) > provider.tabletModePixel.value) return _setTabletLayout(context);
          if (getMediaQueryWidth(context) < provider.tabletModePixel.value) return _setPhoneLayout(context);
        }
        return _setPhoneLayout(context);
      }
    );
  }

  Widget _setPhoneLayout(BuildContext context){
    return CustomScaffold(
      canPop: false,
      useSafeArea: false,
      padding: EdgeInsets.zero,
      backgroundColor: Color(0xFF2E0948),
      body: _bodyWidget(context)
    );
  }

  Widget _setTabletLayout(BuildContext context){
    return CustomScaffold(
      canPop: false,
      useSafeArea: false,
      padding: EdgeInsets.zero,
      backgroundColor: Color(0xFF2E0948),
      body: _bodyWidget(context)
    );
  }

  Widget _bodyWidget(BuildContext context){
    return Stack(
      children: [
        loadImageAssetPNG(path: decorationFlower, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context)),
        loadImageAssetPNG(path: decorationTop, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context)),
        // _onTopLayout(context),
        _onBottomLayout(context),
        Positioned(
          bottom: getMediaQueryHeight(context) * .68,
          left: 20,
          child: loadCircleImage(context: context, imageAssetPath: avatarDummy, radius: 60)
        ),
      ],
    );
  }

  Widget _onBottomLayout(BuildContext context){
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: getMediaQueryHeight(context) * .74,
        padding: EdgeInsets.all(paddingFar),
        decoration: BoxDecoration(
          color: ThemeColors.onSurface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusDiamond)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimateProgressButton(
                    labelButton: "Edit Profile",
                    containerRadius: radiusCircle,
                    height: heightMid,
                    onTap: (){
                      startScreenSwipe(context, EditProfileScreen());
                    },
                  ),
                ),
              ],
            ),
            ColumnDivider(),
            cText(context, UserProvider.watch(context).user?.name ?? 'Pengguna',
                style: TextStyles.giant(context).copyWith(fontWeight: FontWeight.bold)),
            ColumnDivider(),
            cText(context, UserProvider.watch(context).user?.phoneNumber ?? '08123456789',
                style: TextStyles.large(context)),
            _buildButtonLayout(context)
          ],
        ),
      ),
    );
  }

  Widget _buildButtonLayout(BuildContext context){
    return Expanded(
      child: SizedBox(
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: [
            Container(
              padding: EdgeInsets.all(paddingMid),
              decoration: BoxDecoration(color: ThemeColors.secondaryRevert(context), borderRadius: BorderRadius.circular(radiusTriangle)),
              child: Column(
                children: [
                  _button(context: context, label: 'Bahasa', image: loadImageAssetSVG(path: iconLanguage),
                      onTap: () async => await startScreenSwipe(context, EditProfileScreen())),
                  ColumnDivider(),
                  _button(context: context, label: 'Notifikasi', image: loadImageAssetSVG(path: iconNotification),
                      onTap: () async => await startScreenSwipe(context, MainSettingScreen())),
                ],
              ),
            ),
            ColumnDivider(space: spaceMid),
            Container(
              padding: EdgeInsets.all(paddingMid),
              decoration: BoxDecoration(color: ThemeColors.secondaryRevert(context), borderRadius: BorderRadius.circular(radiusTriangle)),
              child: Column(
                children: [
                  _button(context: context, label: 'Seputar Gercepin', image: loadImageAssetSVG(path: iconAbout),
                      onTap: () async => await startScreenSwipe(context, MainSettingScreen())),
                  ColumnDivider(),
                  _button(context: context, label: 'Bantuan dan Laporan', image: loadImageAssetSVG(path: iconHelp),
                      onTap: () async => await startScreenSwipe(context, MainSettingScreen())),
                  ColumnDivider(),
                  _button(context: context, label: 'Pengaturan', image: loadImageAssetSVG(path: iconMainDashboard),
                      onTap: () async => await startScreenSwipe(context, MainSettingScreen())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button({required BuildContext context, required String label, required Widget image, required VoidCallback onTap}){
    return AnimateProgressButton(
      labelButton: label,
      labelButtonStyle: TextStyles.semiLarge(context).copyWith(color: ThemeColors.surface(context), fontWeight: FontWeight.bold),
      textAlign: TextAlign.start,
      containerColor: Colors.transparent,
      height: heightMid,
      image: image,
      useArrow: true,
      arrowColor: ThemeColors.primary(context),
      useShadow: false,
      onTap: onTap
    );
  }
}
