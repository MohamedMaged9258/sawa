// lib/presentation/screens/member/member_restaurant_screen.dart
import 'package:flutter/material.dart';

class MemberRestaurantScreen extends StatefulWidget {
  const MemberRestaurantScreen({super.key});

  @override
  State<MemberRestaurantScreen> createState() => _MemberRestaurantScreenState();
}

class _MemberRestaurantScreenState extends State<MemberRestaurantScreen> {
  final List<Restaurant> _restaurants = [
    Restaurant(
      id: '1',
      name: 'Healthy Bites',
      cuisine: 'Healthy & Organic',
      rating: 4.7,
      deliveryTime: '25-35 min',
      priceRange: '\$',
      image: '',
      meals: [
        Meal(
          id: '1',
          name: 'Grilled Chicken Salad',
          description: 'Fresh greens with grilled chicken breast',
          price: 12.99,
          calories: 450,
          category: 'Salads',
          image: '',
        ),
        Meal(
          id: '2',
          name: 'Quinoa Bowl',
          description: 'Organic quinoa with vegetables and tahini',
          price: 10.99,
          calories: 380,
          category: 'Bowls',
          image: '',
        ),
      ],
    ),
    Restaurant(
      id: '2',
      name: 'Protein Power',
      cuisine: 'Fitness Meals',
      rating: 4.9,
      deliveryTime: '20-30 min',
      priceRange: '\$\$',
      image: '',
      meals: [
        Meal(
          id: '3',
          name: 'Bodybuilder Platter',
          description: 'High protein meal with chicken, rice, and veggies',
          price: 15.99,
          calories: 650,
          category: 'Main Course',
          image: '',
        ),
        Meal(
          id: '4',
          name: 'Protein Smoothie',
          description: 'Whey protein with banana and almond milk',
          price: 8.99,
          calories: 280,
          category: 'Beverages',
          image: '',
        ),
      ],
    ),
    Restaurant(
      id: '3',
      name: 'Fresh & Fit',
      cuisine: 'Mediterranean',
      rating: 4.6,
      deliveryTime: '30-40 min',
      priceRange: '\$',
      image: '',
      meals: [
        Meal(
          id: '5',
          name: 'Greek Salad',
          description: 'Traditional Greek salad with feta cheese',
          price: 11.99,
          calories: 320,
          category: 'Salads',
          image: '',
        ),
      ],
    ),
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Healthy', 'High Protein', 'Low Carb', 'Vegetarian'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search restaurants or meals...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return _buildCategoryChip(category);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                return _buildRestaurantCard(_restaurants[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant, size: 35, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.cuisine,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(restaurant.rating.toString()),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, color: Colors.blue[500], size: 16),
                          const SizedBox(width: 4),
                          Text(restaurant.deliveryTime),
                          const SizedBox(width: 16),
                          Text(
                            restaurant.priceRange,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Popular Meals
            const Text(
              'Popular Meals:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...restaurant.meals.take(2).map((meal) {
              return _buildMealItem(meal, restaurant);
            }).toList(),
            const SizedBox(height: 12),
            // View All Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showRestaurantMenu(restaurant);
                },
                child: const Text('View Full Menu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(Meal meal, Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${meal.calories} cal',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      meal.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '\$${meal.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  _addToCart(meal, restaurant);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  backgroundColor: Colors.orange[700],
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRestaurantMenu(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${restaurant.name} - Full Menu',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: restaurant.meals.length,
                itemBuilder: (context, index) {
                  final meal = restaurant.meals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fastfood, color: Colors.orange),
                      ),
                      title: Text(meal.name),
                      subtitle: Text(meal.description),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\$${meal.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _addToCart(meal, restaurant);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              backgroundColor: Colors.orange[700],
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Meal meal, Restaurant restaurant) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${meal.name} to cart from ${restaurant.name}'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }
}

class Restaurant {
  String id;
  String name;
  String cuisine;
  double rating;
  String deliveryTime;
  String priceRange;
  String image;
  List<Meal> meals;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.priceRange,
    required this.image,
    required this.meals,
  });
}

class Meal {
  String id;
  String name;
  String description;
  double price;
  int calories;
  String category;
  String image;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.category,
    required this.image,
  });
}