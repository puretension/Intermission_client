import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intermission_project/common/component/custom_appbar.dart';
import 'package:intermission_project/common/component/custom_text_form_field.dart';
import 'package:intermission_project/common/component/custom_text_style.dart';
import 'package:intermission_project/common/component/login_next_button.dart';
import 'package:intermission_project/common/component/signup_appbar.dart';
import 'package:intermission_project/common/component/signup_ask_label.dart';
import 'package:intermission_project/common/component/signup_either_button.dart';
import 'package:intermission_project/common/const/colors.dart';
import 'package:intermission_project/models/user.dart';
import 'package:intermission_project/views/signup/signup_screen_page2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

extension InputValidate on String {
  // 이메일 포맷 검증
  bool isValidEmailFormat() {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(this);
  }

  // 대쉬를 포함하는 010 휴대폰 번호 포맷 검증 (010-1234-5678)
  bool isValidPhoneNumberFormat() {
    return RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$').hasMatch(this);
  }
}

class SignupScreenPage1 extends StatefulWidget {
  const SignupScreenPage1({Key? key}) : super(key: key);

  @override
  State<SignupScreenPage1> createState() => _SignupScreenPage1State();
}

class _SignupScreenPage1State extends State<SignupScreenPage1> {
  final globalKey = GlobalKey<FormState>();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController jobController = TextEditingController();

  bool isEmailValid = false;
  //bool isPasswordValid = false;

  bool isMaleSelected = false;
  bool isFemaleSelected = false;
  bool isNameValid = false;
  bool isAgeValid = false;
  bool isPhoneNumValid = false;
  bool isJobValid = false;

  String? nameErrorText;
  String? ageErrorText;
  String? phoneNumErrorText;
  String? jobErrorText;
  String? emailErrorText;
  String? emailValidText;

  bool isButtonEnabled = false;
  bool isGenderSelected = false;
  bool isFieldsValid = false;

  int _duplicationIdCheck = 0;
  int _duplbtnidchecker = 0;
  int _duplicationNickCheck = 1;
  int _duplbtnnickchecker = 0;

  bool duplicate = false; //중복 검사용

  FirebaseAuth auth = FirebaseAuth.instance;

