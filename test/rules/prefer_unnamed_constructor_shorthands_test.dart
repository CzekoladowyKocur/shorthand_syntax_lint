import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:shorthand_syntax_lint/src/rules/prefer_unnamed_constructor_shorthands.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferUnnamedConstructorShorthandsTest);
  });
}

@reflectiveTest
class PreferUnnamedConstructorShorthandsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferUnnamedConstructorShorthands();
    super.setUp();
  }

  Future<void> test_alreadyShorthand_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P() : x = 0;
}

void f() {
  P p = .new();
}
''');
  }

  Future<void> test_arrowBody() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

P f() => P();
''',
      [lint(58, 3)],
    );
  }

  Future<void> test_assignment() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f(P p) {
  p = P();
}
''',
      [lint(69, 3)],
    );
  }

  Future<void> test_awaitContext() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

Future<void> f() async {
  P p = await P();
}
''',
      [lint(88, 3)],
    );
  }

  Future<void> test_cascadeTarget() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f() {
  P p = P()..toString();
}
''',
      [lint(68, 3)],
    );
  }

  Future<void> test_constDeclarationExplicitConst() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

const P p = const P();
''',
      [lint(61, 9)],
    );
  }

  Future<void> test_constDeclarationImplicitConst() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

const P p = P();
''',
      [lint(61, 3)],
    );
  }

  Future<void> test_constList() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

const List<P> l = [P()];
''',
      [lint(68, 3)],
    );
  }

  Future<void> test_constructorTearoff_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P() : x = 0;
}

P Function() f = P.new;
''');
  }

  Future<void> test_dynamicContext_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P() : x = 0;
}

dynamic d = P();
''');
  }

  Future<void> test_enumConstant_noLint() async {
    await assertNoDiagnostics(r'''
enum E { a }

E e = E.a;
''');
  }

  Future<void> test_equalEqualLeftOperand_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P() : x = 0;
}

void f(P p) {
  bool b = P() == p;
}
''');
  }

  Future<void> test_equalEqualRightOperand() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f(P p) {
  bool b = p == P();
}
''',
      [lint(79, 3)],
    );
  }

  Future<void> test_explicitTypeArguments_noLint() async {
    await assertNoDiagnostics(r'''
class Box<T> {
  Box();
}

Box<num> b = Box<int>();
''');
  }

  Future<void> test_expressionStatement_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P() : x = 0;
}

void f() {
  P();
}
''');
  }

  Future<void> test_genericArgument_explicitTypeArguments() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void g<T>(T t) {}

void f() {
  g<P>(P());
}
''',
      [lint(86, 3)],
    );
  }

  Future<void> test_genericArgument_inferred_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P() : x = 0;
}

void g<T>(T t) {}

void f() {
  g(P());
}
''');
  }

  Future<void> test_ifNullAssignment() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f(P? p) {
  p ??= P();
}
''',
      [lint(72, 3)],
    );
  }

  Future<void> test_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Remote {
  const Remote();
}
''');
    await assertDiagnostics(
      r'''
import 'other.dart' as p;

p.Remote r = p.Remote();
''',
      [lint(40, 10)],
    );
  }

  Future<void> test_namedArgument() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void g({P? p}) {}

void f() {
  g(p: P());
}
''',
      [lint(86, 3)],
    );
  }

  Future<void> test_namedConstructor_noLint() async {
    await assertNoDiagnostics(r'''
class Q {
  const Q.origin();
}

Q q = Q.origin();
''');
  }

  Future<void> test_objectContext() async {
    await assertDiagnostics(
      r'''
Object o = Object();
''',
      [lint(11, 8)],
    );
  }

  Future<void> test_positionalArgument() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void g(P p) {}

void f() {
  g(P());
}
''',
      [lint(80, 3)],
    );
  }

  Future<void> test_preDotShorthandsLanguageVersion_noLint() async {
    await assertNoDiagnostics(r'''
// @dart=3.9

class P {
  final int x;
  const P() : x = 0;
}

P p = P();
''');
  }

  Future<void> test_recordField() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f() {
  (P, int) r = (P(), 1);
}
''',
      [lint(76, 3)],
    );
  }

  Future<void> test_returnSync() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

P f() {
  return P();
}
''',
      [lint(66, 3)],
    );
  }

  Future<void> test_staticMethod_noLint() async {
    await assertNoDiagnostics(r'''
int x = int.parse('42');
''');
  }

  Future<void> test_subtypeInSupertypeContext_noLint() async {
    await assertNoDiagnostics(r'''
class A {
  const A();
}

class B extends A {
  const B();
}

A a = B();
''');
  }

  Future<void> test_switchExpressionCase() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f(P p) {
  int i = switch (p) {
    const P() => 1,
    _ => 0,
  };
}
''',
      [lint(96, 3)],
    );
  }

  Future<void> test_switchStatementCase() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f(P p) {
  switch (p) {
    case const P():
      break;
    default:
      break;
  }
}
''',
      [lint(93, 3)],
    );
  }

  Future<void> test_ternaryBranches() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f(bool b) {
  P p = b ? P() : P();
}
''',
      [lint(78, 3), lint(84, 3)],
    );
  }

  Future<void> test_typedListElement() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f() {
  var l = <P>[P()];
}
''',
      [lint(74, 3)],
    );
  }

  Future<void> test_typedLocalVariable() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

void f() {
  P p = P();
}
''',
      [lint(68, 3)],
    );
  }

  Future<void> test_typedTopLevelVariable() async {
    await assertDiagnostics(
      r'''
class P {
  final int x;
  const P() : x = 0;
}

P p = P();
''',
      [lint(55, 3)],
    );
  }

  Future<void> test_untypedVariable_noLint() async {
    await assertNoDiagnostics(r'''
class P {
  final int x;
  const P() : x = 0;
}

void f() {
  var p = P();
}
''');
  }
}
