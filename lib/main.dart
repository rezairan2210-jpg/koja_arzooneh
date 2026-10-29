import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

const kGreen = Color(0xFF0F4C45);
const kGold = Color(0xFFC8A24A);
const kCream = Color(0xFFF8F4EA);
const kInk = Color(0xFF1E2A28);

String rial(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${b.toString()} ریال';
}

class Item {
  final String name;
  final int price;
  final bool govt;
  const Item(this.name, this.price, {this.govt = false});
}

class Shop {
  final String name, category, address, phone, hours;
  final bool premium, paid, delivery;
  final List<Item> items;
  const Shop(this.name, this.category, this.address, this.phone, this.hours,
      this.items,
      {this.premium = false, this.paid = true, this.delivery = true});
}

const shops = [
  Shop('گوشت تازه رضایی', 'گوشت', 'کاشان، خیابان امیرکبیر', '03155551111',
      '۷ صبح تا ۹ شب', [
    Item('گوشت گوسفندی (کیلو)', 4500000),
    Item('مرغ کامل (کیلو)', 1100000, govt: true),
  ], premium: true),
  Shop('قصابی نیک‌پور', 'گوشت', 'کاشان، میدان کمال‌الملک', '03155552222',
      '۸ صبح تا ۸ شب', [
    Item('گوشت گوسفندی (کیلو)', 4400000),
  ]),
  Shop('میوه و تره‌بار سبز', 'میوه', 'کاشان، بلوار قطب راوندی', '03155553333',
      '۸ صبح تا ۱۰ شب', [
    Item('سیب (کیلو)', 600000),
    Item('پیاز (کیلو)', 250000, govt: true),
  ], premium: true),
  Shop('هایپر مارکت کاشان', 'مواد غذایی', 'کاشان، بلوار زین‌العابدین',
      '03155554444', '۹ صبح تا ۱۱ شب', [
    Item('برنج ایرانی (کیلو)', 1200000),
    Item('روغن مایع (۱ لیتر)', 900000, govt: true),
    Item('شکر (کیلو)', 700000, govt: true),
  ]),
  Shop('تعمیرات موبایل آرین', 'تعمیرکار', 'کاشان، خیابان فاضل نراقی',
      '03155555555', '۱۰ صبح تا ۸ شب', [
    Item('تعویض گلس', 800000),
  ], delivery: false),
  Shop('مغازه مسدود (نمونه)', 'گوشت', 'کاشان', '0', '-', [
    Item('گوشت', 1),
  ], paid: false),
];

const categories = [
  'همه', 'سبد کالا', 'گوشت', 'میوه', 'مواد غذایی', 'تعمیرکار'
];

