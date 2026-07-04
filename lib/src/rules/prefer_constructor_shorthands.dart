import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../context_type.dart';
import '../longhand.dart';

class PreferConstructorShorthands extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_constructor_shorthands',
    "Use '.{0}(...)' instead of '{1}.{0}(...)'.",
    correctionMessage: "Try replacing '{1}.{0}(...)' with '.{0}(...)'.",
  );

  PreferConstructorShorthands()
    : super(
        name: 'prefer_constructor_shorthands',
        description: 'Use dot shorthands for named constructors.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isFeatureEnabled(Feature.dot_shorthands)) return;
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferConstructorShorthands rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.name == null) return;
    var longhand = matchLonghand(node);
    if (longhand == null || longhand.kind != LonghandKind.namedConstructor) {
      return;
    }
    var target = longhand.target;
    if (!identical(shorthandContextElement(node), target)) return;
    rule.reportAtNode(
      node,
      arguments: [longhand.memberName, target.displayName],
    );
  }
}
