import 'enums.dart';

class AuthExceptionHandler {
  static handleException(e) {
    AuthResultStatus status;
    switch (e) {
      case "ERROR_INVALID_EMAIL":
        status = AuthResultStatus.invalidEmail;
        break;
      case "ERROR_WRONG_PASSWORD":
        status = AuthResultStatus.wrongPassword;
        break;
      case "ERROR_USER_NOT_FOUND":
        status = AuthResultStatus.userNotFound;
        break;
      case "ERROR_USER_DISABLED":
        status = AuthResultStatus.userDisabled;
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }

  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "E-posta adresiniz yanlış.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Şifreniz yanlış";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "Bu e-postaya sahip kullanıcı mevcut değil.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "Bu e-postaya sahip kullanıcı devre dışı bırakıldı.";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Çok fazla istek var. Daha sonra tekrar deneyin.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "E-posta ve Şifre ile oturum açma etkin değil.";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage = "E-posta zaten kayıtlı. Lütfen giriş yapın veya şifrenizi sıfırlayın.";
        break;
      default:
        errorMessage = "Tanımlanamayan bir Hata oluştu.";
    }

    return errorMessage;
  }
}
