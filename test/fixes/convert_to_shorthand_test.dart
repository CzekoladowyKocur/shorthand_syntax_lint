import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../support/fix_host.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConvertToShorthandTest);
  });
}

@reflectiveTest
class ConvertToShorthandTest extends FixHostTest {
  Future<void> test_argument_enumConstant() async {
    await assertHasEdit(
      r'''
enum Status { active, inactive }

void g(Status s) {}

void f() {
  g(Status.active);
}
''',
      'Status.active',
      r'''
enum Status { active, inactive }

void g(Status s) {}

void f() {
  g(.active);
}
''',
    );
  }

  Future<void> test_argument_namedConstructor() async {
    await assertHasEdit(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void h(P p) {}

void f() {
  h(P.origin());
}
''',
      'P.origin()',
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

void h(P p) {}

void f() {
  h(.origin());
}
''',
    );
  }

  Future<void> test_argument_unnamedConstructor() async {
    await assertHasEdit(
      r'''
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);
}

void i(Pt p) {}

void f() {
  i(Pt(1, 2));
}
''',
      'Pt(1, 2)',
      r'''
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);
}

void i(Pt p) {}

void f() {
  i(.new(1, 2));
}
''',
    );
  }

  Future<void> test_arrowBody() async {
    await assertHasEdit(
      r'''
enum Status { active, inactive }

Status f() => Status.active;
''',
      'Status.active',
      r'''
enum Status { active, inactive }

Status f() => .active;
''',
    );
  }

  Future<void> test_collectionElement_enumConstant() async {
    await assertHasEdit(
      r'''
enum Status { active, inactive }

List<Status> l = [Status.active];
''',
      'Status.active',
      r'''
enum Status { active, inactive }

List<Status> l = [.active];
''',
    );
  }

  Future<void> test_collectionElement_staticMethod() async {
    await assertHasEdit(
      r'''
List<int> l = [int.parse('1')];
''',
      "int.parse('1')",
      r'''
List<int> l = [.parse('1')];
''',
    );
  }

  Future<void> test_constructorTearoff_noEdit() async {
    await assertNoEdit(r'''
class P {
  P.origin();
}

P Function() f = P.origin;
''', 'P.origin');
  }

  Future<void> test_enumConstant() async {
    await assertHasEdit(
      r'''
enum Status { active, inactive }

Status s = Status.active;
''',
      'Status.active',
      r'''
enum Status { active, inactive }

Status s = .active;
''',
    );
  }

  Future<void> test_enumConstant_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
enum Remote { on, off }
''');
    await assertHasEdit(
      r'''
import 'other.dart' as p;

p.Remote r = p.Remote.on;
''',
      'p.Remote.on',
      r'''
import 'other.dart' as p;

p.Remote r = .on;
''',
    );
  }

  Future<void> test_explicitConstructorTypeArguments_noEdit() async {
    await assertNoEdit(r'''
class Box<T> {
  final T value;
  const Box.of(this.value);
}

Box<num> b = Box<int>.of(1);
''', 'Box<int>.of(1)');
  }

  Future<void> test_expressionStatement_noEdit() async {
    await assertNoEdit(r'''
void f() {
  int.parse('42');
}
''', "int.parse('42')");
  }

  Future<void> test_namedConstructor() async {
    await assertHasEdit(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P p = P.origin();
''',
      'P.origin()',
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

P p = .origin();
''',
    );
  }

  Future<void> test_namedConstructor_const() async {
    await assertHasEdit(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const P p = const P.origin();
''',
      'const P.origin()',
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const P p = const .origin();
''',
    );
  }

  Future<void> test_namedConstructor_constListElement() async {
    await assertHasEdit(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const List<P> l = [P.origin()];
''',
      'P.origin()',
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const List<P> l = [.origin()];
''',
    );
  }

  Future<void> test_namedConstructor_implicitConst() async {
    await assertHasEdit(
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const P p = P.origin();
''',
      'P.origin()',
      r'''
class P {
  final int x;
  const P.origin() : x = 0;
}

const P p = .origin();
''',
    );
  }

  Future<void> test_namedConstructor_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class P {
  final int x;
  const P.origin() : x = 0;
}
''');
    await assertHasEdit(
      r'''
import 'other.dart' as p;

p.P v = p.P.origin();
''',
      'p.P.origin()',
      r'''
import 'other.dart' as p;

p.P v = .origin();
''',
    );
  }

  Future<void> test_preDotShorthandsLanguageVersion_noEdit() async {
    await assertNoEdit(r'''
// @dart=3.9
enum Status { active, inactive }

