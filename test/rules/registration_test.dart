import 'dart:io';

import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/error/error.dart';
import 'package:shorthand_syntax_lint/main.dart';
import 'package:test/test.dart';

void main() {
  test('plugin has the expected name', () {
    expect(plugin.name, 'shorthand_syntax_lint');
  });

  test('register registers the kind rules as warning rules', () {
    var registry = _RecordingRegistry();
    plugin.register(registry);
    expect(
      registry.warningRules.map((rule) => rule.name),
      unorderedEquals([
        'prefer_enum_shorthands',
        'prefer_static_member_shorthands',
        'prefer_constructor_shorthands',
      ]),
    );
  });

  test('register registers the opt-in rules as lint rules', () {
    var registry = _RecordingRegistry();
    plugin.register(registry);
    expect(
      registry.lintRules.map((rule) => rule.name),
      unorderedEquals([
        'prefer_unnamed_constructor_shorthands',
        'prefer_return_shorthands',
      ]),
    );
  });

  test('register registers one fix for every diagnostic code', () {
    var registry = _RecordingRegistry();
    plugin.register(registry);
    expect(
      registry.fixes.keys.map((code) => code.lowerCaseName),
      unorderedEquals([
        'prefer_enum_shorthands',
        'prefer_static_member_shorthands',
        'prefer_constructor_shorthands',
        'prefer_unnamed_constructor_shorthands',
        'prefer_return_shorthands',
      ]),
    );
    for (var generators in registry.fixes.values) {
      expect(generators, hasLength(1));
    }
  });

  test('fix map keys are identical to the rule diagnostic codes', () {
    var registry = _RecordingRegistry();
    plugin.register(registry);
    var rules = [...registry.warningRules, ...registry.lintRules];
    expect(rules, hasLength(5));
    for (var rule in rules.cast<AnalysisRule>()) {
      var matches = registry.fixes.keys.where(
        (code) => identical(code, rule.diagnosticCode),
      );
      expect(matches, hasLength(1), reason: rule.name);
    }
  });

  test('each rule code name matches its rule file name', () {
    var registry = _RecordingRegistry();
    plugin.register(registry);
    var rules = [...registry.warningRules, ...registry.lintRules];
    for (var rule in rules.cast<AnalysisRule>()) {
      expect(rule.diagnosticCode.lowerCaseName, rule.name);
      expect(File('lib/src/rules/${rule.name}.dart').existsSync(), isTrue);
    }
  });
}

class _RecordingRegistry implements PluginRegistry {
  final fixes = <DiagnosticCode, List<Object?>>{};
  final lintRules = <AbstractAnalysisRule>[];
  final warningRules = <AbstractAnalysisRule>[];

  @override
  Iterable<AbstractAnalysisRule> enabled(Map<String, Object?> ruleConfigs) =>
      const [];

  @override
  void registerAssist(Object? generator) {}

  @override
  void registerFixForRule(DiagnosticCode code, Object? generator) {
    fixes.putIfAbsent(code, () => []).add(generator);
  }

  @override
  void registerLintRule(AbstractAnalysisRule rule) {
    lintRules.add(rule);
  }

  @override
  void registerWarningRule(AbstractAnalysisRule rule) {
    warningRules.add(rule);
  }
}
