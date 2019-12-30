import 'package:flutter/material.dart';

import 'authentication.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage = "";

  // this will be used to identify the form to show
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Center(
          child: Text('Wheather Login'),
        ),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            showLogo(),
            progressWidget(),
            formWidget(),
            loginButtonWidget(),
            errorWidget(),
          ],
        ),

      ),
    );
  }

  //progress
  Widget progressWidget() {
    if (_isLoading) {
      return Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        ),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

//logo login
  Widget showLogo() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      height: 150,
      width: 150,
      child: Image.asset('assets/images/logo.png'),
    );
  }

//form login
  Widget formWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _emailWidget(),
          _passwordWidget(),
        ],
      ),
    );
  }

  //input email login
  Widget _emailWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Nhập email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Email không được để trống' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  //input pass login
  Widget _passwordWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Nhập mật khẩu',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Mật khẩu không được để trống' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  //login button
  Widget loginButtonWidget() {
    return new Container(
        padding: EdgeInsets.fromLTRB(20.0, 45.0, 20.0, 0.0),
        child: MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5.0,
          minWidth: 400,
          height: 55.0,
          color: Colors.blue,
          child: _formMode == FormMode.LOGIN
              ? Text('Đăng nhập',
                  style: TextStyle(fontSize: 20.0, color: Colors.white))
              : null,
          onPressed: _validateAndSubmit,
        ));
  }

  void showLoginForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  //show error login
  Widget errorWidget() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  //xác thực key
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //xác thực form
  _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
        } else {
          userId = await widget.auth.signUp(_email, _password);
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null) {
          widget.onSignedIn();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
}