Status s = Status.active;
''', 'Status.active');
  }

  Future<void> test_returnStatement() async {
    await assertHasEdit(
      r'''
enum Status { active, inactive }

Status f() {
  return Status.active;
}
''',
      'Status.active',
      r'''
enum Status { active, inactive }

Status f() {
  return .active;
}
''',
    );
  }

  Future<void> test_siblingClassStatic_noEdit() async {
    await assertNoEdit(r'''
class C {
  const C();
}

class D {
  static const C c = C();
}

C x = D.c;
''', 'D.c');
  }

  Future<void> test_staticField() async {
    await assertHasEdit(
      r'''
class Box {
  const Box();
  static const Box empty = Box();
}

Box b = Box.empty;
''',
      'Box.empty',
      r'''
class Box {
  const Box();
  static const Box empty = Box();
}

Box b = .empty;
''',
    );
  }

  Future<void> test_staticField_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Box {
  const Box();
  static const Box empty = Box();
}
''');
    await assertHasEdit(
      r'''
import 'other.dart' as p;

p.Box b = p.Box.empty;
''',
      'p.Box.empty',
      r'''
import 'other.dart' as p;

p.Box b = .empty;
''',
    );
  }

  Future<void> test_staticGetter() async {
    await assertHasEdit(
      r'''
class Box {
  const Box();
  static Box get unit => const Box();
}

Box b = Box.unit;
''',
      'Box.unit',
      r'''
class Box {
  const Box();
  static Box get unit => const Box();
}

Box b = .unit;
''',
    );
  }

  Future<void> test_staticMethod_arguments() async {
    await assertHasEdit(
      r'''
int x = int.parse('42');
''',
      "int.parse('42')",
      r'''
int x = .parse('42');
''',
    );
  }

  Future<void> test_staticMethod_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Box {
  const Box();
  static Box wait(int x) => const Box();
}
''');
    await assertHasEdit(
      r'''
import 'other.dart' as p;

p.Box b = p.Box.wait(1);
''',
      'p.Box.wait(1)',
      r'''
import 'other.dart' as p;

p.Box b = .wait(1);
''',
    );
  }

  Future<void> test_staticMethod_typeArguments() async {
    await assertHasEdit(
      r'''
class Box {
  const Box();
  static Box wait<T>(List<T> xs) => const Box();
}

Box b = Box.wait<int>([1]);
''',
      'Box.wait<int>([1])',
      r'''
class Box {
  const Box();
  static Box wait<T>(List<T> xs) => const Box();
}

Box b = .wait<int>([1]);
''',
    );
  }

  Future<void> test_staticMethodTearoff_noEdit() async {
    await assertNoEdit(r'''
int Function(String) f = int.parse;
''', 'int.parse');
  }

  Future<void> test_supertypeContext_noEdit() async {
    await assertNoEdit(r'''
class A {
  const A();
}

class B extends A {
  const B.make();
}

A a = B.make();
''', 'B.make()');
  }

  Future<void> test_unnamedConstructor() async {
    await assertHasEdit(
      r'''
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);
}

Pt p = Pt(1, 2);
''',
      'Pt(1, 2)',
      r'''
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);
}

Pt p = .new(1, 2);
''',
    );
  }

  Future<void> test_unnamedConstructor_const() async {
    await assertHasEdit(
      r'''
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);
}

const Pt p = const Pt(1, 2);
''',
      'const Pt(1, 2)',
      r'''
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);
}

const Pt p = const .new(1, 2);
''',
    );
  }

  Future<void> test_unnamedConstructor_constListElement() async {
    await assertHasEdit(
      r'''
class Q {
  const Q();
}

const List<Q> qs = [Q()];
''',
      'Q()',
      r'''
class Q {
  const Q();
}

const List<Q> qs = [.new()];
''',
    );
  }

  Future<void> test_unnamedConstructor_importPrefixed() async {
    newFile('$testPackageLibPath/other.dart', r'''
class Pt {
  final int x;
  final int y;
  const Pt(this.x, this.y);
}
''');
    await assertHasEdit(
      r'''
import 'other.dart' as p;

p.Pt w = p.Pt(1, 2);
''',
      'p.Pt(1, 2)',
      r'''
import 'other.dart' as p;

p.Pt w = .new(1, 2);
''',
    );
  }

  Future<void> test_unnamedConstructorTearoff_noEdit() async {
    await assertNoEdit(r'''
class P {
  P();
}

P Function() f = P.new;
''', 'P.new');
  }

  Future<void> test_untypedVariable_noEdit() async {
    await assertNoEdit(r'''
enum Status { active, inactive }

var s = Status.active;
''', 'Status.active');
  }
}
