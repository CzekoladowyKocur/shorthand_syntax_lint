import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:shorthand_syntax_lint/src/rules/prefer_return_shorthands.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferReturnShorthandsTest);
  });
}

@reflectiveTest
class PreferReturnShorthandsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferReturnShorthands();
    super.setUp();
  }

  Future<void> test_alreadyShorthand_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

Status f() => .active;
''');
  }

  Future<void> test_arrowBodyAsync_staticField() async {
    await assertDiagnostics(
      r'''
Future<Duration> f() async => Duration.zero;
''',
      [lint(30, 13)],
    );
  }

  Future<void> test_arrowBody_enumConstant() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

Status f() => Status.active;
''',
      [lint(48, 13)],
    );
  }

  Future<void> test_arrowBody_namedConstructor() async {
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

  Future<void> test_arrowBody_staticField() async {
    await assertDiagnostics(
      r'''
Duration f() => Duration.zero;
''',
      [lint(16, 13)],
    );
  }

  Future<void> test_arrowBody_staticGetter() async {
    await assertDiagnostics(
      r'''
class Endianness {
  static final Endianness _host = Endianness();
  static Endianness get host => _host;
}

Endianness f() => Endianness.host;
''',
      [lint(127, 15)],
    );
  }

  Future<void> test_arrowBody_staticMethod() async {
    await assertDiagnostics(
      r'''
int f() => int.parse('42');
''',
      [lint(11, 15)],
    );
  }

  Future<void> test_arrowBody_unnamedConstructor() async {
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

  Future<void> test_closureInferredReturn_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

T g<T>(T Function() f) => f();

void h() {
  g(() => Status.active);
}
''');
  }

  Future<void> test_getterArrowBody() async {
    await assertDiagnostics(
      r'''
Duration get d => Duration.zero;
''',
      [lint(18, 13)],
    );
  }

  Future<void> test_getterBlockBody() async {
    await assertDiagnostics(
      r'''
Duration get d {
  return Duration.zero;
}
''',
      [lint(26, 13)],
    );
  }

  Future<void> test_localFunction() async {
    await assertDiagnostics(
      r'''
enum Status { active, inactive }

void f() {
  Status g() => Status.active;
  g();
}
''',
      [lint(61, 13)],
    );
  }

  Future<void> test_noDeclaredReturnType_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

f() {
  return Status.active;
}
''');
  }

  Future<void> test_preDotShorthandsLanguageVersion_noLint() async {
    await assertNoDiagnostics(r'''
// @dart=3.9

Duration f() => Duration.zero;
''');
  }

  Future<void> test_returnAsyncFutureValue_noLint() async {
    await assertNoDiagnostics(r'''
Future<int> f() async {
  return Future.value(3);
}
''');
  }

  Future<void> test_returnAsync_enumConstant() async {
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

  Future<void> test_returnNonAsyncTypeMemberArgument() async {
    await assertDiagnostics(
      r'''
Future<Duration> f() {
  return Future.value(Duration.zero);
}
''',
      [lint(32, 27)],
    );
  }

  Future<void> test_returnSync_enumConstant() async {
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

  Future<void> test_returnSync_namedConstructor() async {
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

  Future<void> test_returnSync_staticField() async {
    await assertDiagnostics(
      r'''
Duration f() {
  return Duration.zero;
}
''',
      [lint(24, 13)],
    );
  }

  Future<void> test_returnSync_staticGetter() async {
    await assertDiagnostics(
      r'''
class Endianness {
  static final Endianness _host = Endianness();
  static Endianness get host => _host;
}

Endianness f() {
  return Endianness.host;
}
''',
      [lint(135, 15)],
    );
  }

  Future<void> test_returnSync_staticMethod() async {
    await assertDiagnostics(
      r'''
int f() {
  return int.parse('42');
}
''',
      [lint(19, 15)],
    );
  }

  Future<void> test_returnSync_unnamedConstructor() async {
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

  Future<void> test_returnWithoutExpression_noLint() async {
    await assertNoDiagnostics(r'''
void f() {
  return;
}
''');
  }

  Future<void> test_setterArrowBody_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

class C {
  set s(int v) => Status.active;
}
''');
  }

  Future<void> test_typedDeclaration_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

Status s = Status.active;
''');
  }

  Future<void> test_voidArrowBody_noLint() async {
    await assertNoDiagnostics(r'''
enum Status { active, inactive }

void f() => Status.active;
''');
  }
}
