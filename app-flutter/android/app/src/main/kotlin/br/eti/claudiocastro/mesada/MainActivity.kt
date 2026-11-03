package br.eti.claudiocastro.mesada

// FlutterFragmentActivity (e não FlutterActivity) é exigência do local_auth:
// o BiometricPrompt do Android precisa de uma FragmentActivity.
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
