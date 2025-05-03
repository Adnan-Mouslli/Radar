import '../../../../core/class/crud.dart';
import '../../../../core/constant/Link.dart';


class LogInData {

  Crud crud ;

  LogInData(this.crud) ;

  postData( String email , String password) async {

    var response = await crud.postData(AppLink.login, {
      "phone" :  email,
      "password" : password ,
    });
    return response ;

  }

}
