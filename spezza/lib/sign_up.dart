import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/model/dto/user/create_user_dto.dart';
import 'package:spezza/model/user_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String email = "";
  String password = "";
  String confirmPassword = "";

  bool esconderSenha = true;
  bool carregando = false;
  String? mensagemErro;

  void realizarCadastro() async {
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        setState(() => mensagemErro = "As senhas não coincidem");
        return;
      }

      setState(() {
        carregando = true;
        mensagemErro = null;
      });

      try {
        final userProvider = ref.read(userModelProvider);

        final dto = CreateUserDto(name: name, email: email, password: password);

        final novoUsuario = await userProvider.createUser(dto);

        setState(() => carregando = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bem-vindo(a), ${novoUsuario.name}!")),
          );
          Navigator.pop(context);
        }
      } catch (e, stacktrace) {
        setState(() {
          debugPrint("Erro detalhado: $e");
          debugPrint("Rastro do erro: $stacktrace");
          carregando = false;
          mensagemErro = "Falha ao criar conta: Verifique os dados.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Image(
                image: AssetImage('../assets/spezzaappicon.png'),
                width: 120,
                height: 120,
              ),
              const Text(
                'Crie sua conta no Spezza',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Campo Nome
              TextFormField(
                decoration: _inputStyle('Nome Completo', Icons.person),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value!.isEmpty ? "Informe seu nome" : null,
              ),
              const SizedBox(height: 16),

              // Campo E-mail
              TextFormField(
                decoration: _inputStyle('E-mail', Icons.mail),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
                validator: (value) =>
                    !value!.contains('@') ? "E-mail inválido" : null,
              ),
              const SizedBox(height: 16),

              // Campo Senha
              TextFormField(
                obscureText: esconderSenha,
                decoration: _inputStyle('Senha', Icons.lock, isPassword: true),
                onChanged: (value) => password = value,
                validator: (value) =>
                    value!.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 16),

              // Confirmação de Senha
              TextFormField(
                obscureText: esconderSenha,
                decoration: _inputStyle(
                  'Confirmar Senha',
                  Icons.lock_outline,
                  isPassword: true,
                ),
                onChanged: (value) => confirmPassword = value,
              ),

              const SizedBox(height: 30),

              if (mensagemErro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    mensagemErro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              ElevatedButton(
                onPressed: carregando ? null : realizarCadastro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Cadastrar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                esconderSenha ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => esconderSenha = !esconderSenha),
            )
          : null,
    );
  }
}
