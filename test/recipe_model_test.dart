import 'package:flutter_test/flutter_test.dart';
import 'package:recipehub/main.dart';

void main() {
  test('Recipe model stores recipe information', () {
    final recipe = Recipe(
      id: 'test',
      name: 'Test Pasta',
      category: 'Italian',
      image: '',
      description: 'A test recipe',
      minutes: 20,
      rating: 4.5,
      ingredients: ['Pasta'],
      steps: ['Boil pasta'],
    );
    expect(recipe.name, 'Test Pasta');
    expect(recipe.minutes, 20);
  });
}
