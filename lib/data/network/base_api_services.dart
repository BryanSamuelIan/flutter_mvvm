abstract class BaseApiServices {
  Future<dynamic> getApiResponse(
      String
          endpoint); //future seperti void namun untuk asynchronous /harus ditunggu prosesnya tidak instan
  Future<dynamic> postApiResponse(String url,
      dynamic data); //dynamic artinya bisa .. handle banyak tipe data
}
