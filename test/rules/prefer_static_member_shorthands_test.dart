import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:shorthand_syntax_lint/src/rules/prefer_static_member_shorthands.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferStaticMemberShorthandsTest);
  });
}

@reflectiveTest
class PreferStaticMemberShorthandsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferStaticMemberShorthands();
    super.setUp();
  }

  Future<void> test_alreadyShorthand_noLint() async {
    await assertNoDiagnostics(r'''
void f() {
  Duration d = .zero;
}
''');
  }

  Future<void> test_arrowBody() async {
    await assertDiagnostics(
      r'''
Duration f() => Duration.zero;
''',
      [lint(16, 13)],
    );
  }

  Future<void> test_assignment() async {
    await assertDiagnostics(
      r'''
void f(Duration d) {
  d = Duration.zero;
}
''',
      [lint(27, 13)],
    );
  }

  Future<void> test_awaitContext() async {
    await assertDiagnostics(
      r'''
Future<void> f() async {
  Duration d = await Duration.zero;
}
''',
      [lint(46, 13)],
    );
  }

  Future<void> test_awaitFutureStatic_noLint() async {
    await assertNoDiagnostics(r'''
Future<void> f(List<Future<int>> fs) async {
  List<int> l = await Future.wait(fs);
}
''');
  }

  Future<void> test_cascadeTarget() async {
    await assertDiagnostics(
      r'''
void f() {
  Duration d = Duration.zero..toString();
}
''',
      [lint(26, 13)],
    );
  }

  Future<void> test_constList() async {
    await assertDiagnostics(
      r'''
const List<Duration> l = [Duration.zero];
''',
      [lint(26, 13)],
    );
  }

  Future<void> test_defaultParameterValue() async {
    await assertDiagnostics(
      r'''
void f([Duration d = Duration.zero]) {}
''',
      [lint(21, 13)],
    );
  }

  Future<void> test_dynamicContext_noLint() async {
    await assertNoDiagnostics(r'''
dynamic d = Duration.zero;
''');
  }

  Future<void> test_enumConstant_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

Status s = Status.active;
''');
  }

  Future<void> test_enumStaticMember() async {
    await assertDiagnostics(
      r'''
enum Status {
  active,
  inactive;

  static const Status fallback = Status.active;
}

Status s = Status.fallback;
''',
      [lint(99, 15)],
    );
  }

  Future<void> test_equalEqualDynamicLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
void f(dynamic d) {
  bool b = d == Duration.zero;
}
''');
  }

  Future<void> test_equalEqualLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
void f(Duration d) {
  bool b = Duration.zero == d;
}
''');
  }

  Future<void> test_equalEqualNullableLeftOperand() async {
    await assertDiagnostics(
      r'''
void f(Duration? d) {
  bool b = d == Duration.zero;
}
''',
      [lint(38, 13)],
    );
  }

  Future<void> test_equalEqualObjectCastLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
void f(Duration d) {
  bool b = (d as Object) == Duration.zero;
}
''');
  }

  Future<void>
  test_equalEqualParenthesizedConditionalRightOperand_noLint() async {
    await assertNoDiagnostics(r'''
void f(Duration d, bool b) {
  bool r = d == (b ? Duration.zero : Duration.zero);
}
''');
  }

  Future<void> test_equalEqualRightOperand() async {
    await assertDiagnostics(
      r'''
void f(Duration d) {
  bool b = d == Duration.zero;
}
''',
      [lint(37, 13)],
    );
  }

  Future<void> test_expressionStatement_noLint() async {
    await assertNoDiagnostics(r'''
void f() {
  Duration.zero;
}
''');
  }

  Future<void> test_expressionStatementInvocation_noLint() async {
    await assertNoDiagnostics(r'''
class Box {
  static Box make() => Box();
}

void f() {
  Box.make();
}
''');
  }

  Future<void> test_extensionStaticMember_noLint() async {
    await assertNoDiagnostics(r'''
extension IntDurations on int {
  static Duration get week => const Duration(days: 7);
}

Duration d = IntDurations.week;
''');
  }

  Future<void> test_extensionTypeStaticMember() async {
    await assertDiagnostics(
      r'''
extension type Meters(int value) {
  static Meters get zero => Meters(0);
}

Meters m = Meters.zero;
''',
      [lint(88, 11)],
    );
  }

  Future<void> test_finalUntypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
void f() {
  final d = Duration.zero;
}
''');
  }

  Future<void> test_forElement() async {
    await assertDiagnostics(
      r'''
void f() {
  var l = <Duration>[for (var i = 0; i < 2; i++) Duration.zero];
}
''',
      [lint(60, 13)],
    );
  }

  Future<void> test_futureOrContext() async {
    await assertDiagnostics(
      r'''
import 'dart:async';

FutureOr<Duration> d = Duration.zero;
''',
      [lint(45, 13)],
    );
  }

  Future<void> test_futureValueConstructor_noLint() async {
    await assertNoDiagnostics(r'''
Future<int> f() {
  return Future.value(3);
}
''');
  }

  Future<void> test_genericArgument_explicitTypeArguments() async {
    await assertDiagnostics(
      r'''
