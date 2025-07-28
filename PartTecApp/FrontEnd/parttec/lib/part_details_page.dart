import 'package:flutter/material.dart';
import 'providers/cart_provider.dart';
import 'package:provider/provider.dart';
class PartDetailsPage extends StatelessWidget {
  final Map<String, dynamic> part;

  const PartDetailsPage({Key? key, required this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = part['imageUrl'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child:
                              Icon(Icons.image, size: 100, color: Colors.grey),
                        ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    Text(
                      part['name'] ?? 'بدون اسم',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      part['manufacturer'] ?? 'بدون ماركة',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 12),
                    Text(
                      part['price'] != null
                          ? '${part['price']} \$'
                          : 'بدون سعر',
                      style: TextStyle(fontSize: 18, color: Colors.green[800]),
                    ),
                    Divider(height: 32),
                    Text(
                      'الوصف:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6),
                    Text(
                      part['description'] ?? 'لا يوجد وصف',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, -1)),
            ],
          ),
          child: ElevatedButton(
           onPressed: () async {
              final success = await Provider.of<CartProvider>(context, listen: false)
                  .addToCartToServer(part);
print(success);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '❌ فشل في إضافة القطعة، تحقق من الاتصال أو البيانات'
                        : 'تمت الاضافة الى السلة بنجاح',
                  ),
                  backgroundColor: success ? Colors.red : Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            },

            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'إضافة إلى السلة',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
