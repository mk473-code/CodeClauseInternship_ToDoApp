import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart'; // 👈 adjust package name if different

void main() {
  testWidgets('Add a new task', (WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const TodoApp());

    // Tap FloatingActionButton to add a task
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter task title
    await tester.enterText(find.byType(TextField), "Test Task");

    // Select category (e.g., Personal)
    await tester.tap(find.text("Work").first); // default is Work
    await tester.pumpAndSettle();
    await tester.tap(find.text("Personal").last);
    await tester.pumpAndSettle();

    // Tap "Add" button
    await tester.tap(find.text("Add"));
    await tester.pumpAndSettle();

    // Verify task appears
    expect(find.text("Test Task"), findsOneWidget);
    expect(find.text("Category: Personal"), findsOneWidget);
  });

  testWidgets('Mark a task as done', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Add a new task first
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), "Complete Homework");
    await tester.tap(find.text("Add"));
    await tester.pumpAndSettle();

    // Tap the checkbox
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Verify strikethrough
    final textWidget = tester.widget<Text>(find.text("Complete Homework"));
    expect(textWidget.style!.decoration, TextDecoration.lineThrough);
  });

  testWidgets('Delete a task', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Add task
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), "Temp Task");
    await tester.tap(find.text("Add"));
    await tester.pumpAndSettle();

    // Delete task
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    // Verify it's gone
    expect(find.text("Temp Task"), findsNothing);
  });
}