void g<T>(T t) {}

void f() {
  g<Duration>(Duration.zero);
}
''',
      [lint(44, 13)],
    );
  }

  Future<void> test_genericArgument_inferred_noLint() async {
    await assertNoDiagnostics(r'''
void g<T>(T t) {}

void f() {
  g(Duration.zero);
}
''');
  }

  Future<void> test_ifElement() async {
    await assertDiagnostics(
      r'''
void f(bool b) {
  var l = <Duration>[if (b) Duration.zero];
}
''',
      [lint(45, 13)],
    );
  }

  Future<void> test_ifNullAssignment() async {
    await assertDiagnostics(
      r'''
void f(Duration? d) {
  d ??= Duration.zero;
}
''',
      [lint(30, 13)],
    );
  }

  Future<void> test_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Remote {
  const Remote._();

  static const Remote fallback = Remote._();
}
''');
    await assertDiagnostics(
      r'''
import 'other.dart' as p;

p.Remote r = p.Remote.fallback;
''',
      [lint(40, 17)],
    );
  }

  Future<void> test_indexAssignmentValue() async {
    await assertDiagnostics(
      r'''
void f(Map<String, Duration> m) {
  m['a'] = Duration.zero;
}
''',
      [lint(45, 13)],
    );
  }

  Future<void> test_lateLocalVariable() async {
    await assertDiagnostics(
      r'''
void f() {
  late Duration d = Duration.zero;
}
''',
      [lint(31, 13)],
    );
  }

  Future<void> test_leftOperand_noLint() async {
    await assertNoDiagnostics(r'''
int v = int.parse('1') + 1;
''');
  }

  Future<void> test_memberTypeNotDeclaringClass_noLint() async {
    await assertNoDiagnostics(r'''
class Span {
  static const int perDay = 86400000;
}

int ms = Span.perDay;
''');
  }

  Future<void> test_namedArgument() async {
    await assertDiagnostics(
      r'''
void g({Duration? d}) {}

void f() {
  g(d: Duration.zero);
}
''',
      [lint(44, 13)],
    );
  }

  Future<void> test_notEqualRightOperand() async {
    await assertDiagnostics(
      r'''
void f(Duration d) {
  bool b = d != Duration.zero;
}
''',
      [lint(37, 13)],
    );
  }

  Future<void> test_nullableContext() async {
    await assertDiagnostics(
      r'''
Duration? d = Duration.zero;
''',
      [lint(14, 13)],
    );
  }

  Future<void> test_objectContext_noLint() async {
    await assertNoDiagnostics(r'''
Object o = Duration.zero;
''');
  }

  Future<void> test_objectPatternField() async {
    await assertDiagnostics(
      r'''
class Box {
  final Duration d;
  Box(this.d);
}

void f(Box b) {
  if (b case Box(d: Duration.zero)) {}
}
''',
      [lint(86, 13)],
    );
  }

  Future<void> test_parenthesizedReceiver_noLint() async {
    await assertNoDiagnostics(r'''
int x = (int.parse('42')).abs();
''');
  }

  Future<void> test_positionalArgument() async {
    await assertDiagnostics(
      r'''
void g(Duration d) {}

void f() {
  g(Duration.zero);
}
''',
      [lint(38, 13)],
    );
  }

  Future<void> test_preDotShorthandsLanguageVersion_noLint() async {
    await assertNoDiagnostics(r'''
// @dart=3.9

Duration d = Duration.zero;
''');
  }

  Future<void> test_recordField() async {
    await assertDiagnostics(
      r'''
void f() {
  (Duration, int) r = (Duration.zero, 1);
}
''',
      [lint(34, 13)],
    );
  }

  Future<void> test_relationalPattern() async {
    await assertDiagnostics(
      r'''
void f(Duration d) {
  if (d case == Duration.zero) {}
}
''',
      [lint(37, 13)],
    );
  }

  Future<void> test_returnAsync() async {
    await assertDiagnostics(
      r'''
Future<Duration> f() async {
  return Duration.zero;
}
''',
      [lint(38, 13)],
    );
  }

  Future<void> test_returnAsyncFutureStatic_noLint() async {
    await assertNoDiagnostics(r'''
Future<List<int>> f(List<Future<int>> fs) async {
  return Future.wait(fs);
}
''');
  }

  Future<void> test_returnNonAsyncFutureStatic() async {
    await assertDiagnostics(
      r'''
Future<List<int>> f(List<Future<int>> fs) {
  return Future.wait(fs);
}
''',
      [lint(53, 15)],
    );
  }

  Future<void> test_returnSync() async {
    await assertDiagnostics(
      r'''
Duration f() {
  return Duration.zero;
}
''',
      [lint(24, 13)],
    );
  }

  Future<void> test_selectorReceiverProperty_noLint() async {
    await assertNoDiagnostics(r'''
class Span {
  static const Span zero = Span._(0);

  final int length;

  const Span._(this.length);
}

int x = Span.zero.length;
''');
  }

  Future<void> test_selectorReceiver_noLint() async {
    await assertNoDiagnostics(r'''
int x = int.parse('42').abs();
''');
  }

  Future<void> test_shadowedClass_noLint() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Remote {
  const Remote._();

  static const Remote fallback = Remote._();
}
''');
    await assertNoDiagnostics(r'''
