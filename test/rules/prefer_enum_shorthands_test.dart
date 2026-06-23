import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:shorthand_syntax_lint/src/rules/prefer_enum_shorthands.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEnumShorthandsTest);
  });
}

@reflectiveTest
class PreferEnumShorthandsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferEnumShorthands();
    super.setUp();
  }

  Future<void> test_typedLocalVariable() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  Status s = Status.active;
}
''',
      [lint(58, 13)],
    );
  }

  Future<void> test_untypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f() {
  var s = Status.active;
}
''');
  }
}
