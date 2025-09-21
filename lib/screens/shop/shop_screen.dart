// lib/screens/shop/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:misslog/themes/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:misslog/screens/shop/widgets/purchase_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopScreen extends HookConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState<bool>(true);
    final shopSections = useState<Map<String, List<Map<String, dynamic>>>>({});
    final error = useState<String?>(null);

    // Supabaseからショップデータを取得
    Future<void> loadShopData() async {
      try {
        isLoading.value = true;
        error.value = null;

        final response = await Supabase.instance.client
            .from('shop_items')
            .select()
            .order('section_order', ascending: true)
            .order('display_order', ascending: true);

        // セクションごとにグループ化（順序を維持）
        final Map<String, List<Map<String, dynamic>>> sections = {};
        
        for (var item in response) {
          final sectionTitle = item['section_title'] as String;
          if (!sections.containsKey(sectionTitle)) {
            sections[sectionTitle] = [];
          }
          sections[sectionTitle]!.add({
            'id': item['id'],
            'name': item['name'],
            'price': item['price'],
            'discountPercent': item['discount_percent'],
            'imageUrl': item['image_url'],
            'productUrl': item['product_url'],
            'displayOrder': item['display_order'] ?? 0,
            'sectionOrder': item['section_order'] ?? 0,
          });
        }

        // 各セクション内でdisplay_orderでソート（念のため）
        for (var sectionProducts in sections.values) {
          sectionProducts.sort((a, b) => 
            (a['displayOrder'] as int).compareTo(b['displayOrder'] as int)
          );
        }

        shopSections.value = sections;
        isLoading.value = false;
      } catch (e) {
        error.value = 'データの読み込みに失敗しました: $e';
        isLoading.value = false;
        print('Shop data loading error: $e');
      }
    }

    // 初期データ読み込み
    useEffect(() {
      loadShopData();
      return null;
    }, []);

    void showPurchaseSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.transparent,
        builder: (context) => const PurchaseSheet(),
      );
    }

    Future<void> openBaseShop() async {
      final Uri url = Uri.parse('https://mayth.base.shop');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }

    Future<void> openProductUrl(String url) async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }

    Widget buildProductCard(Map<String, dynamic> product) {
      final bool isOnSale = product['discountPercent'] != null;
      final int price = product['price'];
      
      return Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1:1 正方形商品画像（カード付き）
            GestureDetector(
              onTap: () => openProductUrl(product['productUrl']),
              child: Stack(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.calculate,
                            size: 40,
                            color: Colors.grey[400],
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // セールバッジ
                  if (isOnSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product['discountPercent']}%OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 商品情報（カードなし）
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 価格
                  Text(
                    '¥${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOnSale ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildSection(String title, List<Map<String, dynamic>> products) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryGrey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return buildProductCard(products[index]);
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('ショップ'),
        titleTextStyle: TextStyle(
          color: primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: primaryBlue,
        onRefresh: loadShopData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 課金案内バナー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: showPurchaseSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'プレミアム会員になろう',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '広告なし・限定機能でもっと快適にミス管理を効率化しませんか？',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'タップして詳細を見る',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ローディング・エラー・コンテンツ表示
              if (isLoading.value)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryBlue,
                    ),
                  ),
                )
              else if (error.value != null)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          error.value!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadShopData,
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (shopSections.value.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: textSecondaryGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '商品が見つかりませんでした',
                          style: TextStyle(
                            color: textSecondaryGray,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // 動的セクション表示
                Column(
                  children: shopSections.value.entries.map((entry) {
                    return Column(
                      children: [
                        buildSection(entry.key, entry.value),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),

              // 提携サイト案内
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '提携サイト',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '数学グッズはBASE公式ショップにて販売中',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondaryGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: openBaseShop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('BASE公式ショップを見る'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}