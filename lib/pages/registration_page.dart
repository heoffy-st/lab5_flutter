import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_storage.dart';
import 'user_info_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _lifeStoryController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _lifeStoryFocus = FocusNode();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _lifeStoryController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _lifeStoryFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите имя';
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Введите номер телефона';
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'Используйте только цифры';
    }
    if (phone.length < 7) return 'Номер слишком короткий';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Введите email';
    if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(email)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Минимум 6 символов';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Подтвердите пароль';
    if (value != _passwordController.text) return 'Пароли не совпадают';
    return null;
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = UserRecord(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        lifeStory: _lifeStoryController.text.trim(),
      );
      await UserStorage.register(user);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UserInfoPage()),
      );
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message.toString())),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить данные. Попробуйте ещё раз.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1, size: 64),
                const SizedBox(height: 10),
                Text(
                  'Создать аккаунт',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Заполните поля для регистрации',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Имя', Icons.person_outline),
                  validator: _validateName,
                  onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _decoration('Номер телефона', Icons.phone_outlined),
                  validator: _validatePhone,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: _decoration('Email', Icons.email_outlined),
                  validator: _validateEmail,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'Пароль',
                    Icons.lock_outline,
                    suffix: IconButton(
                      tooltip: _hidePassword ? 'Показать пароль' : 'Скрыть пароль',
                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  obscureText: _hideConfirmPassword,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'Подтвердите пароль',
                    Icons.lock_reset,
                    suffix: IconButton(
                      tooltip: _hideConfirmPassword ? 'Показать пароль' : 'Скрыть пароль',
                      onPressed: () => setState(
                        () => _hideConfirmPassword = !_hideConfirmPassword,
                      ),
                      icon: Icon(
                        _hideConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _lifeStoryFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _lifeStoryController,
                  focusNode: _lifeStoryFocus,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: _decoration('О себе (необязательно)', Icons.notes),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _register,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Зарегистрироваться'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UserInfoPage()),
                    );
                  },
                  child: const Text('Посмотреть сохранённые данные'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
