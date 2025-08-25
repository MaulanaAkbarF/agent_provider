import 'package:agent/core/constant_values/list_string_or_map_string_values.dart';
import 'package:agent/ui/layouts/global_state_widgets/divider/custom_divider.dart';
import 'package:agent/ui/layouts/styleconfig/textstyle.dart';
import 'package:agent/ui/layouts/styleconfig/themecolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant_values/global_values.dart';
import '../../../../core/models/all_services_model/list_services.dart';
import '../../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../../core/utilities/functions/media_query_func.dart';
import '../../../../core/utilities/functions/page_routes_func.dart';
import '../../../layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import '../../../layouts/global_state_widgets/custom_scaffold/custom_appbar.dart';
import '../../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../../../layouts/global_state_widgets/custom_text/markdown_text.dart';
import 'activation_service_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final ListServicesData serviceData;

  const TermsOfServiceScreen({super.key, required this.serviceData});

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
      padding: EdgeInsets.zero,
      appBar: appBarWidget(
        context: context,
        title: 'Syarat & Ketentuan',
        titleColor: Colors.white,
        showBackButton: true,
        backgroundColor: Color(0xFF2E0948)
      ),
      body: _bodyWidget(context),
      bottomNavigation: Padding(
        padding: const EdgeInsets.all(paddingMid),
        child: AnimateProgressButton(
            labelButton: 'Terima & Lanjutkan',
            useArrow: true,
            onTap: () async => await startScreenFade(context, ActivationServiceScreen(serviceData: serviceData))
        ),
      ),
    );
  }

  Widget _setTabletLayout(BuildContext context){
    return CustomScaffold(
      useSafeArea: true,
      padding: EdgeInsets.zero,
      appBar: appBarWidget(
        context: context,
        title: 'Syarat & Ketentuan',
        titleColor: Colors.white,
        showBackButton: true,
        backgroundColor: Color(0xFF2E0948)
      ),
      body: _bodyWidget(context),
      bottomNavigation: Padding(
        padding: const EdgeInsets.all(paddingMid),
        child: AnimateProgressButton(
            labelButton: 'Terima & Lanjutkan',
            useArrow: true,
            onTap: () async => await startScreenFade(context, ActivationServiceScreen(serviceData: serviceData))
        ),
      ),
    );
  }

  Widget _bodyWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(paddingMid),
          decoration: BoxDecoration(color: Color(0xFF2E0948)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Html(
                data: "Syarat & Ketentuan ${serviceData.name ?? ''}",
                style: {
                  "span": HtmlStyles.largeHtml(context).copyWith(color: ThemeColors.primary(context), fontWeight: FontWeight.bold),
                  "body": HtmlStyles.largeHtml(context).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                },
              ),
              cText(context, 'Berlaku sejak ${DateTime.now().toString()}', style: TextStyles.medium(context).copyWith(color: Colors.white)),
              ColumnDivider()
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(paddingMid
            ),
            child: ListView(
              children: [
                cText(context, 'Kami menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. '
                    'Kebijakan privasi ini menjelaskan cara kami mengumpulkan, menggunakan, mengolah, dan mengamankan data pribadi Anda saat menggunakan aplikasi'),
                ColumnDivider(space: spaceFar),
                cText(context, 'Pengumpulan Data', style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold)),
                ColumnDivider(space: spaceNear),
                RegularMarkdown(text: listTermsOfServices[0]),
                ColumnDivider(space: spaceFar),
                cText(context, 'Penggunaan Data', style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold)),
                ColumnDivider(space: spaceNear),
                RegularMarkdown(text: listTermsOfServices[1]),
                ColumnDivider(space: spaceFar),
                cText(context, 'Keamanan Data', style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold)),
                ColumnDivider(space: spaceNear),
                RegularMarkdown(text: listTermsOfServices[2]),
                ColumnDivider(space: spaceFar),
                cText(context, 'Kami berkomitmen untuk melindungi privasi dan data pribadi Anda sesuai dengan peraturan yang berlaku. '
                    'Jika Anda memiliki pertanyaan atau kekhawatiran terkait kebijakan privasi ini, silakan hubungi kami melalui tombol di bawah ini.'),
                ColumnDivider(space: spaceNear),
              ],
            ),
          ),
        )
      ],
    );
  }
}