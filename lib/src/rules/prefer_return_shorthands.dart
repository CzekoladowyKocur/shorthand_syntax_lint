import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../context_type.dart';
import '../longhand.dart';

class PreferReturnShorthands extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_return_shorthands',
    "Return '.{0}' instead of '{1}.{0}'.",
    correctionMessage: "Try replacing '{1}.{0}' with '.{0}'.",
  );

  PreferReturnShorthands()
    : super(
        name: 'prefer_return_shorthands',
        description: 'Use dot shorthands in returned expressions.',
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
    registry.addReturnStatement(this, visitor);
    registry.addExpressionFunctionBody(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferReturnShorthands rule;

  _Visitor(this.rule);

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _check(node.expression);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    var expression = node.expression;
    if (expression == null) return;
    _check(expression);
  }

  void _check(Expression node) {
    while (true) {
      var longhand = matchLonghand(node);
      if (longhand != null) {
        var target = longhand.target;
        if (!identical(shorthandContextElement(node), target)) return;
        rule.reportAtNode(
          node,
          arguments: [longhand.memberName, target.displayName],
        );
        return;
      }
      var receiver = _receiver(node);
      if (receiver == null) return;
      node = receiver;
    }
  }

  Expression? _receiver(Expression node) {
    if (node is MethodInvocation) return node.target;
    if (node is PropertyAccess) return node.target;
    if (node is IndexExpression) return node.target;
    if (node is PostfixExpression && node.operator.type == TokenType.BANG) {
      return node.operand;
    }
    return null;
  }
}
