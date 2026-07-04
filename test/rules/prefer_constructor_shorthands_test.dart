import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:shorthand_syntax_lint/src/rules/prefer_constructor_shorthands.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferConstructorShorthandsTest);
  });
}

@reflectiveTest
class PreferConstructorShorthandsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferConstructorShorthands();
    super.setUp();
  }

  Future<void> test_abstractClassFactory() async {
    await assertDiagnostics(
      r'''
abstract class A {
  factory A.make() = B;
}

class B implements A {}

A a = A.make();
''',
      [lint(77, 8)],
    );
  }

  Future<void> test_alreadyShorthand_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  P p = .origin();
}
''');
  }

  Future<void> test_arrowBody() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P f() => P.origin();
''',
      [lint(65, 10)],
    );
  }

  Future<void> test_assignment() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  p = P.origin();
}
''',
      [lint(76, 10)],
    );
  }

  Future<void> test_awaitContext() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

Future<void> f() async {
  P p = await P.origin();
}
''',
      [lint(95, 10)],
    );
  }

  Future<void> test_awaitFutureValue_noLint() async {
    await assertNoDiagnostics(r'''
Future<void> f() async {
  int x = await Future.value(3);
}
''');
  }

  Future<void> test_bodyFactory() async {
    await assertDiagnostics(
      r'''
class BF {
  BF();
  factory BF.make() => BF();
}

BF b = BF.make();
''',
      [lint(58, 9)],
    );
  }

  Future<void> test_cascadeTarget() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  P p = P.origin()..toString();
}
''',
      [lint(75, 10)],
    );
  }

  Future<void> test_constDeclarationExplicitConst() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const P p = const P.origin();
''',
      [lint(68, 16)],
    );
  }

  Future<void> test_constDeclarationImplicitConst() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const P p = P.origin();
''',
      [lint(68, 10)],
    );
  }

  Future<void> test_constList() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const List<P> l = [P.origin()];
''',
      [lint(75, 10)],
    );
  }

  Future<void> test_constructorFieldInitializer() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

class C {
  final P p;
  C() : p = P.origin();
}
''',
      [lint(91, 10)],
    );
  }

  Future<void> test_constructorTearoff_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P Function() f = P.origin;
''');
  }

  Future<void> test_defaultParameterValue() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f({P p = const P.origin()}) {}
''',
      [lint(70, 16)],
    );
  }

  Future<void> test_dynamicContext_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

dynamic d = P.origin();
''');
  }

  Future<void> test_equalEqualDynamicLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(dynamic d) {
  bool b = d == P.origin();
}
''');
  }

  Future<void> test_equalEqualLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  bool b = P.origin() == p;
}
''');
  }

  Future<void> test_equalEqualNullableLeftOperand() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P? p) {
  bool b = p == P.origin();
}
''',
      [lint(87, 10)],
    );
  }

  Future<void> test_equalEqualObjectCastLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  bool b = (p as Object) == P.origin();
}
''');
  }

  Future<void>
  test_equalEqualParenthesizedConditionalRightOperand_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p, bool b) {
  bool r = p == (b ? P.origin() : P.origin());
}
''');
  }

  Future<void> test_equalEqualRightOperand() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  bool b = p == P.origin();
}
''',
      [lint(86, 10)],
    );
  }

  Future<void> test_explicitTypeArgumentsMatchingContext_noLint() async {
    await assertNoDiagnostics(r'''
List<int> l = List<int>.filled(3, 0);
''');
  }

  Future<void> test_explicitTypeArguments_noLint() async {
    await assertNoDiagnostics(r'''
List<num> l = List<int>.filled(3, 0);
''');
  }

  Future<void> test_expressionStatement_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  P.origin();
}
''');
  }

  Future<void> test_extensionTypeNamedConstructor() async {
    await assertDiagnostics(
      r'''
extension type Meters(int value) {
  Meters.twice(int v) : this(v * 2);
}

Meters m = Meters.twice(2);
''',
      [lint(86, 15)],
    );
  }

  Future<void> test_finalUntypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  final p = P.origin();
}
''');
  }

  Future<void> test_forElement() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  var l = <P>[for (var i = 0; i < 2; i++) P.origin()];
}
''',
      [lint(109, 10)],
    );
  }

  Future<void> test_forInIterable_noLint() async {
    await assertNoDiagnostics(r'''
