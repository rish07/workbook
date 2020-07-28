import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>[
  "https://mail.google.com/",
]);

Future signInWithGoogle() async {
  try {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    print(googleSignInAccount.authHeaders.then((result) {
      print(result);
    }));
  } catch (error) {
    throw error;
  }
}
