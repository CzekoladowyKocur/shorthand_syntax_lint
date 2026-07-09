import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'fixes/convert_to_shorthand.dart';
import 'rules/prefer_constructor_shorthands.dart';
import 'rules/prefer_enum_shorthands.dart';
import 'rules/prefer_return_shorthands.dart';
import 'rules/prefer_static_member_shorthands.dart';
import 'rules/prefer_unnamed_constructor_shorthands.dart';

class ShorthandSyntaxLintPlugin extends Plugin {
  @override
  String get name => 'shorthand_syntax_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(PreferEnumShorthands());
    registry.registerWarningRule(PreferStaticMemberShorthands());
    registry.registerWarningRule(PreferConstructorShorthands());
    registry.registerLintRule(PreferUnnamedConstructorShorthands());
    registry.registerLintRule(PreferReturnShorthands());
    registry.registerFixForRule(
      PreferEnumShorthands.code,
      ConvertToShorthand.new,
    );
    registry.registerFixForRule(
      PreferStaticMemberShorthands.code,
      ConvertToShorthand.new,
    );
    registry.registerFixForRule(
      PreferConstructorShorthands.code,
      ConvertToShorthand.new,
    );
    registry.registerFixForRule(
      PreferUnnamedConstructorShorthands.code,
      ConvertToShorthand.new,
    );
    registry.registerFixForRule(
      PreferReturnShorthands.code,
      ConvertToShorthand.new,
    );
  }
}
