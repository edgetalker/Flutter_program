import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/providers/auth_provider.dart';

import '../../../constants.dart';
// stateful widget定义
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
// state类定义
class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';// 邮箱地址
  String _password = '';// 密码
  bool _agreeToTerms = false;// 同意服务条款

  // 释放资源
  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(// 注册页面
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(// 顶部图片
              "assets/images/signUp_dark.png",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(// 内容区域
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(// 欢迎回来
                    "让我们开始吧！",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(// 请输入有效的信息来创建您的账户。
                    "请输入有效的信息来创建您的账户。",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(// 注册表单
                    formKey: _formKey,
                    onNameChanged: (name) => _name = name,
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
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        value: _agreeToTerms,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "我同意",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, termsOfServicesScreenRoute);
                                  },
                                text: " 服务条款 ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "和隐私政策。",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  
                  // 注册按钮
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (authProvider.isLoading || !_agreeToTerms) 
                              ? null 
                              : () => _handleRegister(context),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text("注册"),
                        ),
                      );
                    },
                  ),
                  // 登录按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("已有账户？"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("登录"),
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

  Future<void> _handleRegister(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("请同意服务条款和隐私政策"),
            backgroundColor: errorColor,
          ),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
      
      final success = await authProvider.register(_email, _password, _name);
      
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          (route) => false,
        );
      }
    }
  }
}
