import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../core/constant_values/global_values.dart';
import '../../../styleconfig/textstyle.dart';
import '../../../styleconfig/themecolors.dart';
import '../../divider/custom_divider.dart';

class AnimateProgressButton extends StatefulWidget {
  final Function onTap;
  final String? semantics;
  final String? labelButton;
  final String? labelProgress;
  final EdgeInsets? margin;
  final EdgeInsets? marginButtonLabel;
  final MainAxisAlignment? mainAxisAlignment;
  final double? width;
  final double? height;
  final Color? progressColor;
  final Color? containerColor;
  final Color? containerColorStart;
  final Color? containerColorEnd;
  final double? containerOpacity;
  final double? containerRadius;
  final Color? shadowColor;
  final Offset? shadowOffset;
  final double? shadowBlurRadius;
  final Color? borderColor;
  final double? borderOpacity;
  final double? borderRadius;
  final double? borderSize;
  final double? xPosition;
  final double? yPosition;
  final TextAlign? textAlign;
  final TextStyle? labelButtonStyle;
  final Icon? icon;
  final Widget? image;
  final bool? fitButton;
  final bool? useArrow;
  final bool? useInkWell;
  final bool? useShadow;
  final bool? enable;
  final Color? arrowColor;
  final Color? splashColorInkWell;
  final Color? highlightColorInkWell;
  final Function(bool)? onHover;

  const AnimateProgressButton({
    super.key,
    required this.onTap,
    this.semantics,
    this.labelButton,
    this.labelProgress,
    this.margin,
    this.marginButtonLabel,
    this.mainAxisAlignment,
    this.width,
    this.height,
    this.progressColor,
    this.containerColor,
    this.containerColorStart,
    this.containerColorEnd,
    this.containerOpacity,
    this.containerRadius,
    this.shadowColor,
    this.shadowOffset,
    this.shadowBlurRadius,
    this.borderColor,
    this.borderOpacity,
    this.borderRadius,
    this.borderSize,
    this.xPosition,
    this.yPosition,
    this.textAlign,
    this.labelButtonStyle,
    this.icon,
    this.image,
    this.fitButton,
    this.useArrow,
    this.useInkWell = true,
    this.useShadow = true,
    this.enable = true,
    this.arrowColor,
    this.splashColorInkWell,
    this.highlightColorInkWell,
    this.onHover
  });

  @override
  AnimateProgressButtonState createState() => AnimateProgressButtonState();
}

