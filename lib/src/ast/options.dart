import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../font/metrics/font_metrics.dart';
import 'font_metrics.dart';
import 'size.dart';
import 'style.dart';

class Options {
  final double baseSizeMultiplier;
  final MathStyle style;
  final Color color;
  SizeMode get size => sizeUnderTextStyle.underStyle(style);
  final SizeMode sizeUnderTextStyle;
  final FontOptions textFontOptions;
  final FontOptions mathFontOptions;
  double get sizeMultiplier => this.size.sizeMultiplier;
  // final double maxSize;
  // final num minRuleThickness; //???
  // final bool isBlank;

  FontMetrics get fontMetrics => getGlobalMetrics(size);
  double get fontSize => 1.0.cssEm.toLpUnder(this);

  const Options({
    this.baseSizeMultiplier = 1,
    @required this.style,
    this.color = Colors.black,
    this.sizeUnderTextStyle = SizeMode.normalsize,
    this.textFontOptions,
    this.mathFontOptions,
    // @required this.maxSize,
    // @required this.minRuleThickness,
  });

  static const displayOptions = Options(
    style: MathStyle.display,
  );
  static const textOptions = Options(
    style: MathStyle.text,
  );

  Options havingStyle(MathStyle style) {
    if (this.style == style) return this;
    return this.copyWith(
      style: style,
    );
  }

  Options havingCrampedStyle() {
    if (this.style.cramped) return this;
    return this.copyWith(
      style: style.cramp(),
    );
  }

  Options havingSize(SizeMode size) {
    if (this.size == size && this.sizeUnderTextStyle == size) return this;
    return this.copyWith(
      style: style.atLeastText(),
      sizeUnderTextStyle: size,
    );
  }

  Options havingStyleUnderBaseSize(MathStyle style) {
    style = style ?? this.style.atLeastText();
    if (this.sizeUnderTextStyle == SizeMode.normalsize && this.style == style) {
      return this;
    }
    return this.copyWith(
      style: style,
      sizeUnderTextStyle: SizeMode.normalsize,
    );
  }

  Options havingBaseSize() {
    if (this.sizeUnderTextStyle == SizeMode.normalsize) return this;
    return this.copyWith(
      sizeUnderTextStyle: SizeMode.normalsize,
    );
  }

  Options withColor(Color color) {
    if (this.color == color) return this;
    return this.copyWith(color: color);
  }

  Options withTextFont(PartialFontOptions font) => this.copyWith(
        mathFontOptions: null,
        textFontOptions:
            (this.textFontOptions ?? FontOptions()).mergeWith(font),
      );

  Options withMathFont(FontOptions font) {
    if (font == this.mathFontOptions) return this;
    return this.copyWith(mathFontOptions: font);
  }

  Color getColor() =>
      // this.phantom ? Color(0x00000000) :
      this.color;

  Options copyWith({
    double baseSizeMultiplier,
    MathStyle style,
    Color color,
    SizeMode sizeUnderTextStyle,
    FontOptions textFontOptions,
    FontOptions mathFontOptions,
    // double maxSize,
    // num minRuleThickness,
  }) =>
      Options(
        baseSizeMultiplier: baseSizeMultiplier ?? this.baseSizeMultiplier,
        style: style ?? this.style,
        color: color ?? this.color,
        sizeUnderTextStyle: sizeUnderTextStyle ?? this.sizeUnderTextStyle,
        textFontOptions: textFontOptions ?? this.textFontOptions,
        mathFontOptions: mathFontOptions ?? this.mathFontOptions,
        // maxSize: maxSize ?? this.maxSize,
        // minRuleThickness: minRuleThickness ?? this.minRuleThickness,
      );

  Options merge(OptionsDiff partialOptions) {
    var res = this;
    if (partialOptions.size != null) {
      res = res.havingSize(partialOptions.size);
    }
    if (partialOptions.style != null) {
      res = res.havingStyle(partialOptions.style);
    }
    if (partialOptions.color != null) {
      res = res.withColor(partialOptions.color);
    }
    // if (partialOptions.phantom == true) {
    //   res = res.withPhantom();
    // }
    if (partialOptions.textFontOptions != null) {
      res = res.withTextFont(partialOptions.textFontOptions);
    }
    if (partialOptions.mathFontOptions != null) {
      res = res.withMathFont(partialOptions.mathFontOptions);
    }
    return res;
  }
}

class OptionsDiff {
  final MathStyle style;
  final SizeMode size;

  final Color color;
  // final bool phantom;
  // SizeMode get size => sizeUnderTextStyle.underStyle(style);
  // final SizeMode sizeUnderTextStyle;
  final PartialFontOptions textFontOptions;
  final FontOptions mathFontOptions;
  FontMetrics get fontMetrics => getGlobalMetrics(size);
  const OptionsDiff({
    this.style,
    this.color,
    this.size,
    // this.phantom,
    this.textFontOptions,
    this.mathFontOptions,
  });
}

class PartialFontOptions extends FontOptions {
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontShape;
  const PartialFontOptions({
    this.fontFamily,
    this.fontWeight,
    this.fontShape,
  });
}

class FontOptions {
  // final String font;
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontShape;
  final List<FontOptions> fallback;
  const FontOptions({
    // @required this.font,
    this.fontFamily = 'Main',
    this.fontWeight = FontWeight.normal,
    this.fontShape = FontStyle.normal,
    this.fallback = const [],
  });

  String get fontName {
    final postfix = '${fontWeight == FontWeight.bold ? 'Bold' : ''}'
        '${fontShape == FontStyle.italic ? "Italic" : ""}';
    return '$fontFamily-${postfix.isEmpty ? "Regular" : postfix}';
  }

  FontOptions copyWith({
    String fontFamily,
    FontWeight fontWeight,
    FontStyle fontShape,
  }) =>
      FontOptions(
        fontFamily: fontFamily ?? this.fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontShape: fontShape ?? this.fontShape,
      );

  FontOptions mergeWith(PartialFontOptions value) {
    if (value == null) return this;
    return copyWith(
      fontFamily: value.fontFamily,
      fontWeight: value.fontWeight,
      fontShape: value.fontShape,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FontOptions &&
        o.fontFamily == fontFamily &&
        o.fontWeight == fontWeight &&
        o.fontShape == fontShape;
  }

  @override
  int get hashCode =>
      hashValues(fontFamily.hashCode, fontWeight.hashCode, fontShape.hashCode);
}
