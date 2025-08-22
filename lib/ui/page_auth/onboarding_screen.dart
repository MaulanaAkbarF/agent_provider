import 'package:agent/ui/page_auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constant_values/assets_values.dart';
import '../../core/constant_values/global_values.dart';
import '../../core/constant_values/list_string_or_map_string_values.dart';
import '../../core/state_management/providers/_settings/appearance_provider.dart';
import '../../core/utilities/functions/media_query_func.dart';
import '../../core/utilities/functions/page_routes_func.dart';
import '../layouts/global_return_widgets/media_widgets_func.dart';
import '../layouts/global_state_widgets/button/button_progress/animation_progress.dart';
import '../layouts/global_state_widgets/custom_scaffold/custom_scaffold.dart';
import '../layouts/global_state_widgets/divider/custom_divider.dart';
import '../layouts/styleconfig/textstyle.dart';
import '../layouts/styleconfig/themecolors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNext() async {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onSkip();
    }
  }

  void _onSkip() async {
    if (!mounted) return;
    startScreenSwipe(context, LoginScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceSettingProvider>(
      builder: (context, provider, child) {
        if (provider.isTabletMode.condition) {
          if (getMediaQueryWidth(context) > provider.tabletModePixel.value) return _setTabletLayout(context);
          if (getMediaQueryWidth(context) < provider.tabletModePixel.value) return _setPhoneLayout(context);
        }
        return _setPhoneLayout(context);
      },
    );
  }

  Widget _setPhoneLayout(BuildContext context) {
    return CustomScaffold(
      canPop: false,
      useExtension: true,
      padding: EdgeInsets.zero,
      backgroundColor: ThemeColors.secondaryRevert(context),
      body: _bodyWidget(context),
    );
  }

  Widget _setTabletLayout(BuildContext context) {
    return CustomScaffold(
      canPop: false,
      useExtension: true,
      padding: EdgeInsets.zero,
      backgroundColor: ThemeColors.secondaryRevert(context),
      body: _bodyWidget(context),
    );
  }

  Widget _bodyWidget(BuildContext context) {
    return Stack(
      children: [
        loadImageAssetPNG(path: decorationOnboarding, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context)),
        loadImageAssetPNG(path: decorationTop, width: getMediaQueryWidth(context), height: getMediaQueryHeight(context)),
        _onTopLayout(context),
        _onCenterLayout(context),
        _onBottomLayout(context)
      ],
    );
  }

  Widget _onTopLayout (BuildContext context) {
    return Positioned(
      top: getMediaQueryHeight(context) * .05,
      right: 20,
      child: cText(context,'Gasskeun', style: TextStyles.semiLarge(context).copyWith(color: ThemeColors.surface(context)), onTap: () => _onSkip()),
    );
  }

  Widget _onCenterLayout(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 0,
      right: 0,
      bottom: getMediaQueryHeight(context) * .4,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          child: Container(
            key: ValueKey<int>(_currentPage),
            child: loadImageAssetSVG(
              path: '${getDefaultImageAssetPath()}on_boarding_${_currentPage + 1}.svg',
              width: getMediaQueryWidth(context) * .75,
              height:  getMediaQueryWidth(context) * .75,
            ),
          ),
        ),
      ),
    );
  }

  Widget _onBottomLayout (BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(paddingFar),
        child: Column(
          children: [
            Container(
              height: 220,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: isActive ? 24 : 6,
                          decoration: BoxDecoration(
                            color: isActive ? ThemeColors.primary(context) : ThemeColors.secondary(context),
                            borderRadius: BorderRadius.circular(radiusSquare * .3),
                          ),
                        );
                      },
                    ),
                  ),
                  ColumnDivider(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        if (mounted){
                          setState(() => _currentPage = index);
                        }
                      },
                      itemBuilder: (context, index) {
                        final item = onboardingData[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            cText(context, item['title']!, align: TextAlign.center, style: TextStyles.giant(context).copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                            ColumnDivider(),
                            cText(context, item['description']!, align: TextAlign.center, style: TextStyles.large(context).copyWith(color: Colors.black)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ColumnDivider(space: spaceMid),
            AnimateProgressButton(
              labelButton: _currentPage == onboardingData.length - 1 ? 'Mulai' : 'Selanjutnya',
              useArrow: true,
              onTap: () {
                _onNext();
              },
            )
          ],
        ),
      ),
    );
  }
}