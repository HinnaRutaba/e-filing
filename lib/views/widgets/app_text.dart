import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

typedef TextBuilder = Text Function(BuildContext context);

// ignore: must_be_immutable
class AppText extends Text {
  AppText(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          color: color,
          height: height,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          decoration: decoration,
          fontFamily: fontFamily,
        ),
      );
    };
  }

  AppText.displayLarge(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.displayMedium(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.displaySmall(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.fontFamily,
    this.decoration,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.headlineLarge(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.headlineMedium(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.headlineSmall(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.titleLarge(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.titleMedium(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              decorationColor: AppColors.textPrimary,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.titleSmall(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.bodyLarge(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.bodyMedium(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.bodySmall(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.labelLarge(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.labelMedium(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  AppText.labelSmall(
    super.data, {
    super.key,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    super.textAlign,
    super.maxLines,
    super.overflow,
  }) {
    builder = (context) {
      return Text(
        data ?? '',
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              decoration: decoration,
              fontFamily: fontFamily,
            ),
      );
    };
  }

  late TextBuilder builder;

  final Color? color;

  final double? height;

  final double? fontSize;

  final FontWeight? fontWeight;

  final double? letterSpacing;

  final TextDecoration? decoration;

  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return builder.call(context);
  }
}
