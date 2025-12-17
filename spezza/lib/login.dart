import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/main.dart';
import 'package:spezza/model/dto/user/create_user_dto.dart';
import 'package:spezza/model/dto/user/login_dto.dart';
import 'package:spezza/model/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool loginComSucesso = false;
  bool esconderSenha = true;
  String email = "";
  String password = "";
  
  void validaLogin(){
    final userProvider = ref.read(userModelProvider);
    userProvider.login(LoginDto(email: email, password: password));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Column(
              children: [
                const Image(image: AssetImage('../assets/spezzaappicon.png')),
                const Text(
                  'Bem-vind@ de volta ao Spezza!',
                  style:TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                    decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onChanged: (value) => email = value
                ),
                const SizedBox(height: 16),
                TextField(
                    obscureText: esconderSenha,
                    decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            esconderSenha ? Icons.visibility_off : Icons.visibility,
                            color: esconderSenha ? Colors.grey : Color(0xFF008000),
                          ),
                          onPressed: () {
                            setState(() {
                              esconderSenha = !esconderSenha;
                            });
                          },
                        )
                    ),
                    onChanged: (value) => password = value
                ),
                TextButton(child: const Text("Criar conta no Spezza"), onPressed: () {}), //NAVEGAR PARA CADASTRO
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: validaLogin,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF008000),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 50)
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white))
                ),
                const SizedBox(height: 20),
                Text(
                  loginComSucesso ? "Login realizado com sucesso!" : "Favor insira seus dados credenciais",
                  style: TextStyle(
                      fontSize: 16,
                      color: loginComSucesso ? Color(0xFF008000) : Colors.black54
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}