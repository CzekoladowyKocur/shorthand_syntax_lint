enum Status { active, inactive }

Status currentStatus() {
  Status status = Status.active;
  return status;
}

void main() {
  print(currentStatus());
}
