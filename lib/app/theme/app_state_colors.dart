/// Material 3 state layer opacities and decorative color values.
///
/// These values define the overlay opacities for interactive states
/// (hover, focus, pressed, selected) and subtle decorative elements
/// like card outlines, optimized for dark mode.
abstract class AppStateColors {
  const AppStateColors._();

  /// Hover state overlay opacity — used when a pointer hovers over interactive elements.
  static const double hover = 0.08;

  /// Focus state overlay opacity — used for keyboard focus and accessibility focus rings.
  static const double focus = 0.12;

  /// Pressed state overlay opacity — used when an interactive element is activated.
  static const double pressed = 0.16;

  /// Selected state overlay opacity — used to indicate the current selection state.
  static const double selected = 0.16;

  /// Card outline opacity — used for subtle borders on desktop cards to improve definition.
  static const double cardOutline = 0.08;
}
