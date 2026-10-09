import 'package:flutter/material.dart';
import '../services/user_storage.dart';
import 'registration_page.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserRecord? _user;
  int _userCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await UserStorage.getCurrentUser();
    final count = await UserStorage.getUserCount();
    if (!mounted) return;
    setState(() {
      _user = user;
      _userCount = count;
      _loading = false;
    });
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value.isEmpty ? 'Не указано' : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о пользователе'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_off_outlined, size: 56),
                        const SizedBox(height: 12),
                        const Text(
                          'Пока нет зарегистрированных пользователей',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const RegistrationPage(),
                            ),
                          ),
                          child: const Text('Перейти к регистрации'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 8),
                      const CircleAvatar(
                        radius: 42,
                        child: Icon(Icons.person, size: 46),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _user!.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Сохранённых пользователей: $_userCount',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _infoTile(Icons.person_outline, 'Имя', _user!.name),
                      _infoTile(Icons.email_outlined, 'Email', _user!.email),
                      _infoTile(Icons.phone_outlined, 'Телефон', _user!.phone),
                      _infoTile(Icons.notes, 'Life Story', _user!.lifeStory),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const RegistrationPage(),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Зарегистрировать другого пользователя'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
