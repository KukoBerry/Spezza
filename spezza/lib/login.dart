import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/home.dart';
import 'package:spezza/model/dto/user/login_dto.dart';
import 'package:spezza/model/user_model.dart';
import 'package:spezza/sign_up.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool? loginComSucesso;
  bool esconderSenha = true;
  String email = "";
  String password = "";

  void validaLogin() async {
    final userProvider = ref.read(userModelProvider);
    
    final resultado = await userProvider.login(
      LoginDto(email: email, password: password)
    );

    if (mounted) {
      setState(() {
        loginComSucesso = resultado;
      });

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login realizado com sucesso!")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Column(
            children: [
              Image(
                image: const AssetImage('../assets/spezzaappicon.png'),
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const Text(
                'Bem-vind@ de volta ao Spezza!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: esconderSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      esconderSenha ? Icons.visibility_off : Icons.visibility,
                      color: esconderSenha ? Colors.grey : const Color(0xFF008000),
                    ),
                    onPressed: () => setState(() => esconderSenha = !esconderSenha),
                  ),
                ),
                onChanged: (value) => password = value,
              ),
              
              TextButton(
                child: const Text("Criar conta no Spezza"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: validaLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (loginComSucesso != null)
                Text(
                  loginComSucesso! ? "Login realizado com sucesso!" : "Credenciais incorretas",
                  style: TextStyle(
                    fontSize: 16,
                    color: loginComSucesso! ? const Color(0xFF008000) : Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}