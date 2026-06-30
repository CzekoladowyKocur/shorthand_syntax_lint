import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

import '../context_type.dart';
import '../longhand.dart';

class PreferEnumShorthands extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_enum_shorthands',
    "Use '.{0}' instead of '{1}.{0}'.",
    correctionMessage: "Try replacing '{1}.{0}' with '.{0}'.",
  );

  PreferEnumShorthands()
    : super(
        name: 'prefer_enum_shorthands',
        description: 'Use dot shorthands for enum values.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isFeatureEnabled(Feature.dot_shorthands)) return;
    var visitor = _Visitor(this);
    registry.addPrefixedIdentifier(this, visitor);
    registry.addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferEnumShorthands rule;

  _Visitor(this.rule);

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _check(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _check(node);
  }

  void _check(Expression node) {
    var longhand = matchLonghand(node);
    if (longhand == null || longhand.kind != LonghandKind.enumConstant) return;
    var target = longhand.target;
    if (target is! EnumElement) return;
    if (!identical(shorthandContextElement(node), target)) return;
    rule.reportAtNode(
      node,
      arguments: [longhand.memberName, target.displayName],
    );
  }
}
