import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test/test.dart';

class SnippetResolutionTest extends AnalysisRuleTest {
  late ResolvedUnitResult snippet;

  InterfaceElement declaration(String name) => declarationIn(snippet, name);

  InterfaceElement declarationIn(ResolvedUnitResult result, String name) {
    for (var member in result.unit.declarations) {
      var element = member.declaredFragment?.element;
      if (element is InterfaceElement && element.name == name) {
        return element;
      }
    }
    fail("No interface declaration named '$name'");
  }

  Expression expression(String source) {
    var collector = _ExpressionCollector(source);
    snippet.unit.accept(collector);
    expect(
      collector.matches,
      hasLength(1),
      reason: "Expected exactly one expression matching '$source'",
    );
    return collector.matches.single;
  }

  Future<void> resolveSnippet(String content) async {
    newFile(testFile.path, content);
    snippet = await resolveFile(testFile.path);
    var errors = [
      for (var diagnostic in snippet.diagnostics)
        if (diagnostic.severity == Severity.error) diagnostic,
    ];
    expect(errors, isEmpty, reason: 'Snippet must resolve without errors');
  }

  @override
  void setUp() {
    rule = _ProbeRule();
    super.setUp();
  }
}

class _ExpressionCollector extends GeneralizingAstVisitor<void> {
  final String source;

  final List<Expression> matches = [];

  _ExpressionCollector(this.source);

  @override
  void visitExpression(Expression node) {
    if (node.toSource() == source) {
      matches.add(node);
    }
    super.visitExpression(node);
  }
}

class _ProbeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'resolution_probe',
    'Resolution probe.',
  );

  _ProbeRule()
    : super(name: 'resolution_probe', description: 'Resolution probe.');

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {}
}
