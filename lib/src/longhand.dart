import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';

enum LonghandKind {
  enumConstant,
  staticMember,
  namedConstructor,
  unnamedConstructor,
}

class LonghandTarget {
  final InterfaceElement target;
  final String memberName;
  final LonghandKind kind;
  final SourceRange head;

  LonghandTarget(this.target, this.memberName, this.kind, this.head);
}

LonghandTarget? matchLonghand(AstNode node) {
  if (node is PrefixedIdentifier) {
    var target = node.prefix.element;
    if (target is! InterfaceElement) return null;
    return _staticMember(target, node.identifier, _range(node.prefix));
  }
  if (node is PropertyAccess) {
    var head = node.target;
    if (head is! PrefixedIdentifier) return null;
    if (head.prefix.element is! PrefixElement) return null;
    var target = head.element;
    if (target is! InterfaceElement) return null;
    return _staticMember(target, node.propertyName, _range(head));
  }
  if (node is MethodInvocation) {
    var head = node.target;
    if (head is! Identifier) return null;
    var target = head.element;
    if (target is! InterfaceElement) return null;
    var method = node.methodName.element;
    if (method is! MethodElement || !method.isStatic) return null;
    return LonghandTarget(
      target,
      node.methodName.name,
      LonghandKind.staticMember,
      _range(head),
    );
  }
  if (node is InstanceCreationExpression) {
    var constructorName = node.constructorName;
    if (constructorName.type.typeArguments != null) return null;
    var element = constructorName.element;
    if (element == null) return null;
    var name = constructorName.name;
    return LonghandTarget(
      element.baseElement.enclosingElement,
      name?.name ?? 'new',
      name == null
          ? LonghandKind.unnamedConstructor
          : LonghandKind.namedConstructor,
      _range(constructorName.type),
    );
  }
  return null;
}

SourceRange _range(AstNode node) => SourceRange(node.offset, node.length);

LonghandTarget? _staticMember(
  InterfaceElement target,
  SimpleIdentifier member,
  SourceRange head,
) {
  var element = member.element;
  var variable = element is PropertyAccessorElement
      ? element.variable
      : element;
  if (variable is! FieldElement || !variable.isStatic) return null;
  var kind = variable.isEnumConstant
      ? LonghandKind.enumConstant
      : LonghandKind.staticMember;
  return LonghandTarget(target, member.name, kind, head);
}
