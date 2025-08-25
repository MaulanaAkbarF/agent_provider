import 'package:agent/core/utilities/functions/page_routes_func.dart';
import 'package:agent/ui/layouts/global_return_widgets/future_state_func.dart';
import 'package:agent/ui/layouts/global_return_widgets/media_widgets_func.dart';
import 'package:agent/ui/layouts/global_state_widgets/divider/custom_divider.dart';
import 'package:agent/ui/layouts/styleconfig/textstyle.dart';
import 'package:agent/ui/layouts/styleconfig/themecolors.dart';
import 'package:agent/ui/page_main/dashboard/all_services/terms_of_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant_values/assets_values.dart';
import '../../../../core/constant_values/global_values.dart';
import '../../../../core/models/all_services_model/list_services.dart';
import '../../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../../core/state_management/providers/all_services/all_services_list_provider.dart';
import '../../../../core/utilities/functions/media_query_func.dart';
import '../../../layouts/global_state_widgets/custom_scaffold/custom_appbar.dart';
import '../../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../../../layouts/global_state_widgets/modal_bottom_sheet/regular_bottom_sheet.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

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
      useSafeArea: true,
      padding: EdgeInsets.symmetric(horizontal: paddingMid),
      appBar: appBarWidget(context: context, title: 'Semua Layanan', showBackButton: true),
      body: _bodyWidget(context)
    );
  }

  Widget _setTabletLayout(BuildContext context){
    return CustomScaffold(
      useSafeArea: true,
      padding: EdgeInsets.symmetric(horizontal: paddingMid),
      appBar: appBarWidget(context: context, title: 'Semua Layanan', showBackButton: true),
      body: _bodyWidget(context)
    );
  }

  Widget _bodyWidget(BuildContext context){
    return Consumer<ListServicesListProvider>(
      builder: (context, provider, child) {
      if (provider.allServicesData.isEmpty) return onLoadingState(context: context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: cText(context, 'Layanan Tersedia', style: TextStyles.semiGiant(context))),
              IconButton(
                icon: Icon(Icons.refresh, color: ThemeColors.primary(context), size: iconBtnMid),
                onPressed: () async => await provider.getListServicesData(context, true),
              )
            ],
          ),
          ColumnDivider(),
          Expanded(
            child: ListView.separated(
              itemCount: provider.allServicesData.length,
              separatorBuilder: (context, index) => Row(
                children: [
                  Expanded(flex: 2, child: Container(height: 1, color: Colors.transparent)),
                  Expanded(flex: 7, child: Container(height: 1, color: Colors.grey.withValues(alpha: .4))),
                ],
              ),
              itemBuilder: (context, index){
                final item = provider.allServicesData[index];
                return GestureDetector(
                  onTap: () {
                    if (item.registrationStatus! == ListServicesRegistrationStatus.PENDING) return _showWaitingBottomSheet(context);
                    startScreenFade(context, TermsOfServiceScreen(serviceData: item));
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: paddingMid, vertical: paddingFar),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(paddingMid),
                            decoration: BoxDecoration(color: ThemeColors.secondaryRevert(context), borderRadius: BorderRadiusGeometry.circular(radiusTriangle)),
                            child: item.iconUrl != null ? loadImageNetwork(imageUrl: item.iconUrl ?? '', width: 45, height: 45) : loadDefaultAppLogoSVG(sizeLogo: 45)
                          ),
                          RowDivider(space: spaceMid),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Html(
                                      data: item.name,
                                      style: {
                                        "span": HtmlStyles.largeHtml(context).copyWith(color: ThemeColors.primary(context), fontWeight: FontWeight.bold),
                                        "body": HtmlStyles.largeHtml(context).copyWith(fontWeight: FontWeight.bold),
                                      },
                                    ),
                                    if (item.registrationStatus! == ListServicesRegistrationStatus.PENDING)...[
                                      RowDivider(),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: paddingNear),
                                        decoration: BoxDecoration(color: ThemeColors.warningLowContrast(context), borderRadius: BorderRadiusGeometry.circular(radiusTriangle)),
                                        child: cText(context, "Menunggu", style: TextStyles.small(context).copyWith(color: ThemeColors.surface(context))),
                                      )
                                    ],
                                  ],
                                ),
                                if (item.description != null) cText(context, item.description ?? '')
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
      },
    );
  }

  void _showWaitingBottomSheet(BuildContext context) async {
    showRegularBottomSheet(
      context: context,
      imagePath: exceptionComingsoon,
      title: 'Menunggu Diproses!',
      description: "Kami sedang meninjau permintaan pembukaan layanan Anda.\n"
          "Harap tunggu dulu ya, kami akan memberikan pemberitahuan kepada Anda secepatnya!",
      onTap: () async => Navigator.pop(context),
    );
  }
}
