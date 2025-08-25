import 'package:agent/core/utilities/functions/system_func.dart';
import 'package:agent/ui/layouts/global_state_widgets/dialog/dialog_button/dialog_two_button.dart';
import 'package:agent/ui/layouts/global_state_widgets/divider/custom_divider.dart';
import 'package:agent/ui/layouts/styleconfig/textstyle.dart';
import 'package:agent/ui/layouts/styleconfig/themecolors.dart';
import 'package:agent/ui/page_main/_global_pages/main_navbar_custom.dart';
import 'package:agent/ui/page_main/profile/detail_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant_values/assets_values.dart';
import '../../../../core/constant_values/global_values.dart';
import '../../../../core/models/all_services_model/list_services.dart';
import '../../../../core/services/http_services/endpoints/all_services/all_list_service_services.dart';
import '../../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../../core/state_management/providers/all_services/all_services_list_provider.dart';
import '../../../../core/state_management/providers/auth/user_provider.dart';
import '../../../../core/utilities/functions/logger_func.dart';
import '../../../../core/utilities/functions/media_query_func.dart';
import '../../../../core/utilities/functions/page_routes_func.dart';
import '../../../layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import '../../../layouts/global_state_widgets/custom_scaffold/custom_appbar.dart';
import '../../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../../../layouts/global_state_widgets/modal_bottom_sheet/regular_bottom_sheet.dart';
import '../../../layouts/global_state_widgets/selected_item/list_radio_button.dart';
import '../../../layouts/global_state_widgets/textfield/textfield_form/regular_form.dart';
import '../../profile/call_us_screen.dart';

class ActivationServiceScreen extends StatefulWidget {
  final ListServicesData serviceData;

  const ActivationServiceScreen({super.key, required this.serviceData});

  @override
  State<ActivationServiceScreen> createState() => _ActivationServiceScreenState();
}

class _ActivationServiceScreenState extends State<ActivationServiceScreen> {
  final _formUserDataHasBeenFilledScreen = GlobalKey<FormState>();
  late final TextEditingController tecNama;
  late final TextEditingController tecNomor;
  late final TextEditingController tecEmail;
  String? gender;
  int? initialIndex;

