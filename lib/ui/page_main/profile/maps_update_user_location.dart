import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../core/constant_values/_setting_value/log_app_values.dart';
import '../../../core/constant_values/enum_values.dart';
import '../../../core/constant_values/global_values.dart';
import '../../../core/state_management/providers/_global_widget/google_maps_provider.dart';
import '../../../core/state_management/providers/_global_widget/location_provider.dart';
import '../../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../../core/state_management/providers/auth/user_provider.dart';
import '../../../core/utilities/functions/logger_func.dart';
import '../../../core/utilities/functions/media_query_func.dart';
import '../../../core/utilities/functions/system_func.dart';
import '../../../core/utilities/local_storage/sqflite/services/_setting_services/log_app_services.dart';
import '../../layouts/global_return_widgets/helper_widgets_func.dart';
import '../../layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import '../../layouts/global_state_widgets/custom_scaffold/custom_appbar.dart';
import '../../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../../layouts/global_state_widgets/dialog/dialog_action/custom_dialog.dart';
import '../../layouts/global_state_widgets/divider/custom_divider.dart';
import '../../layouts/global_state_widgets/modal_bottom_sheet/regular_bottom_sheet.dart';
import '../../layouts/global_state_widgets/textfield/textfield_form/regular_form.dart';
import '../../layouts/styleconfig/textstyle.dart';
import '../../layouts/styleconfig/themecolors.dart';