import 'other.dart' as p;

class Remote {
  const Remote._();

  static const Remote fallback = Remote._();
}

void f(p.Remote x) {
  bool b = x == Remote.fallback;
}
''');
  }

  Future<void> test_siblingClassMember_noLint() async {
    await assertNoDiagnostics(r'''
class Span {
  const Span();
}

class Spans {
  static const Span week = Span();
}

Span d = Spans.week;
''');
  }

  Future<void> test_staticField() async {
    await assertDiagnostics(
      r'''
class C {
  static Duration d = Duration.zero;
}
''',
      [lint(32, 13)],
    );
  }

  Future<void> test_staticGetter() async {
    await assertDiagnostics(
      r'''
class Endianness {
  static Endianness get host => Endianness();
}

Endianness e = Endianness.host;
''',
      [lint(83, 15)],
    );
  }

  Future<void> test_staticMethod() async {
    await assertDiagnostics(
      r'''
void f() {
  int x = int.parse('42');
}
''',
      [lint(21, 15)],
    );
  }

  Future<void> test_staticMethodExplicitTypeArguments() async {
    await assertDiagnostics(
      r'''
Future<List<int>> f(List<Future<int>> fs) => Future.wait<int>(fs);
''',
      [lint(45, 20)],
    );
  }

  Future<void> test_staticMethodTearoff_noLint() async {
    await assertNoDiagnostics(r'''
int Function(String) f = int.parse;
''');
  }

  Future<void> test_stringInterpolation_noLint() async {
    await assertNoDiagnostics(r'''
String s = '${Duration.zero}';
''');
  }

  Future<void> test_supertypeStaticMember_noLint() async {
    await assertNoDiagnostics(r'''
class Sup {
  static final Sub instance = Sub();
}

class Sub extends Sup {}

Sub s = Sup.instance;
''');
  }

  Future<void> test_switchDynamicScrutinee_noLint() async {
    await assertNoDiagnostics(r'''
void f(dynamic d) {
  switch (d) {
    case Duration.zero:
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
void f(Duration d) {
  int i = switch (d) {
    Duration.zero => 1,
    _ => 0,
  };
}
''',
      [lint(48, 13)],
    );
  }

  Future<void> test_switchStatementCase() async {
    await assertDiagnostics(
      r'''
void f(Duration d) {
  switch (d) {
    case Duration.zero:
      break;
    default:
      break;
  }
}
''',
      [lint(45, 13)],
    );
  }

  Future<void> test_ternaryBranches() async {
    await assertDiagnostics(
      r'''
void f(bool b) {
  Duration d = b ? Duration.zero : Duration.zero;
}
''',
      [lint(36, 13), lint(52, 13)],
    );
  }

  Future<void> test_typeAliasContext() async {
    await assertDiagnostics(
      r'''
typedef Span = Duration;

Span s = Duration.zero;
''',
      [lint(35, 13)],
    );
  }

  Future<void> test_typeVariableContext_noLint() async {
    await assertNoDiagnostics(r'''
bool g<T extends Duration>(T t) => t == Duration.zero;
''');
  }

  Future<void> test_typedField() async {
    await assertDiagnostics(
      r'''
class C {
  Duration d = Duration.zero;
}
''',
      [lint(25, 13)],
    );
  }

  Future<void> test_typedListElement() async {
    await assertDiagnostics(
      r'''
void f() {
  var l = <Duration>[Duration.zero];
}
''',
      [lint(32, 13)],
    );
  }

  Future<void> test_typedLocalVariable() async {
    await assertDiagnostics(
      r'''
void f() {
  Duration d = Duration.zero;
}
''',
      [lint(26, 13)],
    );
  }

  Future<void> test_typedMapKey() async {
    await assertDiagnostics(
      r'''
void f() {
  var m = <Duration, int>{Duration.zero: 1};
}
''',
      [lint(37, 13)],
    );
  }

  Future<void> test_typedMapValue() async {
    await assertDiagnostics(
      r'''
void f() {
  var m = <int, Duration>{1: Duration.zero};
}
''',
      [lint(40, 13)],
    );
  }

  Future<void> test_typedTopLevelVariable() async {
    await assertDiagnostics(
      r'''
Duration d = Duration.zero;
''',
      [lint(13, 13)],
    );
  }

  Future<void> test_untypedListLiteral_noLint() async {
    await assertNoDiagnostics(r'''
void f() {
  var l = [Duration.zero];
}
''');
  }

  Future<void> test_untypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
void f() {
  var d = Duration.zero;
}
''');
  }

  Future<void> test_yieldSync() async {
    await assertDiagnostics(
      r'''
Iterable<Duration> f() sync* {
  yield Duration.zero;
}
''',
      [lint(39, 13)],
    );
  }
}
