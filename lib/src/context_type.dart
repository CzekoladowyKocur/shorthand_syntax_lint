import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

InterfaceElement? shorthandContextElement(Expression node) {
  var type = _unwrap(_contextType(node, precise: true));
  return type is InterfaceType ? type.element : null;
}

DartType? _argumentType(Argument argument) {
  var parameter = argument.correspondingParameter;
  if (parameter == null) return null;
  var typeParameters = _unsolvedTypeParameters(argument);
  if (typeParameters.isNotEmpty &&
      _referencesAny(parameter.baseElement.type, typeParameters)) {
    return null;
  }
  return parameter.type;
}

DartType? _binaryOperandType(
  BinaryExpression parent,
  Expression node, {
  required bool precise,
}) {
  var operator = parent.operator.type;
  if (operator == TokenType.QUESTION_QUESTION) {
    return _contextType(parent, precise: false);
  }
  if (operator == TokenType.EQ_EQ || operator == TokenType.BANG_EQ) {
    if (precise && parent.rightOperand == node) {
      return parent.leftOperand.staticType;
    }
    return null;
  }
  if (parent.rightOperand == node) {
    return node.correspondingParameter?.type;
  }
  return null;
}

DartType? _collectionElementType(CollectionElement element, int index) {
  AstNode node = element;
  while (true) {
    var parent = node.parent;
    if (parent is IfElement &&
        (parent.thenElement == node || parent.elseElement == node)) {
      node = parent;
    } else if (parent is ForElement && parent.body == node) {
      node = parent;
    } else if (parent is TypedLiteral) {
      return _literalTypeArgument(parent, index);
    } else {
      return null;
    }
  }
}

DartType? _contextType(Expression node, {required bool precise}) {
  var parent = node.parent;
  if (parent is VariableDeclaration && parent.initializer == node) {
    var list = parent.parent;
    return list is VariableDeclarationList ? list.type?.type : null;
  }
  if (parent is AssignmentExpression && parent.rightHandSide == node) {
    var operator = parent.operator.type;
    if (operator == TokenType.EQ ||
        operator == TokenType.QUESTION_QUESTION_EQ) {
      return parent.writeType;
    }
    return node.correspondingParameter?.type;
  }
  if (parent is ArgumentList) {
    return _argumentType(node);
  }
  if (parent is NamedArgument && parent.argumentExpression == node) {
    return _argumentType(parent);
  }
  if (parent is RecordLiteralNamedField && parent.fieldExpression == node) {
    var literal = parent.parent;
    if (literal is RecordLiteral) {
      return _namedRecordFieldType(literal, parent);
    }
    return null;
  }
  if (parent is ReturnStatement) {
    return _returnContext(parent.thisOrAncestorOfType<FunctionBody>());
  }
  if (parent is ExpressionFunctionBody && parent.expression == node) {
    return _returnContext(parent);
  }
  if (parent is YieldStatement && parent.star == null) {
    return _yieldContext(parent.thisOrAncestorOfType<FunctionBody>());
  }
  if (parent is ConditionalExpression &&
      (parent.thenExpression == node || parent.elseExpression == node)) {
    return _contextType(parent, precise: false);
  }
  if (parent is BinaryExpression) {
    return _binaryOperandType(parent, node, precise: precise);
  }
  if (parent is ParenthesizedExpression || parent is AwaitExpression) {
    return _contextType(parent as Expression, precise: false);
  }
  if (parent is PostfixExpression && parent.operator.type == TokenType.BANG) {
    return _contextType(parent, precise: precise);
  }
  if (parent is CascadeExpression && parent.target == node) {
    return _contextType(parent, precise: false);
  }
  if (parent is MethodInvocation && parent.target == node) {
    if (node is ParenthesizedExpression) return null;
    return _contextType(parent, precise: precise);
  }
  if (parent is PropertyAccess && parent.target == node) {
    if (node is ParenthesizedExpression) return null;
    return _contextType(parent, precise: precise);
  }
  if (parent is IndexExpression && parent.target == node) {
    if (node is ParenthesizedExpression) return null;
    return _contextType(parent, precise: precise);
  }
  if (parent is ListLiteral || parent is SetOrMapLiteral) {
    return _collectionElementType(node, 0);
  }
  if (parent is MapLiteralEntry) {
    return _collectionElementType(parent, parent.key == node ? 0 : 1);
  }
  if (parent is IfElement &&
      (parent.thenElement == node || parent.elseElement == node)) {
    return _collectionElementType(node, 0);
  }
  if (parent is ForElement && parent.body == node) {
    return _collectionElementType(node, 0);
  }
  if (parent is RecordLiteral) {
    return _positionalRecordFieldType(parent, node);
  }
  if (parent is ConstantPattern && parent.expression == node) {
    return parent.matchedValueType;
  }
  if (parent is RelationalPattern && parent.operand == node) {
    return parent.matchedValueType;
  }
  if (parent is FormalParameterDefaultClause && parent.value == node) {
    var formalParameter = parent.parent;
    if (formalParameter is FormalParameter) {
      return formalParameter.declaredFragment?.element.type;
    }
    return null;
  }
  if (parent is ConstructorFieldInitializer && parent.expression == node) {
    var field = parent.fieldName.element;
    return field is PropertyInducingElement ? field.type : null;
  }
  if (parent is IndexExpression && parent.index == node) {
    return node.correspondingParameter?.type;
  }
  return null;
}

