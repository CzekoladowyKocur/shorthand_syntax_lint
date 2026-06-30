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

  Future<void> test_alreadyShorthand_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f() {
  Status s = .active;
}
''');
  }

  Future<void> test_arrowBody() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Status f() => Status.active;
''',
      [lint(48, 13)],
    );
  }

  Future<void> test_assignment() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status s) {
  s = Status.active;
}
''',
      [lint(59, 13)],
    );
  }

  Future<void> test_awaitContext() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Future<void> f() async {
  Status s = await Status.active;
}
''',
      [lint(78, 13)],
    );
  }

  Future<void> test_cascadeTarget() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  Status s = Status.active..index;
}
''',
      [lint(58, 13)],
    );
  }

  Future<void> test_constList() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

const List<Status> l = [Status.active];
''',
      [lint(58, 13)],
    );
  }

  Future<void> test_defaultParameterValue() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f([Status s = Status.active]) {}
''',
      [lint(53, 13)],
    );
  }

  Future<void> test_dynamicContext_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

dynamic d = Status.active;
''');
  }

  Future<void> test_equalEqualDynamicLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f(dynamic d) {
  bool b = d == Status.active;
}
''');
  }

  Future<void> test_equalEqualLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f(Status s) {
  bool b = Status.active == s;
}
''');
  }

  Future<void> test_equalEqualNullableLeftOperand() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status? s) {
  bool b = s == Status.active;
}
''',
      [lint(70, 13)],
    );
  }

  Future<void> test_equalEqualObjectCastLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f(Status s) {
  bool b = (s as Object) == Status.active;
}
''');
  }

  Future<void>
  test_equalEqualParenthesizedConditionalRightOperand_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f(Status s, bool b) {
  bool r = s == (b ? Status.active : Status.inactive);
}
''');
  }

  Future<void> test_equalEqualRightOperand() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status s) {
  bool b = s == Status.active;
}
''',
      [lint(69, 13)],
    );
  }

  Future<void> test_expressionStatement_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f() {
  Status.active;
}
''');
  }

  Future<void> test_finalUntypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f() {
  final s = Status.active;
}
''');
  }

  Future<void> test_forElement() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  var l = <Status>[for (var i = 0; i < 2; i++) Status.active];
}
''',
      [lint(92, 13)],
    );
  }

  Future<void> test_futureOrContext() async {
    await assertDiagnostics(
      r'''
import 'dart:async';

enum Status { active, inactive }

FutureOr<Status> s = Status.active;
''',
      [lint(77, 13)],
    );
  }

  Future<void> test_genericArgument_explicitTypeArguments() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void g<T>(T t) {}

void f() {
  g<Status>(Status.active);
}
''',
      [lint(76, 13)],
    );
  }

  Future<void> test_genericArgument_inferred_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void g<T>(T t) {}

void f() {
  g(Status.active);
}
''');
  }

  Future<void> test_ifElement() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(bool b) {
  var l = <Status>[if (b) Status.active];
}
''',
      [lint(77, 13)],
    );
  }

  Future<void> test_ifNullAssignment() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status? s) {
  s ??= Status.active;
}
''',
      [lint(62, 13)],
    );
  }

  Future<void> test_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
enum Remote { on, off }
''');
    await assertDiagnostics(
      r'''
import 'other.dart' as p;

p.Remote r = p.Remote.on;
''',
      [lint(40, 11)],
    );
  }

  Future<void> test_indexAssignmentValue() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Map<String, Status> m) {
  m['a'] = Status.active;
}
''',
      [lint(77, 13)],
    );
  }

  Future<void> test_lateLocalVariable() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  late Status s = Status.active;
}
''',
      [lint(63, 13)],
    );
  }

  Future<void> test_namedArgument() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void g({Status? s}) {}

void f() {
  g(s: Status.active);
}
''',
      [lint(76, 13)],
    );
  }

  Future<void> test_notEqualRightOperand() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status s) {
  bool b = s != Status.active;
}
''',
      [lint(69, 13)],
    );
  }

  Future<void> test_nullableContext() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Status? s = Status.active;
''',
      [lint(46, 13)],
    );
  }

  Future<void> test_objectContext_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

Object o = Status.active;
''');
  }

  Future<void> test_objectPatternField() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