class AnimateProgressButtonState extends State<AnimateProgressButton> with SingleTickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCirc);
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(_curvedAnimation);
    _positionAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(widget.xPosition ?? 0.0, widget.yPosition ?? -1.0)).animate(_curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semantics ?? widget.labelButton,
      child: Container(
        margin: widget.margin,
        width: widget.fitButton != null && widget.fitButton! ? widget.width : null,
        height: widget.height ?? heightTall,
        constraints: const BoxConstraints(minHeight: 20),
        decoration: BoxDecoration(
          gradient: (widget.containerColorStart != null && widget.containerColorEnd != null)
              ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [widget.containerColorStart ?? Colors.transparent, widget.containerColorEnd ?? Colors.transparent]) : null,
          color: (widget.containerColorStart != null && widget.containerColorEnd != null) ? null
              : widget.containerColor != null ? widget.containerColor?.withValues(alpha: widget.containerOpacity
              ?? (widget.containerColor! == Colors.transparent ? 0.0 : (widget.enable != null) && widget.enable! ? 1.0: .3))
              : ThemeColors.primary(context).withValues(alpha: (widget.enable != null) && widget.enable! ? 1.0 : .3),
          borderRadius: BorderRadius.circular(widget.containerRadius ?? radiusTriangle),
          border: Border.all(color: widget.borderColor?.withValues(alpha: widget.borderOpacity ?? 1.0) ?? Colors.transparent, width: widget.borderSize ?? 1),
          boxShadow: (widget.enable != null) && !widget.enable! ? [] : widget.useShadow == false ? [] : widget.shadowColor == null ? [
            BoxShadow(
              color: ThemeColors.primary(context).withValues(alpha: .4),
              offset: const Offset(0, 3),
              blurRadius: shadowBlueHigh,
              spreadRadius: shadowSpreadHigh
            ),
          ] : [
            BoxShadow(
              color: widget.shadowColor!.withValues(alpha: .15),
              offset: widget.shadowOffset ?? const Offset(0, 1),
              blurRadius: widget.shadowBlurRadius ?? shadowBlurLow,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.containerRadius ?? radiusSquare),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onHover: kIsWeb ? widget.onHover : null,
              splashColor: widget.useInkWell != null && widget.useInkWell!
                  ? widget.splashColorInkWell != null ? widget.splashColorInkWell! : ThemeColors.surface(context).withValues(alpha: 0.2) : Colors.transparent,
              highlightColor: widget.useInkWell != null && widget.useInkWell!
                  ? widget.highlightColorInkWell != null ? widget.highlightColorInkWell! : ThemeColors.surface(context).withValues(alpha: 0.4) : Colors.transparent,
              onTap: () async {
                if ((widget.enable != null) && widget.enable! && !_loading) {
                  setState(() => _loading = true);
                  await widget.onTap();
                  try {
                    if (mounted){
                      _controller.reverse();
                      if (mounted) _controller.forward();
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) _controller.reverse();
                    }
                  } catch (e, s) {
                    print('Terjadi masalah di animasi pada AnimateProgressButtonState: $e\n$s');
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                }
              },
              child: Padding(
                padding: widget.marginButtonLabel ?? EdgeInsets.symmetric(horizontal: paddingMid),
                child: Row(
                  mainAxisSize: widget.fitButton != null && widget.fitButton! ? MainAxisSize.min : MainAxisSize.max,
                  mainAxisAlignment: widget.mainAxisAlignment != null ? widget.mainAxisAlignment! : MainAxisAlignment.center,
                  children: [
                    if (_loading) SizedBox(
                        width: widget.height != null ? widget.height! * 0.5 : 20,
                        height: widget.height != null ? widget.height! * 0.5 : 20,
                        child: LoadingAnimationWidget.discreteCircle(
                          color: widget.progressColor ?? ThemeColors.surface(context),
                          size: widget.height != null ? widget.height! * 0.5 : 20,
                          secondRingColor: ThemeColors.blue(context),
                          thirdRingColor: ThemeColors.green(context)
                        ),
                      ),
                    if (_loading) RowDivider(),
                    if (!_loading) AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? child) {
                          return Opacity(
                            opacity: _opacityAnimation.value,
                            child: Transform.translate(
                              offset: _positionAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: widget.image != null
                          ? SizedBox(
                              width: widget.height != null ? widget.height! * 0.75 : 30,
                              height: widget.height != null ? widget.height! * 0.75 : 30,
                              child: widget.image,
                            ) : (widget.icon ?? SizedBox()),
                      ),
                    if (widget.image != null || widget.icon != null) RowDivider(),
                    if (!_loading && widget.icon != null || !_loading && widget.image != null) RowDivider(),

                    if (widget.useArrow != null && widget.useArrow!)
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (BuildContext context, Widget? child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.translate(
                                offset: _positionAnimation.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: widget.textAlign == TextAlign.start ? Alignment.centerLeft : Alignment.center,
                                      child: cText(
                                        context,
                                        _loading ? widget.labelProgress ?? 'Memproses' : widget.labelButton ?? 'Konfirmasi',
                                        align: widget.textAlign ?? TextAlign.center,
                                        maxLines: 1,
                                        style: widget.labelButtonStyle ?? TextStyles.medium(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Align(alignment: Alignment.centerRight,
                                        child: Icon(Icons.arrow_forward, size: iconBtnMid, color: widget.arrowColor ?? ThemeColors.onSurface(context)))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? child) {
                          return Opacity(
                            opacity: _opacityAnimation.value,
                            child: Transform.translate(
                              offset: _positionAnimation.value,
                              child: Align(
                                alignment: widget.textAlign == TextAlign.start ? Alignment.centerLeft : Alignment.center,
                                child: cText(
                                  context,
                                  _loading ? widget.labelProgress ?? 'Memproses' : widget.labelButton ?? 'Konfirmasi',
                                  align: widget.textAlign,
                                  maxLines: 1,
                                  style: widget.labelButtonStyle ?? TextStyles.medium(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}