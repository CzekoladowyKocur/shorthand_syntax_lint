import 'package:shorthand_syntax_lint/src/context_type.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'support/resolve.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ShorthandContextElementTest);
  });
}

@reflectiveTest
class ShorthandContextElementTest extends SnippetResolutionTest {
  Future<void> test_annotationArgument() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Marker {
  final Status s;
  const Marker(this.s);
}

@Marker(Status.active)
void f() {}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_argumentExplicitTypeArguments() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void g<T>(T t) {}

void f() {
  g<Status>(Status.active);
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_argumentInferredTypeArgument() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void g<T>(T t) {}

void f() {
  g(Status.active);
}
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_arrowBody() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Status f() => Status.active;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_asExpressionOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Object o = Status.active as Object;
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_assignment() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  Status s = Status.active;
  s = Status.inactive;
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Status.inactive')),
      same(declaration('Status')),
    );
  }

  Future<void> test_awaitOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Future<void> f() async {
  Status s = await Status.active;
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_binaryLeftOperand() async {
    await resolveSnippet(r'''
int v = int.parse('1') + 1;
''');
    expect(shorthandContextElement(expression("int.parse('1')")), isNull);
  }

  Future<void> test_binaryRightOperand() async {
    await resolveSnippet(r'''
class Vec {
  const Vec();
  static const Vec zero = Vec();
  static const Vec one = Vec();
  Vec operator +(Vec other) => other;
}

void f() {
  Vec v = Vec.zero + Vec.one;
  v.toString();
}
''');
    expect(
      shorthandContextElement(expression('Vec.one')),
      same(declaration('Vec')),
    );
  }

  Future<void> test_cascadeTarget() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  Status s = Status.active..toString();
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_compoundAssignmentRightOperand() async {
    await resolveSnippet(r'''
class Vec {
  const Vec();
  static const Vec one = Vec();
  Vec operator +(Vec other) => other;
}

void f() {
  var v = const Vec();
  v += Vec.one;
  v.toString();
}
''');
    expect(
      shorthandContextElement(expression('Vec.one')),
      same(declaration('Vec')),
    );
  }

  Future<void> test_conditionalBranches() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Status f(bool b) => b ? Status.active : Status.inactive;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
    expect(
      shorthandContextElement(expression('Status.inactive')),
      same(declaration('Status')),
    );
  }

  Future<void> test_constDeclaration() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

