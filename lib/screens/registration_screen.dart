// lib/screens/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _machineSerial = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try{
        await authProvider.signUp(
          email: _email,
          password: _password,
          name: _name,
          machineSerial: _machineSerial,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful. Please wait for admin approval.'),
          ),
        );
        Navigator.pop(context);
      } catch (error){
      //   throw the error in the argument of the SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );

      }



      setState(() {
        _isLoading = false;
      });

      /*if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful. Please wait for admin approval.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed. Please check your machine serial number and try again.'),
          ),
        );
      }*/
    }
  }

  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Account',
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    _buildTextFormField(
                      label: 'Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value!,
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!,
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!,
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Machine Serial Number',
                      icon: Icons.confirmation_number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the machine serial number';
                        }
                        return null;
                      },
                      onSaved: (value) => _machineSerial = value!,
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Register',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