  @override
  void initState() {
    tecNama = TextEditingController(text: UserProvider.read(context).user?.name ?? '');
    tecNomor = TextEditingController(text: UserProvider.read(context).user?.phoneNumber ?? '');
    tecEmail = TextEditingController(text: UserProvider.read(context).user?.email ?? '');
    if (UserProvider.read(context).user?.gender != null) {
      if (UserProvider.read(context).user?.gender == 'Male'){
        gender = 'Laki-laki';
        initialIndex = 0;
      } else {
        gender = 'Perempuan';
        initialIndex = 1;
      }
    }
    super.initState();
  }

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
      padding: EdgeInsets.zero,
      sliverAppBar: sliverAppBarWidget(
        context: context,
        title: 'Aktivasi Layanan',
        titleColor: Colors.white,
        imagePath: activationService,
        backgroundColor: Color(0xFF2E0948)
      ),
      body: _bodyWidget(context),
      bottomNavigation: Padding(
        padding: const EdgeInsets.all(paddingMid),
        child: AnimateProgressButton(
          labelButton: 'Aktifkan Layanan!',
          useArrow: true,
          onTap: () async {
            if (_formUserDataHasBeenFilledScreen.currentState!.validate()){
              bool resp = false;
              switch (widget.serviceData.id){
                case 1 : resp = await ListServicesHttp(context).activateServices(widget.serviceData.id); break;
                case 2 : resp = await ListServicesHttp(context).activateServices(widget.serviceData.id); break;
                case 3 : resp = await ListServicesHttp(context).activateServices(widget.serviceData.id); break;
                case 4 : resp = await ListServicesHttp(context).activateServices(widget.serviceData.id); break;
                case 5 : resp = await ListServicesHttp(context).activateServices(widget.serviceData.id); break;
                case 6 : resp = await ListServicesHttp(context).activateServices(widget.serviceData.id); break;
                case 7 : resp = await ListServicesHttp(context).activateServices(widget.serviceData.id); break;
              }

              if (resp == true) {
                await Provider.of<ListServicesListProvider>(context, listen: false).getListServicesData(context, true);
                _showSuccessBottomSheet(context);
              }
              showToastTop(context, 'Upss@ Terjadi masalah!');
            } else {
              showDialog(context: context, builder: (context) {
                return DialogTwoButton(
                  header: 'Data kamu belum lengkap',
                  description: 'Harap lengkapi data kamu dulu yaa',
                  acceptedText: 'Lengkapi Profil',
                  acceptedOnTap: () {
                    startScreenSwipe(context, EditProfileScreen());
                  },
                );
              });
            }
          }
        ),
      ),
    );
  }

  Widget _setTabletLayout(BuildContext context){
    return CustomScaffold(
      padding: EdgeInsets.zero,
      sliverAppBar: sliverAppBarWidget(
        context: context,
        title: 'Aktivasi Layanan',
        titleColor: Colors.white,
        imagePath: activationService,
        backgroundColor: Color(0xFF2E0948)
      ),
      body: _bodyWidget(context),
      bottomNavigation: Padding(
        padding: const EdgeInsets.all(paddingMid),
        child: AnimateProgressButton(
          labelButton: 'Aktifkan Layanan!',
          useArrow: true,
          onTap: () async => await startScreenFade(context, CallUsScreen())
        ),
      ),
    );
  }

  Widget _bodyWidget(BuildContext context){
    return Form(
      key: _formUserDataHasBeenFilledScreen,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: paddingMid),
          child: ListView(
            children: [
              RegularTextField(
                controller: tecNama,
                labelText: 'Nama Lengkap',
                labelStyle: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold),
                hintText: UserProvider.read(context).user?.name ?? 'Ketik Nama Kamu',
                enabled: false,
                minInput: 4,
              ),
              ColumnDivider(space: spaceMid),
              cText(context, 'Jenis Kelamin', style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold)),
              CustomRadioButtonGroup(listRadioItem: ['Laki-laki', 'Perempuan'],selectedIndex: initialIndex, enabled: false, onSelected: (value) => clog(value)),
              ColumnDivider(space: spaceNear),
              cText(context, 'Nomor Telepon', style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ColumnDivider(),
              RegularTextField(
                controller: tecNomor,
                hintText: 'Masukkan nomor telepon kamu',
                keyboardType: TextInputType.number,
                enabled: false,
                minInput: 8,
              ),
              ColumnDivider(space: spaceMid),
              RegularTextField(
                controller: tecEmail,
                labelText: 'Email',
                labelStyle: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold),
                hintText: UserProvider.read(context).user?.email ?? 'Ketik Email Kamu',
                enabled: false,
                minInput: 8,
              ),
              ColumnDivider(space: spaceMid),
              cText(context, 'Alamat Rumah', style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ColumnDivider(space: spaceNear),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: paddingMid, vertical: 5),
                decoration: BoxDecoration(
                    color: ThemeColors.secondaryLowContrastRevert(context),
                    borderRadius: BorderRadius.circular(radiusTriangle),
                    border: Border.all(color: UserProvider.read(context).user?.address != null
                        ? ThemeColors.primary(context) : ThemeColors.secondaryRevert(context),
                        width: 2
                    )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: ThemeColors.primary(context), size: iconBtnMid),
                        RowDivider(),
                        Expanded(child: cText(context, 'Rumah Utama', style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cText(context,
                              UserProvider.watch(context).userAddressSelected.address != null
                                  ? (UserProvider.watch(context).userAddressSelected.address ?? 'Alamat tidak diketahui')
                                  : UserProvider.watch(context).user?.address ?? 'Alamat belum diatur',
                              align: TextAlign.justify
                          ),
                          ColumnDivider(),
                          cText(
                              context,
                              'Latitude: ${UserProvider.watch(context).userAddressSelected.latitude != 0
                                  ? UserProvider.watch(context).userAddressSelected.latitude
                                  : UserProvider.watch(context).user?.latitude ?? '-'}',
                              style: TextStyles.small(context).copyWith(color: ThemeColors.grey(context)),
                              align: TextAlign.start
                          ),
                          cText(
                              context,
                              'Longitude: ${UserProvider.watch(context).userAddressSelected.longitude != 0
                                  ? UserProvider.watch(context).userAddressSelected.longitude
                                  : UserProvider.watch(context).user?.longitude ?? '-'}',
                              style: TextStyles.small(context).copyWith(color: ThemeColors.grey(context)),
                              align: TextAlign.start
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ColumnDivider(space: spaceMid),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: paddingMid, vertical: 5),
                decoration: BoxDecoration(
                  color: ThemeColors.secondaryLowContrastRevert(context),
                  borderRadius: BorderRadius.circular(radiusTriangle),
                  border: Border.all(color: ThemeColors.danger(context), width: 2)
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, size: iconBtnBig, color: ThemeColors.danger(context)),
                    RowDivider(),
                    Expanded(
                      child: cText(context, "Harap pastikan data di atas sesuai dengan data Anda!\n"
                        "Kami tidak bertanggungjawab atas segala pemalsuan data oleh mitra. "
                        "Segala bentuk kepalsuan akan ditindak sesuai peraturan yang berlaku.",
                        align: TextAlign.justify
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessBottomSheet(BuildContext context) {
    showRegularBottomSheet(
      context: context,
      imagePath: exceptionComingsoon,
      title: 'Permintaan Berhasil!',
      description: "Kamu berhsil mengirimkan permintaan aktivasi layanan!\n"
          "Kami akan segera memproses permintaan kamu ya!",
      onTap: () async => startScreenRemoveAll(context, MainNavbarCustom()),
    );
  }
}