void f() {
  for (var x in Iterable.empty()) {
    x.toString();
  }
}
''');
  }

  Future<void> test_futureOrContext() async {
    await assertDiagnostics(
      r'''
import 'dart:async';

class P {
  final int x;
  const P.origin() : x = 0;
}

FutureOr<P> p = P.origin();
''',
      [lint(94, 10)],
    );
  }

  Future<void> test_genericArgument_explicitTypeArguments() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void g<T>(T t) {}

void f() {
  g<P>(P.origin());
}
''',
      [lint(93, 10)],
    );
  }

  Future<void> test_genericArgument_inferred_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void g<T>(T t) {}

void f() {
  g(P.origin());
}
''');
  }

  Future<void> test_ifElement() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(bool b) {
  var l = <P>[if (b) P.origin()];
}
''',
      [lint(94, 10)],
    );
  }

  Future<void> test_ifNullAssignment() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P? p) {
  p ??= P.origin();
}
''',
      [lint(79, 10)],
    );
  }

  Future<void> test_ifNullRightOperand() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P f(P? p) {
  return p ?? P.origin();
}
''',
      [lint(82, 10)],
    );
  }

  Future<void> test_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Remote {
  const Remote.origin();
}
''');
    await assertDiagnostics(
      r'''
import 'other.dart' as p;

p.Remote r = p.Remote.origin();
''',
      [lint(40, 17)],
    );
  }

  Future<void> test_indexAssignmentValue() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(Map<String, P> m) {
  m['a'] = P.origin();
}
''',
      [lint(94, 10)],
    );
  }

  Future<void> test_lateLocalVariable() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  late P p = P.origin();
}
''',
      [lint(80, 10)],
    );
  }

  Future<void> test_metadataAnnotation_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

@P.origin()
void f() {}
''');
  }

  Future<void> test_metadataArgument() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

class Marker {
  final P p;
  const Marker(this.p);
}

@Marker(P.origin())
void f() {}
''',
      [lint(119, 10)],
    );
  }

  Future<void> test_namedArgument() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void g({P? p}) {}

void f() {
  g(p: P.origin());
}
''',
      [lint(93, 10)],
    );
  }

  Future<void> test_notEqualRightOperand() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  bool b = p != P.origin();
}
''',
      [lint(86, 10)],
    );
  }

  Future<void> test_nullableContext() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P? p = P.origin();
''',
      [lint(63, 10)],
    );
  }

  Future<void> test_objectContext_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

Object o = P.origin();
''');
  }

  Future<void> test_objectPatternField() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

class Box {
  final P p;
  const Box(this.p);
}

void f(Box b) {
  if (b case Box(p: const P.origin())) {}
}
''',
      [lint(147, 10)],
    );
  }

  Future<void> test_positionalArgument() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void g(P p) {}

void f() {
  g(P.origin());
}
''',
      [lint(87, 10)],
    );
  }

  Future<void> test_preDotShorthandsLanguageVersion_noLint() async {
    await assertNoDiagnostics(r'''
// @dart=3.9

class P {
  final int x;
  const P.origin() : x = 0;
}

P p = P.origin();
''');
  }

  Future<void> test_recordField() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  (P, int) r = (P.origin(), 1);
}
''',
      [lint(83, 10)],
    );
  }

  Future<void> test_redirectingFactory() async {
    await assertDiagnostics(
      r'''
class R {
  R();
  factory R.redirect() = R;
}

R r = R.redirect();
''',
      [lint(54, 12)],
    );
  }

  Future<void> test_relationalPattern() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  if (p case == const P.origin()) {}
}
''',
      [lint(86, 16)],
    );
  }

  Future<void> test_returnAsync() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

Future<P> f() async {
  return P.origin();
}
''',
      [lint(87, 10)],
    );
  }

  Future<void> test_returnAsyncFutureValue_noLint() async {
    await assertNoDiagnostics(r'''
Future<int> f() async {
  return Future.value(3);
}
''');
  }

  Future<void> test_returnNonAsyncFutureValue() async {
    await assertDiagnostics(
      r'''
Future<int> f() {
  return Future.value(3);
}
''',
      [lint(27, 15)],
    );
  }

  Future<void> test_returnNonAsync() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

