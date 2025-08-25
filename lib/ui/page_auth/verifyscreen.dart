import 'package:agent/ui/layouts/global_return_widgets/helper_widgets_func.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constant_values/assets_values.dart';
import '../../core/constant_values/global_values.dart';
import '../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../core/state_management/providers/auth/user_provider.dart';
import '../../core/utilities/functions/media_query_func.dart';
import '../../core/utilities/functions/page_routes_func.dart';
import '../layouts/global_return_widgets/media_widgets_func.dart';
import '../layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import '../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../layouts/global_state_widgets/divider/custom_divider.dart';
import '../layouts/global_state_widgets/textfield/textfield_form/regular_form.dart';
import '../layouts/styleconfig/textstyle.dart';
import '../layouts/styleconfig/themecolors.dart';
import '../page_main/_global_pages/main_navbar_custom.dart';

class VerifyScreen extends StatefulWidget {
  final String nomor;
  const VerifyScreen({super.key, required this.nomor});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _formVerifyScreen = GlobalKey<FormState>();
  final TextEditingController tecKode = TextEditingController(text: '');
  int input = 0;

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
      top: 20,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(paddingVeryFar),
        height: getMediaQueryHeight(context) * .4,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, size: iconBtnMid, color: ThemeColors.surface(context))),
                Expanded(child: SizedBox()),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cText(context, "OTP udah di\nWhatsApp!", style: TextStyles.mega(context).copyWith(
                    color: ThemeColors.typographyHighContrast(context), fontWeight: FontWeight.bold)
                  ),
                  ColumnDivider(),
                  cText(context, "Kode OTP baru aja mendarat di\nnomor +${widget.nomor}", style: TextStyles.large(context).copyWith(
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
      key: _formVerifyScreen,
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
                    flex: 6,
                    child: RegularTextField(
                      controller: tecKode,
                      hintText: '*****',
                      keyboardType: TextInputType.number,
                      minInput: 5,
                      maxInput: 5,
                      inputStyle: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold),
                      hintStyle: TextStyles.large(context).copyWith(color: ThemeColors.grey(context), fontWeight: FontWeight.bold),
                      containerColor: ThemeColors.secondaryRevert(context),
                      suffixIcon: Icon(Icons.copy_outlined, color: ThemeColors.primary(context), size: iconBtnSmall),
                      isRequired: true,
                      onChanged: (value) => setState(() => input = value.length),
                    ),
                  ),
                  RowDivider(),
                  Expanded(
                    flex: 3,
                    child: AnimateProgressButton(
                      labelButton: 'Kirim Kode',
                      height: heightMid,
                      onTap: () async {

                      },
                    ),
                  )
                ],
              ),
              ColumnDivider(space: spaceMid),
              AnimateProgressButton(
                labelButton: 'Lanjutkan',
                useArrow: true,
                enable: input < 5 ? false : true,
                onTap: () async {
                  if (_formVerifyScreen.currentState!.validate()){
                    bool resp = await UserProvider.read(context).verifyOtp(context: context, otpCode: tecKode.text);
                    if (resp) startScreenFade(context, MainNavbarCustom());
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