class MapsUpdateUserLocation extends StatelessWidget {
  const MapsUpdateUserLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceSettingProvider>(
      builder: (context, provider, child) {
        if (provider.isTabletMode.condition) {
          if (getMediaQueryWidth(context) > provider.tabletModePixel.value) return _setTabletLayout(context);
          if (getMediaQueryWidth(context) < provider.tabletModePixel.value) return _setPhoneLayout(context);
        }
        return _setPhoneLayout(context);
      }
    );
  }

  Widget _setPhoneLayout(BuildContext context) {
    return CustomScaffold(
      padding: EdgeInsets.zero,
      appBar: appBarWidget(context: context, title: 'Maps', showBackButton: true,
        onPopupMenuSelected: (value) async {
          switch (value) {
            case '0': {
              Provider.of<LocationProvider>(context, listen: false).getRouteOnGoogleMaps(context); break;
            }
          }
        },
        popupMenuItemBuilder: (context){
          return [
            popupMenuItem(context, '0', 'Buat Rute', Icons.maps_home_work, ThemeColors.blue(context)),
          ];
        }
      ),
      body: _bodyWidget(context)
    );
  }

  Widget _setTabletLayout(BuildContext context) {
    return CustomScaffold(
      padding: EdgeInsets.zero,
      appBar: appBarWidget(context: context, title: 'Maps', showBackButton: true,
        onPopupMenuSelected: (value) async {
          switch (value) {
            case '0': {
              Provider.of<LocationProvider>(context, listen: false).getRouteOnGoogleMaps(context); break;
            }
          }
        },
        popupMenuItemBuilder: (context){
          return [
            popupMenuItem(context, '0', 'Buat Rute', Icons.maps_home_work, ThemeColors.blue(context)),
          ];
        }
      ),
      body: _bodyWidget(context)
    );
  }

  Widget _bodyWidget(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = GoogleMapsProvider(context);
        provider.initialize();
        return provider;
      },
      child: Consumer2<GoogleMapsProvider, LocationProvider>(
        builder: (context, provider, locationProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: true,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapType: provider.mapType,
                      initialCameraPosition: CameraPosition(target: provider.startLocation, zoom: 3.65), // Default full map Indonesia: 3.65,
                      onMapCreated: (controller) async {
                        try {
                          if (locationProvider.geocodingModel.latitude == 0.0 || locationProvider.geocodingModel.longitude == 0.0) await locationProvider.getCurrentUserLocation(context, initFromMaps: true);
                          provider.setMapsCompleterController(controller);
                          provider.setMapsController(controller);
                          provider.mapController!.animateCamera(duration: Duration(milliseconds: 250), CameraUpdate.newCameraPosition(
                              CameraPosition(target: LatLng(locationProvider.geocodingModel.latitude, locationProvider.geocodingModel.longitude), zoom: 18)));
                        } catch (e, s){
                          clog('Terjadi masalah saat onMapCreated! $e\n$s');
                          await addLogApp(level: ListLogAppLevel.critical.level, title: e.toString(), logs: s.toString());
                        }
                      },
                      onCameraMove: (CameraPosition cameraPositions) {
                        provider.setCameraPosition(cameraPositions);
                        provider.setMapsState(GoogleMapsState.loading);
                      },
                      onCameraIdle: () async {
                        if (provider.mapState == GoogleMapsState.loading){
                          bool conn = await checkInternetConnectivity();
                          if (conn){
                            if (provider.cameraPosition != null){
                              locationProvider.reset();
                              await locationProvider.getLocationFromMaps(provider.cameraPosition!.target.latitude, provider.cameraPosition!.target.longitude);
                              provider.setMapsState(GoogleMapsState.success);
                            } else {
                              showToastTop(context, 'Posisi Kamera Kosong');
                              provider.setMapsState(GoogleMapsState.failed);
                            }
                          } else {
                            showToastTop(context, 'Koneksi internet terputus!');
                            provider.setMapsState(GoogleMapsState.failed);
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: getMediaQueryHeight(context) * .12),
                ],
              ),
              _latLongInfo(context, locationProvider, provider.mapType == MapType.satellite ? true : false),
              if (provider.mapState == GoogleMapsState.loading || provider.mapState == GoogleMapsState.success || provider.mapState == GoogleMapsState.failed)
                Center(child: Padding(padding: EdgeInsets.only(bottom: getMediaQueryHeight(context) * .15), child: Icon(Icons.location_on, color: ThemeColors.red(context), size: iconBtnBig))),
              _onLoadingLayout(context, provider.mapState.text, provider),
              if (provider.mapState == GoogleMapsState.success || provider.mapState == GoogleMapsState.failed) _onAddressLayout(context, provider, locationProvider)
            ],
          );
        },
      ),
    );
  }

  Widget _latLongInfo(BuildContext context, LocationProvider provider, bool isSattelite){
    return Positioned(top: paddingNear, left: 0, right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cText(context, provider.geocodingModel.latitude.toString(),
            style: TextStyles.small(context).copyWith(color: isSattelite ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          RowDivider(),
          cText(context, provider.geocodingModel.longitude.toString(),
            style: TextStyles.small(context).copyWith(color: isSattelite ? Colors.white : Colors.black, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _onLoadingLayout(BuildContext context, String text, GoogleMapsProvider provider){
    return Positioned(bottom: paddingMid, left: paddingMid, right: paddingMid, child: Padding(
      padding: const EdgeInsets.all(paddingFar),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: cText(
                context,
                provider.mapState == GoogleMapsState.initial ? 'Menyiapkan Peta' : text,
                align: TextAlign.start, style: TextStyles.large(context).copyWith(fontWeight: FontWeight.bold))),
              LoadingAnimationWidget.inkDrop(color: ThemeColors.primary(context), size: iconBtnMid)
            ],
          ),
          cText(
            context,
              provider.mapState == GoogleMapsState.initial
                ? 'Tunggu sebentar ya!\nProses ini tidak lama kok'
                : 'Pencarian mungkin memerlukan beberapa detik!\nHarap tunggu sebentar, ya',
            maxLines: 2,
            align: TextAlign.start
          ),
        ],
      ),
    ),
    );
  }

  Widget _onAddressLayout(BuildContext context, GoogleMapsProvider provider, LocationProvider locationProvider){
    return Positioned(bottom: 0, left: 0, right: 0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(paddingMid, 0, paddingMid, paddingMid),
            decoration: BoxDecoration(
              color: ThemeColors.onSurface(context),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(radiusDiamond), topRight: Radius.circular(radiusDiamond)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: paddingNear),
                  child: Row(
                    children: [
                      Expanded(child: cText(context, 'Tambah Alamat', align: TextAlign.start, style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold))),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimateProgressButton(
                          labelButton: provider.mapSearchTechnology.text,
                          containerRadius: radiusCircle,
                          useShadow: false,
                          height: heightShort * 1.2,
                          onTap: () async {
                            await showSearchLocation(context, provider);
                          },
                        ),
                      ),
                      IconButton(onPressed: provider.changeSearchMapTechnology, icon: Icon(Icons.change_circle, color: ThemeColors.orange(context))),
                      IconButton(onPressed: provider.changeMapTerrain, icon: Icon(Icons.map_outlined, color: ThemeColors.green(context)), visualDensity: VisualDensity.compact),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(paddingMid),
                  decoration: BoxDecoration(color: ThemeColors.secondaryRevert(context), borderRadius: BorderRadiusGeometry.circular(radiusTriangle)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_rounded),
                      RowDivider(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cText(context, '${locationProvider.subLocality}, ${locationProvider.locality}', align: TextAlign.start,
                              style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold)),
                            cText(context, locationProvider.geocodingModel.address ?? 'unknown', align: TextAlign.start),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if (locationProvider.geocodingModel.latitude != 0.0 && locationProvider.geocodingModel.longitude != 0.0 && locationProvider.geocodingModel.address != "")...[
                  ColumnDivider(),
                  AnimateProgressButton(
                    labelButton: 'Konfirmasi',
                    useArrow: true,
                    enable: locationProvider.geocodingModel.address == 'Indonesia' ? false : true,
                    onTap: () async {
                      await UserProvider.read(context).setUserAddressSelected(locationProvider.geocodingModel);
                      Navigator.pop(context);
                    },
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _onLocationListLayout(BuildContext context, GoogleMapsProvider provider) {
    return Column(
      children: [
        if (provider.isExpanded)...[
          ColumnDivider(),
          ListView.separated(
            shrinkWrap: true,
            itemCount: provider.option.length,
            separatorBuilder: (context, index) => ColumnDivider(space: paddingNear),
            itemBuilder: (context, index){
              final item = provider.option[index];
              return GestureDetector(
                onTap: () {
                  provider.mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(item.lat, item.lon), zoom: 18)));
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(paddingMid),
                  decoration: BoxDecoration(color: ThemeColors.secondaryRevert(context), borderRadius: BorderRadiusGeometry.circular(radiusTriangle)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_rounded, color: ThemeColors.primary(context), size: iconBtnMid),
                      RowDivider(),
                      Expanded(child: cText(context, item.displayname, align: TextAlign.start, style: TextStyles.semiLarge(context).copyWith(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              );
            },
          )
        ]
      ],
    );
  }

  Future<void> showSearchLocation(BuildContext context, GoogleMapsProvider provider) async {
    await showRegularBottomSheet(
      context: context,
      multiplierHeight: .9,
      title: provider.mapSearchTechnology.text,
      labelButton: 'CARI',
      onTap: () async {
        await provider.searchLocation();
        Navigator.pop(context);
        await showListLocations(context, provider);
      },
      child: Column(
        children: [
          RegularTextField(
            controller: provider.tecSearch,
            hintText: 'Ketik alamat yang ingin Anda cari',
            isRequired: true,
          ),
          if (provider.option.isNotEmpty)...[
            ColumnDivider(),
            cText(context, 'Hasil pencarian sebelumnya', align: TextAlign.start, style: TextStyles.large(context)),
            ColumnDivider(),
            _onLocationListLayout(context, provider)
          ]
        ],
      )
    );
  }

  Future<void> showListLocations(BuildContext context, GoogleMapsProvider provider) async {
    await showRegularBottomSheet(
      context: context,
      multiplierHeight: .9,
      title: 'Hasil Pencarian',
      onTap: () async => Navigator.pop(context),
      child: _onLocationListLayout(context, provider)
    );
  }
}