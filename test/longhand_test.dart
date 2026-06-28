import 'package:analyzer/dart/ast/ast.dart';
import 'package:shorthand_syntax_lint/src/longhand.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'support/resolve.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MatchLonghandTest);
  });
}

@reflectiveTest
class MatchLonghandTest extends SnippetResolutionTest {
  Future<void> test_constNamedConstructor() async {
    await resolveSnippet(r'''
class Point {
  const Point.origin();
}

Point p = const Point.origin();
''');
    var node = expression('const Point.origin()') as InstanceCreationExpression;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.namedConstructor);
    expect(target.target, same(declaration('Point')));
    expect(target.memberName, 'origin');
    expect(target.head.offset, node.constructorName.type.offset);
    expect(target.head.length, node.constructorName.type.length);
  }

  Future<void> test_constructorReference_named() async {
    await resolveSnippet(r'''
class Point {
  Point.origin();
}

Point Function() f = Point.origin;
''');
    expect(matchLonghand(expression('Point.origin')), isNull);
  }

  Future<void> test_constructorReference_unnamed() async {
    await resolveSnippet(r'''
class Point {
  Point();
}

Point Function() f = Point.new;
''');
    expect(matchLonghand(expression('Point.new')), isNull);
  }

  Future<void> test_enumConstant() async {
    await resolveSnippet(r'''
enum Status { active, inactive }

Status s = Status.active;
''');
    var node = expression('Status.active') as PrefixedIdentifier;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.enumConstant);
    expect(target.target, same(declaration('Status')));
    expect(target.memberName, 'active');
    expect(target.head.offset, node.prefix.offset);
    expect(target.head.length, node.prefix.length);
  }

  Future<void> test_extensionStaticField() async {
    await resolveSnippet(r'''
extension Marks on int {
  static int unit = 1;
}

int x = Marks.unit;
''');
    expect(matchLonghand(expression('Marks.unit')), isNull);
  }

  Future<void> test_extensionStaticMethodInvocation() async {
    await resolveSnippet(r'''
extension Marks on int {
  static int marker() => 0;
}

int x = Marks.marker();
''');
    expect(matchLonghand(expression('Marks.marker()')), isNull);
  }

  Future<void> test_importPrefixedEnumConstant() async {
    var otherFile = newFile('$testPackageLibPath/other.dart', r'''
enum Remote { on, off }
''');
    await resolveSnippet(r'''
import 'other.dart' as p;

p.Remote r = p.Remote.on;
''');
    var other = await resolveFile(otherFile.path);
    var node = expression('p.Remote.on') as PropertyAccess;
    var head = node.target as PrefixedIdentifier;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.enumConstant);
    expect(target.target, same(declarationIn(other, 'Remote')));
    expect(target.memberName, 'on');
    expect(target.head.offset, head.offset);
    expect(target.head.length, head.length);
  }

  Future<void> test_importPrefixedNamedConstructor() async {
    var otherFile = newFile('$testPackageLibPath/other.dart', r'''
class Point {
  Point.origin();
}
''');
    await resolveSnippet(r'''
import 'other.dart' as p;

p.Point o = p.Point.origin();
''');
    var other = await resolveFile(otherFile.path);
    var node = expression('p.Point.origin()') as InstanceCreationExpression;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.namedConstructor);
    expect(target.target, same(declarationIn(other, 'Point')));
    expect(target.memberName, 'origin');
    expect(target.head.offset, node.constructorName.type.offset);
    expect(target.head.length, node.constructorName.type.length);
  }

  Future<void> test_importPrefixedStaticField() async {
    var otherFile = newFile('$testPackageLibPath/other.dart', r'''
class Box {
  static const Box zero = Box._();
  const Box._();
}
''');
    await resolveSnippet(r'''
import 'other.dart' as p;

p.Box b = p.Box.zero;
''');
    var other = await resolveFile(otherFile.path);
    var node = expression('p.Box.zero') as PropertyAccess;
    var head = node.target as PrefixedIdentifier;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.staticMember);
    expect(target.target, same(declarationIn(other, 'Box')));
    expect(target.memberName, 'zero');
    expect(target.head.offset, head.offset);
    expect(target.head.length, head.length);
  }

  Future<void> test_importPrefixedStaticMethodInvocation() async {
    var otherFile = newFile('$testPackageLibPath/other.dart', r'''
class Box {
  Box();

  static Box make() => Box();
}
''');
    await resolveSnippet(r'''
import 'other.dart' as p;

p.Box b = p.Box.make();
''');
    var other = await resolveFile(otherFile.path);
    var node = expression('p.Box.make()') as MethodInvocation;
    var head = node.target!;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.staticMember);
    expect(target.target, same(declarationIn(other, 'Box')));
    expect(target.memberName, 'make');
    expect(target.head.offset, head.offset);
    expect(target.head.length, head.length);
  }

  Future<void> test_instanceGetterAccess() async {
    await resolveSnippet(r'''
void f(String s) {
  var l = s.length;
  l.toString();
}
''');
    expect(matchLonghand(expression('s.length')), isNull);
  }

  Future<void> test_namedConstructor() async {
    await resolveSnippet(r'''
class Point {
  Point.origin();
}

Point p = Point.origin();
''');
    var node = expression('Point.origin()') as InstanceCreationExpression;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.namedConstructor);
    expect(target.target, same(declaration('Point')));
    expect(target.memberName, 'origin');
    expect(target.head.offset, node.constructorName.type.offset);
    expect(target.head.length, node.constructorName.type.length);
  }

  Future<void> test_namedConstructor_explicitTypeArguments() async {
    await resolveSnippet(r'''
class Box<T> {
  Box.of();
}

Box<int> b = Box<int>.of();
''');
    expect(matchLonghand(expression('Box<int>.of()')), isNull);
  }

  Future<void> test_staticField() async {
    await resolveSnippet(r'''
class Box {
  static const Box zero = Box._();
  const Box._();
}

Box b = Box.zero;
''');
    var node = expression('Box.zero') as PrefixedIdentifier;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.staticMember);
    expect(target.target, same(declaration('Box')));
    expect(target.memberName, 'zero');
    expect(target.head.offset, node.prefix.offset);
    expect(target.head.length, node.prefix.length);
  }

  Future<void> test_staticGetter() async {
    await resolveSnippet(r'''
class Box {
  const Box._();
  static Box get unit => const Box._();
}

Box b = Box.unit;
''');
    var target = matchLonghand(expression('Box.unit'))!;
    expect(target.kind, LonghandKind.staticMember);
    expect(target.target, same(declaration('Box')));
    expect(target.memberName, 'unit');
  }

  Future<void> test_staticMethodInvocation() async {
    await resolveSnippet(r'''
int x = int.parse('42');
''');
    var node = expression("int.parse('42')") as MethodInvocation;
    var head = node.target!;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.staticMember);
    expect(target.target, same(snippet.typeProvider.intElement));
    expect(target.memberName, 'parse');
    expect(target.head.offset, head.offset);
    expect(target.head.length, head.length);
  }

  Future<void> test_staticMethodInvocation_typeArguments() async {
    await resolveSnippet(r'''
class Util {
  static T pick<T>(T t) => t;
}

int x = Util.pick<int>(1);
''');
    var target = matchLonghand(expression('Util.pick<int>(1)'))!;
    expect(target.kind, LonghandKind.staticMember);
    expect(target.target, same(declaration('Util')));
    expect(target.memberName, 'pick');
  }

  Future<void> test_staticMethodTearoff() async {
    await resolveSnippet(r'''
int Function(String) f = int.parse;
''');
    expect(matchLonghand(expression('int.parse')), isNull);
  }

  Future<void> test_topLevelFunctionInvocation() async {
    await resolveSnippet(r'''
int g() => 0;

int x = g();
''');
    expect(matchLonghand(expression('g()')), isNull);
  }

  Future<void> test_unnamedConstructor() async {
    await resolveSnippet(r'''
class Point {
  Point(int x, int y);
}

Point p = Point(1, 2);
''');
    var node = expression('Point(1, 2)') as InstanceCreationExpression;
    var target = matchLonghand(node)!;
    expect(target.kind, LonghandKind.unnamedConstructor);
    expect(target.target, same(declaration('Point')));
    expect(target.memberName, 'new');
    expect(target.head.offset, node.constructorName.type.offset);
    expect(target.head.length, node.constructorName.type.length);
  }

  Future<void> test_unnamedConstructor_explicitTypeArguments() async {
    await resolveSnippet(r'''
class Box<T> {
  Box();
}

Box<int> b = Box<int>();
''');
    expect(matchLonghand(expression('Box<int>()')), isNull);
  }
}
