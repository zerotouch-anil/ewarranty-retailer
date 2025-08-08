import 'package:flutter/material.dart';
import 'package:retailer_app/constants/config.dart';
import 'package:retailer_app/models/categories_model.dart';
import 'package:retailer_app/screens/add_customer/add_customer_screen.dart';
import 'package:retailer_app/services/catalog_service.dart';

class CategoriesComponent extends StatefulWidget {
  const CategoriesComponent({super.key});

  @override
  State<CategoriesComponent> createState() => _CategoriesComponentState();
}

class _CategoriesComponentState extends State<CategoriesComponent> {
  late Future<List<Categories>> _categoriesFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    const double itemHeight = 60.0;
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
          return const Center(
            child: Text(
              "No categories available",
              style: TextStyle(
                color: Color(0xFFdccf7b),
                fontSize: 20,
              ),
            ),
          );
        }

        final categories = snapshot.data!;
        final rowCount = _calculateRowCount(categories.length);

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      'Add Customer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFdccf7b),
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey[800], thickness: 1, height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      'Available Categories',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final visibleColumns = _calculateVisibleColumns(
                      constraints.maxWidth,
                    );
                    final maxVisibleItems = rowCount * visibleColumns;
                    final needsScrolling = categories.length > maxVisibleItems;

                    return RawScrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 3,
                      radius: const Radius.circular(20),
                      thumbColor: const Color(0xFFdccf7b),

                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          physics:
                              needsScrolling
                                  ? const BouncingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: rowCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _buildCategoryItem(category);
                          },
                        ),
                      ),
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
            builder:
                (_) => AddCustomerScreen(
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
              padding: const EdgeInsets.only(left: 5, right: 5),
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
