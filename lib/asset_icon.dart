/// A widget that displays an icon from the assets folder, with support for PNG and SVG formats.
///
/// This widget allows customization of the icon's size, color, opacity, and semantic labels.
/// It also supports global settings for default color and asset path.
library asset_icon;

import './asset_icon_label_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A [StatelessWidget] that displays an asset image or SVG icon.
class AssetIcon extends StatelessWidget {
  /// The default color for the icons when not specified in the constructor.
  static Color? _defaultColor;

  /// The default path where icons are located. The default value is `assets/icons/`.
  static String _defaultPath = "assets/icons/";

  static TextStyle? _defaultLabelStyle;

  static AssetIconLabelPosition _defaultPosition = AssetIconLabelPosition.bottom;

  /// The name of the icon file, including its extension (e.g., `icon.png` or `icon.svg`).
  final String iconName;

  /// The size of the icon. If not specified, it defaults to the size defined by the icon theme or 25.
  final double? size;

  /// The opacity of the icon, ranging from 0.0 (fully transparent) to 1.0 (fully opaque).
  /// If not specified, it defaults to 1.0 or the opacity defined by the icon theme.
  final double? opacity;

  /// The color to use when drawing the icon. If not specified, it uses the default color or
  /// falls back to the color defined in the icon theme or black.
  final Color? color;

  /// A semantic label for the icon, used by screen readers to provide context to visually impaired users.
  final String? semanticLabel;

  final String? label;

  final AssetIconLabelPosition? position;

  final TextStyle? labelStyle;

  /// Creates an [AssetIcon] widget.
  ///
  /// [iconName] is required and should include the file extension (e.g., `icon.png` or `icon.svg`).
  const AssetIcon(
    this.iconName, {
    super.key,
    this.size,
    this.color,
    this.opacity,
    this.semanticLabel,
  })  : label = null,
        position = null,
        labelStyle = null;

  const AssetIcon.withLabel(
    this.iconName, {
    super.key,
    this.size,
    this.color,
    this.opacity,
    this.label,
    this.position,
    this.labelStyle,
  }) : semanticLabel = label;

  /// This method allows the user to configure the default settings for the icon
  /// widget, including the default color, asset path, label style, and label position.
  ///
  /// [defaultColor] The global default color for icons. If `null`, the widget uses
  /// the default color defined in the icon theme or black.
  /// [defaultPath] The global default path where icons are located. If `null`,
  /// it uses the path `assets/icons/`.
  /// [defaultLabelStyle] The default style for the icon label. If `null`, it falls
  /// back to a predefined style or no style at all.
  /// [defaultPosition] The default position for the icon label. If `null`, no label
  /// is displayed.
  static settings(
      {Color? defaultColor,
      String? defaultPath,
      TextStyle? defaultLabelStyle,
      AssetIconLabelPosition? defaultPosition}) {
    if (defaultColor != null) {
      _defaultColor = defaultColor;
    }
    if (defaultPath != null) {
      _defaultPath = defaultPath;
    }
    if (defaultLabelStyle != null) {
      _defaultLabelStyle = defaultLabelStyle;
    }
    if (defaultPosition != null) {
      _defaultPosition = defaultPosition;
    }
  }

  static get path => _defaultPath;

  @override
  Widget build(BuildContext context) {
    // Retrieve the current icon theme from the context
    final iconTheme = IconTheme.of(context);
    final iconOpacity = opacity ?? iconTheme.opacity ?? 1.0;
    if (label != null) {
      return _buildWithLabel(context, iconOpacity, iconTheme);
    }
    return _buildIcon(context, iconOpacity, iconTheme);
  }

  /// Builds the icon widget without applying additional opacity.
  ///
  /// This method creates the icon widget based on the current icon opacity and theme.
  /// If the opacity is less than 1.0, the icon will be wrapped with an `Opacity` widget.
  /// Otherwise, it directly renders the base icon.
  ///
  /// [context] The build context for the widget.
  /// [iconOpacity] The opacity value applied to the icon.
  /// [iconTheme] The icon theme that provides default size and color for the icon.
  ///
  /// Returns a [Widget] that represents the icon, possibly wrapped with opacity.
  Widget _buildIcon(BuildContext context, double iconOpacity, iconTheme) {
    // Build the icon widget with or without opacity, depending on the value
    if (iconOpacity < 1.0) {
      return _buildWithOpacity(context, iconOpacity, iconTheme);
    } else {
      return _buildBase(context, iconTheme);
    }
  }

  /// Builds the icon widget without applying additional opacity.
  Widget _buildBase(BuildContext context, iconTheme) {
    final String iconPath = "$_defaultPath$iconName";
    final Color iconColor =
        color ?? _defaultColor ?? iconTheme.color ?? Colors.black;
    final double iconSize = size ?? iconTheme.size ?? 25;

    // Check if the icon is an SVG file and use the appropriate widget
    if (iconName.toLowerCase().endsWith(".svg")) {
      return SvgPicture.asset(
        iconPath,
        height: iconSize,
        width: iconSize,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        semanticsLabel: semanticLabel,
      );
    }

    // Default to using Image for non-SVG files
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        iconPath,
        width: iconSize,
        height: iconSize,
        color: iconColor,
        fit: BoxFit.scaleDown,
        excludeFromSemantics: true,
      ),
    );
  }

  /// Builds the icon widget with an opacity wrapper.
  Widget _buildWithOpacity(
      BuildContext context, double iconOpacity, iconTheme) {
    return Opacity(
      opacity: iconOpacity,
      child: _buildBase(context, iconTheme),
    );
  }

  /// Builds the icon widget with a label positioned according to the specified [position].
  ///
  /// This method displays the icon along with a label, positioning them based on the
  /// value of the [position] property. The label is styled with the [labelStyle]
  /// provided, or the default style if none is specified.
  ///
  /// [context] The build context for the widget.
  /// [iconOpacity] The opacity value applied to the icon.
  /// [iconTheme] The icon theme that provides default size and color for the icon.
  ///
  /// Returns a [Widget] that contains the icon and label positioned according to
  /// the [position] value (e.g., top, left, right, bottom).

  Widget _buildWithLabel(BuildContext context, double iconOpacity, iconTheme) {
    // ignore: no_leading_underscores_for_local_identifiers
    Widget _label = Text(
      label!,
      style: labelStyle ?? _defaultLabelStyle,
    );
    Widget buildVertical(List<Widget> items) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      );
    }

    Widget buildHorizontal(List<Widget> items) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      );
    }

    return switch (position??_defaultPosition) {
      AssetIconLabelPosition.top =>
        buildVertical([_label, _buildIcon(context, iconOpacity, iconTheme)]),
      AssetIconLabelPosition.left =>
        buildHorizontal([_label, _buildIcon(context, iconOpacity, iconTheme)]),
      AssetIconLabelPosition.right =>
        buildHorizontal([_buildIcon(context, iconOpacity, iconTheme), _label]),
      AssetIconLabelPosition.bottom =>
        buildVertical([_buildIcon(context, iconOpacity, iconTheme), _label]),
      _ => _buildIcon(context, iconOpacity, iconTheme)
    };
  }
}
