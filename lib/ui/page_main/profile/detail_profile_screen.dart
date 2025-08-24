import 'dart:io';

import 'package:agent/core/constant_values/assets_values.dart';
import 'package:agent/core/utilities/functions/media_func.dart';
import 'package:agent/core/utilities/functions/page_routes_func.dart';
import 'package:agent/ui/layouts/global_state_widgets/selected_item/list_radio_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constant_values/global_values.dart';
import '../../../core/models/_global_widget_model/country_data.dart';
import '../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../core/state_management/providers/auth/user_provider.dart';
import '../../../core/utilities/functions/input_func.dart';
import '../../../core/utilities/functions/logger_func.dart';
import '../../../core/utilities/functions/media_query_func.dart';
import '../../layouts/global_return_widgets/media_widgets_func.dart';
import '../../layouts/global_state_widgets/custom_scaffold/custom_appbar.dart';
import '../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../../layouts/global_state_widgets/divider/custom_divider.dart';
import '../../layouts/global_state_widgets/modal_bottom_sheet/regular_bottom_sheet.dart';
import '../../layouts/global_state_widgets/textfield/textfield_form/regular_form.dart';
import '../../layouts/styleconfig/textstyle.dart';
import '../../layouts/styleconfig/themecolors.dart';
import 'maps_update_user_location.dart';

class EditProfileScreen extends StatefulWidget {

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formEditProfileScreen = GlobalKey<FormState>();
  late final TextEditingController tecNama;
  late final TextEditingController tecNomor;
  late final TextEditingController tecEmail;

  CountryData? data = getCountryDataById(1);
  CountryData? dataSaved = getCountryDataById(1);
  int input = 0;
  XFile? takePhoto;
  bool setNewPhoto = false;

