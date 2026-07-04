import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'rules/prefer_constructor_shorthands.dart';
import 'rules/prefer_enum_shorthands.dart';
import 'rules/prefer_static_member_shorthands.dart';

class ShorthandSyntaxLintPlugin extends Plugin {
  @override
  String get name => 'shorthand_syntax_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(PreferEnumShorthands());
    registry.registerWarningRule(PreferStaticMemberShorthands());
    registry.registerWarningRule(PreferConstructorShorthands());
  }
}