Future<P> f() {
  return Future.value(P.origin());
}
''',
      [lint(81, 24)],
    );
  }

  Future<void> test_returnSync() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P f() {
  return P.origin();
}
''',
      [lint(73, 10)],
    );
  }

  Future<void> test_selectorReceiver_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

int x = P.origin().x;
''');
  }

  Future<void> test_shadowedClass_noLint() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Remote {
  const Remote.origin();
}
''');
    await assertNoDiagnostics(r'''
import 'other.dart' as p;

class Remote {
  const Remote.origin();
}

void f(p.Remote x) {
  bool b = x == Remote.origin();
}
''');
  }

  Future<void> test_spreadElement_noLint() async {
    await assertNoDiagnostics(r'''
List<int> f() => [...Iterable.empty()];
''');
  }

  Future<void> test_staticField() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

class C {
  static P p = P.origin();
}
''',
      [lint(81, 10)],
    );
  }

  Future<void> test_staticMethod_noLint() async {
    await assertNoDiagnostics(r'''
int x = int.parse('42');
''');
  }

  Future<void> test_stringInterpolation_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

String s = '${P.origin()}';
''');
  }

  Future<void> test_subtypeConstructorInSupertypeContext_noLint() async {
    await assertNoDiagnostics(r'''
abstract class A {}

class B implements A {
  B.named();
}

A a = B.named();
''');
  }

  Future<void> test_supertypeRedirectingFactory_noLint() async {
    await assertNoDiagnostics(r'''
class Geometry {
  const factory Geometry.all(int v) = Insets.all;
}

class Insets implements Geometry {
  final int v;
  const Insets.all(this.v);
}

Geometry g = Insets.all(8);
''');
  }

  Future<void> test_switchDynamicScrutinee_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(dynamic d) {
  switch (d) {
    case const P.origin():
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
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  int i = switch (p) {
    const P.origin() => 1,
    _ => 0,
  };
}
''',
      [lint(103, 10)],
    );
  }

  Future<void> test_switchStatementCase() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(P p) {
  switch (p) {
    case const P.origin():
      break;
    default:
      break;
  }
}
''',
      [lint(100, 10)],
    );
  }

  Future<void> test_ternaryBranches() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f(bool b) {
  P p = b ? P.origin() : P.origin();
}
''',
      [lint(85, 10), lint(98, 10)],
    );
  }

  Future<void> test_typeAliasContext() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

typedef Q = P;

Q q = P.origin();
''',
      [lint(78, 10)],
    );
  }

  Future<void> test_typeVariableContext_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

bool g<T extends P>(T t) => t == P.origin();
''');
  }

  Future<void> test_typedField() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

class C {
  P p = P.origin();
}
''',
      [lint(74, 10)],
    );
  }

  Future<void> test_typedListElement() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  var l = <P>[P.origin()];
}
''',
      [lint(81, 10)],
    );
  }

  Future<void> test_typedLocalVariable() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  P p = P.origin();
}
''',
      [lint(75, 10)],
    );
  }

  Future<void> test_typedMapKey() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  var m = <P, int>{P.origin(): 1};
}
''',
      [lint(86, 10)],
    );
  }

  Future<void> test_typedMapValue() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  var m = <int, P>{1: P.origin()};
}
''',
      [lint(89, 10)],
    );
  }

  Future<void> test_typedTopLevelVariable() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P p = P.origin();
''',
      [lint(62, 10)],
    );
  }

  Future<void> test_unnamedConstructor_noLint() async {
    await assertNoDiagnostics(r'''
class Q {
  Q();
}

Q q = Q();
''');
  }

  Future<void> test_untypedListLiteral_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  var l = [P.origin()];
}
''');
  }

  Future<void> test_untypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void f() {
  var p = P.origin();
}
''');
  }

  Future<void> test_yieldStar_noLint() async {
    await assertNoDiagnostics(r'''
Iterable<int> f() sync* {
  yield* Iterable.empty();
}
''');
  }

  Future<void> test_yieldSync() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

Iterable<P> f() sync* {
  yield P.origin();
}
''',
      [lint(88, 10)],
    );
  }
}
