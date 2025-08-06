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

  // Calculate dynamic row count based on categories length
  int _calculateRowCount(int categoryCount) {
    if (categoryCount == 0) return 1;
    if (categoryCount <= 3) return 1;
    if (categoryCount <= 6) return 2;
    return 3; // Maximum 3 rows
  }

  // Calculate dynamic height based on row count
  double _calculateHeight(int rowCount) {
    const double itemHeight = 70.0;
    const double spacing = 5.0;
    return (itemHeight * rowCount) + (spacing * (rowCount - 1)) + 20;
  }

  int _calculateVisibleColumns(double containerWidth) {
    const double itemWidth = 90.0; 
    const double spacing = 12.0;
    return ((containerWidth - 24) / (itemWidth + spacing)).floor(); 
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
        final rowCount = _calculateRowCount(categories.length);
        final containerHeight = _calculateHeight(rowCount);

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFdccf7b),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final visibleColumns = _calculateVisibleColumns(constraints.maxWidth);
                    final maxVisibleItems = rowCount * visibleColumns;
                    final needsScrolling = categories.length > maxVisibleItems;
                    
                    return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: needsScrolling 
                          ? const BouncingScrollPhysics() 
                          : const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildCategoryItem(category);
                      },
                    );
                  },
                ),
              ),
            ],
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
            builder: (_) => CustomerForm(
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
          borderRadius: BorderRadius.circular(7),
          color: const Color(0xff131313),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              '$baseUrl${category.img}',
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Image load error for: $baseUrl${category.img}');
                print('Error: $error');
                return const Icon(Icons.broken_image, color: Colors.grey);
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 5, right:5),
              child: Text(
                category.categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}