const Status s = Status.active;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_constructorFieldInitializer() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Holder {
  Status s;
  Holder() : s = Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_constructorTearoff() async {
    await resolveSnippet(r'''
class Holder {
  Holder();
}

void f() {
  Holder Function() g = Holder.new;
  g.toString();
}
''');
    expect(shorthandContextElement(expression('Holder.new')), isNull);
  }

  Future<void> test_defaultParameterValue() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f([Status s = Status.active]) {}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_dynamicContext() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

dynamic d = Status.active;
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_enumStaticMember() async {
    await resolveSnippet(r'''
enum Stat {
  up,
  down;

  static Stat preferred = Stat.up;
}

void f() {
  Stat s = Stat.preferred;
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Stat.preferred')),
      same(declaration('Stat')),
    );
  }

  Future<void> test_equalEqualDynamicLeftOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(dynamic d) {
  if (d == Status.active) {}
}
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_equalEqualLeftOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status s) {
  if (Status.active == s) {}
}
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_equalEqualObjectCastLeftOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status s) {
  if ((s as Object) == Status.active) {}
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(snippet.typeProvider.objectElement),
    );
  }

  Future<void> test_equalEqualParenthesizedConditionalRightOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status s, bool b) {
  if (s == (b ? Status.active : Status.inactive)) {}
}
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
    expect(shorthandContextElement(expression('Status.inactive')), isNull);
  }

  Future<void> test_equalEqualRightOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status s) {
  if (s == Status.active) {}
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_expressionStatement() async {
    await resolveSnippet(r'''
void f() {
  int.parse('42');
}
''');
    expect(shorthandContextElement(expression("int.parse('42')")), isNull);
  }

  Future<void> test_extensionTypeContext() async {
    await resolveSnippet(r'''
extension type Meters(int value) {
  static Meters get zero => Meters(0);
}

void f() {
  Meters m = Meters.zero;
  m.toString();
}
''');
    expect(
      shorthandContextElement(expression('Meters.zero')),
      same(declaration('Meters')),
    );
  }

  Future<void> test_forElement() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

List<Status> f() => <Status>[for (var i = 0; i < 2; i++) Status.active];
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_forInIterable() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  for (var s in Status.values) {
    s.toString();
  }
}
''');
    expect(shorthandContextElement(expression('Status.values')), isNull);
  }

  Future<void> test_functionTypedContext() async {
    await resolveSnippet(r'''
void f() {
  int Function(String) g = int.parse;
  g.toString();
}
''');
    expect(shorthandContextElement(expression('int.parse')), isNull);
  }

  Future<void> test_futureOrContext() async {
    await resolveSnippet(r'''
import 'dart:async';

enum Status { active, inactive }

FutureOr<Status> s = Status.active;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_ifElement() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

List<Status> f(bool b) => <Status>[if (b) Status.active];
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_ifNullAssignment() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status? s) {
  s ??= Status.active;
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_ifNullLeftOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Config {
  static Status? maybe;
}

Status f() => Config.maybe ?? Status.active;
''');
    expect(
      shorthandContextElement(expression('Config.maybe')),
      same(declaration('Status')),
    );
  }

  Future<void> test_ifNullRightOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Config {
  static Status? maybe;
}

Status f() => Config.maybe ?? Status.active;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_indexAssignmentValue() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Map<String, Status> m) {
  m['a'] = Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_isExpressionOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

bool b = Status.active is Status;
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_lateLocalVariable() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  late Status s = Status.active;
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_listOfEnumValues() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

List<Status> l = Status.values;
''');
    expect(
      shorthandContextElement(expression('Status.values')),
      same(snippet.typeProvider.listElement),
    );
  }

  Future<void> test_listPatternElement() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

bool f(List<Status> l) {
  if (l case [Status.active]) return true;
  return false;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_mapPatternValue() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

bool f(Map<String, Status> m) {
  if (m case {'k': Status.active}) return true;
  return false;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_memberTypeDiffersFromContext() async {
    await resolveSnippet(r'''
class Ticks {
  static const int perDay = 86400000;
}

int t = Ticks.perDay;
''');
    expect(
      shorthandContextElement(expression('Ticks.perDay')),
      same(snippet.typeProvider.intElement),
    );
  }

  Future<void> test_namedArgument() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void g({required Status status}) {}

void f() {
  g(status: Status.active);
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_namedConstructor() async {
    await resolveSnippet(r'''
class Point {
  Point.origin();
}

void f() {
  Point p = Point.origin();
  p.toString();
}
''');
    expect(
      shorthandContextElement(expression('Point.origin()')),
      same(declaration('Point')),
    );
  }

  Future<void> test_nestedContexts() async {
    await resolveSnippet(r'''
class Wrap {
  Wrap(int n);
}

void f() {
  Wrap w = Wrap(int.parse('1'));
  w.toString();
}
''');
    expect(
      shorthandContextElement(expression("Wrap(int.parse('1'))")),
      same(declaration('Wrap')),
    );
    expect(
      shorthandContextElement(expression("int.parse('1')")),
      same(snippet.typeProvider.intElement),
    );
  }

  Future<void> test_notEqualRightOperand() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status s) {
  if (s != Status.active) {}
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_nullableContext() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Status? s = Status.active;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_nullableLeftOperandEquality() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status? s) {
  if (s == Status.active) {}
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_nullAssert() async {
    await resolveSnippet(r'''
int x = int.tryParse('1')!;
''');
    expect(
      shorthandContextElement(expression("int.tryParse('1')")),
      same(snippet.typeProvider.intElement),
    );
  }

  Future<void> test_objectContext() async {
    await resolveSnippet(r'''
Object o = Object.hash(1, 2);
''');
    expect(
      shorthandContextElement(expression('Object.hash(1, 2)')),
      same(snippet.typeProvider.objectElement),
    );
  }

  Future<void> test_objectPatternField() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Box {
  final Status s;
  const Box(this.s);
}

void f(Box b) {
  if (b case Box(s: Status.active)) {}
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_orPatternBranches() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

bool f(Status s) {
  if (s case Status.active || Status.inactive) return true;
  return false;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
    expect(
      shorthandContextElement(expression('Status.inactive')),
      same(declaration('Status')),
    );
  }

  Future<void> test_parenthesizedReceiver() async {
    await resolveSnippet(r'''
void f() {
  (int.parse('1')).toString();
}
''');
    expect(shorthandContextElement(expression("int.parse('1')")), isNull);
  }

  Future<void> test_positionalArgument() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void g(Status s) {}

void f() {
  g(Status.active);
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_prefixedContextType() async {
    var otherFile = newFile('$testPackageLibPath/other.dart', r'''
enum Remote { on, off }
''');
    await resolveSnippet(r'''
import 'other.dart' as p;

p.Remote r = p.Remote.on;
''');
    var other = await resolveFile(otherFile.path);
    expect(
      shorthandContextElement(expression('p.Remote.on')),
      same(declarationIn(other, 'Remote')),
    );
  }

  Future<void> test_promotedVariableScrutinee() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Object o) {
  if (o is Status) {
    switch (o) {
      case Status.active:
        break;
      default:
        break;
    }
  }
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_recordField() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

(Status, int) r = (Status.active, 1);
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_recordPatternField() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

bool f((Status, int) r) {
  if (r case (Status.active, 1)) return true;
  return false;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_relationalPattern() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status s) {
  if (s case == Status.active) {}
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_returnAsyncFuture() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Future<Status> f() async {
  return Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_returnNonAsyncFuture() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Future<Status> f() {
  return Future.value(Status.active);
}
''');
    expect(
      shorthandContextElement(expression('Future.value(Status.active)')),
      same(snippet.typeProvider.futureElement),
    );
  }

  Future<void> test_returnSync() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Status f() {
  return Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_selectorChainHead() async {
    await resolveSnippet(r'''
String s = int.parse('1').toString();
''');
    expect(shorthandContextElement(expression("int.parse('1')")), isNull);
  }

  Future<void> test_siblingClassMember() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Palette {
  static const Status bright = Status.active;
}

void f() {
  Status s = Palette.bright;
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Palette.bright')),
      same(declaration('Status')),
    );
  }

  Future<void> test_spreadElement() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

