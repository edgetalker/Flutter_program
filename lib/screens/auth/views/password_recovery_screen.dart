import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../../constants.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}
// state类定义
class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();// 表单键
  final _emailController = TextEditingController();// 邮箱输入框控制器

  @override
  void dispose() {// 释放资源
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {// 提交表单
    if (_formKey.currentState!.validate()) {
      // 这里添加密码重置逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("密码重置链接已发送到您的邮箱"),
          backgroundColor: primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(// 顶部标题
        title: const Text("忘记密码"),
      ),
      body: SafeArea(
        child: Padding(// 内容区域
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(// 表单容器
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: defaultPadding * 2),
                Text(// 重置密码
                  "重置密码",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Text(// 提示信息
                  "请输入您的邮箱地址，我们将发送密码重置链接到您的邮箱。",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: defaultPadding * 3),
                TextFormField(// 邮箱输入框
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "请输入邮箱地址"),
                    EmailValidator(errorText: "请输入有效的邮箱地址"),
                  ]).call,
                  decoration: const InputDecoration(
                    labelText: "邮箱地址",
                    hintText: "请输入您的邮箱",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: defaultPadding * 2),
                SizedBox(// 发送重置链接按钮    
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("发送重置链接"),
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Center(// 返回登录按钮
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("返回登录"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
