import 'package:agent/core/utilities/functions/input_func.dart';
import 'package:agent/ui/layouts/global_return_widgets/media_widgets_func.dart';
import 'package:agent/ui/layouts/global_state_widgets/divider/custom_divider.dart';
import 'package:agent/ui/layouts/styleconfig/textstyle.dart';
import 'package:agent/ui/layouts/styleconfig/themecolors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constant_values/assets_values.dart';
import '../../../core/constant_values/global_values.dart';
import '../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../core/state_management/providers/auth/user_provider.dart';
import '../../../core/utilities/functions/media_query_func.dart';
import '../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
      avoidBottomInset: false,
      padding: EdgeInsets.zero,
      body: _bodyWidget(context)
    );
  }

  Widget _setTabletLayout(BuildContext context){
    return CustomScaffold(
      canPop: false,
      avoidBottomInset: false,
      padding: EdgeInsets.zero,
      body: _bodyWidget(context)
    );
  }

  Widget _bodyWidget(BuildContext context){
    return ListView(
      children: [
        SizedBox(
          height: getMediaQueryHeight(context) * .24,
          child: Stack(
            children: [
              _background(context),
              _accountInfo(context),
              _saldoLayout(context)
            ]
          ),
        ),
        _manageServiceLayout(context),
      ],
    );
  }

  Widget _background(BuildContext context){
    return Column(
      children: [
        Container(
          color: ThemeColors.secondary(context).withValues(alpha: .8),
          child: Stack(
            children: [
              loadImageAssetPNG(path: decorationFlower, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context) * .18),
              loadImageAssetPNG(path: decorationTop, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context) * .18),
            ]
          ),
        ),
        SizedBox(height: getMediaQueryHeight(context) * .06),
      ]
    );
  }

  Widget _accountInfo(BuildContext context){
    bool switchButton = true;
    return Container(
      padding: const EdgeInsets.all(paddingMid),
      height: getMediaQueryHeight(context) * .12,
      child: Row(
        children: [
          loadCircleImage(context: context, imageAssetPath: avatarDummy, radius: 30),
          RowDivider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    cText(context, 'Hai, ', style: TextStyles.semiLarge(context).copyWith(color: Colors.white)),
                    cText(context, '${UserProvider.watch(context).user?.name ?? 'Pengguna'}!',
                        style: TextStyles.semiLarge(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    cText(context, '★ 4.85', style: TextStyles.semiLarge(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    RowDivider(),
                    cText(context, '(95 Orderan)', style: TextStyles.semiLarge(context).copyWith(color: Colors.white)),
                  ],
                ),

              ],
            ),
          ),
          StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: paddingMid),
                  decoration: BoxDecoration(
                      color: switchButton ? ThemeColors.primary(context) : ThemeColors.grey(context),
                      borderRadius: BorderRadius.circular(radiusCircle)
                  ),
                  child: Row(
                    children: [
                      cText(context, switchButton ? 'Online' : "Offline",
                          style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold)
                      ),
                      RowDivider(),
                      Switch(
                          value: switchButton,
                          padding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() => switchButton = !switchButton);
                          }
                      ),
                    ],
                  ),
                );
              }
          )
        ],
      ),
    );
  }

  Widget _saldoLayout(BuildContext context){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(paddingVeryFar),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                    color: ThemeColors.greyVeryLowContrast(context),
                    borderRadius: BorderRadius.circular(radiusTriangle),
                    boxShadow: [
                      BoxShadow(
                          color: ThemeColors.primary(context).withValues(alpha: .2),
                          offset: const Offset(0, 8),
                          blurRadius: shadowBlueHigh * 2,
                          spreadRadius: shadowSpreadHigh
                      )
                    ]
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(paddingMid),
                      child: loadCircleImage(context: context, imageAssetPath: iconWhatsAppPNG, radius: 20),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cText(context, 'Saldo'),
                          cText(context, inputPriceWithFormat('Rp', '80000'), style: TextStyles.medium(context).copyWith(
                              fontWeight: FontWeight.bold
                          ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: paddingFar),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_circle_up_outlined, color: ThemeColors.primary(context), size: iconBtnMid),
                          cText(context, 'Top up')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            RowDivider(),
            Expanded(
              flex: 2,
              child: Container(
                height: 70,
                padding: EdgeInsets.all(paddingNear),
                decoration: BoxDecoration(
                    color: ThemeColors.greyVeryLowContrast(context),
                    borderRadius: BorderRadius.circular(radiusTriangle),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColors.primary(context).withValues(alpha: .2),
                        offset: const Offset(0, 8),
                        blurRadius: shadowBlueHigh * 2,
                        spreadRadius: shadowSpreadHigh
                      )
                    ]
                ),
                child: Container(
                  decoration: BoxDecoration(color: ThemeColors.pinkVeryLowContrast(context), borderRadius: BorderRadius.circular(radiusTriangle)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      loadImageAssetSVG(path: iconAmbulance, width: 30, height: 30),
                      cText(context, 'Darurat', style: TextStyles.medium(context).copyWith(
                          color: ThemeColors.pinkHighContrast(context),
                          fontWeight: FontWeight.bold
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _manageServiceLayout(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(paddingMid),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: cText(context, 'Layanan Pilihan Kamu', style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold))),
              cText(context, 'Atur Layanan', style: TextStyles.semiLarge(context)),
            ],
          ),
          ColumnDivider(),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 5/5,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(color: ThemeColors.secondaryRevert(context), borderRadius: BorderRadius.circular(radiusTriangle)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loadImageAssetSVG(path: iconAddService, width: 40, height: 40)
                  ],
                ),
              );
            },
          ),
          ColumnDivider(space: spaceFar),
          Row(
            children: [
              Expanded(child: cText(context, 'Pesanan Masuk', style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold))),
              cText(context, 'Kelola Pesanan', style: TextStyles.semiLarge(context)),
            ],
          ),
          ColumnDivider(),
          ListView.separated(
            shrinkWrap: true,
            itemCount: 3,
            separatorBuilder: (context, index) => ColumnDivider(),
            itemBuilder: (context, index){
              return Container(
                padding: EdgeInsets.all(paddingVeryFar),
                decoration: BoxDecoration(color: ThemeColors.secondaryRevert(context), borderRadius: BorderRadius.circular(radiusTriangle)),
                child: Row(
                  children: [
                    loadImageAssetSVG(path: iconOrderCoffee, width: 40, height: 40),
                    RowDivider(space: spaceMid),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cText(context, 'Orderan belum ada nih', style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold)),
                          cText(context, 'Sabar dan tetap optimis yaa. Rezeki ga bakalan ketuker kok!', style: TextStyles.semiLarge(context)),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

