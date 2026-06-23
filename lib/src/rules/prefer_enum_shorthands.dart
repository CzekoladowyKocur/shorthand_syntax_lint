import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

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
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferEnumShorthands rule;

  _Visitor(this.rule);

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    var enumElement = node.prefix.element;
    if (enumElement is! EnumElement) return;
    var constant = _enumConstant(node.identifier.element);
    if (constant == null || constant.enclosingElement != enumElement) return;
    var declaration = node.parent;
    if (declaration is! VariableDeclaration ||
        declaration.initializer != node) {
      return;
    }
    var declarationList = declaration.parent;
    if (declarationList is! VariableDeclarationList) return;
    var declaredType = declarationList.type?.type;
    if (declaredType is! InterfaceType || declaredType.element != enumElement) {
      return;
    }
    rule.reportAtNode(
      node,
      arguments: [node.identifier.name, node.prefix.name],
    );
  }

  FieldElement? _enumConstant(Element? element) {
    var variable = element is PropertyAccessorElement
        ? element.variable
        : element;
    if (variable is FieldElement && variable.isEnumConstant) return variable;
    return null;
  }
}
