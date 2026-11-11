import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF10B981)),
              const SizedBox(height: 16),
              const Text('衡账', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('AI 自动记账，轻松理财', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),
              TextField(
                decoration: InputDecoration(
                  labelText: '手机号 / 邮箱',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  child: const Text('登录', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.wechat, color: Color(0xFF07C160), size: 36)),
                  const SizedBox(width: 32),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.account_balance_wallet, color: Color(0xFF1677FF), size: 36)),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () {}, child: const Text('注册新账号')),
            ],
          ),
        ),
      ),
    );
  }
}
