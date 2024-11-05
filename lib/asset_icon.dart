/// A widget that displays an icon from the assets folder, with support for PNG and SVG formats.
///
/// This widget allows customization of the icon's size, color, opacity, and semantic labels.
/// It also supports global settings for default color and asset path.
library asset_icon;


import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A [StatelessWidget] that displays an asset image or SVG icon.
class AssetIcon extends StatelessWidget {
  /// The default color for the icons when not specified in the constructor.
  static var _defaultColor;

  /// The default path where icons are located. The default value is `assets/icons/`.
  static String _defaultPath = "assets/icons/";

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

  /// Stores the current [IconThemeData] for customization within the widget.
  late final IconThemeData iconTheme;

  /// Creates an [AssetIcon] widget.
  ///
  /// [iconName] is required and should include the file extension (e.g., `icon.png` or `icon.svg`).
  AssetIcon({
    super.key,
    required this.iconName,
    this.size,
    this.color,
    this.opacity,
    this.semanticLabel,
  });

  /// Configures the global settings for the [AssetIcon] widget, including the default color and asset path.
  ///
  /// [defaultColor] sets a global default color for icons.
  /// [defaultPath] sets a global default path where icons are located.
  static settings({Color? defaultColor, String? defaultPath}) {
    if (defaultColor != null) {
      _defaultColor = defaultColor;
    }
    if (defaultPath != null) {
      _defaultPath = defaultPath;
    }
  }
  static get path => _defaultPath;

  @override
  Widget build(BuildContext context) {
    // Retrieve the current icon theme from the context
    iconTheme = IconTheme.of(context);
    final iconOpacity = opacity ?? iconTheme.opacity ?? 1.0;

    // Build the icon widget with or without opacity, depending on the value
    if (iconOpacity < 1.0) {
      return _buildWithOpacity(context, iconOpacity);
    } else {
      return _buildBase(context);
    }
  }

  /// Builds the icon widget without applying additional opacity.
  Widget _buildBase(BuildContext context) {
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
  Widget _buildWithOpacity(BuildContext context, double iconOpacity) {
    return Opacity(
      opacity: iconOpacity,
      child: _buildBase(context),
    );
  }
}