List<Status> f() => [...Status.values];
''');
    expect(shorthandContextElement(expression('Status.values')), isNull);
  }

  Future<void> test_staticMethodInvocation() async {
    await resolveSnippet(r'''
int x = int.parse('42');
''');
    expect(
      shorthandContextElement(expression("int.parse('42')")),
      same(snippet.typeProvider.intElement),
    );
  }

  Future<void> test_stringInterpolation() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  print('${Status.active}');
}
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_supertypeContext() async {
    await resolveSnippet(r'''
class A {
  const A();
}

class B extends A {
  const B();
}

void f() {
  A a = B();
  a.toString();
}
''');
    expect(shorthandContextElement(expression('B()')), same(declaration('A')));
  }

  Future<void> test_switchCase() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    default:
      break;
  }
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_switchExpressionCase() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

int f(Status s) => switch (s) {
  Status.active => 1,
  _ => 0,
};
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_switchOnDynamic() async {
    await resolveSnippet(r'''
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
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_typedInstanceField() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Holder {
  Status s = Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedListElement() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

var l = <Status>[Status.active];
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedListElement_contextTypedLiteral() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

List<Status> l = [Status.active];
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedLocalVariable() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  Status s = Status.active;
  s.toString();
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedMapKey() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

var m = <Status, int>{Status.active: 1};
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedMapValue() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

var m = <String, Status>{'a': Status.active};
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedSetElement() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

var s = <Status>{Status.active};
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedStaticField() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

class Holder {
  static Status s = Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typedTopLevelVariable() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Status s = Status.active;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typeAliasContext() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

typedef Alias = Status;

Alias a = Status.active;
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_typeVariableContext() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

T pick<T extends Status>(T t) {
  T v = t;
  return v;
}
''');
    expect(shorthandContextElement(expression('t')), isNull);
  }

  Future<void> test_untypedListLiteral() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

var l = [Status.active];
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_untypedVariable() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  var s = Status.active;
  s.toString();
}
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_untypedVariable_final() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

void f() {
  final s = Status.active;
  s.toString();
}
''');
    expect(shorthandContextElement(expression('Status.active')), isNull);
  }

  Future<void> test_yieldAsyncStar() async {
    await resolveSnippet(r'''
import 'dart:async';

enum Status { active, inactive }

Stream<Status> f() async* {
  yield Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }

  Future<void> test_yieldStar() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Iterable<Status> f() sync* {
  yield* Status.values;
}
''');
    expect(shorthandContextElement(expression('Status.values')), isNull);
  }

  Future<void> test_yieldSyncStar() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Iterable<Status> f() sync* {
  yield Status.active;
}
''');
    expect(
      shorthandContextElement(expression('Status.active')),
      same(declaration('Status')),
    );
  }
}
