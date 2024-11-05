class AssetsIconSettings {
  /// The default color for the icons when not specified in the constructor.
  static var _defaultColor;

  /// The default path where icons are located. The default value is `assets/icons/`.
  static String _defaultPath = "assets/icons/";

  /// Configures the global settings for the [AssetIcon] widget, including the default color and asset path.
  ///
  /// [defaultColor] sets a global default color for icons.
  /// [defaultPath] sets a global default path where icons are located.
  static settings({defaultColor, String? defaultPath}) {
    if (defaultColor != null) {
      _defaultColor = defaultColor;
    }
    if (defaultPath != null) {
      _defaultPath = defaultPath;
    }
  }

  static get path => _defaultPath;
  static get color => _defaultColor;
}
