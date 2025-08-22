import 'package:agent/ui/layouts/global_return_widgets/media_widgets_func.dart';
import 'package:agent/ui/layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import 'package:agent/ui/layouts/global_state_widgets/divider/custom_divider.dart';
import 'package:agent/ui/layouts/global_state_widgets/textfield/textfield_form/regular_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant_values/global_values.dart';
import '../../../../core/models/_global_widget_model/country_data.dart';
import '../../../../core/utilities/functions/input_func.dart';
import '../../../../core/utilities/functions/logger_func.dart';
import '../../../../core/utilities/functions/media_func.dart';
import '../../../../core/utilities/functions/media_query_func.dart';
import '../../styleconfig/textstyle.dart';
import '../../styleconfig/themecolors.dart';

Future<T?> showRegularBottomSheet<T>({
  required BuildContext context,
  double? multiplierHeight,
  String? imagePath,
  String? title,
  String? description,
  bool? showCountryDataOption,
  Widget? child,
  Future<T> Function()? onTap,
}) async {
  return await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(radiusDiamond), topRight: Radius.circular(radiusDiamond)),
      ),
      builder: (BuildContext context) => Container(
        height: getMediaQueryHeight(context, size: multiplierHeight ?? .5),
        decoration: BoxDecoration(
          color: ThemeColors.greyVeryLowContrast(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusDiamond)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(paddingVeryFar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if ((imagePath != null) && imagePath.contains('png')) ClipRRect(
                borderRadius: BorderRadius.circular(radiusDiamond),
                child: Padding(
                    padding: const EdgeInsets.only(bottom: paddingMid),
                    child: loadImageAssetPNG(path: imagePath,
                        height: multiplierHeight != null
                          ? getMediaQueryHeight(context, size: multiplierHeight * .4)
                          : getMediaQueryHeight(context, size: .2))),
              ),
              if ((imagePath != null) && imagePath.contains('svg')) ClipRRect(
                borderRadius: BorderRadius.circular(radiusDiamond),
                child: Padding(
                    padding: const EdgeInsets.only(bottom: paddingMid),
                    child: loadImageAssetSVG(path: imagePath,
                        height: multiplierHeight != null
                          ? getMediaQueryHeight(context, size: multiplierHeight * .5)
                          : getMediaQueryHeight(context, size: .25))),
              ),
              if (title != null)...[
                cText(context, title, align: TextAlign.center,
                    style: TextStyles.semiGiant(context).copyWith(
                        fontWeight: FontWeight.bold)),
                ColumnDivider()
              ],
              if (description != null)...[
                Expanded(child: Align(alignment: Alignment.topCenter,
                    child: cText(context, description, align: TextAlign.center,
                        style: TextStyles.semiLarge(context)))),
                ColumnDivider()
              ],
              if ((showCountryDataOption != null) && showCountryDataOption)...[
                ChangeNotifierProvider(
                  create: (context){
                    final provider = SearchCountryProvider();
                    provider.search();
                    return provider;
                  },
                  child: Consumer<SearchCountryProvider>(
                      builder: (context, provider, child) {
                        return Expanded(
                          child: Column(
                            children: [
                              RegularTextField(
                                controller: provider.tecSearch,
                                hintText: "Ketik nama atau kode negara",
                                prefixIcon: Icon(Icons.search_outlined, color: ThemeColors.primary(context), size: iconBtnMid),
                                containerColor: ThemeColors.secondaryRevert(context),
                                onChanged: (value) => provider.search(),
                              ),
                              ColumnDivider(),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: provider.filteredCountry.length,
                                  itemBuilder: (context, index){
                                    final data = provider.filteredCountry[index];
                                    if (data.id == 1 || data.id == 5) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ColumnDivider(),
                                          cText(context, data.id == 1 ? "Negara Populer" : "Semua Negara", style: TextStyles.medium(context).copyWith(fontWeight: FontWeight.w900)),
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            splashColor: ThemeColors.primary(context),
                                            leading: cText(context, data.flagEmoji, style: TextStyles.giant(context)),
                                            title: cText(context, data.name, style: TextStyles.medium(context).copyWith(color: ThemeColors.typographyHighContrast(context), fontWeight: FontWeight.bold)),
                                            trailing: cText(context, data.dialCode, style: TextStyles.medium(context)),
                                            onTap: () => Navigator.pop(context, data),
                                          ),
                                        ],
                                      );
                                    }
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      splashColor: ThemeColors.primary(context),
                                      leading: cText(context, data.flagEmoji, style: TextStyles.giant(context)),
                                      title: cText(context, data.name, style: TextStyles.medium(context).copyWith(color: ThemeColors.typographyHighContrast(context), fontWeight: FontWeight.bold)),
                                      trailing: cText(context, data.dialCode, style: TextStyles.medium(context)),
                                      onTap: () => Navigator.pop(context, data),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      }
                  ),
                ),
              ],
              if (child != null) child,
              ColumnDivider(),
              if (showCountryDataOption == null || !showCountryDataOption) AnimateProgressButton(
                onTap: () async {
                  if (onTap == null) return;
                  Navigator.pop(context, await onTap());
                }
              )
            ],
          ),
        ),
      )
  );
}

class SearchCountryProvider extends ChangeNotifier {
  final TextEditingController _tecSearch = TextEditingController();
  List<CountryData> _filteredCountry = [];

  TextEditingController get tecSearch => _tecSearch;
  List<CountryData> get filteredCountry => _filteredCountry;

  void search(){
    if (tecSearch.text.trim() == '' || tecSearch.text.isEmpty) _filteredCountry = convertToCountryData();
    _filteredCountry = convertToCountryData().where((c) => c.name.toLowerCase().contains(tecSearch.text.toLowerCase()) || c.dialCode.contains(tecSearch.text)).toList();
    notifyListeners();
  }
}