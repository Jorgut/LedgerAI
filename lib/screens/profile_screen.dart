import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF10B981),
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              title: const Text('用户昵称', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text('已连续记账 128 天'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _buildSettingItem(Icons.account_balance_wallet, '账户管理'),
                _buildSettingItem(Icons.notifications, '通知提醒'),
                _buildSettingItem(Icons.security, '数据安全'),
                _buildSettingItem(Icons.cloud_download, '数据导出 / 备份'),
                _buildSettingItem(Icons.dark_mode, '深色模式'),
                _buildSettingItem(Icons.description, '隐私政策'),
                _buildSettingItem(Icons.description_outlined, '用户协议'),
                _buildSettingItem(Icons.delete_forever, '注销账号', isDanger: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : null),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.red : null)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