final List<MapEntry<Shop, Item>> cart = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen, primary: kGreen),
        scaffoldBackgroundColor: kCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: kGreen,
          foregroundColor: kCream,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: kCream, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      builder: (c, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selected = 'همه';
  String query = '';

  @override
  Widget build(BuildContext context) {
    var list = shops.where((s) {
      if (!s.paid) return false;
      final q = query.trim();
      final qOk = q.isEmpty ||
          s.name.contains(q) ||
          s.category.contains(q) ||
          s.items.any((i) => i.name.contains(q));
      bool catOk;
      if (selected == 'همه') {
        catOk = true;
      } else if (selected == 'سبد کالا') {
        catOk = s.items.any((i) => i.govt);
      } else {
        catOk = s.category == selected;
      }
      return catOk && qOk;
    }).toList();
    list.sort((a, b) => (b.premium ? 1 : 0) - (a.premium ? 1 : 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('کجا ارزونه؟ (کاشان)'),
        actions: [
          IconButton(
            icon: Badge(
                backgroundColor: kGold,
                label: Text('${cart.length}'),
                isLabelVisible: cart.isNotEmpty,
                child: const Icon(Icons.shopping_bag_outlined)),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartPage()));
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'عضویت مغازه‌دار',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JoinPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: kGreen,
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو: گوشت، روغن، تعمیرکار...',
                prefixIcon: const Icon(Icons.search, color: kGreen),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Container(height: 3, color: kGold),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              children: categories.map((c) {
                final sel = selected == c;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: Text(c),
                    selected: sel,
                    selectedColor: kGreen,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                        color: sel ? kCream : kInk,
                        fontWeight: FontWeight.w600),
                    side: BorderSide(color: sel ? kGreen : kGold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) => setState(() => selected = c),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('چیزی پیدا نشد'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    itemBuilder: (context, i) => ShopCard(
                        shop: list[i],
                        onAdd: () => setState(() {}),
                        govtOnly: selected == 'سبد کالا'),
                  ),
          ),
        ],
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onAdd;
  final bool govtOnly;
  const ShopCard(
      {super.key,
      required this.shop,
      required this.onAdd,
      this.govtOnly = false});

  @override
  Widget build(BuildContext context) {
    final items =
        govtOnly ? shop.items.where((i) => i.govt).toList() : shop.items;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: shop.premium ? kGold : const Color(0xFFE8E2D2),
            width: shop.premium ? 1.8 : 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(shop.name,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kGreen)),
            ),
            if (shop.premium)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: kGold, borderRadius: BorderRadius.circular(12)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.star, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('ویژه',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
          ]),
          const SizedBox(height: 8),
          info(Icons.place_outlined, shop.address),
          info(Icons.access_time, shop.hours),
          info(Icons.phone_outlined, shop.phone),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE8E2D2)),
          ),
          ...items.map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(i.name, style: const TextStyle(color: kInk)),
                        if (i.govt)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF6EBCB),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('سبد کالا',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF8A6A12))),
                          ),
                      ],
                    ),
                  ),
                  Text(rial(i.price),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: kGreen)),
                  if (shop.delivery)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add_circle, color: kGold),
                      onPressed: () {
                        cart.add(MapEntry(shop, i));
                        onAdd();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('به سبد اضافه شد'),
                                duration: Duration(seconds: 1)));
                      },
                    ),
                ]),
              )),
          if (!shop.delivery)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('فقط حضوری', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(children: [
          Icon(icon, size: 16, color: kGold),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, color: kInk))),
        ]),
      );
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const courierFee = 500000;
  @override
  Widget build(BuildContext context) {
    final total = cart.fold<int>(0, (s, e) => s + e.value.price);
    return Scaffold(
      appBar: AppBar(title: const Text('سبد خرید و پیک')),
      body: cart.isEmpty
          ? const Center(child: Text('سبد خالی است'))
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.length,
                  itemBuilder: (c, i) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8E2D2))),
                    child: ListTile(
                      title: Text(cart[i].value.name),
                      subtitle: Text(cart[i].key.name),
                      trailing:
                          Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(rial(cart[i].value.price),
                            style: const TextStyle(
                                color: kGreen, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                setState(() => cart.removeAt(i))),
                      ]),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(color: Color(0x22000000), blurRadius: 12)
                  ],
                ),
                child: Column(children: [
                  Text('جمع کالاها: ${rial(total)}'),
                  Text('کرایه پیک: ${rial(courierFee)}'),
                  const SizedBox(height: 4),
                  Text('مبلغ نهایی: ${rial(total + courierFee)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kGreen)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: kGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () {
                        cart.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'سفارش ثبت شد (نمونه). پیک با شما تماس می‌گیرد')));
                      },
                      child: const Text('ثبت سفارش با پیک'),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }
}

class JoinPage extends StatelessWidget {
  const JoinPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عضویت مغازه‌داران')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('مغازه خود را در «کجا ارزونه» ثبت کنید',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: kGreen)),
        const SizedBox(height: 14),
        plan('پلن ساده', '${rial(1000000)} / ماه',
            ['نمایش در لیست مغازه‌ها', 'ثبت قیمت‌ها و آدرس'], false),
        plan('پلن ویژه ⭐', '${rial(3000000)} / ماه',
            ['نمایش بالای لیست', 'نشان طلایی', 'سفارش آنلاین و پیک'], true),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFFBEDEA),
              borderRadius: BorderRadius.circular(14)),
          child: const Text(
              '⚠️ اگر شارژ ماهانه پرداخت نشود، مغازه مسدود شده و در اپ نمایش داده نمی‌شود.'),
        ),
      ]),
    );
  }

  Widget plan(String t, String price, List<String> f, bool gold) {
    final fg = gold ? kCream : kInk;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gold ? kGreen : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGold, width: gold ? 2 : 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: gold ? kGold : kGreen)),
        const SizedBox(height: 4),
        Text(price, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...f.map((x) => Text('✔ $x', style: TextStyle(color: fg))),
      ]),
    );
  }
}
