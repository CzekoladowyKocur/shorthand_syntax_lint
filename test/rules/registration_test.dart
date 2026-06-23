import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/error/error.dart';
import 'package:shorthand_syntax_lint/main.dart';
import 'package:test/test.dart';

void main() {
  test('plugin has the expected name', () {
    expect(plugin.name, 'shorthand_syntax_lint');
  });

  test('register registers prefer_enum_shorthands as a warning rule', () {
    var registry = _RecordingRegistry();
    plugin.register(registry);
    expect(registry.warningRules, hasLength(1));
    expect(registry.warningRules.single.name, 'prefer_enum_shorthands');
    expect(registry.lintRules, isEmpty);
  });
}

class _RecordingRegistry implements PluginRegistry {
  final lintRules = <AbstractAnalysisRule>[];
  final warningRules = <AbstractAnalysisRule>[];

  @override
  Iterable<AbstractAnalysisRule> enabled(Map<String, Object?> ruleConfigs) =>
      const [];

  @override
  void registerAssist(Object? generator) {}

  @override
  void registerFixForRule(DiagnosticCode code, Object? generator) {}

  @override
  void registerLintRule(AbstractAnalysisRule rule) {
    lintRules.add(rule);
  }

  @override
  void registerWarningRule(AbstractAnalysisRule rule) {
    warningRules.add(rule);
  }
}
