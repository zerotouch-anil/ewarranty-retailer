import 'package:flutter/material.dart';
import 'package:retailer_app/constants/config.dart';
import 'package:retailer_app/models/categories_model.dart';
import 'package:retailer_app/screens/retailer_add_customer.dart';
import 'package:retailer_app/services/catalog_service.dart';

class CategoriesComponent extends StatefulWidget {
  const CategoriesComponent({super.key});

  @override
  State<CategoriesComponent> createState() => _CategoriesComponentState();
}

class _CategoriesComponentState extends State<CategoriesComponent> {
  late Future<List<Categories>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Categories>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No categories available"));
        }

        final categories = snapshot.data!;

        return SizedBox(
          height: 355, // Adjust height for 3 rows based on your UI
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 rows
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(category);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(Categories category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CustomerForm(
                  categoryId: category.categoryId,
                  categoryName: category.categoryName,
                  percentList: category.percentList,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFdccf7b), width: 0.6),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xff131313),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              '$baseUrl${category.img}',
              height: 35,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              child: Text(
                category.categoryName,
                style: const TextStyle(
                  color: Color.fromARGB(255, 30, 136, 229),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
