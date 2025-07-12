import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';

// 地址模型
class AddressModel {
  final String id;
  String name;
  String phone;
  String province;
  String city;
  String district;
  String detail;
  bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.isDefault = false,
  });

  String get fullAddress => "$province $city $district $detail";
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<AddressModel> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadDemoAddresses();
  }

  void _loadDemoAddresses() {
    _addresses = [
      AddressModel(
        id: "1",
        name: "张三",
        phone: "138****8888",
        province: "北京市",
        city: "朝阳区",
        district: "望京街道",
        detail: "xxx小区1号楼102室",
        isDefault: true,
      ),
      AddressModel(
        id: "2",
        name: "李四",
        phone: "139****9999",
        province: "上海市",
        city: "浦东新区",
        district: "陆家嘴街道",
        detail: "xxx大厦2008室",
        isDefault: false,
      ),
    ];
  }

  void _setDefaultAddress(String addressId) {
    setState(() {
      for (var address in _addresses) {
        address.isDefault = address.id == addressId;
      }
    });
  }

  void _deleteAddress(String addressId) {
    setState(() {
      _addresses.removeWhere((address) => address.id == addressId);
    });
  }

  void _showAddAddressDialog() {
    _showAddressDialog();
  }

  void _showEditAddressDialog(AddressModel address) {
    _showAddressDialog(address: address);
  }

  void _showAddressDialog({AddressModel? address}) {
    final nameController = TextEditingController(text: address?.name ?? "");
    final phoneController = TextEditingController(text: address?.phone ?? "");
    final provinceController = TextEditingController(text: address?.province ?? "");
    final cityController = TextEditingController(text: address?.city ?? "");
    final districtController = TextEditingController(text: address?.district ?? "");
    final detailController = TextEditingController(text: address?.detail ?? "");
    bool isDefault = address?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(address == null ? "添加地址" : "编辑地址"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("姓名", nameController),
                const SizedBox(height: 12),
                _buildTextField("手机号", phoneController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField("省份", provinceController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField("城市", cityController)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField("区县", districtController),
                const SizedBox(height: 12),
                _buildTextField("详细地址", detailController, maxLines: 3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      onChanged: (value) {
                        setDialogState(() {
                          isDefault = value ?? false;
                        });
                      },
                    ),
                    const Text("设为默认地址"),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validateAddressForm(
                  nameController.text,
                  phoneController.text,
                  provinceController.text,
                  cityController.text,
                  districtController.text,
                  detailController.text,
                )) {
                  _saveAddress(
                    address,
                    nameController.text,
                    phoneController.text,
                    provinceController.text,
                    cityController.text,
                    districtController.text,
                    detailController.text,
                    isDefault,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("保存"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  bool _validateAddressForm(String name, String phone, String province, 
      String city, String district, String detail) {
    if (name.isEmpty || phone.isEmpty || province.isEmpty || 
        city.isEmpty || district.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请填写完整的地址信息")),
      );
      return false;
    }
    return true;
  }

  void _saveAddress(AddressModel? existingAddress, String name, String phone, 
      String province, String city, String district, String detail, bool isDefault) {
    setState(() {
      if (existingAddress != null) {
        // 编辑现有地址
        existingAddress.name = name;
        existingAddress.phone = phone;
        existingAddress.province = province;
        existingAddress.city = city;
        existingAddress.district = district;
        existingAddress.detail = detail;
        if (isDefault) {
          _setDefaultAddress(existingAddress.id);
        }
      } else {
        // 添加新地址
        final newAddress = AddressModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          phone: phone,
          province: province,
          city: city,
          district: district,
          detail: detail,
          isDefault: isDefault,
        );
        _addresses.add(newAddress);
        if (isDefault) {
          _setDefaultAddress(newAddress.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("收货地址"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _addresses.isEmpty ? _buildEmptyAddresses() : _buildAddressList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyAddresses() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/Address.svg",
            height: 80,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!.withValues(alpha: 0.3),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            "还没有收货地址",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: defaultPadding / 2),
          Text(
            "添加收货地址，享受便捷配送服务",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton.icon(
            onPressed: _showAddAddressDialog,
            icon: const Icon(Icons.add),
            label: const Text("添加地址"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.separated(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: _addresses.length,
      separatorBuilder: (context, index) => const SizedBox(height: defaultPadding),
      itemBuilder: (context, index) {
        return _buildAddressCard(_addresses[index]);
      },
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: address.isDefault 
              ? primaryColor 
              : Theme.of(context).dividerColor,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 姓名和电话
          Row(
            children: [
              Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 8),
              Text(
                address.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Text(
                address.phone,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "默认",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 地址信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.fullAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: defaultPadding),
          
          // 操作按钮
          Row(
            children: [
              if (!address.isDefault)
                TextButton.icon(
                  onPressed: () => _setDefaultAddress(address.id),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text("设为默认"),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showEditAddressDialog(address),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text("编辑"),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showDeleteConfirmDialog(address),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text("删除"),
                style: TextButton.styleFrom(
                  foregroundColor: errorColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("删除地址"),
        content: Text("确定要删除地址\"${address.fullAddress}\"吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteAddress(address.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text("删除"),
          ),
        ],
      ),
    );
  }
}
