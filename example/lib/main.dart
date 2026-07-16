enum Status { active, inactive }

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  const Point.origin() : this(0, 0);
}

Duration defaultTimeout() => Duration.zero;

void main() {
  Status status = Status.active;
  Duration delay = Duration.zero;
  Point origin = Point.origin();
  Point point = Point(2, 3);

  print(status);
  print(delay);
  print(origin.x + point.y);
  print(defaultTimeout());
}
