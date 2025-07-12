import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  // 用户信息
  String _username = "购物达人";
  String _email = "shopper@example.com";
  String _phone = "138****8888";
  String _gender = "女";
  String _birthday = "1990-01-01";
  String _location = "北京市朝阳区";
  bool _isEditing = false;

  // 表单控制器
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _usernameController.text = _username;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _locationController.text = _location;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("个人信息"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
            child: Text(_isEditing ? "保存" : "编辑"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // 头像区域
            _buildAvatarSection(),
            
            const SizedBox(height: defaultPadding * 2),
            
            // 基本信息
            _buildInfoSection(),
            
            const SizedBox(height: defaultPadding * 2),
            
            // 账户设置
            _buildAccountSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _changeAvatar,
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    iconSize: 30,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        Text(
          _username,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "会员等级：VIP",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "基本信息",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            
            // 用户名
            _buildInfoItem(
              "用户名",
              _username,
              _usernameController,
              Icons.person_outline,
              isEditable: true,
            ),
            
            // 邮箱
            _buildInfoItem(
              "邮箱",
              _email,
              _emailController,
              Icons.email_outlined,
              isEditable: true,
            ),
            
            // 手机号
            _buildInfoItem(
              "手机号",
              _phone,
              _phoneController,
              Icons.phone_outlined,
              isEditable: true,
            ),
            
            // 性别
            _buildGenderSelector(),
            
            // 生日
            _buildBirthdaySelector(),
            
            // 地址
            _buildInfoItem(
              "所在地区",
              _location,
              _locationController,
              Icons.location_on_outlined,
              isEditable: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    TextEditingController controller,
    IconData icon, {
    bool isEditable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                _isEditing && isEditable
                    ? TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          border: const UnderlineInputBorder(),
                          hintText: "请输入$label",
                        ),
                      )
                    : Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wc_outlined, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "性别",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                _isEditing
                    ? Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("男"),
                              value: "男",
                              groupValue: _gender,
                              onChanged: (value) => setState(() => _gender = value!),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("女"),
                              value: "女",
                              groupValue: _gender,
                              onChanged: (value) => setState(() => _gender = value!),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _gender,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdaySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cake_outlined, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "生日",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                _isEditing
                    ? InkWell(
                        onTap: _selectBirthday,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _birthday,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      )
                    : Text(
                        _birthday,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "账户设置",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            
            _buildSettingItem(
              "修改密码",
              Icons.lock_outline,
              () => _showPasswordDialog(),
            ),
            
            _buildSettingItem(
              "隐私设置",
              Icons.privacy_tip_outlined,
              () => _showPrivacySettings(),
            ),
            
            _buildSettingItem(
              "绑定第三方账号",
              Icons.link,
              () => _showThirdPartyBinding(),
            ),
            
            _buildSettingItem(
              "注销账户",
              Icons.delete_outline,
              () => _showDeleteAccountDialog(),
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    setState(() {
      _username = _usernameController.text;
      _email = _emailController.text;
      _phone = _phoneController.text;
      _location = _locationController.text;
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("个人信息已保存")),
    );
  }

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("拍照"),
              onTap: () {
                Navigator.pop(context);
                // 实现拍照逻辑
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("从相册选择"),
              onTap: () {
                Navigator.pop(context);
                // 实现从相册选择逻辑
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_birthday) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _birthday = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("修改密码"),
        content: const Text("此功能正在开发中，敬请期待！"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("隐私设置"),
        content: const Text("此功能正在开发中，敬请期待！"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void _showThirdPartyBinding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("绑定第三方账号"),
        content: const Text("此功能正在开发中，敬请期待！"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("注销账户"),
        content: const Text("确定要注销账户吗？此操作不可撤销，所有数据将被永久删除。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("账户注销功能暂未开放")),
              );
            },
            child: const Text("确定", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