  @override
  void initState() {
    tecNama = TextEditingController(text: UserProvider.read(context).user?.name ?? '');
    tecNomor = TextEditingController(text: UserProvider.read(context).user?.phoneNumber ?? '');
    tecEmail = TextEditingController(text: UserProvider.read(context).user?.email ?? '');
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
      useSafeArea: true,
      useExtension: true,
      padding: EdgeInsets.all(paddingMid),
      backgroundColor: ThemeColors.onSurface(context),
      appBar: appBarWidget(
        context: context,
        title: 'Edit Profil',
        backgroundColor: ThemeColors.onSurface(context),
        showBackButton: true,
        labelButton: 'Simpan',
        onTap: (){
          if (_formEditProfileScreen.currentState!.validate()){

          }
        }
      ),
      body: _bodyWidget(context)
    );
  }

  Widget _setTabletLayout(BuildContext context){
    return CustomScaffold(
      useSafeArea: true,
      useExtension: true,
      padding: EdgeInsets.all(paddingMid),
      backgroundColor: ThemeColors.onSurface(context),
      appBar: appBarWidget(
        context: context,
        title: 'Edit Profil',
        backgroundColor: ThemeColors.onSurface(context),
        showBackButton: true,
        labelButton: 'Simpan',
        onTap: (){
          Navigator.pop(context);
        }
      ),
      body: _bodyWidget(context)
    );
  }

  Widget _bodyWidget(BuildContext context){
    return Form(
      key: _formEditProfileScreen,
      child: ListView(
        children: [
          Column(
            children: [
              SizedBox(
                width: getMediaQueryWidth(context) * .4,
                height: getMediaQueryWidth(context) * .4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    loadCircleImage(context: context,
                        fileImage: setNewPhoto ? File(takePhoto!.path) : null,
                        imageAssetPath: setNewPhoto ? null : avatarDummy,
                        radius: 80),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(color: ThemeColors.primary(context), borderRadius: BorderRadius.circular(radiusCircle)),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white, size: iconBtnMid),
                          onPressed: () => _showModalPhotoChanger(context),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          ColumnDivider(space: spaceFar),
          RegularTextField(
            controller: tecNama,
            labelText: 'Nama Lengkap',
            labelStyle: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold),
            hintText: UserProvider.read(context).user?.name ?? 'Ketik Nama Kamu',
            keyboardType: TextInputType.number,
            minInput: 8,
          ),
          ColumnDivider(space: spaceMid),
          cText(context, 'Jenis Kelamin', style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold)),
          CustomRadioButtonGroup(listRadioItem: ['Laki-laki', 'Perempuan'], onSelected: (value) => clog(value)),
          ColumnDivider(space: spaceNear),
          cText(context, 'Nomor Telepon', style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold)),
          ColumnDivider(),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await showRegularBottomSheet<CountryData>(
                    context: context,
                    showCountryDataOption: true,
                    multiplierHeight: .8,
                    title: 'Cari kode negara',
                  ).then((value) => setState((){
                    if (value != null) {
                      data = value;
                      dataSaved = value;
                    } else {
                      data = dataSaved;
                    }
                  }));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: paddingNear * .5, horizontal: paddingMid),
                  decoration: BoxDecoration(color: ThemeColors.secondaryLowContrastRevert(context), borderRadius: BorderRadius.circular(radiusCircle),
                      border: Border.all(color: ThemeColors.primary(context).withValues(alpha: .3), width: 2)
                  ),
                  child: Row(
                    children: [
                      cText(context, data?.dialCode ?? ''),
                      Icon(Icons.keyboard_arrow_down_rounded, size: iconBtnMid, color: ThemeColors.primary(context)),
                    ],
                  ),
                ),
              ),
              RowDivider(),
              Expanded(
                flex: 6,
                child: RegularTextField(
                  controller: tecNomor,
                  hintText: 'Masukkan nomor telepon kamu',
                  keyboardType: TextInputType.number,
                  minInput: 8,
                ),
              ),
            ],
          ),
          ColumnDivider(space: spaceMid),
          RegularTextField(
            controller: tecEmail,
            labelText: 'Email',
            labelStyle: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold),
            hintText: UserProvider.read(context).user?.email ?? 'Ketik Email Kamu',
            keyboardType: TextInputType.number,
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
                width: 2)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: ThemeColors.primary(context), size: iconBtnMid),
                    RowDivider(),
                    Expanded(child: cText(context, 'Rumah Utama', style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold))),
                    RowDivider(),
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(radiusCircle),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: ThemeColors.primary(context),
                          overlayColor: ThemeColors.primary(context),
                          visualDensity: VisualDensity.compact
                        ),
                        child: cText(context, 'Edit', style: TextStyles.medium(context)),
                        onPressed: () {
                          startScreenSwipe(context, MapsUpdateUserLocation());
                        }
                      ),
                    ),
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
          )
        ],
      ),
    );
  }

  Future<void> _showModalPhotoChanger(BuildContext context) async {
    await showRegularBottomSheet(
      context: context,
      multiplierHeight: .6,
      title: 'Ubah Foto Profil',
      onTap: () async {
        setState(() {
          setNewPhoto = true;
          Navigator.pop(context);
        });
      },
      child: _onPhotoChangerLayout(context)
    );
  }

  Widget _onPhotoChangerLayout(BuildContext context){
    return StatefulBuilder(
      builder: (context, setState) {
        return Expanded(
          child: Column(
            children: [
              loadCircleImage(
                context: context,
                imageUrl: UserProvider.read(context).user?.avatarUrl,
                fileImage: takePhoto != null
                    ? File(takePhoto!.path)
                    : UserProvider.read(context).user?.avatarUrl != null
                    ? File(UserProvider.read(context).user?.avatarUrl ?? '') : null,
                backgroundColor: Colors.grey,
                radius: getMediaQueryWidth(context) * .25,
              ),
              ColumnDivider(space: spaceMid),
              TextButton(
                style: ButtonStyle(),
                onPressed: () async {
                  XFile? photo = await getMediaFromCamera();
                  if (photo != null) setState(() => takePhoto = photo);
                },
                child: Row(
                  children: [
                    Icon(Icons.camera),
                    RowDivider(),
                    cText(context, 'Ambil Foto', style: TextStyles.medium(context).copyWith(fontWeight: FontWeight.bold))
                  ],
                )
              ),
              ColumnDivider(),
              TextButton(
                onPressed: () async {
                  XFile? photo = await getMediaFromGallery();
                  if (photo != null) setState(() => takePhoto = photo);
                },
                child: Row(
                  children: [
                    Icon(Icons.photo),
                    RowDivider(),
                    cText(context, 'Buka Galeri', style: TextStyles.medium(context).copyWith(fontWeight: FontWeight.bold))
                  ],
                )
              ),
            ],
          ),
        );
      }
    );
  }
}