  void sendEmailVerification() async {
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        final loginUserProvider =
        Provider.of<LoginUserProvider>(context, listen: false);
        loginUserProvider.setEmailVerified(user.emailVerified);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일 인증 링크가 전송되었습니다. 이메일을 확인해 주세요.'))
        );
      }
    } catch (e) {
      // Error handling
      // ...
      print(e);
    }
  }

  void navigateToNextScreen() async {
    User? user = auth.currentUser;

    if (user != null) {
      // User.reload() 메서드를 호출하여 사용자 상태를 최신화
      await user.reload();

      // 최신화된 사용자 정보를 다시 가져옴
      user = auth.currentUser;

      if (user!.emailVerified) {
        // 이메일이 인증되었으므로 다음 페이지로 이동
        if (isButtonEnabled) {
          final loginUserProvider =
          Provider.of<LoginUserProvider>(context, listen: false);

          loginUserProvider.setEmailAccount(emailController.text.trim());
          loginUserProvider.setPassword(passwordController.text.trim());
          loginUserProvider.setName(nameController.text.trim());
          loginUserProvider.setAge(int.parse(ageController.text.trim()));
          loginUserProvider.setJob(jobController.text.trim());
          loginUserProvider.setGender(isMaleSelected == true ? "남성" : "여성");
          loginUserProvider.setPhoneNumber(phoneNumController.text.toString());
          loginUserProvider.setEmailVerified(user!.emailVerified);
          await user.reload();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupScreenPage2()),
          );
        }
      } else {
        // 이메일이 인증되지 않았으므로 에러 메시지를 표시
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일을 인증해 주세요.'))
        );
      }
    }
  }




  // 이메일 중복 검사 함수
  void checkEmailEnabled() async {
    //중복 이메일 검사하기
    String email = emailController.text.trim();
    if (!email.isValidEmailFormat()) {
      setState(() {
        emailErrorText = "올바른 이메일 형식으로 입력해주세요!";
      });
      return;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("emailAccount", isEqualTo: email)
        .get();

    // 쿼리 결과의 문서 개수를 사용하여 중복 여부 확인
    duplicate = querySnapshot.size != 0;
    setState(() {
      if (duplicate) {
        emailErrorText = '이미 사용 중인 이메일입니다.';
        emailValidText = null;
      } else {
        isEmailValid = true;
        emailErrorText = null;
        emailValidText = '사용 가능한 이메일입니다.';
      }
    });
  }
  void checkPasswordEnabled(){

  }

  void checkNameEnabled() {
    String name = nameController.text.trim();
    bool isValid = RegExp(r'^[a-zA-Z가-힣]{2,}$').hasMatch(name);

    setState(() {
      isNameValid = isValid;
      nameErrorText = isValid ? null : '영문자 또는 한글로 2자 이상 입력해 주세요';
    });
    checkButtonEnabled();
  }

  void checkAgeEnabled() {
    String age = ageController.text.trim();
    bool isValid = RegExp(r'^[0-9]+$').hasMatch(age);

    setState(() {
      isAgeValid = isValid;
      ageErrorText = isValid ? null : '숫자만 입력해 주세요';
    });
    checkButtonEnabled();
  }

  void checkPhoneNumEnabled() {
    String number = phoneNumController.text.trim();
    bool isValid = number.isValidPhoneNumberFormat();

    setState(() {
      isPhoneNumValid = isValid;
      phoneNumErrorText = isValid ? null : '올바른 전화번호 형식이 아닙니다';
    });
    checkButtonEnabled();
  }

  void checkJobEnabled() {
    String job = jobController.text.trim();
    bool isValid = job.length >= 3;

    setState(() {
      isJobValid = isValid;
    });
    checkButtonEnabled();
  }

  @override
  void initState() {
    // TODO: implement initState
    nameController.addListener(checkNameEnabled);
    ageController.addListener(checkAgeEnabled);
    phoneNumController.addListener(checkPhoneNumEnabled);
    jobController.addListener(checkJobEnabled);
    super.initState();
  }

  void checkButtonEnabled() {
    bool isGenderSelected = isMaleSelected || isFemaleSelected;
    bool isFieldsValid = isEmailValid && isNameValid && isAgeValid && isPhoneNumValid && isJobValid;
    setState(() {
      isButtonEnabled = isGenderSelected && isFieldsValid;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(12),
                right: ScreenUtil().setWidth(12)),
             child: Form(
              key: globalKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SignupAppBar(currentPage: '1/3'),
                  SignupAskLabel(text: '이메일'),
                  CustomTextFormField(
                    controller: emailController,
                    hintText: 'email@email.com',
                    onChanged: (String value) {
                      checkEmailEnabled();
                    },
                    errorText: emailErrorText,
                  ),
                  if(emailValidText != null)
                    Text(
                      emailValidText!,
                      style: TextStyle(color: PRIMARY_COLOR),
                    ),
                  SignupAskLabel(text: '비밀번호'),
                  CustomTextFormField(
                    controller: passwordController,
                    hintText: '6자 이상의 영문/숫자 조합',
                    onChanged: (String value) {},
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: sendEmailVerification,
                    child: Text('계정 인증하기'),
                  ),
                  SignupAskLabel(text: '이름'),
                  CustomTextFormField(
                    controller: nameController,
                    hintText: '이름을 입력해 주세요',
                    onChanged: (String value) {
                      checkNameEnabled();
                    },
                    errorText: isNameValid ? null : nameErrorText,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SignupAskLabel(text: '성별'),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SignupEitherButton(
                      text: '남성',
                      isSelected: isMaleSelected,
                      onPressed: () {
                        setState(() {
                          isMaleSelected = true;
                          isFemaleSelected = false;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    SignupEitherButton(
                      text: '여성',
                      isSelected: isFemaleSelected,
                      onPressed: () {
                        setState(() {
                          isMaleSelected = false;
                          isFemaleSelected = true;
                        });
                      },
                    ),
                  ]
                  ),
                  SizedBox(
                    height: 15,
                  ),
                SignupAskLabel(text: '나이'),
                  CustomTextFormField(
                    controller: ageController,
                    hintText: '나이를 입력해 주세요',
                    onChanged: (String value) {
                      checkAgeEnabled();
                    },
                    errorText: isAgeValid ? null : ageErrorText,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SignupAskLabel(text: '전화번호'),
                  CustomTextFormField(
                    controller: phoneNumController,
                    hintText: '000-000-0000 형식으로 입력해 주세요',
                    onChanged: (String value) {
                      checkPhoneNumEnabled();
                    },
                    errorText: isPhoneNumValid ? null : phoneNumErrorText,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                SignupAskLabel(text: '직업'),
                  CustomTextFormField(
                    controller: jobController,
                    hintText: '학생(학교명), 직장인(직무) 형식으로 입력해 주세요',
                    onChanged: (String value) {
                      checkJobEnabled();
                    },
                    errorText: isJobValid ? null : jobErrorText,
                    textFieldMinLine: 2,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  LoginNextButton(
                    buttonName: '다음',
                    isButtonEnabled: isButtonEnabled,
                    onPressed: navigateToNextScreen,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class CustomButton extends StatelessWidget {
  final bool istext; //버튼안에 들어갈 내용이 '중복확인' 텍스트인가 화살표아이콘인가를 결정해주는 변수임 164번줄에 이어서 주석달겠음.
  final String text;
  final VoidCallback onPressed;
  const CustomButton({required this.text,required this.istext, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: PRIMARY_COLOR,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
      onPressed: onPressed,
      child: istext == false ? Icon(
        Icons.arrow_forward,
        color: Colors.white,
        size: 35.0,
      ) : Text(text),
    );
  }
}

