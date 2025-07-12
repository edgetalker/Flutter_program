import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/providers/auth_provider.dart';

import 'components/login_form.dart';

// stateful widget定义
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
// state类定义
class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = ''; // 邮箱
  String _password = ''; // 密码

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;// 获取屏幕尺寸

    return Scaffold(
      body: SingleChildScrollView(// 允许页面滚动
        child: Column(
          children: [
            Image.asset(// 顶部图片
              "assets/images/login_dark.png",
              fit: BoxFit.cover,
            ),
            Padding(// 内容区域
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(// 欢迎回来
                    "欢迎回来！",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(// 请使用您注册时的账户信息登录。
                    "请使用您注册时的账户信息登录。",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(// 登录表单
                    formKey: _formKey,
                    onEmailChanged: (email) => _email = email,
                    onPasswordChanged: (password) => _password = password,
                  ),
                  
                  // 错误消息显示
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.errorMessage != null) {
                        return Container(// 错误消息容器
                          margin: const EdgeInsets.only(top: defaultPadding),
                          padding: const EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                            color: errorColor.withOpacity(0.1),// 半透明背景
                            borderRadius: BorderRadius.circular(defaultBorderRadious),
                            border: Border.all(color: errorColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [// 图标+文字
                              Icon(Icons.error_outline, color: errorColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(// 文本自适应宽度
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: TextStyle(
                                    color: errorColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink(); // 如果错误消息为空，则不显示
                    },
                  ),
                  // 忘记密码
                  Align(// 居中对齐
                    child: TextButton(
                      child: const Text("忘记密码？"),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, passwordRecoveryScreenRoute);// 路由跳转
                      },
                    ),
                  ),
                  SizedBox(// 根据屏幕大小动态调整间距
                    height: size.height > 700
                        ? size.height * 0.1
                        : defaultPadding,
                  ),                 
                  // 登录按钮
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading // 加载时禁用按钮
                              ? null 
                              : () => _handleLogin(context),
                          child: authProvider.isLoading // 条件渲染
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text("登录"),
                        ),
                      );
                    },
                  ),
                  // 注册 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,// 水平居中
                    children: [
                      const Text("还没有账户？"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);// 路由跳转
                        },
                        child: const Text("注册"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // 登录逻辑处理
  Future<void> _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
      
      final success = await authProvider.login(_email, _password);// 执行登录
      
      if (success && mounted) {// 登录成功且Widget未销毁
        Navigator.pushNamedAndRemoveUntil(// 清空导航栈并跳转主页
          context,
          entryPointScreenRoute,
          ModalRoute.withName(logInScreenRoute),
        );
      }
    }
  }
}
