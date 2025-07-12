import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 认证管理Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 商品管理Provider
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        // 购物车管理Provider（依赖于ProductProvider）
        ChangeNotifierProxyProvider<ProductProvider, CartProvider>(
          create: (context) => CartProvider(
            Provider.of<ProductProvider>(context, listen: false),
          ),
          update: (context, productProvider, previousCartProvider) =>
              previousCartProvider ?? CartProvider(productProvider),
        ),
        // 订单管理Provider
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '尚品购 - 精品购物商城',
        theme: AppTheme.lightTheme(context),
        themeMode: ThemeMode.light,
        onGenerateRoute: router.generateRoute,
        home: const AuthChecker(),
      ),
    );
  }
}

// 检查认证状态的包装器
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 根据登录状态决定显示哪个页面
        final route = router.generateRoute(
          RouteSettings(
            name: authProvider.isLoggedIn 
            ? entryPointScreenRoute // 已登录
            : onbordingScreenRoute, // 未登录
          ),
        );
        
        // 正确地从MaterialPageRoute获取builder并调用
        if (route is MaterialPageRoute) {
          return route.builder(context);
        } else {
          // 如果不是MaterialPageRoute，返回默认页面
          return const Scaffold(
            body: Center(
              child: Text('页面加载错误'),
            ),
          );
        }
      },
    );
  }
}