DartType? _declaredReturnType(FunctionBody body) {
  var owner = body.parent;
  if (owner is MethodDeclaration) return owner.returnType?.type;
  if (owner is FunctionExpression) {
    var declaration = owner.parent;
    if (declaration is FunctionDeclaration) return declaration.returnType?.type;
  }
  return null;
}

DartType? _literalTypeArgument(TypedLiteral literal, int index) {
  var typeArguments = literal.typeArguments?.arguments;
  if (typeArguments != null) {
    return index < typeArguments.length ? typeArguments[index].type : null;
  }
  var context = _unwrap(_contextType(literal, precise: false));
  if (context is! InterfaceType) return null;
  if (context.isDartCoreList ||
      context.isDartCoreSet ||
      context.isDartCoreIterable ||
      context.isDartCoreMap) {
    var arguments = context.typeArguments;
    return index < arguments.length ? arguments[index] : null;
  }
  return null;
}

DartType? _namedRecordFieldType(
  RecordLiteral literal,
  RecordLiteralNamedField field,
) {
  var context = _unwrap(_contextType(literal, precise: false));
  if (context is! RecordType) return null;
  var name = field.name.lexeme;
  for (var candidate in context.namedFields) {
    if (candidate.name == name) return candidate.type;
  }
  return null;
}

DartType? _positionalRecordFieldType(RecordLiteral literal, Expression field) {
  var context = _unwrap(_contextType(literal, precise: false));
  if (context is! RecordType) return null;
  var index = 0;
  for (var candidate in literal.fields) {
    if (candidate is RecordLiteralNamedField) continue;
    if (candidate == field) {
      var fields = context.positionalFields;
      return index < fields.length ? fields[index].type : null;
    }
    index++;
  }
  return null;
}

bool _referencesAny(DartType type, Set<TypeParameterElement> typeParameters) {
  if (type is TypeParameterType) {
    return typeParameters.contains(type.element);
  }
  if (type is InterfaceType) {
    return type.typeArguments.any((t) => _referencesAny(t, typeParameters));
  }
  if (type is FunctionType) {
    return _referencesAny(type.returnType, typeParameters) ||
        type.formalParameters.any(
          (p) => _referencesAny(p.type, typeParameters),
        );
  }
  if (type is RecordType) {
    return type.positionalFields.any(
          (f) => _referencesAny(f.type, typeParameters),
        ) ||
        type.namedFields.any((f) => _referencesAny(f.type, typeParameters));
  }
  return false;
}

DartType? _returnContext(FunctionBody? body) {
  if (body == null) return null;
  var returnType = _declaredReturnType(body);
  if (returnType == null) return null;
  if (!body.isAsynchronous) return returnType;
  if (returnType is InterfaceType &&
      (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr)) {
    return returnType.typeArguments.first;
  }
  return null;
}

Set<TypeParameterElement> _unsolvedTypeParameters(Argument argument) {
  var invocation = argument.parent?.parent;
  if (invocation is MethodInvocation) {
    if (invocation.typeArguments != null) return const {};
    var element = invocation.methodName.element;
    if (element is ExecutableElement) {
      return element.baseElement.typeParameters.toSet();
    }
    return const {};
  }
  if (invocation is FunctionExpressionInvocation) {
    if (invocation.typeArguments != null) return const {};
    var element = invocation.element;
    if (element == null) return const {};
    return element.baseElement.typeParameters.toSet();
  }
  if (invocation is InstanceCreationExpression) {
    if (invocation.constructorName.type.typeArguments != null) return const {};
    var element = invocation.constructorName.element;
    if (element == null) return const {};
    return element.baseElement.enclosingElement.typeParameters.toSet();
  }
  return const {};
}

DartType? _unwrap(DartType? type) {
  while (type is InterfaceType && type.isDartAsyncFutureOr) {
    type = type.typeArguments.first;
  }
  return type;
}

DartType? _yieldContext(FunctionBody? body) {
  if (body == null) return null;
  var returnType = _declaredReturnType(body);
  if (returnType is InterfaceType &&
      (returnType.isDartCoreIterable || returnType.isDartAsyncStream)) {
    return returnType.typeArguments.first;
  }
  return null;
}
