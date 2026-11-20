import 'package:material_ui/material_ui.dart';

/// Parâmetros de movimento compartilhados pela barra de navegação dos feeds.
///
/// Centralizar durações e curvas mantém todas as animações da app bar com o
/// mesmo "ritmo" e facilita ajustar o tom (mais rápido, mais suave) em um só
/// lugar.
class NavMotion {
  const NavMotion._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 480);

  /// Curva padrão para entradas e mudanças de estado.
  static const Curve emphasized = Curves.easeOutCubic;

  /// Respeita a configuração "reduzir movimento" do sistema.
  static Duration of(BuildContext context, Duration base) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : base;
}