class Box {
  final Status s;
  Box(this.s);
}

void f(Box b) {
  if (b case Box(s: Status.active)) {}
}
''',
      [lint(118, 13)],
    );
  }

  Future<void> test_positionalArgument() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void g(Status s) {}

void f() {
  g(Status.active);
}
''',
      [lint(70, 13)],
    );
  }

  Future<void> test_preDotShorthandsLanguageVersion_noLint() async {
    await assertNoDiagnostics(r'''
// @dart=3.9

enum Status { active, inactive }

Status s = Status.active;
''');
  }

  Future<void> test_recordField() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  (Status, int) r = (Status.active, 1);
}
''',
      [lint(66, 13)],
    );
  }

  Future<void> test_relationalPattern() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status s) {
  if (s case == Status.active) {}
}
''',
      [lint(69, 13)],
    );
  }

  Future<void> test_returnAsync() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Future<Status> f() async {
  return Status.active;
}
''',
      [lint(70, 13)],
    );
  }

  Future<void> test_returnNonAsyncFuture_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

Future<Status> f() {
  return Future.value(Status.active);
}
''');
  }

  Future<void> test_returnSync() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Status f() {
  return Status.active;
}
''',
      [lint(56, 13)],
    );
  }

  Future<void> test_selectorReceiver_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

int i = Status.active.index + 1;
''');
  }

  Future<void> test_shadowedEnum_noLint() async {
    newFile('$testPackageLibPath/other.dart', r'''
enum Status { active, inactive }
''');
    await assertNoDiagnostics(r'''
import 'other.dart' as p;

enum Status { active, inactive }

void f(p.Status x) {
  bool b = x == Status.active;
}
''');
  }

  Future<void> test_siblingClassStatic_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

class StatusValues {
  static Status get fallback => Status.values.first;
}

Status s = StatusValues.fallback;
''');
  }

  Future<void> test_staticField() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

class C {
  static Status s = Status.active;
}
''',
      [lint(64, 13)],
    );
  }

  Future<void> test_stringInterpolation_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

String s = '${Status.active}';
''');
  }

  Future<void> test_switchDynamicScrutinee_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f(dynamic d) {
  switch (d) {
    case Status.active:
      break;
    default:
      break;
  }
}
''');
  }

  Future<void> test_switchExpressionCase() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status s) {
  int i = switch (s) {
    Status.active => 1,
    _ => 0,
  };
}
''',
      [lint(80, 13)],
    );
  }

  Future<void> test_switchStatementCase() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    default:
      break;
  }
}
''',
      [lint(77, 13)],
    );
  }

  Future<void> test_ternaryBranches() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f(bool b) {
  Status s = b ? Status.active : Status.inactive;
}
''',
      [lint(68, 13), lint(84, 15)],
    );
  }

  Future<void> test_typeAliasContext() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

typedef StatusAlias = Status;

StatusAlias s = Status.active;
''',
      [lint(81, 13)],
    );
  }

  Future<void> test_typeVariableContext_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

bool g<T extends Status>(T t) => t == Status.active;
''');
  }

  Future<void> test_typedField() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

class C {
  Status s = Status.active;
}
''',
      [lint(57, 13)],
    );
  }

  Future<void> test_typedListElement() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  var l = <Status>[Status.active];
}
''',
      [lint(64, 13)],
    );
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

  Future<void> test_typedMapKey() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  var m = <Status, int>{Status.active: 1};
}
''',
      [lint(69, 13)],
    );
  }

  Future<void> test_typedMapValue() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  var m = <int, Status>{1: Status.active};
}
''',
      [lint(72, 13)],
    );
  }

  Future<void> test_typedTopLevelVariable() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Status s = Status.active;
''',
      [lint(45, 13)],
    );
  }

  Future<void> test_untypedListLiteral_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f() {
  var l = [Status.active];
}
''');
  }

  Future<void> test_untypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f() {
  var s = Status.active;
}
''');
  }

  Future<void> test_valuesIntoTypedList_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

List<Status> l = Status.values;
''');
  }

  Future<void> test_yieldSync() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Iterable<Status> f() sync* {
  yield Status.active;
}
''',
      [lint(71, 13)],
    );
  }
}
