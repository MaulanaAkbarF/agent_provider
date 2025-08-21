import 'package:agent/core/constant_values/_constant_text_values.dart';
import 'package:agent/core/services/http_services/endpoints/auth/auth_services.dart';
import 'package:agent/ui/layouts/global_return_widgets/helper_widgets_func.dart';
import 'package:agent/ui/layouts/global_state_widgets/selected_item/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constant_values/assets_values.dart';
import '../../core/constant_values/global_values.dart';
import '../../core/services/firebase/firebase_messaging.dart';
import '../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../core/utilities/functions/input_func.dart';
import '../../core/utilities/functions/logger_func.dart';
import '../../core/utilities/functions/media_query_func.dart';
import '../layouts/global_return_widgets/media_widgets_func.dart';
import '../layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import '../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../layouts/global_state_widgets/divider/custom_divider.dart';
import '../layouts/global_state_widgets/textfield/textfield_form/regular_form.dart';
import '../layouts/styleconfig/textstyle.dart';
import '../layouts/styleconfig/themecolors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formLoginScreen = GlobalKey<FormState>();
  final TextEditingController tecNomor = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// Letakkan kode ini pada halaman awal yang tampil ketika pertama kali membuka aplikasi
      /// Namun jangan letakkan kode ini pada halaman splash screen atau sejenisnya
      /// Letakkan pada halaman login [jika tidak ada fitur auto-login] atau halaman beranda [jika terdapat fitur auto-login]
      /// Karena kode ini juga mencakup penanganan aksi notifikasi pada saat aplikasi dimatikan [onTerminated]
      await fcmNotificationInit(context);
      await getFcmNotificationToken();
    });

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
      useExtension: true,
      avoidBottomInset: false,
      padding: EdgeInsets.zero,
      backgroundColor: ThemeColors.secondaryRevert(context),
      body: _bodyWidget(context)
    );
  }

  Widget _setTabletLayout(BuildContext context){
    return CustomScaffold(
      canPop: false,
      useExtension: true,
      avoidBottomInset: false,
      padding: EdgeInsets.zero,
      backgroundColor: ThemeColors.secondaryRevert(context),
      body: _bodyWidget(context)
    );
  }

  Widget _bodyWidget(BuildContext context){
    return Stack(
      children: [
        loadImageAssetPNG(path: decorationFlower, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context)),
        loadImageAssetPNG(path: decorationTop, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context)),
        _onTopLayout(context),
        _onBottomLayout(context)
      ],
    );
  }

  Widget _onTopLayout(BuildContext context){
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(paddingVeryFar),
        height: getMediaQueryHeight(context) * .4,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimateProgressButton(
                labelButton: 'Lanjutkan',
                onTap: () async {

                },
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cText(context, "Selamat Datang\ndi $appNameText", style: TextStyles.mega(context).copyWith(
                    color: ThemeColors.typographyHighContrast(context), fontWeight: FontWeight.bold)
                  ),
                  ColumnDivider(),
                  cText(context, "Mulai sekarang lebih simpel\nDaftar dan login dalam sekejap.", style: TextStyles.large(context).copyWith(
                      color: ThemeColors.typographyHighContrast(context))
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onBottomLayout(BuildContext context){
    return Form(
      key: _formLoginScreen,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          width: double.infinity,
          height: getMediaQueryHeight(context) * .6,
          padding: EdgeInsets.all(paddingVeryFar),
          decoration: BoxDecoration(
            color: ThemeColors.onSurface(context),
            borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radiusDiamond),
            topRight: Radius.circular(radiusDiamond),
          ),
          ),
          child: Column(
            children: [
              labelRequired(context, 'Nomor Telepon', showRequired: true),
              ColumnDivider(),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomDropdown(
                      height: heightMid,
                      borderRadius: BorderRadius.circular(radiusCircle),
                      expansionList: convertDialCodeToList().$1,
                      initialText: convertDialCodeToList().$2,
                      containerColor: ThemeColors.secondaryRevert(context),
                      isRequired: true,
                      onSelected: (value) {
                        clog('Dial Code terpilih: $value');
                      }),
                  ),
                  RowDivider(),
                  Expanded(
                    flex: 6,
                    child: RegularTextField(
                      controller: tecNomor,
                      hintText: '81x-xxx-xxx',
                      keyboardType: TextInputType.number,
                      minInput: 8,
                      inputStyle: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold),
                      hintStyle: TextStyles.large(context).copyWith(color: ThemeColors.grey(context), fontWeight: FontWeight.bold),
                      containerColor: ThemeColors.secondaryRevert(context),
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              ColumnDivider(space: spaceMid),
              AnimateProgressButton(
                labelButton: 'Lanjutkan',
                useArrow: true,
                enable: true,
                onTap: () async {
                  if (_formLoginScreen.currentState!.validate()){
                    bool resp = await AuthServiceHttp(context).requestOtp(tecNomor.text.trim());
                    if (resp) clog('Success');
                    return false;
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}