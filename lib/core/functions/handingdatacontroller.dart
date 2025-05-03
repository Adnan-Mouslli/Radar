import '../class/statusrequest.dart';

handlingData(response){
  // Check if the response is an instance of StatusRequest and return it, otherwise return a success StatusRequest.
  if (response is StatusRequest){
    return response ;
  }else {
    return StatusRequest.success ;
  }
}